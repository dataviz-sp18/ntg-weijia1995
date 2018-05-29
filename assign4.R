### Use dataset from https://www.kaggle.com/START-UMD/gtd

### National Consortium for the Study of Terrorism and Responses to Terrorism (START). (2016). 
### Global Terrorism Database [Data file]. Retrieved from https://www.kaggle.com/START-UMD/gtd

equire(ggplot2)
library(RColorBrewer)
library(data.table)
require(reshape2)
require(ggmap)
require(scales)
require(rgeos)
require(rangeMapper)
require(zoo)
library(rattle)
source("http://peterhaschke.com/Code/multiplot.R")

dt.crimes_ld <- fread("/Users/wli/Documents/data_viz/critique-weijia1995/Crimes_chi-2.csv", header=TRUE,sep=",")
dt.crimes <- dt.crimes_ld[Year>=2007]
colnames(dt.crimes)
dt.crimes[, c("Beat","FBI Code","X Coordinate","Y Coordinate","Location") := NULL]
rexp <- "\\d{2}/\\d{2}/\\d{4}\\s?(.*)$"
dt.crimes$Time=sub(rexp,"\\1",dt.crimes$Date)
dt.crimes$Date<-as.Date(dt.crimes$Date,format='%m/%d/%Y')
dt.crimes$Month = format.Date(as.Date(dt.crimes$Date), "%m") 

# Indexed crimes -------
crime_index <- fread("/Users/wli/Documents/data_viz/critique-weijia1995/IUCR__Codes.csv", header=TRUE,sep=",",colClasses = c(IUCR="character"), 
                     drop = c("PRIMARY DESCRIPTION","SECONDARY DESCRIPTION"))

dt.crimes$IUCR<-sub("[0](?=\\d{3})", "", dt.crimes$IUCR,perl = TRUE) 
setkey(crime_index,"IUCR")
setkey(dt.crimes,"IUCR")
dt.crimes.ind<-dt.crimes[crime_index]

### Indexed crimes are more serious crimes that need to be reported to FBI
ind.crimes<-dt.crimes.ind[`INDEX CODE`=="I"& Domestic=="false"]

### Further clean data based on location types --
### Remove some locations we are not interested in these locations now
locations=ind.crimes[,.N,by=`Location Description`][order(-N)][1:70]$`Location Description`
ind.crimes.u=ind.crimes[`Location Description` %in% locations]
ind.crimes.u[, c("Beat","Updated On","FBI Code","X Coordinate","Y Coordinate","Location") := NULL]

rlocations=locations[grep("AIRPORT|CONSTRUCTION|CHA |YARD|ABANDONED|HOUSE|VACANT|OTHER|SCHOOL|NURSING|DAY CARE CENTER|PORCH|FACTORY/MANUFACTURING BUILDING",locations)]

ind.crimes.u=ind.crimes.u[!`Location Description` %in% rlocations]
ind.crimes.u=ind.crimes.u[!`Location Description` %in% c("","ATHLETIC CLUB")]

ind.crimes.u[`Location Description` %in% c("CONVENIENCE STORE", "GROCERY FOOD STORE"),"Location Description"]="SMALL RETAIL STORE"
ind.crimes.u[`Location Description` %in% c("PARK PROPERTY","LAKEFRONT/WATERFRONT/RIVERBANK"),"Location Description"]="PARK"
ind.crimes.u[`Location Description` %in% c("CTA BUS","CTA TRAIN","CTA PLATFORM","CTA STATION","CTA BUS STOP"),"Location Description"]="PUBLIC TRANSPORTATION"
ind.crimes.u[`Location Description` %in% c("CAR WASH"),"Location Description"]="GAS STATION"
ind.crimes.u[`Location Description` %in% c("BAR OR TAVERN","RESTAURANT"),"Location Description"]="RESTAURANT/BAR"
ind.crimes.u[`Location Description` %in% c("BANK","CURRENCY EXCHANGE","ATM (AUTOMATIC TELLER MACHINE)"),"Location Description"]="BANK/ATM"
ind.crimes.u[`Location Description` %in% c("HOSPITAL BUILDING/GROUNDS","MEDICAL/DENTAL OFFICE"),"Location Description"]="MEDICAL BUILDINGS"
ind.crimes.u[`Location Description` %in% c("BRIDGE","SIDEWALK"),"Location Description"]="STREET"
ind.crimes.u[`Location Description` %in% c("TAXICAB"),"Location Description"]="VEHICLE-COMMERCIAL"
ind.crimes.u[`Location Description` %in% c("CLEANING STORE","BARBERSHOP","APPLIANCE STORE"),"Location Description"]="SMALL BUSINESS STORE"
ind.crimes.u[`Location Description` %in% c("PARKING LOT/GARAGE(NON.RESID.)"),"Location Description"]="PARKING LOT"

