
# a 2-dimensional point

magnitude(p::Point) = LinearAlgebra.norm((p.x, p.y))

LinearAlgebra.dot(a::Point, b::Point) = a.x*b.x + a.y*b.y
LinearAlgebra.normalize(p::Point) = (1/magnitude(p))*p

Base.angle(p::Point) = atan(p.y, p.x)


dist(p1::Point, p2::Point)       = magnitude(p2 - p1)
Base.:(==)(p1::Point, p2::Point) = (p1.x == p2.x && p1.y == p2.y)
Base.isapprox(p1::Point, p2::Point) = dist(p1, p2) <= PREC


rotate(p::Point, θ)         = Point(cos(θ)*p.x - sin(θ)*p.y, sin(θ)*p.x + cos(θ)*p.y)
translate(p::Point, dx, dy) = Point(p.x + dx, p.y + dy)
scale(p::Point, sx, sy)     = Point(sx * p.x, sy * p.y)


align(p::Point{T}) where T = Point(align_round(p.x), align_round(p.y))


Base.in(p::Point, s::Point) = p ≈ s


function Base.intersect(p1::Point, p2::Point)
    if p1 == p2
        return p1
    end
    return nothing
end
