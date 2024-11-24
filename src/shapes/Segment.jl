
# finite line, storing the 2 endpoints


#               x
#               |
#               |
# +-------------+------------+
#l.p1           s          l.p2

# s = l.p1 + delta*(l.p2-.lp1), (s-x) ⊥ (l.p2-l.p1)
function delta(x::Point{T}, l::Segment{S}) where {T,S}
    d = l.p2-l.p1
    d != Point(0.0, 0.0) || error("cant compute delta, invalid segment (l.p1 == l.p2)...")
    return ((x-l.p1) ⋅ d) / (d ⋅ d)
end

Base.length(l::Segment{T}) where T = dist(l.p1, l.p2) 

# orthogonally project p onto the line induced by s
function project(p::Point{T}, l::Segment{S}) where {T, S}
    l.p1 ≉ l.p2 || error("segment too short $l")
    δ = delta(p, l)
    q = l.p1 + δ * (l.p2 - l.p1)
    return q
end

# assumes both segments live on the same infinite line
function overlapping_segment(l1::Segment{T}, l2::Segment{S}) where {T,S}
    ll, ls = length(l1) > length(l2) ? (l1, l2) : (l2, l1)
    δ₁ = delta(ls.p1, ll)
    δ₂ = delta(ls.p2, ll)
    start = max(0, min(δ₁, δ₂))
    stop  = min(1, max(δ₁, δ₂))

    if stop < start return nothing end
    
    dir = ll.p2 - ll.p1
    return Segment(ll.p1 + start*dir, ll.p1 + stop*dir)
end

function is_on_right_side(s::Segment{T1}, p::Point{T2}) where {T1, T2}
    d1 = s.p2 - s.p1
    d2 = p - s.p1
    v = d1.x * d2.y - d1.y * d2.x
    return v >= 0
end




function dist(p::Point{T}, l::Segment{S}) where {T,S}
    if l.p1 ≈ l.p2 return dist(p, 0.5*(l.p1 + l.p2)) end
    δ = delta(p, l)
    if 0 <= δ <= 1
        q = project(p, l)
        return dist(p, q)
    end
    return min(dist(p, l.p1), dist(p, l.p2))
end


function dist(s::Segment{T}, l::Segment{S}) where {T,S}
    i = s ∩ l
    if !isnothing(i) return 0.0 end
    ds = dist(s.p1, l), dist(s.p2, l), dist(l.p1, s), dist(l.p2, s)
    return min(ds...)
end



Base.:(==)(l1::Segment{T}, l2::Segment{S})    where {T,S} = (l1.p1 == l2.p1 && l1.p2 == l2.p2) || (l1.p1 == l2.p2 && l1.p2 == l2.p1)
Base.isapprox(l1::Segment{T}, l2::Segment{S}) where {T,S} = (l1.p1 ≈  l2.p1 && l1.p2 ≈  l2.p2) || (l1.p1 ≈  l2.p2 && l1.p2 ≈  l2.p1)



rotate(l::Segment{T}, θ) where T = Segment(rotate(l.p1, θ), rotate(l.p2, θ))
translate(l::Segment{T}, dx, dy)  where T = Segment(translate(l.p1, dx, dy), translate(l.p2, dx, dy))
scale(l::Segment{T}, sx, sy) where T = Segment(scale(l.p1, sx, sy), scale(l.p2, sx, sy))



align(s::Segment{T}) where T = Segment(align(s.p1), align(s.p2))

function simplify(s::Segment{T}) where T
    if s.p1 ≈ s.p2
        return 0.5(s.p1 + s.p2)
    end
    return s
end



Base.in(p::Point{T}, l::Segment{S}) where {T,S} = dist(p, l) < EPS


function Base.intersect(l1::Segment{T}, l2::Segment{S}) where {T,S} 
    i = intersect(l1, Line(l2))
    if i isa Point && i ∈ l2
        return i
    elseif i isa Segment
        return overlapping_segment(l1, l2)
    end
    return nothing
end



