## Louise Searle   
## Jan 09 2015

## Lesson 5 Tutorial: Introduction to the vector handling in R

# 2.2.1 Points: SpatialPoints, SpatialPointsDataFrame

# load sp package
library(sp)
library(rgdal)

# coordinates of two points identiefied in Google Earth, for example
pnt1_xy <- cbind(5.6735, 51.9884)   # enter your own coordinates
pnt2_xy <- cbind(5.6750, 51.9984)   # enter your own coordinates

# combine coordinates in single matrix
coords <- rbind(pnt1_xy, pnt2_xy)

# make spatial points object
prj_string_WGS <- CRS("+proj=longlat +datum=WGS84")
mypoints <- SpatialPoints(coords, proj4string=prj_string_WGS)

# inspect object
class(mypoints)
str(mypoints)

# create and display some attribute data and store in a data frame
mydata <- data.frame(cbind(id = c(1,2), 
                           Name = c("home", 
                                    "supermarket")))

# make spatial points data frame
mypointsdf <- SpatialPointsDataFrame(
     coords, data = mydata, 
     proj4string=prj_string_WGS)

class(mypointsdf) # inspect and plot object
names(mypointsdf)
str(mypointsdf)

spplot(mypointsdf, zcol="Name", col.regions = c("violet", "turquoise"), 
       xlim = bbox(mypointsdf)[1, ]+c(-0.01,0.01), 
       ylim = bbox(mypointsdf)[2, ]+c(-0.01,0.01),
       scales= list(draw = TRUE))

## play with the spplot function
## What is needed to make the following work?
spplot(mypointsdf, zcol = 'id', col.regions = c(1,2))
# Choose the attribute to plot using zcol = 'id' or 'Name'.

### Question: What is the the difference between the objects mypoints and mypointsdf.
### In the data frame the names are stored as attributes.

## 2.2.2 Lines

# consult help on SpatialLines class
(simple_line <- Line(coords))
# An object of class "Line"
# Slot "coords":
#      [,1]    [,2]
# [1,] 5.6735 51.9884
# [2,] 5.6750 51.9984

(lines_obj <- Lines(list(simple_line), "1"))
# An object of class "Lines"
# Slot "Lines":
#      [[1]]
# An object of class "Line"
# Slot "coords":
#      [,1]    [,2]
# [1,] 5.6735 51.9884
# [2,] 5.6750 51.9984
# Slot "ID":
#      [1] "1"

(spatlines <- SpatialLines(list(lines_obj), proj4string=prj_string_WGS))
# An object of class "SpatialLines"
# Slot "lines":
#      [[1]]
# An object of class "Lines"
# Slot "Lines":
#      [[1]]
# An object of class "Line"
# Slot "coords":
#      [,1]    [,2]
# [1,] 5.6735 51.9884
# [2,] 5.6750 51.9984
# 
# Slot "ID":
#      [1] "1"
# 
# Slot "bbox":
#      min     max
# x  5.6735  5.6750
# y 51.9884 51.9984
# 
# Slot "proj4string":
#      CRS arguments:
#      +proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0 

(line_data <- data.frame(Name = "straight line", row.names="1"))
# Name
# 1 straight line

(mylinesdf <- SpatialLinesDataFrame(spatlines, line_data))
# An object of class "SpatialLinesDataFrame"
# Slot "data":
#      Name
# 1 straight line
# 
# Slot "lines":
#      [[1]]
# An object of class "Lines"
# Slot "Lines":
#      [[1]]
# An object of class "Line"
# Slot "coords":
#      [,1]    [,2]
# [1,] 5.6735 51.9884
# [2,] 5.6750 51.9984
# 
# Slot "ID":
#      [1] "1"
# 
# Slot "bbox":
#      min     max
# x  5.6735  5.6750
# y 51.9884 51.9984
# 
# Slot "proj4string":
#      CRS arguments:
#      +proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0 

### Q: What is the difference between Line and Lines?
### Line can store a single line, lines can store several lines in one object.

class(mylinesdf)
str(mylinesdf)

spplot(mylinesdf, col.regions = "darkmagenta",
       xlim = bbox(mypointsdf)[1, ]+c(-0.01,0.01), 
       ylim = bbox(mypointsdf)[2, ]+c(-0.01,0.01),
       scales= list(draw = TRUE))

### Try to add the points together with the lines on the same map. 

## 2.2.3 Writing and reading spatial vector data using OGR

library(rgdal)
# write to kml ; below we assume a subdirectory data within the current 
# working directory.
dir.create("data", showWarnings = FALSE) 
writeOGR(mypointsdf, file.path("data","mypointsGE.kml"), 
         "mypointsGE", driver="KML", overwrite_layer=TRUE)
writeOGR(mylinesdf, file.path("data","mylinesGE.kml"), 
         "mylinesGE", driver="KML", overwrite_layer=TRUE)

dsn = file.path("data","route.kml")
ogrListLayers(dsn) ## to find out what the layers are
myroute <- readOGR(dsn, layer = ogrListLayers(dsn))

# put both in single data frame
proj4string(myroute) <- prj_string_WGS

## Warning in `proj4string<-`(`*tmp*`, value = <S4 object of class structure("CRS", package = "sp")>): A new CRS was assigned to an object with an existing CRS:
## +proj=longlat +ellps=WGS84 +towgs84=0,0,0,0,0,0,0 +no_defs
## without reprojecting.
## For reprojection, use function spTransform in package rgdal

names(myroute)
myroute$Description <- NULL # delete Description
mylinesdf <- rbind(mylinesdf, myroute)]

spplot(mylinesdf, col.regions = c("darkmagenta", 'turquoise'),
       xlim = bbox(mypointsdf)[1, ]+c(-0.01,0.01), 
       ylim = bbox(mypointsdf)[2, ]+c(-0.01,0.01),
       scales= list(draw = TRUE))

## 2.2.4 Transformation of coordinate system



