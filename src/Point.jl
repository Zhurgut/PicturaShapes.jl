


function Point(x::Real, y::Real)
    (x, y) = Base.promote(x, y)
    T = typeof(x)
    Point{T}(x, y)
end

Point{T}(p::Point{S}) where {S, T} = Point{T}(T(p.x), T(p.y))
Base.convert(::Type{Point{T}}, p::Point{S}) where {T, S} = Point{T}(p)


Base.:(+)(p1::Point{T}, p2::Point{S}) where {T, S} = Point(p1.x + p2.x, p1.y + p2.y)
Base.:(-)(p::Point{T}) where T = Point(-p.x, -p.y)
Base.:(-)(p1::Point{T}, p2::Point{S}) where {T, S} = p1 + (-p2)
Base.:(*)(s, p::Point{T}) where T  = Point(s * p.x, s * p.y)


LinearAlgebra.norm(p::Point{T}) where T= norm((p.x, p.y))
LinearAlgebra.dot(a::Point{T}, b::Point{S}) where {T,S} = a.x*b.x + a.y*b.y
dist(p1::Point{T}, p2::Point{S}) where {T,S} = norm(p2 - p1)
magnitude(p::Point{T}) where T = norm(p)

LinearAlgebra.normalize(p::Point{T}) where T = (1/magnitude(p))*p


Base.:(==)(p1::Point{T}, p2::Point{S})    where {T, S} = (p1.x == p2.x && p1.y == p2.y)
Base.isapprox(p1::Point{T}, p2::Point{S}) where {T, S} = dist(p1, p2) <= EPS


# clockwise, around origin
rotate(p::Point{T}, θ) where T = Point(cos(θ)*p.x - sin(θ)*p.y, sin(θ)*p.x + cos(θ)*p.y)
translate(p::Point{T}, dx, dy) where T = p + Point(dx, dy)
scale(p::Point{T}, sx, sy) where T = Point(sx * p.x, sy * p.y)

Base.in(p::Point{T}, s::Point{S}) where {T, S} = p == s


align(p::Point{T}) where T = Point(round(p.x, DIGITS), round(p.y, DIGITS))


function Base.intersect(p1::Point{T}, p2::Point{S}) where {T, S}
    if p1 == p2
        return p1
    end
    if p1 ≈ p2
        return 0.5*(p1 + p2)
    end
    return nothing
end
