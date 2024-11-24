


# a = radius.x, radius.y = 1, center=(0,0)
# function ellipse_approx(x, a)
#     x = x/a
#     return if x <= 0.8
#         -0.728125x^2 + 0.0825x + 1
#     else
#         -11.125x^2 + 17.025x - 5.9
#     end
# end

flip(e) = Ellipse(e.center, e.radius.y, e.radius.x, e.θ + π/2) # same ellipse as before, different parameters


ellipse_curve(x, rx, ry) = ry * sqrt(1 - (x/rx)^2)

function closest_point_to_parabola(pt, rx)
    # assuming p.x > 0 and p.y > 0, rx > 1, ry=1
    # approximate ellipse with 1-(x/rx)^2, find closest point on that curve (only considering first quadrant)

    if 0.5rx*pt.x - 0.5*rx^2 >= pt.y
        return Point(rx, 0)
    end

    p = rx^2 * (rx^2/2 + pt.y - 1)
    q = -0.5 * rx^4 * pt.x
    R = sqrt(max(0, q^2/4 + p^3/27))
    
    x = cbrt(-q/2 + R) + cbrt(-q/2 - R)
    
    return Point(x, 1 - (x/rx)^2)
end

function approximately_closest_point(pt, rx)
    # assuming p.x > 0 and p.y > 0, rx > 1, ry=1
    # approximate ellipse with 1-(x/rx)^2, use it to find point which is close to target point
    a = closest_point_to_parabola(pt, rx)
    if a.x == 0 return a end

    function intersecting_unit_circle(sa, spt) # which point on the line between a and b lies on the boundary of circle
        
        function quadratic(a, b, c, dir)
            return if dir
                (-b + sqrt(b^2 - 4*a*c)) / (2a)
            else
                (-b - sqrt(b^2 - 4*a*c)) / (2a)
            end
        end
    
        local a = sa.x
        e = spt.x - sa.x
        b = sa.y
        f = spt.y - sa.y
    
        δ = quadratic(f^2 + e^2, 2(b*f + a*e), a^2+b^2-1, f >= 0)

        return sa + δ*(spt-sa)
    end

    p = intersecting_unit_circle(scale(a, 1/rx, 1), scale(pt, 1/rx, 1))

    return scale(p, rx, 1)
end


# at what point is the derivative of the centered ellipse function equal to d
function derivative_equals(d, rx, ry)
    x = d * rx / sqrt(ry^2/rx^2 + d^2)
    return Point(x, ry*sqrt(max(0, 1-x^2/rx^2)))
end

function focal_points(e::Ellipse{T}) where T
    if e.radius.y > e.radius.x
        return focal_points(flip(e))
    end

    c = sqrt(1 - (e.radius.y/e.radius.x)^2)
    fps = rotate(Segment(-c, 0, c, 0), e.θ) + e.center

    return fps.p1, fps.p2, e.radius.x
end

function axes(e::Ellipse{T}) where T
    if e.radius.y > e.radius.x
        return axes(flip(e))
    end
    major = rotate(Segment(e.radius.x, 0, -e.radius.x, 0), e.θ)
    minor = rotate(Segment(0, e.radius.y, 0, -e.radius.y), e.θ)
    return major + e.center, minor + e.center
end

