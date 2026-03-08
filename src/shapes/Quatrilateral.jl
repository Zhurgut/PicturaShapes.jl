# 4 sided polygon
# points go clockwise, screenspace coordinate system

struct Quatrilateral{T} <: AbstractQuatrilateral{T}
    p1::Point{T}
    p2::Point{T}
    p3::Point{T}
    p4::Point{T}
end

function Quatrilateral(p1::Point{T1}, p2::Point{T2}, p3::Point{T3}, p4::Point{T4}) where {T1, T2, T3, T4}
    T = promote_type(T1, T2, T3, T4)
    return Quatrilateral{T}(Point{T}(p1), Point{T}(p2), Point{T}(p3), Point{T}(p4))
end

Quatrilateral(x1, y1, x2, y2, x3, y3, x4, y4) = Quatrilateral(Point(x1, y1), Point(x2, y2), Point(x3, y3), Point(x4, y4))

Base.convert(::Type{Quatrilateral{T}}, q::Quatrilateral) where T = Quatrilateral{T}(Point{T}(q.p1), Point{T}(q.p2), Point{T}(q.p3), Point{T}(q.p4))
Quatrilateral{T}(q) where T = convert(Quatrilateral{T}, q)


function points(r::AbstractQuatrilateral)
    c = corners(r)
    return (c.tl, c.tr, c.bl, c.br)
end

corners(t::Quatrilateral) = (tl=t.p1, tr=t.p2, bl=t.p4, br=t.p3)

function sides(t::Quatrilateral)
    return (
        Segment(t.p1, t.p2),
        Segment(t.p2, t.p3),
        Segment(t.p3, t.p4),
        Segment(t.p4, t.p1)
    )
end


# function dist(p::Point, t::AbstractPolygon)
#     s = sides(t)
#     d = min((x->dist(x, p)).(s)...)
#     return p ∈ t ? -d : d
# end

function diagonals(r::AbstractQuatrilateral)
    c = corners(r)
    return Segment(c.tl, c.br), Segment(c.tr, c.bl)
end


function Base.:(==)(a::AbstractQuatrilateral, b::AbstractQuatrilateral)
    da1, da2 = diagonals(a)
    db1, db2 = diagonals(b)
    return (da1 == db1 && da2 == db2) || (da2 == db1 && da1 == db2)
end



rotate(t::Quatrilateral, θ)         = Quatrilateral(rotate(t.p1, θ),         rotate(t.p2, θ),         rotate(t.p3, θ),         rotate(t.p4, θ))
translate(t::Quatrilateral, dx, dy) = Quatrilateral(translate(t.p1, dx, dy), translate(t.p2, dx, dy), translate(t.p3, dx, dy), translate(t.p4, dx, dy))
scale(t::Quatrilateral, sx, sy)     = Quatrilateral(scale(t.p1, sx, sy),     scale(t.p2, sx, sy),     scale(t.p3, sx, sy),     scale(t.p4, sx, sy)) 
# TODO reverse order if only one of sx and sy has negative sign, add assertion


# function simplify(t::Quatrilateral)
#     r = Rect(tr=t.p2, br=t.p3, bl=t.p4)
#     if r ≈ t return simplify(r) end
#     return t
# end


# function Base.in(p::Point, t::Quatrilateral)
#     t1 = Triangle(t.p1, t.p2, t.p3)
#     t2 = Triangle(t.p1, t.p3, t.p4)
#     return p ∈ t1 || p ∈ t2
# end
