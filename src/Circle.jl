
struct Circle
    center::Point{Float64}
    radius::Float64
end

unit_circle() = Circle(Point(0,0), 1)


dist(c::Circle, p::Point) = dist(p, c)
function dist(p::Point, c::Circle)
    d = dist(p, c.center)
    if d < c.radius return 0 end
    return d - c.radius
end

# returns nothing, a point or a line!
function intersect_with_unit_circle(l::Line)
    if l.p1 == l.p2 # degenerate line...
        if dist(l.p1, Point(0,0)) == 0
            return l.p1 end # point inside circle
        else
            return nothing # point outside circle
        end
    end

    L = length(l)
    d = l.p2 - l.p1
    σ = (l.p1 ⋅ d) / (d ⋅ d)
    p = l.p1 + σ*(l.p1-l.p2) # point between two intersetion points, if they exist
    dst = dist(p, Point(0,0))
    if dst < 1 # inside, two intersection points
        distp = sqrt(1-dst^2)
        σL = σ*L
        σ⁺ = (σL + distp) / L
        σ⁻ = (σL - distp) / L
        p⁺ = l.p1 + σ⁺*(l.p1-l.p2)
        p⁻ = l.p1 + σ⁻*(l.p1-l.p2)
        return Line(p⁺, p⁻)
    elseif dst == 1 # tangential connection, 1 intersection point
        return p
    else # no intersection
        return nothing
    end
end

function intersect(c::Circle, l::Line)
    L = (1/c.r)*(l - c.c) # do we need to make sure the line is somehow long enough for good results?
    L = intersect_with_unit_circle(L)
    if isnothing(L) return nothing end
    L = c.r*L + c.c
    return L
end