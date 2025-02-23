library(raster) #raster as usual
library(dismo) #also species distribution modelling (get this for rgbif function)
library(maptools) #for country boundaries maps
#library(rgbif)
library(rgdal) #for readOGR
library(sp)


setwd("/Users/buithuuyen/Desktop/lab")

#get species info on rgbif gbif(genus, spcies) but because tardigarde is a newly-introduced species, therefore, its taxonomy is still simple => Get the whole "Eutardigrada" 
tardigrade<- gbif("Eutardigrada",)
#dimension
dim(tardigrade) #results 4401 row species, 162 col obs
#'s see what were observed
names(tardigrade)
#get lon and let for spatial points
loca_tardigrade<- tardigrade[,c("lon","lat")]
#clean up NA data
na.omit(loca_tardigrade)
#plot for visualizing 
plot(loca_tardigrade)
#the result is messy, doesn't have geographical composition through lon and lat => not sufficient for imagination :P 

#plot background world map
#data(wrld_simpl)
#plot(wrld_simpl) 
#add points from location of tardigrade 
#points(loca_tardigrade[,1],loca_tardigrade[,2],col="red", pch=20)

#now i'm curious about only europe, because tardigrade is the reason I came to europ for my master
#plot(wrld_simpl, xlim=c(-35,50), ylim=c(50,50)) # crop to ext to europe
#add points from location of tardigrade
#points(loca_tardigrade[,1],loca_tardigrade[,2],col="red", pch=20)

#now I'm curious about Italy
#which(wrld_simpl$NAME=="Italy")
#plot(wrld_simpl[86,])
#points(loca_tardigrade[,1],loca_tardigrade[,2],col="red", pch=20)

#tardigrade occurrences of each country
table(tardigrade$country)

#NOW MAPPING BIOGEO
biogeo<-readOGR("~/Desktop/lab/BiogeoRegions2016.shp")
biogeo@data

#adding color to each polygon for visualizing biogeo regions easier
	# I wanted to use viridis, but it shows error saying that replacement has 19 rows while dataset has 12 rows => sadly i have to create another color rampallet 
biogeo@data$COLOUR<- c("#EF9A9A", "#F48FB1", "#CE93D8", "#B39DDB", "#90CAF9", "#80CBC4", "#FFCC80", "#BCAAA4", "#C5E1A5", "#1565C0", "#37474F", "#FDD835")
# beautiful map result, only that it took forever to map :<< 


 
#plot-> point/polygon
#I have to change CRS because I can see biogeo'crs is EPSG:3035-ETRS89, and loca-tardi is not

plot (biogeo, col=biogeo@data$COLOUR)
plot(tardigrade,col="red", pch=20, add=T)
legend("bottomright",   
      legend = levels(biogeo@data$code), 
      fill = biogeo@data$COLOUR) 

legend("bottomright",   # location of legend
      legend = levels(biogeo@data$code), # categories or elements to render in
			 # the legend
      fill = biogeo@data$COLOUR) # color palette to use to fill objects in legend.

#or 
ggplot()+
geom_polygon(data=biogeo, mapping = aes (x=lon, y=lat,group=biogeo@data$code, fill=biogeo@data$COLOUR))+
geom_point(data=loca_tardigrade, aes(x=loca_tardigrade[,1],y=loca_tardigrade[,2]), color="red")


#plot -> points
#tìm cách assign biogeography cho bọn này 
pointsInPolygons(
  point.feat,
  polyg.feat,
  studyplot = NULL,
  scenario,
  buffer = 0,
  cex.text = 0.7
)
#tính specices richness theo biogeography regions xem region nào bọn này xuất hiện nhiều nhất.

#làm map như vegan


###################DAY N of trying-SUCESSFULL DAY_I will never forget this day!!! 31/12/21 ######################


library(dismo) #also species distribution modelling (get this for rgbif function)
library(rgdal) #for readOGR
library(sp) #to transform crs
library(cartography) #data visualization 

setwd("/Users/buithuuyen/Desktop/lab")

