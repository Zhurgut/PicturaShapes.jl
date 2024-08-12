module Shapes
using LinearAlgebra

# using screen space coordinates
# positive x towards right
# positive y downwards





DIGITS::Int = 3
EPS::Float64 = 1e-3

function set_eps(eps)
    global DIGITS, EPS
    DIGITS = -log10(eps) |> round |> Int
    EPS = 10.0^-DIGITS
end



abstract type AbstractShape{T} end
abstract type AbstractQuatrilateral{T} <: AbstractShape{T} end # corners, sides
export AbstractShape, AbstractQuatrilateral

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
end

struct Rect{T} <: AbstractQuatrilateral{T}
    tl::Point{T}
    w::T
    h::T
    θ::Float64

    Rect{T}(p::Point{T}, w, h, θ=0.0) where T = new(p, T(w), T(h), mod2pi(θ + π) - π)
end

struct Circle{T} <: AbstractShape{T}
    center::Point{T}
    radius::Float64

    Circle{T}(p::Point{T}, r::Float64) where T = new(p, abs(r))
end

struct Ellipse{T} <: AbstractShape{T}
    center::Point{T}
    radius_x::Float64 # along x axis (before rotation)
    radius_y::Float64 # along y axis
    θ::Float64

    Ellipse{T}(p::Point{T}, r1::Float64, r2::Float64, θ::Float64) where T = new(p, abs(r1), abs(r2), mod2pi(θ + π) - π)
end

struct Triangle{T} <: AbstractShape{T}
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


Base.intersect(s1::AbstractShape, s2::AbstractShape) = intersect(s2,s1)
Base.intersect(p::Point{T}, s::AbstractShape) where T = p ∈ s ? p : nothing
Base.:(+)(p::Point{T}, s) where T = s + p

# distance function
# distance from edge, positive if p is outside of shape
# negative if p is inside shape
dist(l, p::Point{T}) where T = dist(p,l)


export dist, translate, scale, rotate # Base.intersect, Base.in



include("Point.jl")
export Point, magnitude # LinearAlgebra.normalize

include("Segment.jl")
export Segment

include("Line.jl")
export Line

include("AxisRect.jl")
export AxisRect, corners, sides, center

include("Rect.jl")
export Rect

include("Quatrilateral.jl") 
export Quatrilateral

include("Circle.jl")
export Circle

include("Ellipse.jl")
export Ellipse

include("Triangle.jl")
export Triangle

include("intersects.jl")

include("BoundingBoxes.jl")
export bounding_box

end
