

function Point(x::Real, y::Real)
    (xp, yp) = Base.promote(x, y)
    T = typeof(xp)
    Point{T}(xp, yp)
end

Base.convert(::Type{Point{T}}, p::Point{S}) where {T, S} = Point{T}(T(p.x), T(p.y))
Point{T}(p) where T = convert(Point{T}, p)



function Segment(p1::Point{T}, p2::Point{S}) where {T, S}
    R = promote_type(T, S)
    return Segment{R}(Point{R}(p1), Point{R}(p2))
end

Segment(x1, y1, x2, y2) = Segment(Point(x1, y1), Point(x2, y2))
Segment(p1::Point{T}, x2, y2) where T = Segment(p1, Point(x2, y2))

Segment(l::Line) = (Circle(0,0, max(1, 2*l.dist)) ∩ l)::Segment{Float64}

Base.convert(::Type{Segment{T}}, s::Segment{S}) where {T, S} = Segment{T}(Point{T}(s.p1), Point{T}(s.p2))
Segment{T}(s) where T = convert(Segment{T}, s)



Line(theta::Real, dist::Real) = Line(Float64(theta), Float64(dist))
Line(p, x2, y2)        = Line(Segment(p, x2, y2))
Line(x1, y1, x2, y2) = Line(Segment(x1, y1, x2, y2))
Line(l::Segment{T}) where T = Line(l.p1, l.p2)

function Line(p1::Point{T}, p2::Point{S}) where {T, S}
    p1 != p2 || error("cannot construct line from 2 points that are equal $p1 == $p2")
    q = project(Point(0,0), Segment(p1, p2))

    if q ≈ Point(0,0)
        p = p2 - p1
        pr = rotate(p, π/2)
        θ = angle(pr)
        return Line(θ, 0)
    end

    θ = angle(q)
    return Line(θ, magnitude(q))
    
end



# possible modes:
    # :corner
    # :center
    # :radius
    
AxisRect(x, y, w, h; mode=:corner) = AxisRect(Point(x, y), w, h, mode)
AxisRect(p, w, h; mode=:corner)    = AxisRect(p, w, h, mode)

function AxisRect(p1::Point{T1}, p2::Point{T2}) where {T1, T2}
    w = abs(p1.x - p2.x)
    h = abs(p1.y - p2.y)
    tl = Point(min(p1.x, p2.x), min(p1.y, p2.y))
    return AxisRect(tl, w, h)
end


function AxisRect(p::Point{F}, w, h, mode) where F
    if mode == :center
        tlc = Point(p.x-w/2, p.y-h/2)
        Tc = promote_type(typeof(tlc.x), typeof(w), typeof(h))
        return AxisRect{Tc}(tlc, w, h)
    elseif mode == :radius
        # center=p, xradius=w, yradius=h
        tlr = Point(p.x - w, p.y - h)
        Tr = promote_type(typeof(tlr.x), typeof(w), typeof(h))
        return AxisRect{Tr}(tlr, 2w, 2h)
    elseif mode == :corner # DEFAULT
        T = promote_type(F, typeof(w), typeof(h))
        return AxisRect{T}(p, w, h)
    else
        error("invalid rectmode '$mode', valid are :center, :radius, :corner")
    end
end






Rect(x, y, w, h, θ=0.0; mode=:corner) =  Rect(Point(x, y), w, h, θ, mode)
Rect(p::Point{T}, w, h, θ=0.0; mode=:corner) where T  = Rect(p, w, h, θ, mode)

function Rect(;tl::Union{Nothing, Point{T1}} = nothing, 
               tr::Union{Nothing, Point{T2}} = nothing, 
               bl::Union{Nothing, Point{T3}} = nothing, 
               br::Union{Nothing, Point{T4}} = nothing) where {T1, T2, T3, T4}
    nr_points = 4 - sum(isnothing.((tl, tr, bl, br)))

    nr_points >= 3 || error("not enough points, need at least 3")
    (bl != tl != tr && bl != br != tr && tl != br && tr != bl) || error("points coincide with each other, cannot construct rectangle")

    w, θ = if !isnothing(tl) && !isnothing(tr)
            dist(tl, tr), angle(tr - tl)
        else
            dist(bl, br), angle(br - bl)
        end
    h = if !isnothing(tl) && !isnothing(bl)
            dist(tl, bl)
        else
            dist(tr, br)
        end
    if isnothing(tl)
        tl = tr + (bl-br)
    end
    return Rect(tl, w, h, θ)
end


function Rect(p::Point{F}, w, h, θ, mode) where F
    if mode == :center
        tlc = rotate(Point(-w/2, -h/2), θ) + p
        Tc = promote_type(typeof(tlc.x), typeof(w), typeof(h))
        return Rect{Tc}(tlc, w, h, θ)
    elseif mode == :radius
        tlr = rotate(Point(-w, -h), θ) + p
        Tr = promote_type(typeof(tlr.x), typeof(w), typeof(h))
        return Rect{Tr}(tlr, 2w, 2h, θ)
    elseif mode == :corner # DEFAULT
        T = promote_type(F, typeof(w), typeof(h))
        return Rect{T}(p, w, h, θ)
    else
        error("invalid rectmode '$mode', valid are :center, :radius, :corner")
    end
end

