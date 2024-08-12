


Circle(p::Point{T}, r) where T = Circle{T}(p, Float64(r))
Circle(x, y, r) = Circle(Point(x, y), r)
Circle{S}(c::Circle{T}) where {S, T} = Circle{S}(Point{S}(c.center), c.radius)


Base.:(+)(c::Circle{T}, p::Point{S}) where {S, T} = Circle(c.center + p, c.radius)
Base.:(-)(c::Circle{T}, p::Point{S}) where {S, T} = c + (-p)
Base.:(*)(s, c::Circle{T}) where T = Circle(s * c.center, s * c.radius)



unit_circle() = Circle(Point(0,0), 1)





function dist(p::Point{T}, c::Circle{S}) where {T, S}
    d = dist(p, c.center)
    return d - c.radius
end



Base.:(==)(c1::Circle{T}, c2::Circle{S}) where {T, S} = c1.center == c2.center && c1.radius == c2.radius
Base.isapprox(c1::Circle{T}, c2::Circle{S}) where {T, S} = c1.center ≈ c2.center && abs(c1.radius - c2.radius) <= EPS



rotate(c::Circle{T}, θ) where T = Circle(rotate(c.center, θ), c.radius)
translate(c::Circle{T}, dx, dy) where T = Circle(c.center + Point(dx, dy), c.radius)
function scale(c::Circle{T}, sx, sy) where T
    if sx == sy
        return sx * c
    end
    Ellipse(scale(c.center, sx, sy), sx * c.radius, sy * c.radius)
end




Base.in(p::Point{T}, c::Circle{S}) where {T, S} = dist(p, c) <= 0




function intersect_unit_circle_with_x_axis(y)
    abs(y) > 1 && return nothing
    abs(y) == 1 && return Point(0, y)
    c = sqrt(1 - y*y)
    return Segment(-c, y, c, y)
end

function intersect_with_unit_circle(l::Line)
    l.dist > 1 && return nothing
    l.dist == 1 && return rotate(Point(1, 0), l.θ)
    s = intersect_unit_circle_with_x_axis(l.dist)::Segment{Float64}
    return rotate(s, l.θ - π/2)
end


function Base.intersect(c::Circle{T}, l::Line) where T
    s = l - c.center

    s.dist > c.radius && return nothing

    if abs(s.dist - c.radius) < EPS
        i = intersect_with_unit_circle(Line(l.θ, 1))::Point{Float64}
        return c.radius*i + c.center
    end

    j = intersect_with_unit_circle((1/c.radius) * s)::Segment{Float64}
    return c.radius*j + c.center
end


