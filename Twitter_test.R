setwd("C:/Users/Yichu/Desktop/Data_Analytics_Business_Insight/Code/CodeBase")

source("Twitter_Coordinates.R")
source("Twitter_Place.R")
source("Twitter_Tweet.R")



# test code
e	<-	Place$new(coord.nonull[[1]][["place"]])
e$getFull_name()
e$getGeometry()
e$getBounding_box()

d	<-	Coordinates$new(coord.nonull[[1]][["coordinates"]])
d$getCoord()
d$getType()

a	<-	tweet$new(coord.nonull[[1]])
a$getTime()
a$getID()
a$getPlace()
a$getCoord()
a$getUser()

b		<-	tweet.l$new(coord.nonull)
times	<-	b$getTimes()
places	<-	b$getPlaces()
coords	<-	b$getCoords()

plot(x=coords[,1], y=coords[,2], pch=20)

ts.int	<-	xts(x=rep(0, 60*24+1), order.by=strptime("2015-08-26 00:00:00", format="%Y-%m-%d %H:%M:%S")+seq(0,3600*24,60))
for (i in 2:length(ts.int))
{
	ts.int[i]	<-	length(which(times>=index(ts.int[i-1]) & times<=index(ts.int[i])))
}
plot(ts.int)