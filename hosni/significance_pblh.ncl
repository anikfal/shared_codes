load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
begin
  in1 = addfile("pblh_omet.nc", "r")
  in2 = addfile("pblh_fbda.nc", "r")
  in3 = addfile("15-25-omet.nc", "r")
  X = in1->PBLH
  Y = in2->PBLH
  lat = in3->XLAT
  lon = in3->XLONG

  diff = X-Y
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
  iflag   = False ;True                                   ; population variance similar
  prob = 1. -ttest(aveX,varX,sX, aveY,varY,sY, iflag, False)

wks= gsn_open_wks("x11","SignifPlot_pblh")
res = True
; res@mpMinLatF = min(lat)
; res@mpMaxLatF = max(lat) - 3
; res@mpMinLonF = 113 ;min(lon)
; res@mpMaxLonF = 180 ;max(lon)
res@cnFillOn = True
res@gsnDraw = True
res@gsnFrame = False
; res@mpProjection = "LambertConformal"
; res@mpLambertParallel1F = -35
; res@mpLambertParallel2F = -20
; res@mpLambertMeridianF = 145
; gsn_define_colormap(wks,"MPL_rainbow")	; choose a color map
; res@lbBoxEndCapStyle     = "TriangleBothEnds"   ; triangle label bar
; res2 = True
; res2@gsnDraw = False
; res2@gsnFrame = False
; res2@gsnAddCyclic = False
; res2@cnLevelSelectionMode = "ExplicitLevels"
; res2@cnLevels = (/0.05/) ;-- draw only the 95% contour line, 0.05 for 5%
; res2@cnInfoLabelOn = False
; res2@cnLinesOn = True ;-- draw contour lines
; res2@cnLineLabelsOn = False ;-- do not add line labels
; res2@lbLabelBarOn = False ;-- disable labelbar
; res2@cnFillColor = "black" ;-- trick to have the fill pattern in colour (choose other than "black")

; res@tfDoNDCOverlay       = True     
; res@pmTickMarkDisplayMode = "Always"         ; turn on tickmarks
;res@cnFillColors = 
contour_tc = wrf_contour(in3, wks, diffXY, res)
draw(contour_tc)
frame(wks)
exit()
plot = wrf_map_overlays(in3, wks, (/contour_tc/), True, True)
; plot = gsn_csm_contour_map(wks, diffXY, res)
exit()
pval = gsn_csm_contour(wks, prob, res2) ;-- this adds a contour line around the stippling
exit()

;pval = gsn_contour_shade(pval,0.05,1.00,opt) ;-- this adds the stippling for all pvalues <= 0.05
overlay(plot,pval)
draw(plot)
frame(wks)
end