####TAKE SPECIES DATA####
# cut extention for europe
e<- extent(-8.250667, 32.14889, 34.66667, 66.28333)
tardigrade<- gbif("Eutardigrada",ext=e, sp=T, removeZeros=T, download=T)
dim(tardigrade) #for the number of results
# tardigrade now is spatial point data frame, because argument sp=T, no need to extract long, lat as the other day 
plot(tardigrade)

####PLOT BIOGEO####
biogeo<-readOGR("~/Desktop/lab/BiogeoRegions2016.shp")
biogeo@data

#first look 
plot (biogeo, col=biogeo@data$COLOUR)
plot(tardigrade,col="red", pch=20, add=T)
#cant distinguish biogeo 

#adding color to each polygon
	#I wanted to use viridis, but it shows error saying that replacement has 19 rows while dataset has 12 rows => sadly i have to create another color rampallet
biogeo@data$COLOUR<- c("#EF9A9A", "#F48FB1", "#CE93D8", "#B39DDB", "#90CAF9", "#80CBC4", "#FFCC80", "#BCAAA4", "#C5E1A5", "#1565C0", "#37474F", "#FDD835")
# beautiful result
#plot (biogeo, col=biogeo@data$COLOUR) 
#đợi plot xong cái củ l lâu la này thì plot điểm thêm vào
#plot(tardigrade, col="red", pch=20, add=T)


##check CRS
proj4string(biogeo)
proj4string(tardigrade)
#they show different CRS => not the time to over() now 
#=> georeference them in the same universal CRS

#this method is not correct
#georef<-proj4string(biogeo)
#proj4string(tardigrade)<- georef

#this way is correct, choose CRS epsg:4326 (WGS84 (EPSG: 4326)
# Commonly used by organizations that provide GIS data for the entire globe or many countries. CRS used by Google Earth.  EPSG 4326 defines a full coordinate reference system, providing spatial meaning to otherwise meaningless pairs of numbers. It means "latitude and longitude coordinates on the WGS84 reference ellipsoid."

#with sp products that already has CRS set up, change it this way
biogeo<- spTransform(biogeo, CRS("+init=epsg:4326"))
#with sp products that hasn;t had CRS yet, set up this way
proj4string(tardigrade) <- CRS("+init=epsg:4326") 
#now over()
res<- over(tardigrade, biogeo)

##misunderstanding and NOT neccessary steps
?over #there is no option for over (spatial pointdataframe vs spatial polygonsdataframe)
#=> likely need to change class of tardigrade to spatial points
#tardigrade_sp<- as(tardigrade, "SpatialPoints") #no need anymore
#georef again new sp object #but this way is also not correct
#proj4string(tardigrade_sp)<- "+proj=laea +lat_0=52 +lon_0=10 +x_0=4321000 +y_0=3210000 +ellps=GRS80 +units=m +no_defs"
#now over() again
#res<- over(tardigrade_sp, biogeo) # doesn't work, because the CRS was not correct

#continue line 142
res_tab<- table(res$name)
#take the result from res_tab to build a vector of result, with available results relevent to biogeo fields of biogeo@data, not availale biogeo result=0
tardigrade_occ<- c(184,0, 0, 1004, 0, 390,101,0, 17, 73,0,3)
#bind new vector to the data frame
biogeo@data$tardigrade_occ<- tardigrade_occ
biogeo@data

####thematic, data visualization####
plot(biogeo, col=biogeo@data$COLOUR)
#sp data to be able to use in this function need to go transparent through spdf=, df=, spdfid=, dfid= argument
propSymbolsLayer(
  spdf = biogeo, 
   df = biogeo, 
   spdfid = "code", 
   dfid = "code", 
   var = "tardigrade_occ", 
   legend.pos = "bottomright",
   col = "red4", 
   border = "white", 
   legend.title.txt = "Occurrences",
   legend.title.cex=1.2 ,
   legend.values.cex=1
 )
legend("topleft", legend= biogeo@data$code,fill = biogeo@data$COLOUR, cex=0.6)
layoutLayer(title = "Tardigrade Occurrences",
             sources = "Data: EEA 2016, GBIF 2021",
             author =  paste0("© Bui Thu Uyen"),
             scale = 300, frame = TRUE, col = "#688994")
north("topright")