ind.crimes.u$Time = as.ITime(ind.crimes.u$Time,format = "%I:%M:%S %p")
ind.crimes.u$Date<-as.Date(ind.crimes.u$Date,format='%m/%d/%Y')


violent.u<-ind.crimes.u[`Primary Type` %in% c("ASSAULT","BATTERY","CRIM SEXUAL ASSAULT","HOMICIDE","KIDNAPPING","ROBBERY")]


subtypes=ind.crimes.u[,.N,by= Description][order(-N)]
subtypesv=violent.u[,.N,by= Description][order(-N)]
guns=subtypes$Description[grep("HANDGUN|FIREARM|GUN",subtypes$Description)]
gun.crimes=violent.u[Description %in% guns]

ind.crimes.u[Description %in% guns,Gun:=1]
ind.crimes.u[!Description %in% guns,Gun:=0]
violent.u[Description %in% guns,Gun:=1]
violent.u[!Description %in% guns,Gun:=0]


# Explore Gun Crimes ------
### Percentage of gun involved in all indexed crimes and violent crimes
nrow(gun.crimes)/nrow(ind.crimes.u)
nrow(gun.crimes)/nrow(violent.u)

#gun.crimes$Date=as.Date(gun.crimes$Date)
gun.crimes$WD=weekdays(gun.crimes$Date)
gun.crimes$month=month(gun.crimes$Date)
#gun.crimes$Time=as.ITime(gun.crimes$Time,format = "%I:%M:%S %p")
gun.crimes$hour=hour(gun.crimes$Time)

# ggmap gun -------

p7<-dmap +
  geom_point(aes(x = Longitude, y = Latitude),color="red",size=0.4,alpha=0.3,data = gun.crimes[Year>=2016,])+
  theme_minimal()+
  facet_wrap(~Year)+
  theme(legend.position="None",
        plot.title = element_text(hjust = 0),
        plot.margin=unit(c(8, 5.5, 5.5, 5.5), "points"))+
  geom_polygon(data = csp,aes(x=long,y=lat,group=group),color=alpha("brown",0.5),size=0.3,fill=alpha('grey',0.))


# d2= dmap+
#   stat_density2d(aes(x = Longitude, y = Latitude, fill = ..level.., alpha = ..level..),
#                  bins = 20, geom = "polygon",
#                  data = gun.crimes[Year>=2014,]) +
#   scale_fill_gradient(low = "white", high = "red") +
#   facet_wrap(~ Year,labeller = label_both)


m3=dmap+
  stat_density2d(data=gun.crimes[Year>=2016], aes(x=Longitude
                                                  , y=Latitude
                                                  ,size=ifelse(..density..<=1,0,..density..),
                                                  colour="orange"
                                                  ,alpha=..density..)
                 ,geom="tile",contour=F) +
  scale_size_continuous(range = c(0, 1), guide = "none") +
  scale_alpha(range = c(0,.5)) +
  ggtitle("Seattle Crime")

m4=dmap+
  stat_density2d(data=gun.crimes[Year>=2014], aes(x=Longitude, y=Latitude,
                                                  size=ifelse(..density..<=1,0,..density..^3),
                                                  color="red",
                                                  alpha=..density..)
                 ,geom="point",contour=F) +
  geom_polygon(data = csp,aes(x=long,y=lat,group=group),color=alpha("brown",0.3),size=0.3,fill=alpha('grey',0.1))+
  
  scale_size_continuous(range = c(0, 1.5), guide = "none") +
  scale_alpha(range = c(0,1)) +
  guides(colour="none",alpha=guide_legend(title = "Density",override.aes = list(colour= "red")))+
  facet_wrap(~Year)
