# 4 sided polygon


corners(t::Quatrilateral{T}) where T = (tl=t.p1, tr=t.p2, bl=t.p4, br=t.p3)

function sides(t::Quatrilateral{T}) where T
    return (
        Segment(t.p1, t.p2),
        Segment(t.p2, t.p3),
        Segment(t.p3, t.p4),
        Segment(t.p4, t.p1)
    )
end


function dist(p::Point{T}, t::AbstractPolygon{S}) where {T, S}
    s = sides(t)
    d = min(dist.(s, p)...)
    return p ∈ t ? -d : d
end

function diagonals(r::AbstractQuatrilateral{T}) where T
    c = corners(r)
    return Segment(c.tl, c.br), Segment(c.tr, c.bl)
end




function Base.:(==)(a::AbstractQuatrilateral{T}, b::AbstractQuatrilateral{S}) where {T, S}
    da1, da2 = diagonals(a)
    db1, db2 = diagonals(b)
    return (da1 == db1 && da2 == db2) || (da2 == db1 && da1 == db2)
end
function Base.isapprox(a::AbstractQuatrilateral{T}, b::AbstractQuatrilateral{S}) where {T, S}
    da1, da2 = diagonals(a)
    db1, db2 = diagonals(b)
    return (da1 ≈ db1 && da2 ≈ db2) || (da2 ≈ db1 && da1 ≈ db2)
end



rotate(t::Quatrilateral{T}, θ) where T =     Quatrilateral(rotate(t.p1, θ),     rotate(t.p2, θ),     rotate(t.p3, θ),     rotate(t.p4, θ))
translate(t::Quatrilateral{T}, dx, dy) where T = Quatrilateral(translate(t.p1, dx, dy), translate(t.p2, dx, dy), translate(t.p3, dx, dy), translate(t.p4, dx, dy))
scale(t::Quatrilateral{T}, sx, sy) where T = Quatrilateral(scale(t.p1, sx, sy), scale(t.p2, sx, sy), scale(t.p3, sx, sy), scale(t.p4, sx, sy))


align(t::Quatrilateral{T}) where T = Quatrilateral(align(t.p1), align(t.p2), align(t.p3), align(t.p4))

function simplify(t::Quatrilateral{T}) where T
    r = Rect(tr=t.p2, br=t.p3, bl=t.p4)
    if r ≈ t return simplify(r) end
    return t
end


function Base.in(p::Point{T}, t::Quatrilateral{S}) where {T, S}
    t1 = Triangle(t.p1, t.p2, t.p3)
    t2 = Triangle(t.p1, t.p3, t.p4)
    return p ∈ t1 || p ∈ t2
end
