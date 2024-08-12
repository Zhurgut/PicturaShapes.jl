

function Point(x::Real, y::Real)
    (xp, yp) = Base.promote(x, y)
    T = typeof(xp)
    Point{T}(xp, yp)
end

Base.convert(::Type{Point{T}}, p::Point{S}) where {T, S} = Point{T}(T(p.x), T(p.y))
Point{T}(p) where T = convert(Point{T}, p)



function Segment(p1::Point{T}, p2::Point{S}) where {T, S}
    R = promote_type(T, S)
    return Segment{R}(Point{R}(p1), Point{R}(p2))
end

Segment(x1, y1, x2, y2) = Segment(Point(x1, y1), Point(x2, y2))
Segment(p1::Point{T}, x2, y2) where T = Segment(p1, Point(x2, y2))

Segment(l::Line) = (Circle(0,0, max(1, 2*l.dist)) ∩ l)::Segment{Float64}

Base.convert(::Type{Segment{T}}, s::Segment{S}) where {T, S} = Segment{T}(Point{T}(s.p1), Point{T}(s.p2))
Segment{T}(s) where T = convert(Segment{T}, s)
