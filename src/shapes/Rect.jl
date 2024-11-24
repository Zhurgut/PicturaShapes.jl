


function center(r::Rect{T}) where T
    c = corners(r)
    return 0.5(c.tl + c.br)
end

function corners(r::Rect{T}) where T
    c = corners(AxisRect(Point(0,0), r.w, r.h))
    d = rotate.((c.tr, c.bl, c.br), r.θ)
    return (tl=r.tl, tr=d[1] + r.tl, bl=d[2] + r.tl, br=d[3] + r.tl)
end

function sides(r::Rect{T}) where T
    c = corners(r)
    t = Segment(c.tl, c.tr)
    l = Segment(c.bl, c.tl)
    b = Segment(c.br, c.bl)
    r = Segment(c.tr, c.br)
    return (t, l, b, r)
end



function dist(p::Point{T}, r::Rect{S}) where {T,S}
    p2 = rotate(p - r.tl, -r.θ)
    return dist(p2, AxisRect(Point(0,0), r.w, r.h))
end



rotate(r::Rect{T}, θ) where T = Rect(rotate(r.tl, θ), r.w, r.h, r.θ + θ) # around origin, the whole thing!
translate(r::Rect{T}, dx, dy) where T = Rect(r.tl + Point(dx, dy), r.w, r.h, r.θ)
function scale(r::Rect{T}, sx, sy) where T
    c = corners(r)
    if sx == sy
        Rect(tl=scale(c.tl, sx, sy), tr=scale(c.tr, sx, sy), bl=scale(c.bl, sx, sy))
    end
    return Quatrilateral(scale(c.tl, sx, sy), scale(c.tr, sx, sy), scale(c.br, sx, sy), scale(c.bl, sx, sy))
end



function align(r::Rect{T}) where T
    d = diagonals(r)
    Rect(tl=align(d[1].p1), tr=align(d[2].p1), br=align(d[1].p2)) # ?
end

function simplify(r::Rect{T}) where T
    θ_aligned_to_axis = round(2r.θ/π)*π/2
    r_aligned = Rect(r.tl, r.w, r.h, θ_aligned_to_axis)
    if !(r_aligned ≈ r) # kinda expensive, but the only way to be sure
        return r
    end
    # r is pretty much a axis aligned rectangle
    c = corners(r)
    x1, x2, y1, y2 = c.tl.x, c.br.x, c.tl.y, c.br.y
    l, r, t, b = min(x1, x2), max(x1, x2), min(y1, y2), max(y1, y2)
    tl = Point(l, t)
    w = r - l
    h = b - t
    return simplify(AxisRect(tl, w, h))
end




function Base.in(p::Point{T}, r::Rect{S}) where {T, S}
    p2 = rotate(p - r.tl, -r.θ)
    return p2 ∈ AxisRect(Point(0,0), r.w, r.h)
end





