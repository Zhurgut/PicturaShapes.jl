
# axis aligned rectangle

# possible modes:
    # :corner
    # :center
    # :radius

function AxisRect(p::Point{F}, w, h, mode) where F
    if mode == :center
        tlc = Point(p.x-w/2, p.y-h/2)
        Tc = promote_type(typeof(tl.x), typeof(w), typeof(h))
        return AxisRect{Tc}(tlc, w, h)
    elseif mode == :radius
        # center=p, xradius=w, yradius=h
        tlr = Point(p.x - w, p.y - h)
        Tr = promote_type(typeof(tlr.x), typeof(w), typeof(h))
        return AxisRect{Tr}(tlr, 2w, 2h)
    else # mode == corner
        T = promote_type(F, typeof(w), typeof(h))
        return AxisRect{T}(p, w, h)
    end
end

AxisRect(x, y, w, h; mode=:corner) = AxisRect(Point(x, y), w, h, mode)
AxisRect(p, w, h; mode=:corner) = AxisRect(p, w, h, mode)

function AxisRect(p1::Point{T1}, p2::Point{T2}) where {T1, T2}
    w = abs(p1.x - p2.x)
    h = abs(p1.y - p2.y)
    tl = Point(min(p1.x, p2.x), min(p1.y, p2.y))
    return AxisRect(tl, w, h)
end

AxisRect{T}(a::AxisRect{S}) where {T,S} = AxisRect{T}(Point{T}(a.tl), T(a.w), T(a.h))




Base.:(+)(a::AxisRect{T}, p::Point{S}) where {S, T} = AxisRect(a.tl + p, a.w, a.h)
Base.:(-)(a::AxisRect{T}, p::Point{S}) where {S, T} = a + (-p)
Base.:(*)(r, a::AxisRect{T}) where T = AxisRect(r*a.tl, r*a.w, r*a.h)


center(a::AxisRect{T}) where T = Point(a.tl.x + 0.5*a.w, a.tl.y + 0.5*a.h)

function corners(a::AxisRect{T}) where T
    tl = a.tl
    tr = Point(a.tl.x + a.w, a.tl.y)
    bl = Point(a.tl.x, a.tl.y + a.h)
    br = Point(a.tl.x + a.w, a.tl.y + a.h)
    return (tl=tl, tr=tr, bl=bl, br=br)
end

# sides go down or to the right
function sides(a::AxisRect{T}) where T
    c = corners(a)
    t = Segment{T}(c.tl, c.tr)
    l = Segment{T}(c.tl, c.bl)
    b = Segment{T}(c.bl, c.br)
    r = Segment{T}(c.tr, c.br)
    return (t=t, l=l, b=b, r=r)
end




function dist(p::Point{T}, a::AxisRect{S}) where {T,S}
    c = corners(a)

    # on the left
    if p.x <= c.tl.x 
        if p.y <= c.tl.y
            return dist(p, c.tl)
        elseif c.tl.y < p.y < c.bl.y
            return c.tl.x - p.x
        elseif c.bl.y <= p.y
            return dist(p, c.bl)
        end
    end

    # on the right
    if c.tr.x <= p.x 
        if p.y <= c.tl.y
            return dist(p, c.tr)
        elseif c.tl.y < p.y < c.bl.y
            return p.x - c.tr.x
        elseif c.bl.y <= p.y
            return dist(p, c.br)
        end
    end

    # c.tl.x < p.x < c.tr.x
    if p.y <= c.tl.y
        return c.tl.y - p.y
    elseif c.bl.y <= p.y
        return p.y - c.bl.y
    end

    # inside the rect
    dx1 = p.x - c.tl.x
    dx2 = c.tr.x - p.x
    dy1 = p.y - c.tl.y
    dy2 = c.bl.y - p.y
    return -min(dx1, dx2, dy1, dy2)

    # s = sides(a)
    # ds = dist.((s.t, s.l, s.b, s.r), p)
    # if a.tl.x <= p.x <= a.tl.x + a.w && a.tl.y <= p.y <= a.tl.y + a.h # inside
    #     return -min(ds...)
    # end
    # return min(ds...)

end




Base.:(==)(a1::AxisRect{T}, a2::AxisRect{S}) where {T,S} = a1.tl == a2.tl && a1.w == a2.w && a1.h == a2.h
Base.isapprox(a1::AxisRect{T}, a2::AxisRect{S}) where {T,S} = a1.tl ≈ a2.tl && abs(a1.w - a2.w) < EPS && abs(a1.h - a2.h) < EPS



function rotate(a::AxisRect{T}, θ) where T
    if θ == 0.0
        return a
    end
    return Rect(rotate(a.tl, θ), a.w, a.h, θ)
end
translate(a::AxisRect{T}, dx, dy) where T = AxisRect(a.tl + Point(dx, dy), a.w, a.h)
scale(a::AxisRect{T}, sx, sy) where T = AxisRect(scale(a.tl, sx, sy), sx * a.w, sy * a.h)




align(a::AxisRect{T}) where T = AxisRect(align(a.tl), round(a.w, DIGITS), round(a.h, DIGITS))




function Base.in(p::Point{T}, a::AxisRect{S}) where {T, S}
    tl = a.tl
    br = Point(a.tl.x + a.w, a.tl.y + a.h)
    return tl.x <= p.x <= br.x && tl.y <= p.y <= br.y
end

Base.intersect(p::Point{T}, a::AxisRect{S}) where {T, S} = p ∈ a ? p : nothing

function Base.intersect(a1::AxisRect{T}, a2::AxisRect{S}) where {T, S}
    if  a1.tl.x + a1.w < a2.tl.x || a2.tl.x + a2.w < a1.tl.x ||
        a1.tl.y + a1.h < a2.tl.y || a2.tl.y + a2.h < a1.tl.y
        return nothing
    end

    br1 = Point(a1.tl.x + a1.w, a1.tl.y + a1.h)
    br2 = Point(a2.tl.x + a2.w, a2.tl.y + a2.h)
    tl = Point(max(a1.tl.x, a2.tl.x), max(a1.tl.y, a2.tl.y))
    br = Point(min(br1.x, br2.x), min(br1.y, br2.y))

    if abs(tl.x - br.x) < EPS
        x = 0.5(tl.x + br.x)
        if abs(tl.y - br.y) < EPS
            y = 0.5(tl.y + br.y)
            return Point(x, y)
        end
        return Segment(x, tl.y, x, br.y)
    end
    if abs(tl.y - br.y) < EPS
        y = 0.5(tl.y + br.y)
        return Segment(tl.x, y, br.x, y)
    end

    return AxisRect(tl, br.x - tl.x, br.y - tl.y)
end


