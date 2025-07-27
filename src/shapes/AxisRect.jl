
# axis aligned rectangle
# w and h might be negative




center(a::AxisRect) = Point(a.tl.x + 0.5*a.w, a.tl.y + 0.5*a.h)

function corners(a::AxisRect)
    l, r, t, b = a.tl.x, a.tl.x + a.w, a.tl.y, a.tl.y + a.h
    tl = a.tl
    tr = Point(r, t)
    bl = Point(l, b)
    br = Point(r, b)
    return (tl=tl, tr=tr, bl=bl, br=br)
end

# sides go down or to the right
function sides(a::AxisRect)
    c = corners(a)
    t = Segment(c.tl, c.tr)
    l = Segment(c.bl, c.tl)
    b = Segment(c.br, c.bl)
    r = Segment(c.tr, c.br)
    return (t, l, b, r)
end




function dist(p::Point, a::AxisRect) # TODO can be optimized
    s = sides(a) 
    dst = min((x->dist(x, p)).(s)...)
    if p ∈ a
        return -dst
    end
    return dst
end




function Base.:(==)(a1::AxisRect, a2::AxisRect)
    c1 = corners(a1)
    c2 = corners(a2)
    return c1.tl == c2.tl && c1.br == c2.br
end
function Base.isapprox(a1::AxisRect{T}, a2::AxisRect{S}) where {T,S}
    c1 = corners(a1)
    c2 = corners(a2)
    return c1.tl ≈ c2.tl && c1.br ≈ c2.br
end 



rotate(a::AxisRect, θ)         = rect(rotate(a.tl, θ), a.w, a.h, θ) # this constructor will go to base constuctor, here we know w and h are positive
translate(a::AxisRect, dx, dy) = AxisRect(translate(a.tl, dx, dy), a.w, a.h)
scale(a::AxisRect, sx, sy)     = AxisRect(scale(a.tl, sx, sy), sx * a.w, sy * a.h)




function align(a::AxisRect)
    c = corners(a)
    AxisRect(align(c.tl), align(c.br))
end

function simplify(a::AxisRect)
    c = corners(a)
    if c.tl ≈ c.br return 0.5(c.tl + c.br) end

    t, r, b, l = c.tl.y, c.br.x, c.br.y, c.tl.x
    if abs(t - b) < PREC
        y = 0.5(t + b)
        return Segment(l, y, r, y)
    elseif abs(r - l) < PREC
        x = 0.5(r + l)
        return Segment(x, t, x, b)
    end

    return a
end



function Base.in(p::Point, a::AxisRect)
    c = corners(a)
    return c.tl.x <= p.x <= c.br.x && c.tl.y <= p.y <= c.br.y
end



function Base.intersect(a1::AxisRect, a2::AxisRect)
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


