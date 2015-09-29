# Text mining of Tweets
# Yichu Li
# Sep 21, 2015

require(rmongodb)

setwd("C:/Users/Yichu/Desktop/Data_Analytics_Business_Insight")

rm(list=ls())

# Parameter setting
NS			<-	"twitter.tweets_sample"
#NS			<-	"twitter.tweets"
time_begin	<-	'Wed Aug 26 23:30:00 +0000 2015'
time_end	<-	'Wed Aug 26 23:40:00 +0000 2015'

# Converting time to unix time
time_begin_unix	<-	as.character(as.numeric(as.POSIXct(strptime(time_begin, format="%b %d %H:%M %z %Y"))))
time_end_unix	<-	as.character(as.numeric(as.POSIXct(strptime(time_end, format="%b %d %H:%M %z %Y"))))

# Remember to run MongoDB daemon on localhost before running the code below!
mongo	<-	mongo.create()
mongo.is.connected(mongo)

# get text from MongoDB
count	<-	mongo.count(mongo=mongo, ns=NS, query=list('timestamp_ms'=list('$lte'=time_end_unix), 'timestamp_ms'=list('$gt'=time_end_unix)))
Sys.time()
#test	<-	mongo.find.all(mongo=mongo, ns=NS, query=list('created_at'=list('$lte'='Wed Aug 26 07:30:00 +0000 2015'), 'created_at'=list('$gt'='Wed Aug 26 07:00:00 +0000 2015')), fields=list('text'=1L,'created_at'=1L), limit=10, data.frame=TRUE)
test	<-	mongo.find.all(mongo=mongo, ns=NS, query=list('timestamp_ms'=list('$lte'=time_end_unix), 'timestamp_ms'=list('$gt'=time_end_unix)), fields=list('text'=1L,'created_at'=1L), limit=0, data.frame=TRUE)
Sys.time()
