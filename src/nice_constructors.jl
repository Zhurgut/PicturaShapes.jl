

function Point(x::Real, y::Real)
    (xp, yp) = Base.promote(x, y)
    T = typeof(xp)
    Point{T}(xp, yp)
end

Base.convert(::Type{Point{T}}, p::Point{S}) where {T, S} = Point{T}(T(p.x), T(p.y))
Point{T}(p) where T = convert(Point{T}, p)
