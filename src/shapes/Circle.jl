


unit_circle() = Circle(Point(0,0), 1)


function intersect_unit_circle_with_x_axis(y)
    abs(y) > 1 && return nothing
    c = sqrt(1 - y*y)
    return Segment(-c, y, c, y)
end

function intersect_with_unit_circle(l::Line)
    l.dist > 1 && return nothing
    s = intersect_unit_circle_with_x_axis(l.dist)
    return rotate(s, l.θ - π/2)
end

function intersect_with_circle_at_origin(l::Line, radius)
    return radius * intersect_with_unit_circle((1/radius) * l)
end





function dist(p::Point, c::Circle)
    d = dist(p, c.center)
    return d - c.radius
end

dist(c1::Circle, c2::Circle) = max(0, dist(c1.center, c2.center) - c1.radius - c2.radius)




Base.:(==)(c1::Circle, c2::Circle)    = c1.center == c2.center && c1.radius == c2.radius
Base.isapprox(c1::Circle, c2::Circle) = c1.center ≈ c2.center && abs(c1.radius - c2.radius) <= PREC



rotate(c::Circle, θ)         = Circle(rotate(c.center, θ), c.radius)
translate(c::Circle, dx, dy) = Circle(translate(c.center, dx, dy), c.radius)
scale(c::Circle, sx, sy)     = Ellipse(scale(c.center, sx, sy), sx * c.radius, sy * c.radius)



align(c::Circle) = Circle(align(c.center), align_round(c.radius))
simplify(c::Circle) = c.radius < PREC ? c.center : c


Base.in(p::Point, c::Circle) = dist(p, c) <= 0





