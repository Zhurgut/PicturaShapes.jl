

struct Ellipse{T} <: AbstractShape{T}
    center::Point{T}
    radius::Point{T}
    θ::Float64
end



Ellipse(x, y, rx, ry, θ=0.0) = Ellipse(Point(x, y), rx, ry, θ)

function Ellipse(p::Point{T1}, rx::T2, ry::T3, θ=0.0) where {T1, T2 <: Real, T3 <: Real}
    T = promote_type(T1, T2, T3)
    if rx >= ry
        return Ellipse{T}(Point{T}(p), Point{T}(Point(abs(rx), abs(ry))), Float64(mod2pi(θ)))
    else
        return Ellipse{T}(Point{T}(p), Point{T}(Point(abs(ry), abs(rx))), Float64(mod2pi(θ) + 0.5π))
    end
end


# p1 and p2 points at the end of axes of the ellipse
function Ellipse(center::Point, p1::Point, p2::Point)
    rx = sdf(p1, center)
    ry = sdf(p2, center)
    θ = angle(p1 - center)
    return Ellipse(center, rx, ry, θ)
end


# every point p on ellipse satisfies dist(p, f1) + dist(p, f2) = 2*rx
function Ellipse(f1::Point, f2::Point, rx::Real)
    d = 0.5*sdf(f1, f2)
    rx >= d || error("focus points too far apart, or 'rx' too small")
    ry = sqrt(rx*rx - d*d)
    θ = angle(f2 - f1)
    return Ellipse(0.5*(f1 + f2), rx, ry, θ)
end

Base.convert(::Type{Ellipse{T}}, e::Ellipse) where T = Ellipse{T}(Point{T}(e.center), Point{T}(e.radius), e.θ)
Ellipse{T}(e) where T = convert(Ellipse{T}, e)

flip(e) = Ellipse(e.center, e.radius.y, e.radius.x, e.θ + π/2) # same ellipse as before, different parameters



function focal_points(e::Ellipse)
    c = sqrt(e.radius.x^2 - e.radius.y^2)
    fps = rotate(Segment(-c, 0, c, 0), e.θ) + e.center

    return fps.p1, fps.p2, e.radius.x
end


function axes(e::Ellipse{T}) where T
    major = rotate(Segment(e.radius.x, 0, -e.radius.x, 0), e.θ)
    minor = rotate(Segment(0, e.radius.y, 0, -e.radius.y), e.θ)
    return major + e.center, minor + e.center
end





function sdf(p_in::Point, e::Ellipse)
    mix(p1, p2, z) = (1-z)*p1 + z*p2
    distance(x1, y1, x2, y2) = sqrt((x1 - x2)^2 + (y1 - y2)^2)
    parabola(a, b, c, x) = a*x^2 + b*x + c
    solve_quadratic(a, b, c; ϵ=0) = (-b - sqrt(max(0, b^2 - 4*a*c))) / (2a+ϵ)

    p = p_in - e.center

    p = Point(abs(p.x), abs(p.y)) * (1 / e.radius.y)

    r = e.radius.x / e.radius.y

    parabola_peak_x = (r^2 - 1) * (1 / r)

    A = -r / (parabola_peak_x + 1e-6)
    B = 2r
    C = 1 - r^2

    a = -A
    b = 2*A*p.x
    c = B*p.x + C - p.y

    tx = solve_quadratic(a, b, c)
    tx = clamp(tx, 0, parabola_peak_x - 1e-4)
    ty = parabola(A, B, C, tx)

    p_shift = Point(p.x * (1 / r), p.y)
    t_shift = Point(tx * (1 / r), ty)
    dif = t_shift - p_shift

    a2 = dot(dif, dif)
    b2 = 2*dot(dif, p_shift)
    c2 = dot(p_shift, p_shift) - 1

    z = solve_quadratic(a2, b2, c2, ϵ=1e-20)

    # the point between t_shift and p_shift on the unit circle
    c = mix(p_shift, t_shift, z)

    # the point between t and p on the ellipse
    b = Point(r * c.x, c.y)

    return sign(c2) * radius.y * sdf(b, p)

end


function Base.:(==)(e1::Ellipse, e2::Ellipse)
    if e1.center != e2.center return false end
    
    f11, f12, rx1 = focal_points(e1)
    f21, f22, rx2 = focal_points(e2)
    if rx1 != rx2 return false end

    s1 = Segment(f11, f12)
    s2 = Segment(f21, f22)
    return s1 == s2
end


rotate(e::Ellipse, θ) = Ellipse(rotate(e.center, θ), e.radius.x, e.radius.y, e.θ + θ)
translate(e::Ellipse, dx, dy) = Ellipse(e.center + Point(dx, dy), e.radius.x, e.radius.y, e.θ)
function scale(e::Ellipse, sx, sy)
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


function Base.in(p::Point, e::Ellipse)
    pr = rotate(p - e.center, -e.θ)
    ps = scale(pr, 1/e.radius.x, 1/e.radius.y)
    return ps ∈ Circle(Point(0,0), 1)
end


function simplify(e::Ellipse)
    if e.radius.x == e.radius.y
        return Circle(e.center, e.radius.x)
    end
    nothing
end

