# R object of user
# Yichu Li
# Sep 10, 2015

# user
{
User	<-	setRefClass("User",
	fields	=	list(created_at="POSIXct", followers_count="integer", friends_count="integer", description="character",geo_enabled="logical",id_str="character",name="character",protected="logical",statuses_count="integer"),
	methods	=	list(
						initialize	=	function(lst=list(created_at=character(), followers_count=integer(),friends_count=integer(),description=character(),geo_enabled=logical(),id_str=character(),name=character(),protected=logical(),statuses_count=integer()))
										{
											directflds	<-	c("followers_count","friends_count","description","id_str","name","statuses_count","geo_enabled","protected")
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
						getCreated_at=	function()
										{
											return(.self$created_at)
										},
						getID		=	function()
										{
											return(.self$id_str)
										},
						getStatuses_count	=	function()
										{
											return(.self$statuses_count)
										},
						getFollowers_count	=	function()
										{
											return(.self$followers_count)
										},
						getFriends_count	=	function()
										{
											return(.self$friends_count)
										},
						getGeo_enabled		=	function()
										{
											return(.self$geo_enabled)
										},
						getProtected		=	function()
										{
											return(.self$protected)
										}
					)
)
}