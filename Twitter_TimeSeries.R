# Time Series Analysis of Tweets
# Yichu Li
# Sep 13, 2015

require(rmongodb)
require(xts)

setwd("C:/Users/Yichu/Desktop/Data_Analytics_Business_Insight")

rm(list=ls())

# bin length
bin			<-	600 # bin length in sec

# Remember to run MongoDB daemon on localhost before running the code below!
mongo	<-	mongo.create()
mongo.is.connected(mongo)
#NS		<-	"twitter.tweets_sample"
NS		<-	"twitter.tweets"

# get data of interests directly from DB : )
pipe_1		<-	mongo.bson.from.JSON('{"$project":{"min":{"$substr":["$created_at",4,12]}}}')
pipe_2		<-	mongo.bson.from.JSON('{"$group":{"_id":"$min", "count":{"$sum": 1}}}')
cmd_list	<-	list(pipe_1, pipe_2)
if (mongo.is.connected(mongo))
{
	res			<-	mongo.bson.to.list(mongo.aggregation(mongo, NS, cmd_list))[[1]]
}
# extract the result
count.vec	<-	rep(0,length(res))
time.vec	<-	rep(strptime(paste(res[[1]][[1]], "+0000 2015"), format="%b %d %H:%M %z %Y"),length(res))
for (i in 1:length(res))
{
	time.vec[i]		<-	as.POSIXct(strptime(paste(res[[i]][[1]], "+0000 2015"), format="%b %d %H:%M %z %Y"))+60
	count.vec[i]	<-	res[[i]][[2]]
}
ts.int	<-	xts(x=count.vec, order.by=time.vec)

# construct a time series with no missing bin
time.vec.complete	<-	seq(range(time.vec)[1], range(time.vec)[2], bin)
ts.int.complete		<-	xts(x=rep(0, length(time.vec.complete)-1), order.by=time.vec.complete[-1])
for (i in 1:length(ts.int))
{
	time.tmp					<-	index(ts.int[i])
	ind.tmp						<-	min(which(time.tmp<=time.vec.complete[-1]), length(ts.int.complete))
	ts.int.complete[ind.tmp]	<-	as.numeric(ts.int.complete[ind.tmp])+as.numeric(ts.int[i])
}
#y			<-	as.numeric(ts.int.complete)
y			<-	ts.int.complete

# analysis
if (FALSE)
{
x			<-	diff(diff(y, lag=1), lag=24*3600/bin)

res.acf		<-	acf(x, na.action=na.pass, lag.max=24*3600/bin+100)
fit.ma		<-	arima(x=x, order=c(0,0,1), seasonal=list(order=c(0,0,1), period=24*3600/bin))
acf(fit.ma$resid, lag.max=24*3600/bin+100, na.action=na.pass)

plot(fit.ma$resid)
tsdiag(fit.ma)

# model fitting: seasonal-ARIMA model (0,1,1)-(0,1,1)(period)
y.train		<-	y[1:((24*3600/bin)*4)] # choose the first 4 days
fit			<-	arima(y.train, order=c(0,1,1), seasonal=list(order=c(0,1,1), period=24*3600/bin))
summary(fit)
tsdiag(fit)
plot(forecast(fit, h=24*3600/bin), ylim=c(0,max(y.train)*2)) # predict 1 day
lines(y[1:((24*3600/bin)*5)])
}

#application
hist.lth	<-	4 # number of normal days to be included in training dataset
clock		<-	index(y)[1]
prd			<-	xts() # prediction
se			<-	xts() # std error
normal.days	<-	numeric() # set for normal days

while (clock<=tail(index(y),1))
{
	day			<-	as.Date(clock)
	index.train	<-	sort(union(which(index(y)<=clock & as.Date(index(y))>=day), which(as.Date(index(y)) %in% tail(normal.days, hist.lth)))) # get index for training
	if (length(which(diff(index.train)%%(3600*24/bin)!=1))>0) # sanity check, time series must have equal distance
	{
		cat("time series is not correct!\n")
		break
	}
	if (length(index.train)>=(hist.lth*3600*24/bin)) # satisfies minimum historical length
	{
		y.train.tmp	<-	as.numeric(y[index.train])
		fit.tmp		<-	arima(y.train.tmp, order=c(0,1,1), seasonal=list(order=c(0,1,1), period=24*3600/bin))
		prd.tmp		<-	predict(fit.tmp, n.ahead=1) # only predict 1 period
		if (length(prd)==0)
		{
			prd			<-	xts(x=prd.tmp$pred, order.by=clock+bin)
			se			<-	xts(x=prd.tmp$se, order.by=clock+bin)		
		} else
		{
			prd			<-	rbind(prd, xts(x=prd.tmp$pred, order.by=clock+bin))
			se			<-	rbind(se, xts(x=prd.tmp$se, order.by=clock+bin))
		}
	}	
	clock		<-	clock + bin # time goes!
	if (as.Date(clock)>day) # new day!
	{
		if (length(prd)>0)
		{
			day.tmp	<-	merge.xts(y=y[as.Date(index(y))==day], prd=prd, all=FALSE, join="left")
			day.tmp	<-	merge.xts(day.tmp, se=se, all=FALSE, join="left")
			outrange<-	length(which(day.tmp$y>(day.tmp$prd+4*day.tmp$se) | day.tmp$y<(day.tmp$prd-4*day.tmp$se)))
			if (outrange<=24*3600/bin/8)
				normal.days	<-	sort(c(normal.days, day))
		} else
			normal.days	<-	sort(c(normal.days, day))
	}
}
as.Date(normal.days)

# plot
num.graph	<-	4
ind.y		<-	index(y)
lth			<-	round(length(ind.y)/num.graph)
Reald_CI	<-	merge.xts(y=y, prd=prd, all=FALSE, join="left")
Reald_CI	<-	merge.xts(Reald_CI, se=se, all=FALSE, join="left")
ind.out		<-	ind.y[which(Reald_CI$y>(Reald_CI$prd+2*Reald_CI$se))]
for (i in 1:num.graph)
{
	png(paste(i, ".png", sep=""), height=600, width=600*1.5)
	plot.xts(y, type='l', xlim=range(na.omit(ind.y[((i-1)*lth+1):(i*lth)])))
	lines(prd+2*se, col='blue', lty=2)
	lines(prd-2*se, col='blue', lty=2)
	abline(v=ind.out, col='red', lty=4)
	dev.off()
}


# old code
if (FALSE)
{
source("Code/CodeBase/Twitter_Coordinates.R")
source("Code/CodeBase/Twitter_Place.R")
source("Code/CodeBase/Twitter_User.R")
source("Code/CodeBase/Twitter_Tweet.R")

load("Data/samplelist.RData")

# plot
Rprof("Rprof.out")
tweets	<-	tweet.l$new(samplelist)
Rprof(NULL)
summaryRprof("Rprof.out")
times	<-	tweets$getTimes()
range(times)

ts.int	<-	xts(x=rep(0, 60*24+1), order.by=strptime("2015-08-26 00:00:00", format="%Y-%m-%d %H:%M:%S")+seq(0,3600*24,60)) # create a series of time with equal interval
for (i in 2:length(ts.int))
{
	ts.int[i]	<-	length(which(times>=index(ts.int[i-1]) & times<=index(ts.int[i])))
}
plot(ts.int)
}