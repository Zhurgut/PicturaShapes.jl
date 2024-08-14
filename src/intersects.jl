
function Base.intersect(p::Point{T}, l::Segment{S}) where {T,S}
    if p ∈ l 
        project(p, l)
    end
    return nothing
end

function Base.intersect(p::Point{T}, l::Line) where T
    if p ∈ l
        return project(p, l)
    end
    return nothing
end


function Base.intersect(l::Line, s::Segment{S}) where S
    p1, p2 = project.((s.p1, s.p2), l)
    if Segment(p1, p2) ≈ s return s end

    i = l ∩ Line(s)
    if i isa Point && i ∈ s return i end
    
    return nothing
end


function Base.intersect(l::Line, r::AbstractQuatrilateral{R}) where R
    s = sides(r)
    i = (s.t ∩ l, s.l ∩ l, s.b ∩ l, s.r ∩ l) 
    p = filter(x->x isa Point, i)
    if length(p) == 0
        return nothing
    elseif length(p) == 1
        return p[1]
    elseif length(p) == 2
        return Segment(p[1], p[2])
    else
        p = p .|> (pt->Point(round(pt.x, digits=1), round(pt.y, digits=1))) |> Set |> Tuple
        if length(p) == 1
            return p[1]
        elseif length(p) == 2
            return Segment(p[1], p[2])
        else
            error("what is going on?")
        end
    end
end
