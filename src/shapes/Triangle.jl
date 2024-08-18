


function sides(t::Triangle{T}) where T
    return (
        Segment(t.p1, t.p2),
        Segment(t.p2, t.p3),
        Segment(t.p3, t.p1)
    )
end

# return α, β s.t. p = t.p1 + α(t.p2-t.p1) + β(t.p3-t.p1)
function barycentric_coordinates(t::Triangle{T}, p::Point{S}) where {T, S}
    a, b, c, d = t.p2.x - t.p1.x, t.p3.x - t.p1.x, t.p2.y - t.p1.y, t.p3.y - t.p1.y
    idet = 1 / (a*d  - b*c)
    ia, ib, ic, id = idet .* (d, -b, -c, a) # matrix inverse of [a b; c d]
    v = p - t.p1
    α = ia * v.x + ib * v.y
    β = ic * v.x + id * v.y
    return α, β
end



function Base.:(==)(t1::Triangle{T}, t2::Triangle{S})    where {T,S}
    return  (t1.p1 == t2.p1 && t1.p2 == t2.p2 && t1.p3 == t2.p3) || 
            (t1.p1 == t2.p2 && t1.p2 == t2.p3 && t1.p3 == t2.p1) || 
            (t1.p1 == t2.p3 && t1.p2 == t2.p1 && t1.p3 == t2.p2) || 
            (t1.p1 == t2.p3 && t1.p2 == t2.p2 && t1.p3 == t2.p1) || 
            (t1.p1 == t2.p2 && t1.p2 == t2.p1 && t1.p3 == t2.p3) || 
            (t1.p1 == t2.p1 && t1.p2 == t2.p3 && t1.p3 == t2.p2)
end
function Base.isapprox(t1::Triangle{T}, t2::Triangle{S}) where {T,S}
    return  (t1.p1 ≈ t2.p1 && t1.p2 ≈ t2.p2 && t1.p3 ≈ t2.p3) || 
            (t1.p1 ≈ t2.p2 && t1.p2 ≈ t2.p3 && t1.p3 ≈ t2.p1) || 
            (t1.p1 ≈ t2.p3 && t1.p2 ≈ t2.p1 && t1.p3 ≈ t2.p2) || 
            (t1.p1 ≈ t2.p3 && t1.p2 ≈ t2.p2 && t1.p3 ≈ t2.p1) || 
            (t1.p1 ≈ t2.p2 && t1.p2 ≈ t2.p1 && t1.p3 ≈ t2.p3) || 
            (t1.p1 ≈ t2.p1 && t1.p2 ≈ t2.p3 && t1.p3 ≈ t2.p2)
end

rotate(t::Triangle{T}, θ) where T         = Triangle(rotate(t.p1, θ), rotate(t.p2, θ), rotate(t.p3, θ))
shift(t::Triangle{T}, dx, dy) where T = Triangle(shift(t.p1, dx, dy), shift(t.p2, dx, dy), shift(t.p3, dx, dy))
scale(t::Triangle{T}, sx, sy) where T     = Triangle(scale(t.p1, sx, sy), scale(t.p2, sx, sy), scale(t.p3, sx, sy))



align(t::Triangle{T}) where T = Triangle(align(t.p1), align(t.p2), align(t.p3))

function simplify(t::Triangle{T}) where T
    if t.p1 ≈ t.p2
        return simplify(Segment(0.5(t.p1 + t.p2), t.p3))
    elseif t.p1 ≈ t.p3
        return simplify(Segment(0.5(t.p1 + t.p3), t.p2))
    elseif t.p3 ≈ t.p2
        return simplify(Segment(0.5(t.p3 + t.p2), t.p1))
    else
        return t
    end
end


function Base.in(p::Point{T}, t::Triangle{S}) where {T, S}
    α, β = barycentric_coordinates(t, p)
    return 0 <= α + β <= 1 && 0 <= α <= 1 && 0 <= β <= 1
end


