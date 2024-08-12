
# infinite line


Line(t::Real, d::Real) = Line(Float64(t), Float64(d))
Line(a, b, c)        = Line(Segment(a, b, c))
Line(x1, y1, x2, y2) = Line(Segment(x1, y1, x2, y2))
Line(l::Segment{T}) where T = Line(l.p1, l.p2)


function Line(p1::Point{T}, p2::Point{S}) where {T, S}
    p1 != p2 || error("cannot construct line from 2 points that are equal")
    δ = delta(Point(0,0), Segment(p1, p2))
    q = p1 + δ*(p2 - p1) # point on line closest to origin
    dst = magnitude(q)
    if q == Point(0,0)
        p = p1 != Point(0,0) ? rotate(p1, π/2) : rotate(p2, π/2)
        θ = atan(p.y, p.x)
    else
        θ = atan(q.y, q.x)
    end
    
    return Line(θ, dst)
end




function Base.:(+)(l::Line, p::Point{T}) where T
    c = Point(cos(l.θ), sin(l.θ))
    q = l.dist*c + p # point on the new line
    if norm(q) < EPS
        return Line(l.θ, 0)
    end
    s = orth_project(q, Line(l.θ + π/2, 0)) # characteristic point of new line
    dst = magnitude(s)
    if dst < EPS return Line(l.θ, 0) end
    θ = atan(s.y, s.x)
    return Line(abs(θ - l.θ) < 0.1 ? l.θ : l.θ + π, dst)
end

Base.:(-)(l::Line, p::Point{T}) where T = l + (-p)

function Base.:(*)(r, l::Line)
    if r >= 0
        return Line(l.θ, r*l.dist)
    else
        return Line(l.θ + π, r*l.dist)
    end
end








# orthogonally project the point onto the line
function orth_project(p::Point{T}, l::Line) where T
    c = Point(cos(l.θ), sin(l.θ))
    d = Segment(l.dist*c,  l.dist*c + Point(c.y, -c.x)) # segment along line
    δ = delta(p, d)
    return d.p1 + δ*(d.p2 - d.p1)
end



dist(p::Point{T}, l::Line) where T = dist(p, orth_project(p, l))


function Base.:(==)(l1::Line, l2::Line)
    if l1.dist == 0 && l2.dist == 0
        return mod(l1.θ, π) == mod(l2.θ, π)
    end
    return l1.θ == l2.θ && l1.dist == l2.dist
end
function Base.isapprox(l1::Line, l2::Line)
    if l1.dist < EPS && l2.dist < EPS
        return mod(l1.θ, π) == mod(l2.θ, π)
    end
    return l1.θ == l2.θ && abs(l1.dist - l2.dist) < EPS
end



rotate(l::Line, θ) = Line(l.θ + θ, l.dist)
translate(l::Line, dx, dy)  = l + Point(dx, dy)
scale(l::Line, sx, sy) = Line(scale(Segment(l), sx, sy))



Base.in(p::Point{T}, l::Line) where T = dist(p, l) < EPS

function Base.intersect(p::Point{T}, l::Line) where T
    if p ∈ l
        return orth_project(p, l)
    end
    return nothing
end

function Base.intersect(l1::Line, l2::Line)
    if l1 ≈ l2
        return Line(l1.θ, 0.5*(l1.dist+l2.dist))
    end

    if mod(l1.θ, π) == mod(l2.θ, π) # parallel, but not the same
        return nothing
    end

    if l1.dist < EPS && l2.dist < EPS # not parallel, intersecting at origin
        return Point(0,0)
    end

    if l2.dist == 0
        l1, l2 = l2, l1
        p = Point(0,0)
    elseif l1.dist != 0
        p = l1.dist*Point(cos(l1.θ), sin(l1.θ))
        l1 = Line(l1.θ, 0) # move both lines so that one goes through origin ( = l1 - p)
        l2 = l2 - p
    end
    # l1.dist == 0
    
    θ1 = l1.θ
    θ2 = l2.θ
    α = (θ1 - π/2) - θ2
    ak = l2.dist
    hyp = ak * sec(α) # ak / cos(α)
    std_hyp = Point(sin(θ1), -cos(θ1))

    return hyp*std_hyp + p
end







