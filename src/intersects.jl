

Base.intersect(s1::AbstractShape, s2) = intersect(s2,s1)
Base.intersect(::Nothing, s::AbstractShape) = nothing

Base.intersect(p::Point{T}, s::AbstractShape) where T = p ∈ s ? p : nothing

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





