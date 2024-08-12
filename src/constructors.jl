

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



Line(t::Real, d::Real) = Line(Float64(t), Float64(d))
Line(a, b, c)        = Line(Segment(a, b, c))
Line(x1, y1, x2, y2) = Line(Segment(x1, y1, x2, y2))
Line(l::Segment{T}) where T = Line(l.p1, l.p2)

function Line(p1::Point{T}, p2::Point{S}) where {T, S}
    p1 != p2 || error("cannot construct line from 2 points that are equal $p1 == $p2")
    q = project(Point(0,0), Segment(p1, p2))

    if q ≈ Point(0,0)
        p = p2 - p1
        pr = rotate(p, π/2)
        θ = atan(pr.y, pr.x)
        return Line(θ, 0)
    end

    θ = atan(q.y, q.x)
    return Line(θ, magnitude(q))
    
end

