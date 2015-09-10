# R object of place
# Yichu Li
# Sep 1, 2015

# place
{
Place		<-	setRefClass("Place",
	fields	=	list(name="character", country="character", country_code="character",full_name="character", geometry="Coordinates", bounding_box="Coordinates"),
	methods	=	list(
						initialize	=	function(lst=list(name=character(), country=character(), country_code=character(), full_name=character(), geometry=list(), bounding_box=list()))
						{
							directflds	<-	c("name","country","country_code","full_name")
							for (elt in directflds)
							{
								if (!is.null(lst[[elt]]))
									.self[[elt]]	<-	lst[[elt]]
							}
							if (!is.null(lst[["geometry"]]))
								.self[["geometry"]]		<-	Coordinates$new(lst[["geometry"]])
							if (!is.null(lst[["bounding_box"]]))
								.self[["bounding_box"]]	<-	Coordinates$new(lst[["bounding_box"]])
						},
						getName		=	function()
						{
							return(.self$name)
						},
						getCountry	=	function()
						{
							return(.self$country)
						},
						getCountry_code=function()
						{
							return(.self$country_code)
						},
						getFull_name=	function()
						{
							if (length(.self$full_name)>0)
								return(.self$full_name)
							else
								return(NA)
						},
						getGeometry	=	function()
						{
							return(.self$geometry$getCoord())
						},
						getBounding_box	=	function()
						{
							return(.self$bounding_box$getCoord())
						}
					)
)
}