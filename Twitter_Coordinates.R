# R object of coordinates
# Yichu Li
# Aug 31, 2015

# coordinates
{
Coordinates		<-	setRefClass("Coordinates",
	fields	=	list(value="numeric", type="character"),
	methods	=	list(
						initialize	=	function(lst=list(coordinates=numeric(), type=character()))
						{
							if (!is.null(lst[["coordinates"]]))
								.self[["value"]]		<-	lst[["coordinates"]]
							if (!is.null(lst[["type"]]))
								.self[["type"]]			<-	lst[["type"]]
						},
						getCoord	=	function()
						{
							return(c(.self[["value"]]))
						},
						getType		=	function()
						{
							return(type)
						}
					)
)
}
