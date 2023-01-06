load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin

var = read_colormap_file("NCV_jet")
; ff = span_color_rgba("WhiteBlueGreenYellowRed", 1)
colors  = span_color_rgba("NCV_jet",8)
; printVarSummary(colors)
; printVarSummary(var)

; print(var(:7,:))
; print(colors)
; exit()


filewrf = addfile("wrfout_d01_2022-01-15_all", "r") ;needed for correct XLAT and XLONG. Because filefas is a manipulation of the original WRF file
;filefas = addfile("15-25-fasdas.nc", "r")
filefas = addfile("15-25-noda.nc", "r")
type = "x11"
wks = gsn_open_wks(type,"noda_so2_plot")

so2fas0 = filefas->so2(0,0,:,:)
so2fas = so2fas0 * 1000 ;ppm to ppb
copy_VarAtts(so2fas0, so2fas)
copy_VarCoords(so2fas0, so2fas)
so2fas@units = "ppb"
opts = True
opts@MainTitle = "SO2 Mixing Ratio"

res = opts
res@cnFillOn = True
res@cnFillPalette = "WhiteBlueGreenYellowRed"
contourfas = wrf_contour(filefas, wks, so2fas, res)
pltres = True
pltres@PanelPlot = True  ; to overlay marker
mpres = True
mpres@mpOutlineBoundarySets = "National"
mpres@mpGeophysicalLineColor      = "black"
mpres@mpNationalLineColor         = "black"
mpres@mpGeophysicalLineThicknessF = 4
mpres@mpNationalLineThicknessF    = 4
mpres@mpFillOn = True
mpres@gsnDraw               =  False                  ;-- don't draw the plot yet
mpres@gsnFrame              =  False
mpres@mpFillColors = (/"transparent","gray50","gray50","gray50", "transparent"/)
mpres@mpFillDrawOrder             =  "PreDraw"  ;"PostDraw"  ; draw map fill last
plot = wrf_map_overlays(filewrf, wks, (/contourfas/), pltres, mpres)

; exit()

; gsres = True ; set some resource
; gsres@gsMarkerSizeF = 10.
; gsres@gsMarkerIndex = 16.  ; filled circles
; gsres@gsMarkerColor = 0  ; white
; ; xs_d02 = (/lon_min_d02, lon_max_d02, lon_max_d02, lon_min_d02/)
; ; ys_d02 = (/lat_min_d02, lat_min_d02, lat_max_d02, lat_max_d02/)
; ; xs_d03 = (/lon_min_d03, lon_max_d03, lon_max_d03, lon_min_d03/)
; ; ys_d03 = (/lat_min_d03, lat_min_d03, lat_max_d03, lat_max_d03/)
; lon_min_d02 = 120
; lon_max_d02 = 140
; lat_min_d02 = -40
; lat_max_d02 = -20
; lon_min_d03 = 130
; lon_max_d03 = 150
; lat_min_d03 = -30
; lat_max_d03 = -20
; xs_d02 = (/lon_min_d02, lon_max_d02, lon_max_d02, lon_min_d02/)
; ys_d02 = (/lat_min_d02, lat_min_d02, lat_max_d02, lat_max_d02/)
; xs_d03 = (/lon_min_d03, lon_max_d03, lon_max_d03, lon_min_d03/)
; ys_d03 = (/lat_min_d03, lat_min_d03, lat_max_d03, lat_max_d03/)
; xs = array_append_record(xs_d02, xs_d03, 0)
; ys = array_append_record(ys_d02, ys_d03, 0)
; plot1 = gsn_add_polymarker(wks,plot,xs,ys,gsres)

lats  = (/   -20,       -25,      -30,      -35/)
lons  = (/   130,      140,     150,     160/)
tstrs = (/"New Orleans","Atlanta", "Nashville", "Chicago"/)
mkres = True
mkres@gsMarkerIndex = 16 ; filled dot
mkres@gsMarkerColor      = "blue"  ;colors(i,:)
; mkres@gsMarkerSizeF      = base_size * (i+1)/3.
; mkres@gsMarkerThicknessF = 0.7*(i+1)


txres = True
txres@txFontHeightF = 0.015
txres@txJust        = "CenterLeft"
mkid = gsn_add_polymarker(wks,plot,lons,lats,mkres)
txid = gsn_add_text(wks,plot,"   " + tstrs,lons,lats,txres)

draw(plot)
frame(wks)

end
