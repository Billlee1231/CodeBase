# R object of coordinates
# Yichu Li
# Aug 31, 2015

# coordinates
{
Coordinates		<-	setRefClass("Coordinates",
	fields	=	list(longitude="numeric", latitude="numeric", type="character"),
	methods	=	list(
						initialize	=	function(lst=list(coordinates=numeric(), type=character()))
						{
							.self[["longitude"]]	<-	lst[["coordinates"]][1]
							.self[["latitude"]]		<-	lst[["coordinates"]][2]
							.self[["type"]]			<-	lst[["type"]]
						},
						getCoord	=	function()
						{
							return(c(.self[["longitude"]], .self[["latitude"]]))
						},
						getType		=	function()
						{
							return(type)
						}
					)
)
}
