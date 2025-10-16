#names of currently used layers
const BUILDINGS = "buildings"
const COMMON = "common"
const HIGHWAYS = "highways"
const WATER = "water"
const POINT = "point"
const NATURAL = "natural"

#widths for different kinds of paths
const WIDTHS = {
	"motorway": 5,
	"primary": 5,
	"secondary": 5,
	"tertiary": 5,
	"residential":5 ,
}

#description of polygon height in tags. Used in calculate_polygon_heights
const HEIGHT_IN_LEVELS = "levels"
const HEIGHT_IN_METERS = "height"

#offset which represents length / width of one tile
const OFFSET = 655.25
