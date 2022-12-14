load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
begin
in1 = addfile("pblh_omet.nc", "r")
in2 = addfile("pblh_fbda.nc", "r")
in3 = addfile("output_fasdas.nc", "r")
X = in1->PBLH
Y = in2->PBLH
lat = in3->XLAT
lon = in3->XLONG
siglvl  = 0.05
aveX    = dim_avg_n_Wrap(X,0)
aveY    = dim_avg_n_Wrap (Y,0)
varX    = dim_variance_n_Wrap (X,0)
varY    = dim_variance_n_Wrap (Y,0)
sX      = dimsizes (X(:,0,0))
sY      = dimsizes(Y(:,0,0))   ;dimsizes (Y&XTIME)
iflag   = False ;True                                   ; population variance similar
prob0 = 1. -ttest(aveX,varX,sX, aveY,varY,sY, iflag, False)
prob = where(prob0.gt.0.95, 1, 0)
; prob = prob0
prob@lat2d = lat
prob@lon2d = lon
copy_VarCoords(X(0,:,:), prob)
prob@description = "T-Test significance > 0.95"
diffXY0  = aveX - aveY
diffXY  = mask(diffXY0, prob, 1)
copy_VarCoords(aveX, diffXY)
diffXY@lat2d = lat
diffXY@lon2d = lon
diffXY@description = "pblh_omet - pblh_fbda"
diffXY@units = "m"
wks= gsn_open_wks("x11","SignifPlot_pblh")
res = True
res@cnFillOn = True
res@gsnDraw = False
res@gsnFrame = False
; res@mpLandFillColor             = "gray50"
; res@mpOceanFillColor            = "gray50"
res2 = True
res2@gsnDraw = False
res2@gsnFrame = False
res2@cnMaxLevelValF = 1
res2@cnMinLevelValF = 0.90
res2@cnInfoLabelOn = False
res2@cnFillOn = True
res2@cnLinesOn = False ;-- draw contour lines
res2@cnLineLabelsOn = False ;-- do not add line labels
res2@cnLevelSelectionMode  = "ExplicitLevels"
res2@cnLevels              = (/0.95, 0.96, 0.97, 0.98, 0.99, 1/) ;ispan(0.95, 1, 0.2)
res2@cnFillColor = "black"
res2@cnFillOpacityF        = 1
res2@lbLabelBarOn = False
; res2@mpLandFillColor             = "gray50"
; res2@mpOceanFillColor            = "gray50"
cmap_r              = read_colormap_file("cyclic")
mycol = (/ (/0.1,0.1,0.1,0/), (/0.1,0.1,0.1,1/), (/0.1,0.1,0.1,1/), (/0.1,0.1,0.1,1/), (/0.1,0.1,0.1,1/), (/0.1,0.1,0.1,0/) /)
cmap_r(0,3)         = 0.0    ; first color fully transparent
cmap_r(5,3)         = 0.0    ; last color fully transparent
mycol(0,:)         = 0    ; first color fully transparent
mycol(5,:)         = 0    ; last color fully transparent
res2@cnFillPalette  =  mycol
res2@cnFillPattern       = 17
res2@cnFillDotSizeF = 0.004
contour_tc = wrf_contour(in3, wks, diffXY, res)
pval = wrf_contour(in3, wks, prob, res2)
mpres = True
mpres@mpOutlineBoundarySets = "National"
mpres@mpGeophysicalLineColor      = "black"
mpres@mpNationalLineColor         = "black"
mpres@mpGeophysicalLineThicknessF = 4
mpres@mpNationalLineThicknessF    = 4
mpres@mpFillOn = True
mpres@gsnDraw               =  False                  ;-- don't draw the plot yet
mpres@gsnFrame              =  False
; mpres@mpFillColors = (/"transparent","LightSkyBlue1","transparent","LightSkyBlue1", "transparent"/)
mpres@mpFillColors = (/"transparent","gray50","gray50","gray50", "transparent"/)
; mpres@mpLandFillColor             = "red"
; mpres@mpOceanFillColor            = "gray50"
mpres@mpFillDrawOrder             =  "PreDraw"  ;"PostDraw"  ; draw map fill last
; plot = wrf_map_overlays(in3, wks, (/contour_tc, pval/), True, mpres)
plot = wrf_map_overlays(in3, wks, (/contour_tc/), True, mpres)
; setvalues plot
; "vpXF"      : 0.15
; "vpYF"      : 0.85
; "vpWidthF"  : 0.7
; "vpHeightF" : 0.7
; end setvalues
; txres                       = True
; txres@txPerimOn             = True
; txres@txBackgroundFillColor = "Salmon"
; txres@txFontHeightF         = 0.03
; txres@txBackgroundFillColor = "transparent"
; txres@txFont                = "helvetica-bold"
; txid1 = gsn_create_text(wks, "String 1", txres)
; amres = True
; amres@amParallelPosF   = 0.5    ; This is the right edge of the plot.
; amres@amOrthogonalPosF = 0.5    ; This is the bottom edge of the plot.
; amres@amJust           = "BottomRight"
; annoid1 = gsn_add_annotation(plot, txid1, amres)
; txres1                     =  True
; txres1@txFontHeightF       =  0.03
; txres1@txAngleF            =  40.                     ;-- rotate text string 40 degrees
; text1 = gsn_add_text(wks,plot,"Atlantic",0,0,txres1)
draw(plot)
; frame(wks)
end
