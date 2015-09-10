# R object of coordinates
# Yichu Li
# Aug 31, 2015

# coordinates
{
Coordinates		<-	setRefClass("Coordinates",
	fields	=	list(value="matrix", type="character"),
	methods	=	list(
						initialize	=	function(lst=list(coordinates=matrix(), type=character()))
						{
							if (!is.null(lst[["coordinates"]]))
								.self[["value"]]		<-	matrix(unlist(lst[["coordinates"]]),ncol=2,byrow=TRUE)
							if (!is.null(lst[["type"]]))
								.self[["type"]]			<-	lst[["type"]]
						},
						getCoord	=	function()
						{
							return(.self[["value"]])
						},
						getType		=	function()
						{
							return(type)
						}
					)
)
}
