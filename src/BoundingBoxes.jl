
bounding_box(a::AxisRect{T}) where T = a

function bounding_box(a::AxisRect{T}, slack) where T
    if slack==0 return a end
    return AxisRect(a.tl - Point(slack, slack), a.w+2slack, a.h+2slack)
end

function bounding_box(p::Point{T}, slack=0) where T
    return bounding_box(AxisRect(p, 0, 0), slack)
end

function bounding_box(s::Segment{T}, slack=0) where T
    return bounding_box(AxisRect(s.p1, s.p2), slack)
end

function bounding_box(r::AbstractQuatrilateral{T}, slack=0) where T
    c = corners(r)
    tl = Point(min(c.tl.x, c.tr.x, c.bl.x, c.br.x), min(c.tl.y, c.tr.y, c.bl.y, c.br.y))
    br = Point(max(c.tl.x, c.tr.x, c.bl.x, c.br.x), max(c.tl.y, c.tr.y, c.bl.y, c.br.y))
    return bounding_box(AxisRect(tl, br.x - tl.x, br.y - tl.y), slack)
end

function bounding_box(c::Circle{T}, slack=0) where T
    return bounding_box(AxisRect(c.center, c.radius, c.radius, mode=:radius), slack)
end

function bounding_box(e::Ellipse{T}, slack=0) where T
    theta = (e.θ + 2π) % (π/2)
    if theta == 0
        if e.θ == 0.0 || e.θ == -π
            return bounding_box(AxisRect(e.center, e.radius_x, e.radius_y, mode=:radius), slack)
        else
            return bounding_box(AxisRect(e.center, e.radius_y, e.radius_x, mode=:radius), slack)
        end
    end
    angles = (theta + π/2, theta)
    derivatives = tan.(angles)
    ps = rotate.(derivative_equals.(derivatives, e.radius_x, e.radius_y), e.θ)
    bps = e.center + ps[1], e.center - ps[1], e.center + ps[2], e.center - ps[2]
    tl = Point(min(bps[1].x, bps[2].x, bps[3].x, bps[4].x), min(bps[1].y, bps[2].y, bps[3].y, bps[4].y))
    br = Point(max(bps[1].x, bps[2].x, bps[3].x, bps[4].x), max(bps[1].y, bps[2].y, bps[3].y, bps[4].y))
    return bounding_box(AxisRect(tl, br.x - tl.x, br.y - tl.y), slack)
end