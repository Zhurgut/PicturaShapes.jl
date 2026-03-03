
struct Point{T} <: AbstractShape{T}
    x::T
    y::T
end




function Point(x::T1, y::T2) where {T1, T2}
    T = promote_type(T1, T2)
    Point{T}(T(x), T(y))
end

Point(t::Tuple{A, B}) where {A, B} = Point(t[1], t[2])

Base.convert(::Type{Point{T}}, p::Point) where T = Point{T}(T(p.x), T(p.y))
Point{T}(p::Point) where T = convert(Point{T}, p)






magnitude(p::Point) = LinearAlgebra.norm((p.x, p.y))

LinearAlgebra.dot(a::Point, b::Point) = a.x*b.x + a.y*b.y
LinearAlgebra.normalize(p::Point) = (1/magnitude(p))*p

Base.angle(p::Point) = atan(p.y, p.x)


sdf(p1::Point, p2::Point) = magnitude(p2 - p1)

Base.:(==)(p1::Point, p2::Point) = p1.x == p2.x && p1.y == p2.y


rotate(p::Point, θ)         = Point(cos(θ)*p.x - sin(θ)*p.y, sin(θ)*p.x + cos(θ)*p.y)
translate(p::Point, dx, dy) = Point(p.x + dx, p.y + dy)
scale(p::Point, sx, sy)     = Point(sx * p.x, sy * p.y)


Base.in(p::Point, s::Point) = p == s

