
# axis aligned rectangle
# w and h might be negative




center(a::AxisRect{T}) where T = Point(a.tl.x + 0.5*a.w, a.tl.y + 0.5*a.h)

function corners(a::AxisRect{T}) where T
    x1, x2, y1, y2 = a.tl.x, a.tl.x + a.w, a.tl.y, a.tl.y + a.h
    l, r, t, b = min(x1, x2), max(x1, x2), min(y1, y2), max(y1, y2)
    tl = Point(l, t)
    tr = Point(r, t)
    bl = Point(l, b)
    br = Point(r, b)
    return (tl=tl, tr=tr, bl=bl, br=br)
end

# sides go down or to the right
function sides(a::AxisRect{T}) where T
    c = corners(a)
    t = Segment{T}(c.tl, c.tr)
    l = Segment{T}(c.bl, c.tl)
    b = Segment{T}(c.br, c.bl)
    r = Segment{T}(c.tr, c.br)
    return (t=t, l=l, b=b, r=r)
end




function dist(p::Point{T}, a::AxisRect{S}) where {T,S}
    s = sides(a)
    dst = min(dist.((s.t, s.l, s.b, s.r), p)...)
    if p ∈ a
        return -dst
    end
    return dst
end




function Base.:(==)(a1::AxisRect{T}, a2::AxisRect{S}) where {T,S}
    c1 = corners(a1)
    c2 = corners(a2)
    return c1.tl == c2.tl && c1.br == c2.br
end
function Base.isapprox(a1::AxisRect{T}, a2::AxisRect{S}) where {T,S}
    c1 = corners(a1)
    c2 = corners(a2)
    return c1.tl ≈ c2.tl && c1.br ≈ c2.br
end 



rotate(a::AxisRect{T}, θ) where T = Rect(rotate(a.tl, θ), a.w, a.h, θ)
shift(a::AxisRect{T}, dx, dy) where T = AxisRect(a.tl + Point(dx, dy), a.w, a.h)
scale(a::AxisRect{T}, sx, sy) where T = AxisRect(scale(a.tl, sx, sy), sx * a.w, sy * a.h)




function align(a::AxisRect{T}) where T
    c = corners(a)
    AxisRect(align(c.tl), align(c.br))
end

function simplify(a::AxisRect{T}) where T
    c = corners(a)
    if c.tl ≈ c.br return 0.5(c.tl + c.br) end

    t, r, b, l = c.tl.y, c.br.x, c.br.y, c.tl.x
    if abs(t - b) < EPS
        y = 0.5(t + b)
        return Segment(l, y, r, y)
    elseif abs(r - l) < EPS
        x = 0.5(r + l)
        return Segment(x, t, x, b)
    end

    return a
end



function Base.in(p::Point{T}, a::AxisRect{S}) where {T, S}
    c = corners(a)
    return c.tl.x <= p.x <= c.br.x && c.tl.y <= p.y <= c.br.y
end



function Base.intersect(a1::AxisRect{T}, a2::AxisRect{S}) where {T, S}
    c1, c2 = corners(a1), corners(a2)
    t1, r1, b1, l1 = c1.tl.y, c1.br.x, c1.br.y, c1.tl.x
    t2, r2, b2, l2 = c2.tl.y, c2.br.x, c2.br.y, c2.tl.x

    if b2 < t1 || b1 < t2 || r2 < l1 || r1 < l2
        return nothing
    end

    il = max(l1, l2)
    ir = min(r1, r2)
    it = max(t1, t2)
    ib = min(b1, b2)

    i_tl = Point(il, it)
    i_br = Point(ir, ib)

    if il == ir && it == ib
        return i_tl
    end

    if il == ir || it == ib
        return Segment(i_tl, i_br)
    end

    return AxisRect(i_tl, i_br)
end


