

function aligned_bounding_box(a::AxisRect, slack=0)
    @assert a.w >= 0 && a.h >= 0
    return AxisRect(a.tl - Point(slack, slack), a.w+2slack, a.h+2slack)
end


function aligned_bounding_box(p::Point, slack=0)
    return aligned_bounding_box(AxisRect(p, 0, 0), slack)
end


function aligned_bounding_box(s::Segment, slack=0)
    return aligned_bounding_box(AxisRect(s.p1, s.p2), slack)
end


function aligned_bounding_box(c::Circle, slack=0)
    return aligned_bounding_box(AxisRect(c.center, c.radius, c.radius, mode=:radius), slack)
end


function aligned_bounding_box(e::Ellipse,  slack=0)
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
    return bounding_box(AxisRect(tl, br), slack)
end

function aligned_bounding_box(p::AbstractPolygon, slack=0)
    ps = points(p)
    t = minimum(p.y for p in ps)
    l = minimum(p.x for p in ps)
    r = maximum(p.x for p in ps)
    b = maximum(p.y for p in ps)
    return aligned_bounding_box(AxisRect(l, t, r-l, b-t), slack)
end




bounding_box(s, slack=0) = aligned_bounding_box(s, slack)

function bounding_box(r::Rect, slack=0)
    a = rotate(r, -r.θ)
    return rotate(aligned_bounding_box(AxisRect(a.tl, a.w, a.h), slack), r.θ)
end

function bounding_box(s::Segment, slack=0)
    r = Rect(0.5(s.p1 + s.p2), sdf(s.p1, s.p2), 0, angle(s.p2 - s.p1), mode=:center)
    return bounding_box(r, slack)
end

function bounding_box(e::Ellipse, slack=0)
    return bounding_box(Rect(e.center, e.radius.x, e.radius.y, e.θ, mode=:radius), slack)
end

# function bounding_box(t::Triangle, slack=0)
#     len(x) = dist(x.p1, x.p2)
#     ss = sides(t)
#     ls = len.(ss)
#     i = argmax(ls)
#     p1 = ss[i].p1
#     p2 = ss[i].p2
#     if i == 1
#         p3 = t.p3
#     elseif i == 2
#         p3 = t.p1
#     else
#         p3 = t.p2
#     end
#     w = len(ss[i])
#     h = dist(ss[i], p3)
#     if !is_on_right_side(ss[i], p3)
#         h = -h
#     end
#     return bounding_box(Rect(p1, w, h, angle(p2 - p1)), slack)
# end


