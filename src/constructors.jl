


"""
Point
"""
function Point(x::Real, y::Real)
    (xp, yp) = Base.promote(x, y)
    T = typeof(xp)
    Point{T}(xp, yp)
end

Base.convert(::Type{Point{T}}, p::Point) where T = Point{T}(T(p.x), T(p.y))
Point{T}(p) where T = convert(Point{T}, p)










"""
Segment
"""
function Segment(p1::Point{T}, p2::Point{S}) where {T, S}
    R = promote_type(T, S)
    return Segment{R}(Point{R}(p1), Point{R}(p2))
end

Segment(x1, y1, x2, y2) = Segment(Point(x1, y1), Point(x2, y2))
Segment(p::Point, x, y) = Segment(p, Point(x, y))
Segment(x, y, p::Point) = Segment(Point(x, y), p)

Segment(l::Line) = intersect_with_circle_at_origin(l, max(1, 2*l.dist))

Base.convert(::Type{Segment{T}}, s::Segment) where T = Segment{T}(Point{T}(s.p1), Point{T}(s.p2))
Segment{T}(s) where T = convert(Segment{T}, s)









"""
Line
"""
Line(theta, dist)    = Line(Float64(theta), Float64(dist))
Line(s::Segment)     = Line(s.p1, s.p2)
Line(a, b, c)        = Line(Segment(a, b, c))
Line(x1, y1, x2, y2) = Line(Segment(x1, y1, x2, y2))

function Line(p1::Point, p2::Point)
    p1 != p2 || error("cannot construct line from 2 points that are equal $p1 == $p2")

    q = project(Point(0,0), Segment(p1, p2))
    p = p2 - p1

    if q ≈ Point(0,0)
        pr = rotate(p, π/2)
        θ = angle(pr)
        return Line(θ, 0)
    end

    return Line(angle(q), magnitude(q))
    
end










"""
AxisRect
"""

# possible modes:
    # :corner
    # :center
    # :radius



AxisRect(x, y, w, h; mode=:corner) = AxisRect(Point(x, y), w, h, mode)
AxisRect(p, w, h; mode=:corner)    = AxisRect(p, w, h, mode)


function AxisRect(p::Point, w, h, mode)
    if mode == :center
        # center = p
        tl = Point(p.x-w/2, p.y-h/2)
        return AxisRect(tl, tl + Point(w, h))

    elseif mode == :radius
        # center = p
        # x_radius = w
        # y_radius = h
        tl = Point(p.x - w, p.y - h)
        return AxisRect(tl, tl + 2*Point(w, h))

    elseif mode == :corner # DEFAULT
        # top_left = p
        return AxisRect(p, p + Point(w, h))

    else
        error("invalid rectmode '$mode', valid are [:center, :radius, :corner]")
    end
end

Base.convert(::Type{AxisRect{T}}, s::AxisRect) where T = AxisRect{T}(Point{T}(s.tl), T(s.w), T(s.h))
AxisRect{T}(a) where T = convert(AxisRect{T}, a)









"""
Rect
"""

Rect(p::Point, w, h, θ; mode=:corner) = Rect(p, w, h, θ, mode)
Rect(x, y, w, h, θ; mode=:corner)     = Rect(Point(x, y), w, h, θ, mode)


function Rect(p::Point, w, h, θ, mode)
    r = if mode == :center
        AxisRect(Point(0,0), w, h, mode=:center)
    elseif mode == :radius
        AxisRect(Point(0,0), w, h, mode=:radius)
    elseif mode == :corner # DEFAULT
        AxisRect(Point(0,0), w, h, mode=:corner)
    else
        error("invalid rectmode '$mode', valid are :center, :radius, :corner")
    end

    return translate(rotate(r, θ), p.x, p.y)
end




function rect(tl::Point, tr::Point, bl::Point)
    w = dist(tl, tr)
    θ = if dist(tl, tr) > dist(tl, bl)
            angle(tr - tl)
        else
            angle(bl - tl) + π/2
        end
    h = dist(tl, bl)
    return rect(tl, w, h, θ)
end

function rect(tl::Point{T}, w::S, h::R, θ) where {T, S, R}
    @assert w >= 0 && h >= 0
    F = promote_type(T, S, R)
    return Rect{F}(Point{F}(tl), F(w), F(h), θ)
end


function Rect(;tl::Union{Nothing, Point} = nothing, 
               tr::Union{Nothing, Point} = nothing, 
               bl::Union{Nothing, Point} = nothing, 
               br::Union{Nothing, Point} = nothing)
    
    nr_points = 4 - sum(isnothing.((tl, tr, bl, br)))
    if nr_points < 3 error("not enough points, need at least 3") end

    

    if isnothing(tl)
        tl = tr + (bl - br)
    elseif isnothing(tr)
        tr = tl + (br - bl)
    elseif isnothing(bl)
        bl = br + (tr - tl)
    end

    return rect(tl, tr, bl)
end

Base.convert(::Type{Rect{T}}, s::Rect) where T = Rect{T}(Point{T}(s.tl), T(s.w), T(s.h), s.θ)
Rect{T}(r) where T = convert(Rect{T}, r)





"""
Circle
"""
function Circle(p::Point{T}, r::S) where {S,T}
    U = promote_type(S, T)
    return Circle{U}(Point{U}(p), U(r))
end
Circle(x, y, r) = Circle(Point(x, y), r)

Base.convert(::Type{Circle{T}}, s::Circle) where T = Circle{T}(Point{T}(s.center), T(s.radius))
Circle{T}(c) where T = convert(Circle{T}, c)









"""
Ellipse
"""
Ellipse(x, y, rx, ry, θ=0.0) = Ellipse(Point(x, y), rx, ry, θ)

function Ellipse(p::Point{T1}, rx::T2, ry::T3, θ=0.0) where {T1, T2, T3}
    T = promote_type(T1, T2, T3)
    Ellipse{T}(Point{T}(p), Point{T}(Point(rx, ry)), θ)
end


# p1 and p2 points at the end of axes of the ellipse
function Ellipse(center::Point, p1::Point, p2::Point)
    rx = dist(p1, center)
    ry = dist(p2, center)
    θ = angle(p1 - center)
    return Ellipse(center, rx, ry, θ)
end


# every point p on ellipse satisfies dist(p, f1) + dist(p, f2) = 2*rx
function Ellipse(f1::Point, f2::Point, rx)
    d = 0.5*dist(f1, f2)
    rx >= d || error("focus points too far apart, or 'rx' too small")
    ry = sqrt(rx*rx - d*d)
    θ = angle(f2 - f1)
    return Ellipse(0.5*(f1 + f2), rx, ry, θ)
end










"""
Triangle
"""
function Triangle(p1::Point{T1}, p2::Point{T2}, p3::Point{T3}) where {T1, T2, T3}
    T = promote_type(T1, T2, T3)
    return Triangle{T}(Point{T}(p1), Point{T}(p2), Point{T}(p3))
end

Triangle(x1, y1, x2, y2, x3, y3) = Triangle(Point(x1, y1), Point(x2, y2), Point(x3, y3))










"""
Quatrilateral
"""
function Quatrilateral(p1::Point{T1}, p2::Point{T2}, p3::Point{T3}, p4::Point{T4}) where {T1, T2, T3, T4}
    T = promote_type(T1, T2, T3, T4)
    return Quatrilateral{T}(Point{T}(p1), Point{T}(p2), Point{T}(p3), Point{T}(p4))
end

Quatrilateral(x1, y1, x2, y2, x3, y3, x4, y4) = Quatrilateral(Point(x1, y1), Point(x2, y2), Point(x3, y3), Point(x4, y4))





