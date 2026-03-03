

Base.intersect(s1::AbstractShape, s2) = intersect(s2,s1)
Base.intersect(::Nothing, s::AbstractShape) = nothing

Base.intersect(p::Point{T}, s::AbstractShape) where T = p ∈ s ? p : nothing



function Base.intersect(p1::Point, p2::Point)
    if p1 == p2
        return p1
    end
    return nothing
end


function Base.intersect(s::Segment{T}, f::AbstractShape{S}) where {S,T}
    i = f ∩ Line(s)
    if i isa Segment
        return overlapping_segment(i, s)
    else 
        return i ∩ s
    end
end

function Base.intersect(s::Segment{S}, l::Line) where S
    p1, p2 = project(s.p1, l), project(s.p2, l)

    if Segment(p1, p2) ≈ s return s end

    i = l ∩ Line(s)
    if i isa Point && i ∈ s return i end
    
    return nothing
end




function Base.intersect(q::AbstractPolygon{T}, l::Line) where T
    s = sides(q)
    i = (x->x ∩ l).(s)
    if all(isnothing, i) return nothing end
    if any(x->(x isa Segment), i)
        for t in i
            if t isa Segment
                return t
            end
        end
    end
    p = filter(x->(x isa Point), i)
    if length(p) == 1 return p[1] end
    if length(p) == 2
        if p[1] ≈ p[2] return 0.5(p[1] + p[2]) end
        return Segment(p[1], p[2])
    end
    
    like_p1_idx = [p_i ≈ p[1] for p_i in p]
    like_p1 = p[like_p1_idx]
    unlike_p1 = p[.!like_p1_idx]

    if unlike_p1 == ()
        return (1/length(p))*sum(p)
    end

    p1 = (1/length(like_p1)) * sum(like_p1)
    p2 = (1/length(unlike_p1)) * sum(unlike_p1)
    return Segment(p1, p2)
end


function Base.intersect(c::Circle{T}, l::Line) where T
    s = l - c.center

    s.dist > c.radius && return nothing

    i = intersect_with_unit_circle((1/c.radius) * s)

    return c.radius * i + c.center
end

function Base.intersect(e::Ellipse{T}, l::Line) where T
    er = rotate(e, -e.θ)
    lr = rotate(l, -e.θ)
    es = scale(er, e.radius.y/e.radius.x, 1)
    ls = scale(lr, e.radius.y/e.radius.x, 1)

    c = Circle(es.center, es.radius.x)
    i = c ∩ ls

    if isnothing(i) return i end

    is = scale(i, e.radius.x/e.radius.y, 1) # function barrier trick inconvenient... hmm
    ir = rotate(is, e.θ)

    return ir
end






function Base.intersect(l1::Segment, l2::Segment)
    i = intersect(l1, Line(l2))
    if i isa Point && i ∈ l2
        return i
    elseif i isa Segment
        return overlapping_segment(l1, l2)
    end
    return nothing
end



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



function Base.intersect(a1::AxisRect, a2::AxisRect)
    c1, c2 = corners(a1), corners(a2)
    t1, r1, b1, l1 = c1.tl.y, c1.br.x, c1.br.y, c1.tl.x
    t2, r2, b2, l2 = c2.tl.y, c2.br.x, c2.br.y, c2.tl.x

    if b2 < t1 || b1 < t2 || r2 < l1 || r1 < l2
        return nothing
    end

    il = max(l1, l2)
    ir = min(r1, r2)
    it = max(t1, t2)
    ib = min(b1, b2)

    i_tl = Point(il, it)
    i_br = Point(ir, ib)

    if il == ir && it == ib
        return i_tl
    end

    if il == ir || it == ib
        return Segment(i_tl, i_br)
    end

    return AxisRect(i_tl, i_br)
end







