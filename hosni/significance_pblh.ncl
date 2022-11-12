load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
begin
  in1 = addfile("pblh_omet.nc", "r")
  in2 = addfile("pblh_fbda.nc", "r")
  X = in1->PBLH
  Y = in2->PBLH 

  diff = X-Y
 siglvl  = 0.05
  aveX    = dim_avg_n (X,0)             ; 23.6    ; dim_avg_n (X,0)
  aveY    = dim_avg_n (Y,0)            ; 19.222
  varX    = dim_variance_n (X,0)        ; 17.083  ; dim_variance_n (X,0)
  varY    = dim_variance_n (Y,0)        ; 13.477
  sX      = dimsizes (X(:,0,0))
  sY      = dimsizes(Y(:,0,0))   ;dimsizes (Y&XTIME)
                                                  ; Following not used; FYI only
  diffXY  = aveX - aveY                            ; 4.378
  iflag   = False ;True                                   ; population variance similar
  prob = 1. -ttest(aveX,varX,sX, aveY,varY,sY, iflag, False)

wks= gsn_open_wks("x11","SignifPlot_pblh")
res = True
gsn_define_colormap(wks,"MPL_rainbow")	; choose a color map
res@lbBoxEndCapStyle     = "TriangleBothEnds"   ; triangle label bar
res2 = True
res2@gsnDraw = False
res2@gsnFrame = False
res2@gsnAddCyclic = False
res2@cnLevelSelectionMode = "ExplicitLevels"
res2@cnLevels = (/0.05/) ;-- draw only the 95% contour line, 0.05 for 5%
res2@cnInfoLabelOn = False
res2@cnLinesOn = True ;-- draw contour lines
res2@cnLineLabelsOn = False ;-- do not add line labels
res2@lbLabelBarOn = False ;-- disable labelbar
res2@cnFillColor = "black" ;-- trick to have the fill pattern in colour (choose other than "black")

;opt = True
;opt@gsnShadeFillType = "pattern"
;opt@gsnShadeLow = 17
;opt@gsnShadeFillScaleF = 0.75
  
  res@tfDoNDCOverlay       = True     

;  if (.not.res@tfDoNDCOverlay) then
;      diff@lat2d = f->XLAT(0,:,:)                      ; direct assignment
;      diff@lon2d = f->XLONG(0,:,:)
;  end if
  res@pmTickMarkDisplayMode = "Always"         ; turn on tickmarks
  
dimx  = dimsizes(diff)                          ; dimensions of x
  ntim  = dimx(0)                              ; number of time steps
  klev  = dimx(1)                              ; number of "bottom_top" levels
  nt    = 0                                    ; arbitrary time
 kl    =  6 
plot=gsn_csm_contour_map(wks,diff,res)
pval = gsn_csm_contour(wks,prob,res2) ;-- this adds a contour line around the stippling
;pval = gsn_contour_shade(pval,0.05,1.00,opt) ;-- this adds the stippling for all pvalues <= 0.05
overlay(plot,pval)
draw(plot)
frame(wks)
end