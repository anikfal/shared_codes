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
                                                  ; Following not used; FYI only
  diffXY  = aveX - aveY
  copy_VarCoords(aveX, diffXY)
  diffXY@lat2d = lat
  diffXY@lon2d = lon
  diffXY@description = "pblh_omet - pblh_fbda"
  diffXY@units = "m"
  iflag   = False ;True                                   ; population variance similar
  prob = 1. -ttest(aveX,varX,sX, aveY,varY,sY, iflag, False)
  prob@lat2d = lat
  prob@lon2d = lon
  copy_VarCoords(X(0,:,:), prob)
wks= gsn_open_wks("x11","SignifPlot_pblh")
res = True
res@cnFillOn = True
res@gsnDraw = False
res@gsnFrame = False
; res@cnFillPalette = "cmocean_gray"
; gsn_define_colormap(wks,"MPL_rainbow")	; choose a color map
; res@lbBoxEndCapStyle     = "TriangleBothEnds"   ; triangle label bar

res2 = True
res2@gsnDraw = False
res2@gsnFrame = False
; res2@gsnAddCyclic = False
;res2@cnLevels = (/0.05/) ;-- draw only the 95% contour line, 0.05 for 5%
res2@cnMaxLevelValF = 1
res2@cnMinLevelValF = 0.90
res2@cnInfoLabelOn = False
res2@cnFillOn = True
res2@cnLinesOn = False ;-- draw contour lines
res2@cnLineLabelsOn = False ;-- do not add line labels
; res2@lbLabelBarOn = False ;-- disable labelbar
; res2@cnFillColor = "black" ;-- trick to have the fill pattern in colour (choose other than "black")
res2@cnLevelSelectionMode  = "ExplicitLevels"
res2@cnLevels              = (/0.95, 0.96, 0.97, 0.98, 0.99, 1/) ;ispan(0.95, 1, 0.2)
;   res2@cnFillPalette         = "OceanLakeLandSnow"
res2@cnFillOpacityF        = 0.5
;   cmap_r              = read_colormap_file("WhViBlGrYeOrRe")
cmap_r              = read_colormap_file("cyclic")
; cmap_r(:, :2) = 0
;   print(cmap_r)
cmap_r(0,3)         = 0.0    ; first color fully transparent
cmap_r(5,3)         = 0.0    ; last color fully transparent
res2@cnFillPalette  = cmap_r
; res2@cnMonoFillPattern    = True
; res2@cnFillDotSizeF       = 0.0001
; res2@cnSpanFillPalette    = False
; res2@cnFillPatterns       = 3
; res2@cnFillDotSizeF       = 0.005
; res@tfDoNDCOverlay       = True     
; res@pmTickMarkDisplayMode = "Always"         ; turn on tickmarks
;res@cnFillColors = 
contour_tc = wrf_contour(in3, wks, diffXY, res)
pval = wrf_contour(in3, wks, prob, res2)
mpres = True
mpres@mpOutlineBoundarySets = "National"
mpres@mpGeophysicalLineColor      = "black"
mpres@mpNationalLineColor         = "black"
; mpres@mpGridLineColor             = "Black"
; mpres@mpGridAndLimbOn = False
; mpres@mpLimbLineColor             = "Black"
; mpres@mpPerimLineColor            = "Black"
mpres@mpGeophysicalLineThicknessF = 2
; mpres@mpGridLineThicknessF        = 2.0
; mpres@mpLimbLineThicknessF        = 2.0
mpres@mpNationalLineThicknessF    = 2
plot = wrf_map_overlays(in3, wks, (/contour_tc, pval/), True, mpres)
; plot = wrf_map_overlays(in3, wks, (/contour_tc/), True, mpres)
;draw(contour_tc)
draw(plot)
;frame(wks)

; plot = gsn_csm_contour_map(wks, diffXY, res)
; pval = gsn_csm_contour(wks, prob, res2) ;-- this adds a contour line around the stippling
exit()

;pval = gsn_contour_shade(pval,0.05,1.00,opt) ;-- this adds the stippling for all pvalues <= 0.05
;overlay(plot,pval)
;draw(plot)
;frame(wks)
end
