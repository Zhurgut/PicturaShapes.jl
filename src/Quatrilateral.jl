# 4 sided polygon


function Quatrilateral(p1::Point{T1}, p2::Point{T2}, p3::Point{T3}, p4::Point{T4}) where {T1, T2, T3, T4}
    T = promote_type(T1, T2, T3, T4)
    return Quatrilateral{T}(Point{T}(p1), Point{T}(p2), Point{T}(p3), Point{T}(p4))
end

Quatrilateral(x1, y1, p2::Point{T2}, p3::Point{T3}, p4::Point{T4}) where {T2, T3, T4} = Quatrilateral(Point(x1, y1), p2, p3, p4)
Quatrilateral(p1::Point{T1}, x2, y2, p3::Point{T3}, p4::Point{T4}) where {T1, T3, T4} = Quatrilateral(p1, Point(x2, y2), p3, p4)
Quatrilateral(p1::Point{T1}, p2::Point{T2}, x3, y3, p4::Point{T4}) where {T1, T2, T4} = Quatrilateral(p1, p2, Point(x3, y3), p4)
Quatrilateral(p1::Point{T1}, p2::Point{T2}, p3::Point{T3}, x4, y4) where {T1, T2, T3} = Quatrilateral(p1, p2, p3, Point(x4, y4))
Quatrilateral(x1, y1, x2, y2, x3, y3, p4::Point{T4}) where T4 = Quatrilateral(Point(x1, y1), Point(x2, y2), Point(x3, y3), p4)
Quatrilateral(x1, y1, x2, y2, p3::Point{T3}, x4, y4) where T3 = Quatrilateral(Point(x1, y1), Point(x2, y2), p3, Point(x4, y4))
Quatrilateral(x1, y1, p2::Point{T2}, x3, y3, x4, y4) where T2 = Quatrilateral(Point(x1, y1), p2, Point(x3, y3), Point(x4, y4))
Quatrilateral(p1::Point{T1}, x2, y2, x3, y3, x4, y4) where T1 = Quatrilateral(p1, Point(x2, y2), Point(x3, y3), Point(x4, y4))
Quatrilateral(x1, y1, x2, y2, x3, y3, x4, y4) = Quatrilateral(Point(x1, y1), Point(x2, y2), Point(x3, y3), Point(x4, y4))

Base.:(+)(t::Quatrilateral{T}, p::Point{S}) where {S, T} = Quatrilateral(t.p1 + p, t.p2 + p, t.p3 + p, t.p4 + p)
Base.:(-)(t::Quatrilateral{T}, p::Point{S}) where {S, T} = t + (-p)
Base.:(*)(s, t::Quatrilateral{T}) where T = Quatrilateral(s * t.p1, s * t.p2, s * t.p3, s * t.p4)

corners(t::Quatrilateral{T}) where T = (tl=t.p1, tr=t.p2, bl=t.p4, br=t.p3)

function sides(t::Quatrilateral{T}) where T
    return (
        t=Segment(t.p1, t.p2),
        l=Segment(t.p1, t.p4),
        b=Segment(t.p4, t.p3),
        r=Segment(t.p2, t.p3)
    )
end


function dist(p::Point{T}, t::Quatrilateral{S}) where {T, S}
    t1 = Triangle(t.p1, t.p2, t.p3)
    t2 = Triangle(t.p1, t.p3, t.p4)
    if p ∈ t1 || p ∈ t2
        s = sides(t)
        d = min(dist(s.t, p), dist(s.r, p), dist(s.l, p), dist(s.b, p))
        return -d
    end
    return min(dist(t1, p), dist(t2, p))
end




function Base.:(==)(t1::Quatrilateral{T}, t2::Quatrilateral{S})    where {T,S}
    return  (t1.p1 == t2.p1 && t1.p2 == t2.p2 && t1.p3 == t2.p3 && t1.p4 == t2.p4) || 
            (t1.p1 == t2.p2 && t1.p2 == t2.p3 && t1.p3 == t2.p4 && t1.p4 == t2.p1) || 
            (t1.p1 == t2.p3 && t1.p2 == t2.p4 && t1.p3 == t2.p1 && t1.p4 == t2.p2) || 
            (t1.p1 == t2.p4 && t1.p2 == t2.p2 && t1.p3 == t2.p2 && t1.p4 == t2.p3) || 
            (t1.p1 == t2.p4 && t1.p2 == t2.p3 && t1.p3 == t2.p2 && t1.p4 == t2.p1) || 
            (t1.p1 == t2.p3 && t1.p2 == t2.p2 && t1.p3 == t2.p1 && t1.p4 == t2.p4) || 
            (t1.p1 == t2.p2 && t1.p2 == t2.p1 && t1.p3 == t2.p4 && t1.p4 == t2.p3) || 
            (t1.p1 == t2.p1 && t1.p2 == t2.p4 && t1.p3 == t2.p3 && t1.p4 == t2.p2)
end
function Base.isapprox(t1::Quatrilateral{T}, t2::Quatrilateral{S}) where {T,S}
    return  (t1.p1 ≈ t2.p1 && t1.p2 ≈ t2.p2 && t1.p3 ≈ t2.p3 && t1.p4 ≈ t2.p4) || 
            (t1.p1 ≈ t2.p2 && t1.p2 ≈ t2.p3 && t1.p3 ≈ t2.p4 && t1.p4 ≈ t2.p1) || 
            (t1.p1 ≈ t2.p3 && t1.p2 ≈ t2.p4 && t1.p3 ≈ t2.p1 && t1.p4 ≈ t2.p2) || 
            (t1.p1 ≈ t2.p4 && t1.p2 ≈ t2.p2 && t1.p3 ≈ t2.p2 && t1.p4 ≈ t2.p3) || 
            (t1.p1 ≈ t2.p4 && t1.p2 ≈ t2.p3 && t1.p3 ≈ t2.p2 && t1.p4 ≈ t2.p1) || 
            (t1.p1 ≈ t2.p3 && t1.p2 ≈ t2.p2 && t1.p3 ≈ t2.p1 && t1.p4 ≈ t2.p4) || 
            (t1.p1 ≈ t2.p2 && t1.p2 ≈ t2.p1 && t1.p3 ≈ t2.p4 && t1.p4 ≈ t2.p3) || 
            (t1.p1 ≈ t2.p1 && t1.p2 ≈ t2.p4 && t1.p3 ≈ t2.p3 && t1.p4 ≈ t2.p2)
end

rotate(t::Quatrilateral{T}, θ) where T = Quatrilateral(rotate(t.p1, θ), rotate(t.p2, θ), rotate(t.p3, θ), rotate(t.p4, θ))
translate(t::Quatrilateral{T}, dx, dy) where T = t + Point(dx, dy)
scale(t::Quatrilateral{T}, sx, sy) where T = Quatrilateral(scale(t.p1, sx, sy), scale(t.p2, sx, sy), scale(t.p3, sx, sy), scale(t.p4, sx, sy))


function Base.in(p::Point{T}, t::Quatrilateral{S}) where {T, S}
    t1 = Triangle(t.p1, t.p2, t.p3)
    t2 = Triangle(t.p1, t.p3, t.p4)
    return p ∈ t1 || p ∈ t2
end
