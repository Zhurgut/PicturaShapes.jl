

Base.intersect(s1::AbstractShape, s2) = intersect(s2,s1)
Base.intersect(::Nothing, s::AbstractShape) = nothing

Base.intersect(p::Point{T}, s::AbstractShape) where T = p ∈ s ? p : nothing

function Base.intersect(s::Segment{T}, f::AbstractShape) where T
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


function Base.intersect(c::Circle{T}, l::Line) where T
    s = l - c.center

    s.dist > c.radius && return nothing

    i = intersect_with_unit_circle((1/c.radius) * s)

    return c.radius * i + c.center
end




# function Base.intersect(l::Line, r::AbstractQuatrilateral{R}) where R
#     s = sides(r)
#     i = (s.t ∩ l, s.l ∩ l, s.b ∩ l, s.r ∩ l) 
#     p = filter(x->x isa Point, i)
#     if length(p) == 0
#         return nothing
#     elseif length(p) == 1
#         return p[1]
#     elseif length(p) == 2
#         return Segment(p[1], p[2])
#     else
#         p = p .|> (pt->Point(round(pt.x, digits=1), round(pt.y, digits=1))) |> Set |> Tuple
#         if length(p) == 1
#             return p[1]
#         elseif length(p) == 2
#             return Segment(p[1], p[2])
#         else
#             error("what is going on?")
#         end
#     end
# end




