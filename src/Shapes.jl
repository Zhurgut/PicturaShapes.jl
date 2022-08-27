module Shapes

include("Point.jl")
export Point, dist, magnitude, scale, rotate

include("Line.jl")

include("Segment.jl")
export Line


include("Joint.jl")

include("Rect.jl")

include("Circle.jl")

include("Ellipse.jl")

end
