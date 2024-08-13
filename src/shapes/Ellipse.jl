

Ellipse(x, y, rx, ry, θ=0.0) = Ellipse(Point(x, y), rx, ry, θ)
Ellipse(p::Point{T}, rx, ry, θ=0.0) where T = Ellipse{T}(p, Float64(rx), Float64(ry), Float64(θ))

# p1 and p2 points at the end of axes of the ellipse
function Ellipse(center::Point{T}, p1::Point{S}, p2::Point{V}) where {V, S, T}
    rx = dist(p1, center)
    ry = dist(p2, center)
    θ = atan(p1.y - center.y, p1.x - center.x)
    return Ellipse(center, rx, ry, θ)
end


# every point p on ellipse satisfies dist(p, f1) + dist(p, f2) = 2a
function Ellipse(f1::Point{T}, f2::Point{S}, a) where {T, S}
    rx = a
    d = 0.5*dist(f1, f2)
    a >= d || error("focus points too far apart, or 'a' too small")
    ry = sqrt(a*a - d*d)
    l = f2 - f1
    θ = atan(l.y, l.x)
    p = 0.5*(f1 + f2)
    return Ellipse(p, rx, ry, θ)
end

Base.:(+)(e::Ellipse{T}, p::Point{S}) where {S, T} = Ellipse(e.center + p, e.radius_x, e.radius_y, e.θ)
Base.:(-)(e::Ellipse{T}, p::Point{S}) where {S, T} = e + (-p)
Base.:(*)(s, e::Ellipse{T}) where T = Ellipse(s * e.center, s * e.radius_x, s * e.radius_y, e.θ)

# at what point is the derivative of the centered ellipse function equal to d
function derivative_equals(d, rx, ry)
    x = d * rx / sqrt(ry^2/rx^2 + d^2)
    return Point(x, ry*sqrt(max(0, 1-x^2/rx^2)))
end

function axes(e::Ellipse{T}) where T
    if e.radius_y > e.radius_x
        e = Ellipse(e.center, e.radius_y, e.radius_x, e.θ + π/2)
    end
    major = Segment(e.radius_x, 0, -e.radius_x, 0)
    minor = Segment(0, e.radius_y, 0, -e.radius_y)
    major = rotate(major, e.θ)
    minor = rotate(minor, e.θ)
    return major + e.center, minor + e.center
end

let 
    global function dist(p::Point{T}, e::Ellipse{S}) where {T, S}
        p1 = rotate(p - e.center, -e.θ)
        p2 = Point(abs(p1.x), abs(p1.y)) # point in first quadrant
        if e.radius_y > e.radius_x
            rx, ry = e.radius_y, e.radius_x
            p2 = Point(p2.y, p2.x)
        else
            rx, ry = e.radius_x, e.radius_y
        end
        (rx >= ry > 0 && p2.x >= 0 && p2.y >= 0) || error("preconditions not met D:")
        closest = closest_point_to_ellipse(rx, ry, p2)
        d = dist(closest, p2)
        if p ∈ e
            return -d
        end
        return d
    end

# https://www.geometrictools.com/Documentation/DistancePointEllipseEllipsoid.pdf
    function get_root(r0, z0, z1, g)
        n0 = r0*z0
        s0 = z1 - 1
        s1 = g < 0 ? 0 : sqrt(n0*n0+z1*z1) - 1
        s = 0
        for i = 0:100
            s = 0.5*(s0 + s1)
            rt0 = n0/(s + r0)
            rt1 = z1/(s + 1)
            g = rt0*rt0 + rt1*rt1 - 1
            if g+1 ≈ 1
                # println("3nr iterations: $i")
                break
            end
            if g > 0
                s0 = s
            elseif g < 0
                s1 = s
            end
        end
        return s
    end
    # rx >= ry > 0, p.x >= 0, p.y >= 0
    function closest_point_to_ellipse(rx, ry, p) # aligned ellipse with radii rx and ry, return closest point on ellipse to p
        y0, y1 = p.x, p.y
        e0, e1 = rx, ry
        if y1 > 0
            if y0 > 0
                z0 = y0/e0
                z1 = y1/e1
                g = z0*z0+z1*z1-1
                if g == 0
                    return Point(y0, y1)
                end
                r0 = e0*e0/(e1*e1)
                s̄ = get_root(r0, z0, z1, g)
                x0 = (r0*y0)/(s̄ + r0)
                x1 = y1 / (s̄ + 1)
                return Point(x0, x1)
            else # y0 == 0
                return Point(0, e1)
            end
        else # y1 == 0
            A = e0*y0
            B = (e0*e0 - e1*e1)
            if A < B
                c = A/B
                x0 = c*e0
                x1 = e1*sqrt(1-c*c)
                return Point(x0, x1)
            else
                return Point(e0, 0)
            end
        end
    end
end

function Base.:(==)(e1::Ellipse{T}, e2::Ellipse{S}) where {T, S}
    if e1.center != e2.center
        return false
    end
    maj1, min1 = axes(e1)
    maj2, min2 = axes(e2)
    return maj1 == maj2 && min1 == min2    
end
function Base.isapprox(e1::Ellipse{T}, e2::Ellipse{S}) where {T, S}
    if e1.center ≉ e2.center
        return false
    end
    maj1, min1 = axes(e1)
    maj2, min2 = axes(e2)
    return maj1 ≈ maj2 && min1 ≈ min2    
end

rotate(e::Ellipse{T}, θ) where T = Ellipse(rotate(e.center, θ), e.radius_x, e.radius_y, e.θ + θ)
translate(e::Ellipse{T}, dx, dy) where T = e + Point(dx, dy)
function scale(e::Ellipse{T}, sx, sy) where T
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
    ps = scale(pr, 1/e.radius_x, 1/e.radius_y)
    return ps ∈ Circle(Point(0,0), 1)
end


let
    function transform_back(i, e)
        s = scale(i, e.radius_x, e.radius_y)
        r = rotate(s, e.θ)
        return r + e.center
    end

    global function Base.intersect(e::Ellipse{T}, l::Line) where T
        lt = l - e.center
        lr = rotate(lt, -e.θ)
        ls = scale(lr, 1/e.radius_x, 1/e.radius_y)
        i = intersect_with_unit_circle(ls)
        if isnothing(i)
            return nothing
        end
        return transform_back(i, e) # function barrier trick
    end
end


