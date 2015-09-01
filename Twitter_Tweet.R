# R object of tweet, and R object of list of tweet
# Yichu Li
# Aug 30, 2015

require(xts)

# tweet
{
tweet		<-	setRefClass("tweet",
	fields	=	list(id_str="character", created_at="POSIXct", text="character", place="list", coordinates="Coordinates", user="list"),
	methods =	list(
						initialize	=	function(lst=list(id_str=character(), created_at=character(), text=character(), place=list(), coordinates=list(), user=list()))
										{											
											directflds		<-	c("id_str","text","place","user")
											for (elt in directflds)
											{
												if (!is.null(lst[[elt]]))
													.self[[elt]]	<-	lst[[elt]]
											}
											if (!is.null(lst[["created_at"]]))
												.self[["created_at"]]	<-	as.POSIXct(strptime(lst[["created_at"]], format="%a %b %d %H:%M:%S %z %Y"))
											if (!is.null(lst[["coordinates"]]))
												.self[["coordinates"]]	<-	Coordinates$new(lst[["coordinates"]])											
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
											return(.self$coordinates$getCoord())
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
						initialize		=	function(lst=list())
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
						getTimes		=	function()
						{
							lth		<-	length(.self[["tweets"]])
							times	<-	.POSIXct(vector(mode = "integer", length = lth))
							for (i in 1:lth)
							{
								times[[i]]	<-	.self[["tweets"]][[i]]$getTime()
							}
							return(times)
						},
						getPlaces		=	function()
						{
							lth		<-	length(.self[["tweets"]])
							places	<-	vector(mode = "list", length = lth)
							for (i in 1:lth)
							{
								places[[i]]	<-	.self[["tweets"]][[i]]$getPlace()
							}
							return(places)
						},
						getCoords	=	function()
						{
							lth		<-	length(.self[["tweets"]])
							coords	<-	matrix(NA, lth, 2)
							for (i in 1:lth)
							{
								tmp	<-	.self[["tweets"]][[i]]$getCoord()
								if (length(tmp)>0)
									coords[i,]	<-	tmp
							}
							return(coords)
						}
					)
)
}
