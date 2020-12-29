
#----------------------------------------
rm(list=ls())

allDistrics<-c('Abiansemal','Petang','Megwi','Kuta','KutaS','KutaU')
lapply(allDistrics, function(x){



setwd(paste0("folder",x))


library(data.table)
veg_outcomes<-fread(paste0(x,'.csv'))
veg_outcomes$Date<-as.Date(veg_outcomes$Date)
names(veg_outcomes)
anyNA(veg_outcomes)
min(veg_outcomes$Date)

#Smothing with adaptive smooth Savitzky-Golay filter 
Myorder=1
veg_outcomes$EVI=signal::sgolayfilt(veg_outcomes$EVI, p=Myorder, n=31, ts=1)
veg_outcomes$ET=signal::sgolayfilt(veg_outcomes$ET, p=Myorder, n=31, ts=1)
veg_outcomes$Wind=signal::sgolayfilt(veg_outcomes$Wind, p=Myorder, n=31, ts=1)
veg_outcomes$Hum=signal::sgolayfilt(veg_outcomes$Hum, p=Myorder, n=31, ts=1)
veg_outcomes$Temp=signal::sgolayfilt(veg_outcomes$Temp, p=Myorder, n=31, ts=1)
veg_outcomes$Rain=signal::sgolayfilt(veg_outcomes$Rain, p=Myorder, n=31, ts=1)



#-----------------------------------------------------
#sine end cosine of time 
#-----------------------------------------------------
library(lubridate)
sinner<-as.data.table(cyclic_encoding(veg_outcomes$Date, c("week", "month","year")))
veg_outcomes<-cbind(veg_outcomes,sinner)
veg_outcomes$ydaynum<-yday(veg_outcomes$Date)
#-----------------------------------------------------
# LAGS 
#-----------------------------------------------------


lagval=15
#veg_outcomes[, sprintf("EVI_lag_%01d", 1:lagval) := shift(EVI, 1:lagval, type = 'lag')]
veg_outcomes[, sprintf("Hum_lag_%01d", 1:lagval) := shift(Hum, 1:lagval, type = 'lag')]
veg_outcomes[, sprintf("Rain_lag_%01d", 1:lagval) := shift(Rain, 1:lagval, type = 'lag')]
veg_outcomes[, sprintf("Temp_lag_%01d", 1:lagval) := shift(Temp, 1:lagval, type = 'lag')]
veg_outcomes[, sprintf("Wind_lag_%01d", 1:lagval) := shift(Wind, 1:lagval, type = 'lag')]
veg_outcomes[, sprintf("ET_lag_%01d", 1:lagval) := shift(ET, 1:lagval, type = 'lag')]


SumCols<-c("Rain")
MeanCols<-c("Temp","Hum")

#ROLLSUMS
library(zoo)
veg_outcomes[ , paste0("last2W",SumCols) := lapply(.SD, function(x) rollsumr(x,k = 15, fill = NA)), .SDcols = SumCols]
veg_outcomes[ , paste0("last1M",SumCols) := lapply(.SD, function(x) rollsumr(x,k = 30, fill = NA)), .SDcols = SumCols]

#ROLLMEANS
veg_outcomes[ , paste0("last2W",MeanCols) := lapply(.SD, function(x) rollmeanr(x,k = 15, fill = NA)), .SDcols = MeanCols]
veg_outcomes[ , paste0("last1M",MeanCols) := lapply(.SD, function(x) rollmeanr(x,k = 30, fill = NA)), .SDcols = MeanCols]


#save the after lockdown for later
veg_outcomesTest<-veg_outcomes[treat==1,]
#select only before lockdown
veg_outcomes<-veg_outcomes[treat==0,]
veg_outcomes$treat<-NULL

#-----------------------------------------------------
# SELECT VARS
#-----------------------------------------------------

names(veg_outcomes)
cols <- c("EVI","Rain","Hum","Temp","Wind","ET",
          "Month","Day","Year","Week","ydaynum",
          grep("sin",names(veg_outcomes),value = T), 
          grep("cos",names(veg_outcomes),value = T),
          
          grep("lag_1$|lag_3|lag_7|lag_15",names(veg_outcomes),value = T),
          grep("last",names(veg_outcomes),value = T)
          )
veg_outcomes<-na.omit(veg_outcomes[,..cols])
setDF(veg_outcomes)

#define the target variable
names(veg_outcomes)
target <- "EVI"
#define the predictor features
predictors <-setdiff(names(veg_outcomes),target)

veg_outcomes[3349,] # training fino al  4   1 2019
TrainDataTS = veg_outcomes[1:3349, ]
dim(TrainDataTS)
testDataTS = veg_outcomes[3350:nrow(veg_outcomes), ] #test fino al 4   1 2020
tail(testDataTS)
dim(testDataTS)

########################
library(caret)
library(xgboost)

setDF(TrainDataTS)
#[][][][][[[][][][][[][[][][[][][][][]]]]]]][][[][[][][[][][][][]]]]]]][][[][[][][[][][][][]]]]]]

train_control <- trainControl(method = "cv", 
                              search = "random", 
                              number = 10,                             
                              verboseIter=TRUE,
                              allowParallel=TRUE)

set.seed(1989) 
xgb_modelCV<-train(TrainDataTS[,predictors], TrainDataTS[,target],  
                   trControl = train_control,
                   tuneLength = 100,
                   method = 'xgbTree')


PredsCV = predict(xgb_modelCV,testDataTS[,predictors])
length(PredsCV)
length(testDataTS[,target])
residuals = testDataTS[,target] - PredsCV
cor(testDataTS[,target] , PredsCV)
postResample(pred = PredsCV, obs = testDataTS[,target])


# save environment
save.image(file = paste0('XGBfinal',x,gsub('-','',Sys.Date()),'.Rdata'))

})
