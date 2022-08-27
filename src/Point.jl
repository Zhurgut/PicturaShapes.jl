using LinearAlgebra: norm, dot, normalize

struct Point{T <: Real}
    x::T
    y::T
end

function Point(x::Real, y::Real)
    (x, y) = Base.promote(x, y)
    T = typeof(x)
    Point{T}(x, y)
end

Point{T}(p::Point) where T = Point{T}(T(p.x), T(p.y))

Base.convert(::Type{Point{T}}, p::Point) where T = Point{T}(p)

Base.:(+)(p::Point, p2::Point) = Point(p.x + p2.x, p.y + p2.y)
Base.:(-)(p::Point) = Point(-p.x, -p.y)
Base.:(-)(p::Point, p2::Point) = p + (-p2)
Base.:(*)(s::Real, p::Point)   = Point(s * p.x, s * p.y)
# Base.:(*)(p1::Real, p2::Point)   = Point(p1.x * p2.x, p1.y * p2.y)
Base.LinearAlgebra.dot(a::Point, b::Point) = a.x*b.x + a.y*b.y


dist(p1::Point, p2::Point) = norm((p1.x - p2.x, p1.y - p2.y))

magnitude(p1::Point) = dist(p1, Point(0,0))

normalize(p::Point) = (1/magnitude(p))*p

scale(p::Point, xs, ys) = Point(p.x * xs, p.y * ys)

# counterclockwise
rotate(p::Point, θ::Float64) = Point(cos(θ)*p.x - sin(θ)*p.y, sin(θ)*p.x + cos(θ)*p.y)



