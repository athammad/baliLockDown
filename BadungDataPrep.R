#---------------------------------
#         ALL BADUNG DATA
#---------------------------------
rm(list=ls())

allDistrics<-c('Abiansemal','Petang','Megwi','Kuta','KutaS','KutaU')
lapply(allDistrics, function(x){


setwd(paste0("folder",x))
#---------------------------------
#       DAILY WEATHER DATA
#         RAIN-TEMP-WIND
#---------------------------------

library(data.table)
EVI<-fread("EVI.csv")
NDVI<-fread("NDVI.csv")
ET<-fread("ET.csv")
RAIN<-fread("RAIN.csv")
TEMP<-fread("TEMP.csv")
WIND<-fread("WIND.csv")
HUM<-fread("HUM.csv")
HUM<-HUM[,mean(Specific_humidity_height_above_ground),by= timeFormat]
setnames(HUM,c('timeFormat', 'humidity'))
#prendo le covariate
library(lubridate)
veg_outcomes<-lapply(list(EVI,NDVI,ET,RAIN,TEMP,WIND,HUM),function(x){
  x[,Date:=as.Date(timeFormat, '%d-%m-%Y')]
  x<-unique(x,by="Date")
  x$timeFormat<-NULL
  x
  
})
veg_outcomes[[1]]

#MERGIO
veg_outcomes = Reduce(function(...) merge(...,by = "Date", all = TRUE), veg_outcomes)
setnames(veg_outcomes,c('Date','EVI','NDVI','ET','Rain','Temp','Wind','Hum'))
lapply(veg_outcomes, class)


#wind is available from 1979 to three months from real-time
veg_outcomes<-veg_outcomes[!is.na(Wind)]
veg_outcomes[veg_outcomes==0.000000000]<-NA
#veg_outcomes[Date%between%c('2020-04-02','2020-06-07'),treat:=1]
#veg_outcomes[is.na(treat),treat:=0]
veg_outcomes$Day<-day(veg_outcomes$Date)
veg_outcomes$Year<-year(veg_outcomes$Date)
veg_outcomes$Month<-month(veg_outcomes$Date)
veg_outcomes$Week<-week(veg_outcomes$Date)

setcolorder(veg_outcomes,c('Date','Day','Month','Year','Week'))



#####-------  MISSING IMPUTATION ----------#
library(imputeTS)
library(missRanger)
plot.ts(veg_outcomes[,.(NDVI,EVI,ET,Rain,Temp,Wind,Hum)])

statsNA(ts(veg_outcomes[,.(Temp)]))
veg_outcomes<-missRanger::missRanger(veg_outcomes[,.(Day, Month, Year, Week, NDVI,EVI,ET,Rain,Temp,Wind,Hum)],seed = 1234)

plot(ts(veg_outcomes$ET))
plot.ts(veg_outcomes[,.(NDVI,EVI,ET,Rain,Temp,Wind,Hum)])

names(veg_outcomes)
veg_outcomes[,Date:=as.Date(paste(Month,Day,Year,sep = '-'),format='%m-%d-%Y')]
#-- TREATMENT VARIABLE --#
veg_outcomes[Date>='2020-04-02',treat:=1]
veg_outcomes[is.na(treat),treat:=0]

fwrite(veg_outcomes,paste0(x,'.csv'))

})

