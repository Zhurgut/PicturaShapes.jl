
# infinite line

struct Line <: AbstractShape{Float64}
    θ::Float64 # angle between x axis and shortest line to line [-π, π[
    dist::Float64 # distance of line from origin
end

Segment(l::Line) = intersect_with_circle_at_origin(l, max(1, 2*l.dist))

function Line(p1::Point, p2::Point)
    p1 != p2 || error("cannot construct line from 2 points that are equal $p1 == $p2")

    q = project(Point(0,0), Segment(p1, p2))
    p = p2 - p1

    if q == Point(0,0)
        pr = rotate(p, π/2)
        θ = angle(pr)
        return Line(θ, 0)
    end

    return Line(angle(q), magnitude(q))
    
end

Line(s::Segment)     = Line(s.p1, s.p2)
Line(a, b, c)        = Line(Segment(a, b, c))
Line(x1, y1, x2, y2) = Line(Segment(x1, y1, x2, y2))



 

# orthogonally project the point onto the line
project(p::Point, l::Line)    = project(p, Segment(l))
characteristic_point(l::Line) = rotate(Point(l.dist, 0), l.θ) # Point on line closest to origin



sdf(p::Point, l::Line) = dist(p, project(p, l))




rotate(l::Line, θ)         = Line(mod2pi(l.θ + θ), l.dist)
translate(l::Line, dx, dy) = Line(translate(Segment(l), dx, dy))
scale(l::Line, sx, sy)     = Line(scale(Segment(l), sx, sy))




