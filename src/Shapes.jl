module Shapes
using LinearAlgebra

# using screen space coordinates
# positive x towards right
# positive y downwards



# precision used for comparison, 
# == checks for ==, which may not be meaningful due to rounding errors
# use \isapprox to compare shapes

DIGITS::Int = 3
EPS::Float64 = 1e-3

function set_eps(eps::Real)
    if 0 < eps < 1 
        global DIGITS, EPS
        DIGITS = -(log10(eps) |> floor |> Int)
        EPS = eps
    else
        @warn "to set eps for shape comparison, eps needs to be between 0 and 1, you gave: $eps"
    end
end

function rounded(x)
    global DIGITS
    return round(x, digits=DIGITS)
end



abstract type AbstractShape{T} end
abstract type AbstractPolygon{T} <: AbstractShape{T} end # has corners and sides
export AbstractShape, AbstractPolygon

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
struct AxisRect{T} <: AbstractPolygon{T}
    tl::Point{T}
    w::T
    h::T
end

struct Rect{T} <: AbstractPolygon{T}
    tl::Point{T}
    w::T
    h::T
    θ::Float64

    Rect{T}(p::Point{T}, w, h, θ=0.0) where T = new(p, T(w), T(h), mod2pi(θ + π) - π)
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

struct Quatrilateral{T} <: AbstractPolygon{T}
    p1::Point{T}
    p2::Point{T}
    p3::Point{T}
    p4::Point{T}
end


Base.intersect(s1::AbstractShape, s2::AbstractShape) = intersect(s2,s1)
Base.intersect(p::Point{T}, s::AbstractShape) where T = p ∈ s ? p : nothing


# distance function
# distance from edge, positive if p is outside of shape
# negative if p is inside shape
dist(l, p::Point{T}) where T = dist(p,l)


simplify(s::AbstractShape{T}) where T = s # some shapes can't be simplified, some can sometimes


export align, simplify
export dist, shift, scale, rotate # Base.intersect, Base.in

include("nice_constructors.jl")
include("operators.jl")
include("show.jl")



include("Point.jl")
export Point, magnitude # LinearAlgebra.normalize

# include("Segment.jl")
# export Segment

# include("Line.jl")
# export Line

# include("AxisRect.jl")
# export AxisRect, corners, sides, center

# include("Rect.jl")
# export Rect

# include("Quatrilateral.jl") 
# export Quatrilateral

# include("Circle.jl")
# export Circle

# include("Ellipse.jl")
# export Ellipse

# include("Triangle.jl")
# export Triangle

# include("intersects.jl")

# include("BoundingBoxes.jl")
# export bounding_box

end
