module PicturaShapes
using LinearAlgebra


abstract type AbstractShape{T} end
abstract type AbstractPolygon{T} <: AbstractShape{T} end # has corners and sides
abstract type AbstractQuatrilateral{T} <: AbstractPolygon{T} end
abstract type AbstractRect{T} <: AbstractPolygon{T} end
export AbstractShape, AbstractPolygon, AbstractQuatrilateral, AbstractRect



include("shapes/Point.jl")
export Point, magnitude # LinearAlgebra.normalize

include("shapes/Segment.jl")
export Segment

include("shapes/Line.jl")
export Line

include("shapes/AxisRect.jl")
export AxisRect, corners, sides, center

include("shapes/Rect.jl")
export Rect

include("shapes/Circle.jl")
export Circle

include("shapes/Ellipse.jl")
export Ellipse

# include("shapes/Quatrilateral.jl") 
# export Quatrilateral

# include("shapes/Triangle.jl")
# export Triangle


sdf(s, p::Point) = sdf(p,s)



# some shapes can be simplified, for example, a segment where the beginning and end points are the same can be simplified to a point
# simplify will not change the mathematical meaning of the shape
# returns a simplified shape on success, and nothing on failure
simplify(s::AbstractShape) = nothing


export simplify, sdf
export translate, scale, rotate



include("operators.jl")
include("show.jl")
# include("intersects.jl")
# include("constructors.jl")

include("bounding_boxes.jl")
export aligned_bounding_box, bounding_box










end


