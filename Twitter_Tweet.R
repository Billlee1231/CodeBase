# R object of tweet, and R object of list of tweet
# Yichu Li
# Aug 30, 2015

require(xts)

# tweet
{
tweet		<-	setRefClass("tweet",
	fields	=	list(id_str="character", created_at="POSIXct", text="character", place="list", coordinates="list", user="list"),
	methods =	list(
						initialize	=	function(lst=list(id_str=character(), created_at=character(), text=character(), place=list(), coordinates=list(), user=list()))
										{											
											directflds		<-	c("id_str","text","place","coordinates","user")
											for (elt in directflds)
											{
												if (!is.null(lst[[elt]]))
													.self[[elt]]	<-	lst[[elt]]
											}
											if (!is.null(lst[["created_at"]]))
												.self[["created_at"]]	<-	as.POSIXct(strptime(lst[["created_at"]], format="%a %b %d %H:%M:%S %z %Y"))
										},
						getID		=	function()
										{
											return(.self$id_str)
										},
						getTime		=	function()
										{
											return(.self$created_at)
										},
						getPlace	=	function()
										{
											return(.self$place)
										},
						getCoord	=	function()
										{
											return(.self$coordinates)
										},
						getUser		=	function()
										{
											return(.self$user)
										}
						)
)
}

# tweet.l
{
tweet.l		<-	setRefClass("tweet.l",
	fields	=	list(tweets="list"),
	methods	=	list(
						initialize	=	function(lst=list())
						{
							lth		<-	length(lst)
							.self[["tweets"]]	<-	vector(mode="list", lth)
							if (lth>0)
							{
								for (i in 1:lth)
								{
									.self[["tweets"]][[i]]		<-	tweet$new(lst[[i]])
								}							
							}
						},
						getTimes	=	function()
						{
							lth		<-	length(.self[["tweets"]])
							times	<-	.POSIXct(vector(mode = "integer", length = lth))
							for (i in 1:lth)
							{
								times[[i]]	<-	.self[["tweets"]][[i]]$getTime()
							}
							return(times)
						},
						getPlaces	=	function()
						{
							lth		<-	length(.self[["tweets"]])
							places	<-	vector(mode = "list", length = lth)
							for (i in 1:lth)
							{
								places[[i]]	<-	.self[["tweets"]][[i]]$getPlace()
							}
							return(places)
						}
					)
)
}

# test code
a	<-	tweet$new(coord.nonull[[1]])
a$getTime()
a$getID()
a$getPlace()
a$getCoord()
a$getUser()

b		<-	tweet.l$new(coord.nonull)
times	<-	b$getTimes()
places	<-	b$getPlaces()

ts.int	<-	xts(x=rep(0, 60*24+1), order.by=strptime("2015-08-26 00:00:00", format="%Y-%m-%d %H:%M:%S")+seq(0,3600*24,60))
for (i in 2:length(ts.int))
{
	ts.int[i]	<-	length(which(times>=index(ts.int[i-1]) & times<=index(ts.int[i])))
}
plot(ts.int)