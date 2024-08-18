
# a 2-dimensional point

_norm(p::Point{T}) where T = LinearAlgebra.norm((p.x, p.y))
LinearAlgebra.dot(a::Point{T}, b::Point{S}) where {T,S} = a.x*b.x + a.y*b.y
magnitude(p::Point{T}) where T = _norm(p)
LinearAlgebra.normalize(p::Point{T}) where T = (1/magnitude(p))*p
Base.angle(p::Point{T}) where T = atan(p.y, p.x)


dist(p1::Point{T}, p2::Point{S}) where {T,S} = _norm(p2 - p1)
Base.:(==)(p1::Point{T}, p2::Point{S})    where {T, S} = (p1.x == p2.x && p1.y == p2.y)
Base.isapprox(p1::Point{T}, p2::Point{S}) where {T, S} = dist(p1, p2) <= EPS


rotate(p::Point{T}, θ) where T = Point(cos(θ)*p.x - sin(θ)*p.y, sin(θ)*p.x + cos(θ)*p.y)
shift(p::Point{T}, dx, dy) where T = Point(p.x + dx, p.y + dy)
scale(p::Point{T}, sx, sy) where T = Point(sx * p.x, sy * p.y)


align(p::Point{T}) where T = Point(rounded(p.x), rounded(p.y))


Base.in(p::Point{T}, s::Point{S}) where {T, S} = p == s


function Base.intersect(p1::Point{T}, p2::Point{S}) where {T, S}
    if p1 ≈ p2
        return 0.5*(p1 + p2)
    end
    return nothing
end
