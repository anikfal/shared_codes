load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin

csvfile  = asciiread("station_data.csv",-1,"string")
nlines = dimsizes(csvfile)-1   ; First line is a header
;---First line is name of each field
delim       = ","
field_names = str_split(csvfile(0), delim)
nfields     = dimsizes(field_names)
csv_fields = new((/nfields,nlines/), string)
do nf=0, nfields-1
  csv_fields(nf,:) = str_get_field(csvfile(1:), nf+1, delim)    
end do

; mycolors = read_colormap_file("NCV_jet")
; mycolors = read_colormap_file("WhiteBlueGreenYellowRed")
; mycolors = read_colormap_file("precip2_17lev")
mycolors = read_colormap_file("precip2_15lev")

mycolors_num = dimsizes(mycolors(:,0))

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
; res@cnFillPalette = "WhiteBlueGreenYellowRed"
res@cnFillPalette = mycolors  ;"WhiteBlueGreenYellowRed"
res@cnLevelSelectionMode = "ManualLevels"
so2min = 2
so2max = 36
res@cnMinLevelValF = so2min
res@cnMaxLevelValF = so2max
res@cnLevelSpacingF = 2
contourfas = wrf_contour(filefas, wks, so2fas, res)
pltres = True
pltres@PanelPlot = True  ; to overlay marker
mpres = True
mpres@mpOutlineBoundarySets = "National"
mpres@mpGeophysicalLineColor      = "black"
mpres@mpNationalLineColor         = "black"
mpres@mpGeophysicalLineThicknessF = 2
mpres@mpNationalLineThicknessF    = 2
mpres@mpFillOn = True
mpres@gsnDraw               =  False                  ;-- don't draw the plot yet
mpres@gsnFrame              =  False
mpres@mpFillColors = (/"transparent","gray50","gray50","gray50", "transparent"/)
mpres@mpFillDrawOrder             =  "PreDraw"  ;"PostDraw"  ; draw map fill last
plot = wrf_map_overlays(filewrf, wks, (/contourfas/), pltres, mpres)
lats  = tofloat(csv_fields(1,:))     ;(/   -20,       -25,      -30,      -35/)
lons  = tofloat(csv_fields(2,:))     ;(/   130,      140,     150,     160/)
station_names = csv_fields(0,:)        ;(/"New Orleans","Atlanta", "Nashville", "Chicago"/)
station_so2 = tofloat(csv_fields(3,:))

mkres = True
; mkres@gsMarkerIndex = 16 ; filled dot
; ; col2 = mycolors(::33, :)
; mkres@gsMarkerColor      = col2 ;"blue"  ;colors(i,:)
; ; mkres@gsMarkerSizeF      = base_size * (i+1)/3.
; ; mkres@gsMarkerThicknessF = 0.7*(i+1)
txres = True
; txres@txFontHeightF = 0.015
; txres@txJust        = "CenterLeft"
; mkid = gsn_add_polymarker(wks, plot, lons, lats, mkres)
; txid = gsn_add_text(wks,plot,"   " + station_names, lons, lats, txres)
cities_count = dimsizes(station_names)
markerid = new(cities_count, graphic)
textid = new(cities_count, graphic)
do i = 0, cities_count-1
  color_index = tointeger( (station_so2(i) / so2max) * mycolors_num )
  ; print("color_index " + color_index)
  mkres@gsMarkerColor = mycolors(color_index,:)
  mkres = True
  mkres@gsMarkerIndex = 16 ; filled dot
  ; col2 = mycolors(::33, :)
  ; mkres@gsMarkerColor      = col2 ;"blue"  ;colors(i,:)
  txres@txFontHeightF = 0.015
  txres@txJust        = "CenterLeft"
  markerid(i) = gsn_add_polymarker(wks, plot, lons(i), lats(i), mkres)
  delta = (-1)^i 
  textid(i) = gsn_add_text(wks,plot,"   " + station_names(i), lons(i), lats(i)+delta, txres)
end do

draw(plot)
frame(wks)

end
