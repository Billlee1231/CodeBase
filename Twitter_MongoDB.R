# Twitter Data analysis: using mongodb as database
# Yichu Li
# Aug 30, 2015

require(rmongodb)

setwd("C:/Users/Yichu/Desktop/Data_Analytics_Business_Insight")

rm(list=ls())

# Remember to run MongoDB daemon on localhost before running the code below!
mongo	<-	mongo.create()
mongo.is.connected(mongo)
NS		<-	"twitter.tweets"

{
# case 1: go through the whole db of twitter
if (FALSE)
{
cursor	<-	mongo.find(mongo=mongo, ns=NS)
while(mongo.cursor.next(cursor))
{
	value	<-	mongo.cursor.value(cursor)
	list.r	<-	mongo.bson.to.list(value)	
}
mongo.cursor.destroy(cursor)
}

# case 2: go through filtered records: only choose records with geo NULL, and only choose id, geo and text fields
if (FALSE)
{
buf			<-	mongo.bson.buffer.create() # first create a bson so to filter
mongo.bson.buffer.append(buf, "geo", NULL)
null.filter	<-	mongo.bson.from.buffer(buf)
cursor		<-	mongo.find(mongo=mongo, ns=NS, query=null.filter, fields=list("id"=1L, "geo"=1L, "text"=1L))
geo.null	<-	list()
while(mongo.cursor.next(cursor))
{
	value		<-	mongo.cursor.value(cursor)
	geo.null	<-	c(geo.null, mongo.bson.to.list(value))	
}
mongo.cursor.destroy(cursor)
}

# case 3: go through filtered records: only choose records with geo NOT NULL (geo is deprecated)
if (FALSE)
{
cursor		<-	mongo.find(mongo=mongo, ns=NS, query=list("geo"=list("$ne"=NULL)), fields=list("id"=1L, "geo"=1L, "text"=1L, "created_at"=1L, "source"=1L, "timestamp_ms"=1L, "place"=1L))
geo.nonull	<-	list()
i			<-	1
while(mongo.cursor.next(cursor))
{
	value		<-	mongo.cursor.value(cursor)
	geo.nonull	<-	c(geo.nonull, list(mongo.bson.to.list(value)))
	print(i)
	i			<-	i+1
}
mongo.cursor.destroy(cursor)
}

# case 4: go through filtered records: only choose records with coordinates NOT NULL
if (FALSE)
{
cursor		<-	mongo.find(mongo=mongo, ns=NS, query=list("coordinates"=list("$ne"=NULL)), fields=list("id_str"=1L, "text"=1L, "user"=1L, "created_at"=1L, "place"=1L, "coordinates"=1L))
mongo.count(mongo=mongo, ns=NS, query=list("coordinates"=list("$ne"=NULL)))
mongo.count(mongo=mongo, ns=NS)
coord.nonull<-	list()
i			<-	1
while(mongo.cursor.next(cursor) & i<=2000)
{
	value		<-	mongo.cursor.value(cursor)
	coord.nonull<-	c(coord.nonull, list(mongo.bson.to.list(value)))
	if (i%%100==0)
		print(i)
	i			<-	i+1
}
mongo.cursor.destroy(cursor)
}

# case 5: go through all records with fields text, created_at.
# why stop at 26200??? the total is over 70000
if (FALSE)
{
a	<-	Sys.time()
cursor		<-	mongo.find(mongo=mongo, ns=NS, fields=list("text"=1L, "created_at"=1L))
samplelist	<-	list()
i			<-	1
while(mongo.cursor.next(cursor))
{
	value		<-	mongo.cursor.value(cursor)
	samplelist	<-	c(samplelist, list(mongo.bson.to.list(value)))
	if (i%%100==0)
		print(i)
	i			<-	i+1
}
b	<-	Sys.time()
difftime(b, a, unit="min")
}
}

# case 5.2: go through all records with fields text, created_at.
# create a new cursor if mongo.cursor.next return FALSE but didn't reach the end
{
Rprof("Rprof.out")
lth			<-	mongo.count(mongo=mongo, ns=NS)
cursor		<-	mongo.find(mongo=mongo, ns=NS, fields=list("text"=1L, "created_at"=1L))
samplelist	<-	list()
i			<-	1
systime		<-	Sys.time()
while (i <= lth)
{
	if(mongo.cursor.next(cursor))
	{
		value			<-	mongo.cursor.value(cursor)
		samplelist[[i]]	<-	mongo.bson.to.list(value)
		i				<-	i+1
	} else
	{		
		cursor			<-	mongo.find(mongo=mongo, ns=NS, fields=list("text"=1L, "created_at"=1L), skip=i-1)	
		cat("New cursor at ", i, ".\n")
	}
	if (i%%1000==0)
	{
		print(i)
		systime			<-	c(systime, Sys.time())
	}
}
systime	<-	c(systime, Sys.time())
Rprof(NULL)
summaryRprof("Rprof.out")
plot(difftime(systime[-1], systime[-length(systime)], unit="min"), xlab="1000 entries", ylab="time taken (min)")
}

save("samplelist", file="samplelist.RData")
mongo.is.connected(mongo)
mongo.cursor.destroy(cursor)