let
    global function dist(p::Point{T}, e::Ellipse{S}) where {T, S}
        if e.radius.y > e.radius.x
            return dist(p, flip(e))
        end

        std_pt = (1 / e.radius.y) * rotate(p - e.center, -e.θ)
        rx = e.radius.x / e.radius.y
        sx, sy = std_pt.x >= 0 ? 1 : -1, std_pt.y >= 0 ? 1 : -1
        std_pt = scale(std_pt, sx, sy)
        init = approximately_closest_point(std_pt, rx)

        closest_std = optimize(init, rx, std_pt)
        # closest = rotate(e.radius.y * scale(closest_std, sx, sy), e.θ) + e.center

        # display(closest)

        # d = dist(p, closest)
        d = e.radius.y * dist(std_pt, closest_std)
        return p ∈ e ? -d : d
    end

    function optimize(init, rx, p)
        ϕ = angle(init)
        θ = atan(rx*tan(ϕ))
        return newton(θ, rx, p)
    end

    function newton(ϕ, rx, p)
        L(ϕ) = 2p.x*rx*sin(ϕ) + (1-rx^2)*sin(2ϕ) - 2p.y*cos(ϕ)
        dL(ϕ) = 2p.x*rx*cos(ϕ) + 2(1-rx^2)*cos(2ϕ) + 2p.y*sin(ϕ)
        # X = ϕ-1:0.01:ϕ+1
        # println("phi = ", ϕ)
        # P = plot(X, [L.(X), dL.(X)])
        # scatter!(P, [ϕ], [L(ϕ)], markersize=1)
        # display(P)

        # X = 0:0.01:rx
        # P = plot(X, ellipse_curve.(X, rx, 1), ratio=:equal)
        # pt = scale(rotate(Point(1, 0), ϕ), rx, 1)
        # scatter!(P, [p.x, pt.x], [p.y, pt.y])
        # display(P)
        ϕ_next = ϕ - L(ϕ) / dL(ϕ)
        # println()
        # println(L(ϕ))
        # println("phi2 = ", ϕ_next)
        for i=1:20 # usually takes like 3-5 iterations 👌
            ϕ = ϕ_next
            ϕ_next = ϕ - L(ϕ) / dL(ϕ)
            # println(L(ϕ))
            if abs(ϕ - ϕ_next) < 1e-12 break end
        end
        return scale(rotate(Point(1, 0), ϕ_next), rx, 1)
    end

end

function Base.:(==)(e1::Ellipse{T}, e2::Ellipse{S}) where {T, S}
    if e1.center != e2.center return false end
    
    f11, f12, rx1 = focal_points(e1)
    f21, f22, rx2 = focal_points(e2)
    if rx1 != rx2 return false end

    s1 = Segment(f11, f12)
    s2 = Segment(f21, f22)
    return s1 == s2
end
function Base.isapprox(e1::Ellipse{T}, e2::Ellipse{S}) where {T, S}
    if e1.center ≉ e2.center return false end

    f11, f12, rx1 = focal_points(e1)
    f21, f22, rx2 = focal_points(e2)
    if abs(rx1 - rx2) > EPS return false end

    s1 = Segment(f11, f12)
    s2 = Segment(f21, f22)
    return s1 ≈ s2
end

rotate(e::Ellipse{T}, θ) where T = Ellipse(rotate(e.center, θ), e.radius.x, e.radius.y, e.θ + θ)
translate(e::Ellipse{T}, dx, dy) where T = Ellipse(e.center + Point(dx, dy), e.radius.x, e.radius.y, e.θ)
function scale(e::Ellipse{T}, sx, sy) where T
    if e.θ == 0
        return Ellipse(scale(e.center, sx, sy), sx*e.radius.x, sy*e.radius.y)
    end
    mj, mn = axes(e)
    mj, mn = mj-e.center, mn-e.center
    mj, mn = scale(mj, sx, sy), scale(mn, sx, sy)
    F = svd([mj.p1.x  mn.p1.x;
             mj.p1.y  mn.p1.y])
    p1, p2 = Point(F.U[1, 1], F.U[2, 1]), Point(F.U[1, 2], F.U[2, 2]) # singular vectors
    return Ellipse(Point(0,0), F.S[1]*p1, F.S[2]*p2) + scale(e.center, sx, sy)
end

function Base.in(p::Point{T}, e::Ellipse{S}) where {T, S}
    pr = rotate(p - e.center, -e.θ)
    ps = scale(pr, 1/e.radius.x, 1/e.radius.y)
    return ps ∈ Circle(Point(0,0), 1)
end

align(e::Ellipse) = Ellipse(align(e.center), rounded(e.radius.x), rounded(e.radius.y), e.θ)
function simplify(e::Ellipse)
    f1, f2, rx = focal_points(e)
    if f1 ≈ f2
        if rx < EPS
            return 0.5(f1 + f2)
        else
            return Circle(0.5(f1 + f2), 0.5(e.radius.x + e.radius.y))
        end
    end
    return e
end

