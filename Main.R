# Names: Daniel Scheerooren & Jorn Dallinga
# Team: DD
# Date: 12-1-2015

# load libraries
library(raster)
library(rgdal)

# download data
download.file(url = 'https://github.com/GeoScripting-WUR/VectorRaster/raw/gh-pages/data/MODIS.zip', destfile = 'data/Modis.zip', method = 'auto')

# unzip the data
unzip('data/Modis.zip', files = NULL, list = FALSE, overwrite = TRUE,
      junkpaths = FALSE, exdir = "data", unzip = "internal",
      setTimes = FALSE)

# brick and stack the Modis data
ModisPath <- list.files('data/', pattern = glob2rx('*.grd'), full.names = TRUE)
Modis <- brick('data/MOD13A3.A2014001.h18v03.005.grd')


# download manicipalicty boundaries
nlCity <- getData('GADM',country='NLD', level=3)
class(nlCity)

# convert coordinate systems
ContourWGS <- spTransform(nlCity, CRS(proj4string(Modis)))

# select the months of the year from MODIS
January <- Modis[[1]]
August <- Modis[[8]]

# masking January and August 
ModissatJanuary <- mask(January, ContourWGS)
ModissatAugust <- mask(August, ContourWGS)

# Testing overlapping data sets
plot(ModissatJanuary)
plot(ContourWGS, add=T)

plot(ModissatAugust)
plot(ContourWGS, add=T)

# Extract values

NDVI_Yearround <- extract(Modis, ContourWGS, fun=mean, na.rm=TRUE, cellnumbers=FALSE, df=FALSE,
                          factors=FALSE, along=FALSE, sp=TRUE)


# create data frame

ndviDF <- NDVI_Yearround@data

# show max NDVI value from all manucipalities from data set

January_max <- subset(ndviDF, ndviDF$January == max(ndviDF$January, na.rm = TRUE), select = NAME_2)
August_max <- subset(ndviDF, ndviDF$August == max(ndviDF$August, na.rm = TRUE), select = NAME_2)
#All_year_max <- subset(ndviDF, ndviDF$layer == max(ndviDF$layer, na.rm = TRUE), select = NAME_2)


# plot the extracted NDVI values

spplot(NDVI_Yearround[15], main = 'Yearround NDVI', col.regions = colorRampPalette(c("yellow","orange", "forestgreen"))(20))

# The following information to answer the assignment question
# The highest NDVI in August was recorded in Vorden
# The highest NDVI in January was recorded in Littenseradiel
January_max
August_max
