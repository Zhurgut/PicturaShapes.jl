
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


function Base.intersect(l1::Line, l2::Segment)
    i = l1 ∩ Line(l2)
    if i isa Point && i ∈ l2
        return i
    elseif i isa Line
        return l2
    end
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
