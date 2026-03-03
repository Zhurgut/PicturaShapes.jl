

struct Circle{T} <: AbstractShape{T}
    center::Point{T}
    radius::T
end
 
function Circle(p::Point{T}, r::S) where {S,T}
    U = promote_type(S, T)
    return Circle{U}(Point{U}(p), U(r))
end
Circle(x, y, r) = Circle(Point(x, y), r)

Base.convert(::Type{Circle{T}}, s::Circle) where T = Circle{T}(Point{T}(s.center), T(s.radius))
Circle{T}(c) where T = convert(Circle{T}, c)




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





function sdf(p::Point, c::Circle)
    d = sdf(p, c.center)
    return d - c.radius
end




Base.:(==)(c1::Circle, c2::Circle)    = c1.center == c2.center && c1.radius == c2.radius



rotate(c::Circle, θ)         = Circle(rotate(c.center, θ), c.radius)
translate(c::Circle, dx, dy) = Circle(translate(c.center, dx, dy), c.radius)
scale(c::Circle, sx, sy)     = Ellipse(scale(c.center, sx, sy), sx * c.radius, sy * c.radius)


simplify(c::Circle) = c.radius == 0 ? c.center : nothing


Base.in(p::Point, c::Circle) = dist(p, c.center) <= c.radius





