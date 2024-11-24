
# infinite line



# orthogonally project the point onto the line
project(p::Point{T}, l::Line) where T = project(p, Segment(l))
characteristic_point(l::Line) = project(Point(0,0), l) # Point on line closest to origin



dist(p::Point{T}, l::Line) where T = dist(p, project(p, l))


function Base.:(==)(l1::Line, l2::Line)
    if l1.dist == 0 == l2.dist
        return mod(l1.θ, π) == mod(l2.θ, π)
    end
    return l1.θ == l2.θ && l1.dist == l2.dist
end
function Base.isapprox(l1::Line, l2::Line)
    p1, p2 = characteristic_point.((l1, l2))
    if p1 ≉ p2 return false end
    
    return mod(l1.θ, π) == mod(l2.θ, π)
end



rotate(l::Line, θ) = Line(l.θ + θ, l.dist)
function translate(l::Line, dx, dy) # we dont want to recalculate the angle, otherwise the new line is not perfectly parallel 
    q = characteristic_point(l)
    p = q + Point(dx, dy)
    s = project(p, l)
    q_new = q + p - s
    dst_new = magnitude(q_new)
    if dist(q, q_new) > max(l.dist, dst_new) # the line moved through the origin
        return Line(l.θ, -dst_new) # negative distance will rotate the angle by 180°
    else # otherwise line still on the same side of the origin
        return Line(l.θ, dst_new) 
    end
end
scale(l::Line, sx, sy) = Line(scale(Segment(l), sx, sy))



Base.in(p::Point{T}, l::Line) where T = dist(p, l) < EPS


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


align(l::Line) = Line(align(Segment(l))) 






