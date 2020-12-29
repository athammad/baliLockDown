rm(list=ls())

allDistrics<-c('Abiansemal','Petang','Megwi','Kuta','KutaS','KutaU')
lapply(allDistrics, function(x){

setwd(paste0("folder",x))
load(paste0('XGBfinal',x,gsub('-','',Sys.Date()),'.Rdata'))

library(data.table)
library(caret)
library(xgboost)
library(jtools)

vegCF<-veg_outcomesTest
vegCF$treat<-NULL

names(vegCF)
cols <- c("EVI","Rain","Hum","Temp","Wind","ET",
          "Month","Day","Year","Week","ydaynum",
          grep("sin",names(vegCF),value = T), 
          grep("cos",names(vegCF),value = T),
          
          grep("lag_1$|lag_3|lag_7|lag_15",names(vegCF),value = T),
          grep("last",names(vegCF),value = T)
)
vegCF<-na.omit(vegCF[,..cols])
setDF(vegCF)

#define the target variable
names(vegCF)
target <- "EVI"
#define the predictor features
predictors <-setdiff(names(vegCF),target)

dim(vegCF)
#XGB PREDICTION 
PredsXGB <- predict(xgb_modelCV,vegCF[,predictors])
#PUT ALL IN THE MAIN DF
vegCF$xgb<-PredsXGB

setDT(vegCF)
vegCF<-vegCF[,.(EVI,xgb)]
vegCF$district<-District
vegCF$treat<-1

#poi devi prendere il test set testDataTS e metterlo sopra
setDT(testDataTS)
names(testDataTS)
testDataTS$xgb<-PredsCV
testDataTS<-testDataTS[,.(EVI,xgb)]
testDataTS$district<-District
testDataTS$treat<-0

vegCF<-rbind(testDataTS,vegCF)


fwrite(vegCF,paste0(District,'CF.csv'))

})
#####################################################

allDistrics<-c('Abiansemal','Petang','Megwi','Kuta','KutaS','KutaU')
MyPath<-paste0(allDistrics,'CF.csv') 

# Il test inizia il 4   2 2019 (Month Day Year)  finisce il 4   1 2020
# mentre il periodo di covid inizia il  4   2 2020  e finisce il 7   9 2020
# first(testDataTS[,.(Month, Day, Year)]) 
# last(testDataTS[,.(Month, Day, Year)]) 
# first(veg_outcomesTest[,.(Month, Day, Year)])  
# last(veg_outcomesTest[,.(Month, Day, Year)])  
StartTest<-as.Date(paste(4,2,2019,sep = '-'),format='%m-%d-%Y')
EndCov<-as.Date(paste(7,9, 2020,sep = '-'),format='%m-%d-%Y')

Dates<-seq(StartTest, EndCov, by = "day")

library(data.table)
AllCF<-lapply(MyPath,function(x){
  Fin<-fread(x)
  Fin$Date<-Dates
  Fin
  
})

AllCF<-rbindlist(AllCF)

AllCF[district%like%'Kuta',area:=1] #Sud
AllCF[is.na(area),area:=0]#Nord

totalCrop<-58990457.742402+64869508.2980392+21339120.4816176+6131177.34877451+23448804.4223039+15714872.2894608

AllCF[district=='Abiansemal',weig:=	58990457.742402/totalCrop]
AllCF[district=='Megwi',weig:=64869508.2980392/totalCrop]
AllCF[district=='Petang',weig:=	21339120.4816176/totalCrop]
AllCF[district=='Kuta',weig:=	6131177.34877451/totalCrop]
AllCF[district=='KutaU',weig:=23448804.4223039/totalCrop]
AllCF[district=='KutaS',weig:=15714872.2894608/totalCrop]

#create the main outcome 
AllCF[,Devi:=EVI-xgb]


#overall model on all badung
summ(ateCF<-lm(Devi~as.factor(treat),data =AllCF,weights = weig),digits = 4,confint = T)
#model on the North
summ(ateCFNord<-lm(Devi~as.factor(treat),data =AllCF[area==0],weights = weig),digits = 4,confint = T)
#Model on the South
summ(ateCFSud<-lm(Devi~as.factor(treat),data =AllCF[area==1],weights =weig),digits = 4,confint = T)


#PLACEBO TEST
AllCF
#4   2 2020  e finisce il 7   9 2020
AllCF[Date%between%c('2019-04-02','2019-07-09'),treat2:=1]
AllCF[is.na(treat2),treat2:=0]
allCFJ<-AllCF[treat==0]

summ(placebo<-lm(Devi~as.factor(treat2),weights =weig,data=allCFJ),digits = 4,confint = T)

