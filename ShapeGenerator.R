library(sf)
library(data.table)
location <- read_sf('shapefile/Kecamatan Bali_region.shp')
plot(location)
View(location)
badungSud <- location[location$NAMA %like%"Kuta", ]
plot(badungSud)
badungNord <- location[location$NAMA %like%"Abiansemal|Petang|Megwi", ]
plot(badungNord)
st_write(badungSud,dsn = 'badungSud', layer = 'badungSud', driver = 'ESRI Shapefile')
st_write(badungNord,dsn = 'badungNord', layer = 'badungNord', driver = 'ESRI Shapefile')

##################################################################

#Abiansemal
badungAbia <- location[location$NAMA %like%"Abiansemal", ]
plot(badungAbia)
st_write(badungAbia,dsn = 'badungAbia', layer = 'badungAbia', driver = 'ESRI Shapefile')

#Petang
badungPeta <- location[location$NAMA %like%"Petang", ]
plot(badungPeta)
st_write(badungPeta,dsn = 'badungPeta', layer = 'badungPeta', driver = 'ESRI Shapefile')

#Megwi
badungMegwi <- location[location$NAMA %like%"Megwi", ]
plot(badungMegwi)
st_write(badungMegwi,dsn = 'badungMegwi', layer = 'badungMegwi', driver = 'ESRI Shapefile')

#Kec. Kuta Utara
badungKutaU <- location[location$NAMA=="Kec. Kuta Utara" , ]
plot(badungKutaU)
st_write(badungKutaU,dsn = 'badungKutaU', layer = 'badungKutaU', driver = 'ESRI Shapefile')

#"Kec. Kuta Selatan"
badungKutaS <- location[location$NAMA=="Kec. Kuta Selatan" , ]
plot(badungKutaS)
st_write(badungKutaS,dsn = 'badungKutaS', layer = 'badungKutaS', driver = 'ESRI Shapefile')

#Kec. Kuta
badungKuta<- location[location$NAMA=="Kec. Kuta" , ][1,]
plot(badungKuta)
st_write(badungKuta,dsn = 'badungKuta', layer = 'badungKuta', driver = 'ESRI Shapefile')


