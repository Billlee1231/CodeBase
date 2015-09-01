# Twitter Data analysis: using mongodb as database
# Yichu Li
# Aug 30, 2015

require(rmongodb)

rm(list=ls())

# Remember to run MongoDB daemon on localhost before running the code below!
mongo	<-	mongo.create()
mongo.is.connected(mongo)
NS		<-	"twitter.tweets"

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
