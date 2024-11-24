
function aligned_bounding_box(p::Point{T},    slack=0) where T
    return aligned_bounding_box(AxisRect(p, 0, 0), slack)
end

function aligned_bounding_box(s::Segment{T},  slack=0) where T
    t = min(s.p1.y, s.p2.y)
    l = min(s.p1.x, s.p2.x)
    r = max(s.p1.x, s.p2.x)
    b = max(s.p1.y, s.p2.y)
    return aligned_bounding_box(AxisRect(l, t, r-l, b-t), slack)
end

function aligned_bounding_box(a::AxisRect{T}, slack=0) where T
    if slack==0 return a end
    return AxisRect(a.tl - Point(slack, slack), a.w+2slack, a.h+2slack)
end

function aligned_bounding_box(c::Circle{T},   slack=0) where T
    return aligned_bounding_box(AxisRect(c.center, c.radius, c.radius, mode=:radius), slack)
end

function aligned_bounding_box(e::Ellipse{T},  slack=0) where T
    theta = (e.θ + 2π) % (π/2)
    if theta == 0
        if e.θ == 0.0 || e.θ == -π
            return bounding_box(AxisRect(e.center, e.radius.x, e.radius.y, mode=:radius), slack)
        else
            return bounding_box(AxisRect(e.center, e.radius.y, e.radius.x, mode=:radius), slack)
        end
    end
    angles = (theta + π/2, theta)
    derivatives = tan.(angles)
    ps = rotate.(derivative_equals.(derivatives, e.radius.x, e.radius.y), e.θ)
    bps = e.center + ps[1], e.center - ps[1], e.center + ps[2], e.center - ps[2]
    tl = Point(min(bps[1].x, bps[2].x, bps[3].x, bps[4].x), min(bps[1].y, bps[2].y, bps[3].y, bps[4].y))
    br = Point(max(bps[1].x, bps[2].x, bps[3].x, bps[4].x), max(bps[1].y, bps[2].y, bps[3].y, bps[4].y))
    return bounding_box(AxisRect(tl, br.x - tl.x, br.y - tl.y), slack)
end

function aligned_bounding_box(p::AbstractPolygon{T}, slack=0) where T
    ps = points(p)
    t = minimum(p.y for p in ps)
    l = minimum(p.x for p in ps)
    r = maximum(p.x for p in ps)
    b = maximum(p.y for p in ps)
    return aligned_bounding_box(AxisRect(l, t, r-l, b-t), slack)
end




bounding_box(s::AbstractShape{T}, slack=0) where T = aligned_bounding_box(s, slack)

function bounding_box(r::Rect{T}, slack=0) where T
    if slack == 0 return r end
    a = rotate(r, -r.θ)
    return rotate(aligned_bounding_box(AxisRect(a.tl, a.w, a.h), slack), r.θ)
end

function bounding_box(s::Segment{T}, slack=0) where T
    return bounding_box(Rect(0.5(s.p1 + s.p2), length(s), 0, angle(s.p2 - s.p1)), slack)
end

function bounding_box(e::Ellipse{T}, slack=0) where T
    return bounding_box(Rect(e.center, e.radius.x, e.radius.y, e.θ, mode=:radius), slack)
end


