# 4 sided polygon


struct Quatrilateral{T} <: AbstractQuatrilateral{T}
    p1::Point{T}
    p2::Point{T}
    p3::Point{T}
    p4::Point{T}
end



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


function dist(p::Point, t::AbstractPolygon)
    s = sides(t)
    d = min((x->dist(x, p)).(s)...)
    return p ∈ t ? -d : d
end

function diagonals(r::AbstractQuatrilateral)
    c = corners(r)
    return Segment(c.tl, c.br), Segment(c.tr, c.bl)
end




function Base.:(==)(a::AbstractQuatrilateral, b::AbstractQuatrilateral)
    da1, da2 = diagonals(a)
    db1, db2 = diagonals(b)
    return (da1 == db1 && da2 == db2) || (da2 == db1 && da1 == db2)
end
function Base.isapprox(a::AbstractQuatrilateral, b::AbstractQuatrilateral)
    da1, da2 = diagonals(a)
    db1, db2 = diagonals(b)
    return (da1 ≈ db1 && da2 ≈ db2) || (da2 ≈ db1 && da1 ≈ db2)
end



rotate(t::Quatrilateral, θ)         = Quatrilateral(rotate(t.p1, θ),         rotate(t.p2, θ),         rotate(t.p3, θ),         rotate(t.p4, θ))
translate(t::Quatrilateral, dx, dy) = Quatrilateral(translate(t.p1, dx, dy), translate(t.p2, dx, dy), translate(t.p3, dx, dy), translate(t.p4, dx, dy))
scale(t::Quatrilateral, sx, sy)     = Quatrilateral(scale(t.p1, sx, sy),     scale(t.p2, sx, sy),     scale(t.p3, sx, sy),     scale(t.p4, sx, sy))


align(t::Quatrilateral) = Quatrilateral(align(t.p1), align(t.p2), align(t.p3), align(t.p4))

function simplify(t::Quatrilateral)
    r = Rect(tr=t.p2, br=t.p3, bl=t.p4)
    if r ≈ t return simplify(r) end
    return t
end


function Base.in(p::Point, t::Quatrilateral)
    t1 = Triangle(t.p1, t.p2, t.p3)
    t2 = Triangle(t.p1, t.p3, t.p4)
    return p ∈ t1 || p ∈ t2
end
