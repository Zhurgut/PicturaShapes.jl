

struct Segment{T} <: AbstractShape{T}
    p1::Point{T}
    p2::Point{T}
end



function Segment(p1::Point{T}, p2::Point{S}) where {T, S}
    R = promote_type(T, S)
    return Segment{R}(Point{R}(p1), Point{R}(p2))
end

Segment(x1, y1, x2, y2) = Segment(Point(x1, y1), Point(x2, y2))
Segment(p::Point, x, y) = Segment(p, Point(x, y))
Segment(x, y, p::Point) = Segment(Point(x, y), p)


Base.convert(::Type{Segment{T}}, s::Segment) where T = Segment{T}(Point{T}(s.p1), Point{T}(s.p2))
Segment{T}(s) where T = convert(Segment{T}, s)





#               x
#               |
#               |
# +-------------+------------+
#l.p1           s          l.p2

# s = l.p1 + delta*(l.p2-.lp1), (s-x) ⊥ (l.p2-l.p1)
function delta(x::Point, l::Segment)
    if dist(l.p1, l.p2) == 0 error("cant compute delta, invalid segment (l.p1 == l.p2) $l") end
    d = l.p2-l.p1
    return ((x-l.p1) ⋅ d) / (d ⋅ d)
end

# orthogonally project p onto the line induced by s
function project(p::Point, l::Segment)
    δ = delta(p, l)
    q = l.p1 + δ * (l.p2 - l.p1)
    return q
end

# assumes both segments live on the same infinite line
function overlapping_segment(l1::Segment, l2::Segment)
    long, short = length(l1) > length(l2) ? (l1, l2) : (l2, l1)
    
    δ₁ = delta(short.p1, long)
    δ₂ = delta(short.p2, long)
    
    start = max(0, min(δ₁, δ₂))
    stop  = min(1, max(δ₁, δ₂))

    if stop < start return nothing end
    
    dir = long.p2 - long.p1
    return Segment(long.p1 + start*dir, long.p1 + stop*dir)
end

function is_on_right_side(s::Segment, p::Point)
    d1 = s.p2 - s.p1
    d2 = p - s.p1
    v = d1.x * d2.y - d1.y * d2.x
    return v >= 0
end




function sdf(p::Point, l::Segment)
    if l.p1 == l.p2 return dist(p, l.p1) end
    δ = delta(p, l)
    if 0 <= δ <= 1
        q = project(p, l)
        return dist(p, q)
    end
    return min(dist(p, l.p1), dist(p, l.p2))
end




Base.:(==)(l1::Segment, l2::Segment)    = (l1.p1 == l2.p1 && l1.p2 == l2.p2) || (l1.p1 == l2.p2 && l1.p2 == l2.p1)



rotate(l::Segment, θ)         = Segment(rotate(l.p1, θ), rotate(l.p2, θ))
translate(l::Segment, dx, dy) = Segment(translate(l.p1, dx, dy), translate(l.p2, dx, dy))
scale(l::Segment, sx, sy)     = Segment(scale(l.p1, sx, sy), scale(l.p2, sx, sy))


function simplify(s::Segment)
    if s.p1 == s.p2
        return s.p1
    end
    return nothing
end





