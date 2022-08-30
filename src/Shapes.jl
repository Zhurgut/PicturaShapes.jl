module Shapes


include("Point.jl")
export Point, dist, magnitude, scale, rotate

dist(l,p::Point) = dist(p,l)
Base.intersect(l,p) = intersect(p,l)

include("Line.jl")
export Line

include("Segment.jl")
export Segment

include("Circle.jl")
export Circle
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
