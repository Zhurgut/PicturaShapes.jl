module Shapes
using LinearAlgebra

# using screen space coordinates
# positive x towards right
# positive y downwards


abstract type AbstractShape{T} end
abstract type AbstractPolygon{T} <: AbstractShape{T} end # has corners and sides
abstract type AbstractQuatrilateral{T} <: AbstractPolygon{T} end

struct Point{T} <: AbstractShape{T}
    x::T
    y::T
end

struct Segment{T} <: AbstractShape{T}
    p1::Point{T}
    p2::Point{T}
end


struct Line <: AbstractShape{Float64}
    θ::Float64 # angle between x axis and shortest line to line [-π, π[
    dist::Float64 # distance of line from origin

    # thou (the user) shalt not use this constructor!
    Line(theta::Float64, dist::Float64) = new(mod2pi(theta + π + (dist < 0)π) - π, abs(dist))
end


# possible modes:
    # :corner
    # :center
    # :radius
struct AxisRect{T} <: AbstractQuatrilateral{T}
    tl::Point{T}
    w::T
    h::T
    function AxisRect(p1::Point{S}, p2::Point{T}) where {S, T}
        w = abs(p1.x - p2.x)
        h = abs(p1.y - p2.y)
        tl = Point(min(p1.x, p2.x), min(p1.y, p2.y))
        F = promote_type(T, S)
        return new{F}(Point{F}(tl), F(w), F(h))
    end
end

struct Rect{T} <: AbstractQuatrilateral{T}
    tl::Point{T}
    w::T
    h::T
    θ::Float64

    function Rect{T}(p::Point{T}, w::T, h::T, θ=0.0) where T
        @assert w >= 0
        @assert h >= 0
        return new{T}(p, w, h, mod2pi(θ + π) - π)
    end
end

struct Circle{T} <: AbstractShape{T}
    center::Point{T}
    radius::T

    Circle{T}(p::Point{T}, r::T) where T = new(p, abs(r))
end

struct Ellipse{T} <: AbstractShape{T}
    center::Point{T}
    radius::Point{T}
    θ::Float64

    Ellipse{T}(p::Point{T}, r::Point{T}, θ::Float64) where T = new(p, Point(abs(r.x), abs(r.y)), mod2pi(θ + π) - π)
end


struct Triangle{T} <: AbstractPolygon{T}
    p1::Point{T}
    p2::Point{T}
    p3::Point{T}
end

struct Quatrilateral{T} <: AbstractQuatrilateral{T}
    p1::Point{T}
    p2::Point{T}
    p3::Point{T}
    p4::Point{T}
end

struct Polygon{T} <: AbstractPolygon{T}
    ps::Vector{Point{T}}
end


# distance function
# distance from edge, positive if p is outside of shape
# negative if p is inside shape
dist(s, p::Point{T}) where T = dist(p,s)



# to facilitate comparison between shapes in the face of floating point arithmetic, 
# shapes can "rounded", or aligned. The granularity of the aligning can be changed using set_prec. 
align(s::AbstractShape) = error("not implemented")

# this also changes the tolerance for \isapprox comparisons
function set_prec(eps::Real)
    global PREC
    global INV_PREC
    PREC = eps
    INV_PREC = inv(eps)
end

set_prec(1e-3) # default



function align_round(x)
    global PREC, INV_PREC
    return PREC * round(x * INV_PREC)
end



# some shapes can be simplified, for example, a segment where the beginning and end points are the same can be simplified to a point
# simplify aims to not change the mathematical meaning of the shape
simplify(s::AbstractShape) = s # however some shapes can't be simplified

# simplify and intersect are not typestable



# == compares for shapes to be numerically the same
# you can use \approx to compare if shapes are roughly the same
function Base.:(==)(s1::AbstractShape{T}, s2::AbstractShape{S}) where {T, S}
    # this only gets called when s1 and s2 have different types, e.g. a point and a segment
    ss1 = simplify(s1)
    ss2 = simplify(s2)

    if ss1 != s1 || ss2 != s2
        # simplification changed things
        return ss1 == ss2 # one more chance
    else 
        # else different types means different shape 🤷
        return false
    end
end

function Base.isapprox(s1::AbstractShape{T}, s2::AbstractShape{S}) where {T, S}
    # this only gets called when s1 and s2 have different types, e.g. a point and a segment
    ss1 = simplify(s1)
    ss2 = simplify(s2)

    if ss1 != s1 || ss2 != s2
        # simplification changed things
        return ss1 ≈ ss2 # one more chance
    else 
        # else different types means different shape
        return false
    end
end




export AbstractShape, AbstractPolygon, AbstractQuatrilateral


export align, simplify
export dist, translate, scale, rotate # Base.intersect, Base.in

include("constructors.jl")
include("operators.jl")
include("show.jl")
include("intersects.jl")

include("bounding_boxes.jl")
export aligned_bounding_box, bounding_box



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

include("shapes/Quatrilateral.jl") 
export Quatrilateral

include("shapes/Circle.jl")
export Circle

include("shapes/Ellipse.jl")
export Ellipse

include("shapes/Triangle.jl")
export Triangle
 

# include("BoundingBoxes.jl")
# export bounding_box

end


