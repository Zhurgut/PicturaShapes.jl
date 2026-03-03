


# possible modes:
    # :corner
    # :center
    # :radius
struct AxisRect{T} <: AbstractQuatrilateral{T}
    tl::Point{T}
    w::T
    h::T
    
end


function AxisRect(p1::Point{S}, p2::Point{T}) where {S, T}
    w = abs(p1.x - p2.x)
    h = abs(p1.y - p2.y)
    tl = Point(min(p1.x, p2.x), min(p1.y, p2.y))
    F = promote_type(T, S)
    return AxisRect{F}(Point{F}(tl), F(w), F(h))
end



AxisRect(x, y, w, h; mode=:corner) = AxisRect(Point(x, y), w, h, mode)
AxisRect(p, w, h; mode=:corner)    = AxisRect(p, w, h, mode)


function AxisRect(p, w, h, mode::Symbol)
    if mode == :center
        # center = p
        tl = Point(p.x-0.5w, p.y-0.5h)
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




 

center(a::AxisRect) = Point(a.tl.x + 0.5*a.w, a.tl.y + 0.5*a.h)

function corners(a::AxisRect{T}, type=T) where T
    l, r, t, b = a.tl.x, a.tl.x + a.w, a.tl.y, a.tl.y + a.h
    tl = Point{type}(l, t)
    tr = Point{type}(r, t)
    bl = Point{type}(l, b)
    br = Point{type}(r, b)
    return (tl=tl, tr=tr, bl=bl, br=br)
end


function sides(a::AxisRect)
    c = corners(a)
    t = Segment(c.tl, c.tr)
    l = Segment(c.bl, c.tl)
    b = Segment(c.br, c.bl)
    r = Segment(c.tr, c.br)
    return (t, l, b, r)
end




function sdf(p::Point, a::AxisRect)
    c = corners(a)
    if p.x < a.tl.x
        if p.y < a.tl.y
            return dist(p, c.tl)
        elseif a.tl.y <= p.y <= a.tl.y + a.h
            return a.tl.x - p.x
        else
            return dist(p, c.bl)
        end
    elseif a.tl.x <= p.x <= a.tl.x + a.w
        if p.y < a.tl.y
            return a.tl.y - p.y
        elseif a.tl.y <= p.y <= a.tl.y + a.h
            return -min(p.x - a.tl.x, a.tl.x + a.w - p.x, p.y - a.tl.y, a.tl.y + a.h - p.y)
        else
            return p.y - (a.tl.y + a.h)
        end
    else
        if p.y < a.tl.y
            return dist(p, c.tr)
        elseif a.tl.y <= p.y <= a.tl.y + a.h
            return p.x - (a.tl.x + a.w)
        else
            return dist(p, c.br)
        end
    end 
end




function Base.:(==)(a1::AxisRect, a2::AxisRect)
    c1 = corners(a1)
    c2 = corners(a2)
    return c1.tl == c2.tl && c1.br == c2.br
end



rotate(a::AxisRect, θ)         = Rect(rotate(a.tl, θ), a.w, a.h, θ)
translate(a::AxisRect, dx, dy) = AxisRect(translate(a.tl, dx, dy), a.w, a.h)
scale(a::AxisRect, sx, sy)     = AxisRect(scale(a.tl, sx, sy), sx * a.w, sy * a.h)


function simplify(a::AxisRect)
    if a.h == 0 || a.w == 0
        return Segment(a.tl, a.tl + Point(a.w, a.h))
    end
    return nothing
end



function Base.in(p::Point, a::AxisRect)
    return a.tl.x <= p.x <= a.tl.x + a.w && a.tl.y <= p.y <= a.tl.y + a.h
end




