


function center(r::Rect)
    c = corners(r)
    return 0.5(c.tl + c.br)
end

function corners(r::Rect)
    c = corners(AxisRect(Point(0,0), r.w, r.h))
    d = rotate.((c.tr, c.bl, c.br), r.θ)
    return (tl=r.tl, tr=r.tl + d[1], bl=r.tl + d[2], br=r.tl + d[3])
end

function sides(r::Rect)
    c = corners(r)
    t = Segment(c.tl, c.tr)
    l = Segment(c.bl, c.tl)
    b = Segment(c.br, c.bl)
    r = Segment(c.tr, c.br)
    return (t, l, b, r)
end



function dist(p::Point, r::Rect)
    p2 = rotate(p - r.tl, -r.θ)
    return dist(p2, AxisRect(Point(0,0), r.w, r.h))
end



rotate(r::Rect, θ)         = rect(rotate(r.tl, θ), r.w, r.h, r.θ + θ) # around origin, the whole thing!
translate(r::Rect, dx, dy) = rect(r.tl + Point(dx, dy), r.w, r.h, r.θ)
function scale(r::Rect, sx, sy)
    c = corners(r)
    return Quatrilateral(scale(c.tl, sx, sy), scale(c.tr, sx, sy), scale(c.br, sx, sy), scale(c.bl, sx, sy))
end



align(r::Rect) = rect(align(r.tl), align_round(r.w), align_round(r.h), r.θ)


function simplify(r::Rect)
    a = AxisRect(Point(0,0), r.w, r.h)
    simple_a = simplify(a)
    if a != simple_a
        return simplify(rotate(simple_a, r.θ) + r.tl)
    end
    return r
end




function Base.in(p::Point, r::Rect)
    p2 = rotate(p - r.tl, -r.θ)
    return p2 ∈ AxisRect(Point(0,0), r.w, r.h)
end





