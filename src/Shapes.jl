module Shapes

include("Point.jl")
export Point, dist, magnitude, scale, rotate

include("Line.jl")
export Line

include("Segment.jl")
export Segment
#
#
#
# include("Joint.jl")
#
# include("Rect.jl")
#
# include("Circle.jl")
#
# include("Ellipse.jl")

end
