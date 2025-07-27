
# infinite line



# orthogonally project the point onto the line
project(p::Point, l::Line)    = project(p, Segment(l))
characteristic_point(l::Line) = rotate(Point(l.dist, 0), l.θ) # Point on line closest to origin



dist(p::Point, l::Line) = dist(p, project(p, l))


function Base.:(==)(l1::Line, l2::Line)
    if l1.dist == 0 == l2.dist
        return mod(l1.θ, π) == mod(l2.θ, π)
    end
    return l1.θ == l2.θ && l1.dist == l2.dist
end
function Base.isapprox(l1::Line, l2::Line)
    p1, p2 = characteristic_point.((l1, l2))
    if p1 ≈ Point(0,0) ≈ p2
        return mod(l1.θ, π) == mod(l2.θ, π)
    end
    return p1 ≈ p2
end



rotate(l::Line, θ)         = Line(l.θ + θ, l.dist)
translate(l::Line, dx, dy) = Line(translate(Segment(l), dx, dy))
scale(l::Line, sx, sy)     = Line(scale(Segment(l), sx, sy))



Base.in(p::Point, l::Line) = dist(p, l) < PREC


function Base.intersect(l1::Line, l2::Line)
    if l1 ≈ l2 # literally the same
        return Line(l1.θ, 0.5*(l1.dist+l2.dist))
    end
    # not the same

    if mod(l1.θ, π) == mod(l2.θ, π) # parallel, but not the same
        return nothing
    end
    # not parallel

    if l2.dist == 0
        l1, l2 = l2, l1
    end

    p = characteristic_point(l1)
    l1 = Line(l1.θ, 0) # move both lines so that one goes through origin ( = l1 - p)
    l2 = l2 - p

    # l1.dist == 0
    
    α = (l1.θ - π/2) - l2.θ
    ak = l2.dist
    hyp = ak * sec(α) # ak / cos(α)
    std_hyp = Point(sin(l1.θ), -cos(l1.θ))

    return hyp*std_hyp + p
end


function align(l::Line)
    p = align(characteristic_point(l))
    return Line(angle(p), dist(p, Point(0,0))) 
end






