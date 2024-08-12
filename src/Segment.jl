
# finite line


function Segment(p1::Point{T}, p2::Point{S}) where {T, S}
    R = promote_type(T, S)
    return Segment{R}(Point{R}(p1), Point{R}(p2))
end

Segment(x1, y1, x2, y2) = Segment(Point(x1, y1), Point(x2, y2))
Segment(p1::Point{T}, x2, y2) where T = Segment(p1, Point(x2, y2))
Segment(x1, y1, p2::Point{T}) where T = Segment(Point(x1, y1), p2)

Segment{T}(x1, y1, x2, y2) where T = Segment{T}(Point{T}(x1, y1), Point{T}(x2, y2))
Segment{T}(p1::Point{S}, x2, y2) where {T, S} = Segment{T}(Point{T}(p1), Point{T}(x2, y2))
Segment{T}(x1, y1, p2::Point{S}) where {T, S} = Segment{T}(Point{T}(x1, y1), Point{T}(p2))

Segment(l::Line) = (Circle(0,0, max(1, 2*l.dist)) ∩ l)::Segment{Float64}


Base.:(+)(l::Segment{N}, p::Point{T}) where {T,N} = Segment(l.p1 + p, l.p2 + p)
Base.:(-)(l::Segment{N}, p::Point{T}) where {T,N} = l + (-p)
Base.:(*)(r, l::Segment{T}) where T = Segment(r*l.p1, r*l.p2)




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

function dist(p::Point{T}, l::Segment{S}) where {T,S}
    if l.p1 == l.p2 return dist(p, l.p1) end
    δ = delta(p, l)
    if 0 <= δ <= 1
        s = l.p1 + δ*(l.p2-l.p1)
        return dist(p, s)
    end
    return min(dist(p, l.p1), dist(p, l.p2))
end



Base.:(==)(l1::Segment{T}, l2::Segment{S})    where {T,S} = (l1.p1 == l2.p1 && l1.p2 == l2.p2) || (l1.p1 == l2.p2 && l1.p2 == l2.p1)
Base.isapprox(l1::Segment{T}, l2::Segment{S}) where {T,S} = (l1.p1 ≈  l2.p1 && l1.p2 ≈  l2.p2) || (l1.p1 ≈  l2.p2 && l1.p2 ≈  l2.p1)



rotate(l::Segment{T}, θ) where T = Segment(rotate(l.p1, θ), rotate(l.p2, θ))
translate(l::Segment{T}, dx, dy)  where T = Segment(translate(l.p1, dx, dy), translate(l.p2, dx, dy))
scale(l::Segment{T}, sx, sy) where T = Segment(scale(l.p1, sx, sy), scale(l.p2, sx, sy))



align(s::Segment{T}) where T = Segment(align(s.p1), align(s.p2))



Base.in(p::Point{T}, l::Segment{S}) where {T,S} = dist(p, l) < EPS

function Base.intersect(p::Point{T}, l::Segment{S}) where {T,S}
    if p ∈ l 
        δ = delta(p, l)
        s = l.p1 + δ*(l.p2-l.p1)
        return s
    end
    return nothing
end

# assumes both segments live on the same infinite line
function overlapping_segment(l1::Segment{T}, l2::Segment{S}) where {T,S}
    δ₁ = delta(l2.p1, l1)
    δ₂ = delta(l2.p2, l1)
    δₛ = min(δ₁, δ₂)
    δₜ = max(δ₁, δ₂)
    p1,p2 = l1.p1, l1.p2
    if abs(δₛ-1) < EPS
        return p2
    elseif abs(δₜ) < EPS
        return p1
    elseif δₛ <= 1 || 0 <= δₜ
        δₛ = max(δₛ, 0)
        δₜ = min(δₜ, 1)
        return Segment((1-δₛ)p1 + δₛ*p2, (1-δₜ)p1 + δₜ*p2)
    end
    return nothing
end
