


unit_circle() = Circle(Point(0,0), 1)


function intersect_unit_circle_with_x_axis(y)
    abs(y) > 1 && return nothing
    abs(y - 1) < EPS && return Point(0, y)
    c = sqrt(1 - y*y)
    return Segment(-c, y, c, y)
end

function intersect_with_unit_circle(l::Line)
    l.dist > 1 && return nothing
    abs(l.dist - 1) < EPS && return rotate(Point(1, 0), l.θ)
    s = intersect_unit_circle_with_x_axis(l.dist)::Segment{Float64}
    return rotate(s, l.θ - π/2)
end

function intersect_with_circle_at_origin(l::Line, radius)
    l.dist > radius && return nothing
    abs(l.dist - 1) < EPS && return rotate(Point(radius, 0), l.θ)
    i = intersect_unit_circle_with_x_axis(l.dist / radius)::Segment{Float64}
    return rotate(radius * i, l.θ - π/2)
end





function dist(p::Point{T}, c::Circle{S}) where {T, S}
    d = dist(p, c.center)
    return d - c.radius
end

dist(c1::Circle, c2::Circle) = dist(c1.center, c2.center) - c1.radius - c2.radius




Base.:(==)(c1::Circle{T}, c2::Circle{S}) where {T, S} = c1.center == c2.center && c1.radius == c2.radius
Base.isapprox(c1::Circle{T}, c2::Circle{S}) where {T, S} = c1.center ≈ c2.center && abs(c1.radius - c2.radius) <= EPS



rotate(c::Circle{T}, θ) where T = Circle(rotate(c.center, θ), c.radius)
shift(c::Circle{T}, dx, dy) where T = Circle(c.center + Point(dx, dy), c.radius)
scale(c::Circle{T}, sx, sy) where T = Ellipse(scale(c.center, sx, sy), sx * c.radius, sy * c.radius)



align(c::Circle) = Circle(align(c.center), c.radius)
simplify(c::Circle) = c.radius < EPS ? c.center : c


Base.in(p::Point{T}, c::Circle{S}) where {T, S} = dist(p, c) <= 0





