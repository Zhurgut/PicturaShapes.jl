
function Triangle(p1::Point{T1}, p2::Point{T2}, p3::Point{T3}) where {T1, T2, T3}
    T = promote_type(T1, T2, T3)
    return Triangle{T}(Point{T}(p1), Point{T}(p2), Point{T}(p3))
end

Triangle(x1, y1, p2::Point{T2}, p3::Point{T3}) where {T2, T3} = Triangle(Point(x1, y1), p2, p3)
Triangle(p1::Point{T1}, x2, y2, p3::Point{T3}) where {T1, T3} = Triangle(p1, Point(x2, y2), p3)
Triangle(p1::Point{T1}, p2::Point{T2}, x3, y3) where {T1, T2} = Triangle(p1, p2, Point(x3, y3))
Triangle(x1, y1, x2, y2, p3::Point{T3}) where T3 = Triangle(Point(x1, y1), Point(x2, y2), p3)
Triangle(x1, y1, p2::Point{T2}, x3, y3) where T2 = Triangle(Point(x1, y1), p2, Point(x3, y3))
Triangle(p1::Point{T1}, x2, y2, x3, y3) where T1 = Triangle(p1, Point(x2, y2), Point(x3, y3))
Triangle(x1, y1, x2, y2, x3, y3) = Triangle(Point(x1, y1), Point(x2, y2), Point(x3, y3))

Base.:(+)(t::Triangle{T}, p::Point{S}) where {S, T} = Triangle(t.p1 + p, t.p2 + p, t.p3 + p)
Base.:(-)(t::Triangle{T}, p::Point{S}) where {S, T} = t + (-p)
Base.:(*)(s, t::Triangle{T}) where T = Triangle(s * t.p1, s * t.p2, s * t.p3)

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

function dist(p::Point{T}, t::Triangle{S}) where {T, S}
    if p ∈ t
        s = sides(t)
        d = min(dist(p, s[1]), dist(p, s[2]), dist(p, s[3]))
        return -d
    end
    d1, d2, d3 = dist(p, t.p1), dist(p, t.p2), dist(p, t.p3)
    if d1 > d2
        if d1 > d3 # d1 biggest
            return dist(p, Segment(t.p2, t.p3))
        else # d3 biggest
            return dist(p, Segment(t.p1, t.p2))
        end
    else # d2 > d1
        if d2 > d3 # d2 biggest
            return dist(p, Segment(t.p1, t.p3))
        else # d3 biggest
            return dist(p, Segment(t.p1, t.p2))
        end
    end
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

rotate(t::Triangle{T}, θ) where T = Triangle(rotate(t.p1, θ), rotate(t.p2, θ), rotate(t.p3, θ))
translate(t::Triangle{T}, dx, dy) where T = t + Point(dx, dy)
scale(t::Triangle{T}, sx, sy) where T = Triangle(scale(t.p1, sx, sy), scale(t.p2, sx, sy), scale(t.p3, sx, sy))


function Base.in(p::Point{T}, t::Triangle{S}) where {T, S}
    α, β = barycentric_coordinates(t, p)
    return 0 <= α + β <= 1 && 0 <= α <= 1 && 0 <= β <= 1
end

function Base.intersect(t::Triangle{T}, l::Line) where T
    s = sides(t)
    i1 = s[1] ∩ l
    i2 = s[2] ∩ l
    i3 = s[3] ∩ l
    if i1 isa Segment
        return i1
    elseif i2 isa Segment
        return i2
    elseif i3 isa Segment
        return i3
    end

    if !isnothing(i1)
        if !isnothing(i2)
            return Segment(i1, i2)
        elseif !isnothing(i3)
            return Segment(i1, i3)
        end
        return i1
    end
    if !isnothing(i2)
        if !isnothing(i3)
            return Segment(i2, i3)
        end
        return i2
    end
    return nothing
end