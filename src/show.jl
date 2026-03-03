  

# just overwrite display..

align_round(x) = round(x, digits=3)
align(p::Point) = Point(round(p.x, digits=3), round(p.y, digits=3))

function Base.show(io::IO, ::MIME"text/plain", p::Point{T}) where T <: AbstractFloat
    print(io, align(p))
end

function Base.show(io::IO, ::MIME"text/plain", s::Segment{T}) where T
    x = s.p1.x, s.p1.y, s.p2.x, s.p2.y
    if T <: AbstractFloat
        x = align_round.(x)
    end
    print(io, "Segment{$T}(($(x[1]), $(x[2])) --> ($(x[3]), $(x[4])))")
end

function Base.show(io::IO, ::MIME"text/plain", l::Line)
    s = Segment(l)
    print(io, "Line(θ=$(l.θ), dist=$(l.dist)) ≘ ", Segment(align(s.p1), align(s.p2)))
end

function Base.show(io::IO, ::MIME"text/plain", a::AxisRect{T}) where T
    x = a.tl.x, a.tl.y, a.w, a.h
    if T <: AbstractFloat
        x = align_round.(x)
    end
    print(io, "AxisRect{$T}(tl=($(x[1]), $(x[2])), w=$(x[3]), h=$(x[4]))")
end

function Base.show(io::IO, ::MIME"text/plain", r::Rect{T}) where T
    c = corners(r)
    x = (c.tl, c.tr, c.br, c.bl)
    w,h = r.w, r.h
    if T <: AbstractFloat
        x = align.(x)
        w,h = align_round.((w,h))
    end
    print(io, "Rect{$T}(tl=($(x[1].x), $(x[1].y)), tr=($(x[2].x), $(x[2].y)), br=($(x[3].x), $(x[3].y)), bl=($(x[4].x), $(x[4].y)), w=$w, h=$h, θ=$(r.θ))")
end

function Base.show(io::IO, ::MIME"text/plain", c::Circle{T}) where T
    if T <: AbstractFloat
        c = Circle(align(c.center), align_round(c.radius))
    end
    print(io, "Circle{$T}(($(c.center.x), $(c.center.y)), radius=$(c.radius))")
end

function Base.show(io::IO, ::MIME"text/plain", e::Ellipse{T}) where T
    if T <: AbstractFloat
        e = Ellipse(align(e.center), align(e.radius), e.θ)
    end
    print(io, "Ellipse{$T}(($(e.center.x), $(e.center.y)), radius_x=$(align_round(e.radius.x)), radius_y=$(align_round(e.radius.y)), θ=$(e.θ))")
end

# function Base.show(io::IO, ::MIME"text/plain", t::Triangle{T}) where T
#     if T <: AbstractFloat
#         t = align(t)
#     end
#     print(io, "Triangle{$T}(($(t.p1.x), $(t.p1.y)), ($(t.p2.x), $(t.p2.y)), ($(t.p3.x), $(t.p3.y)))")
# end

# function Base.show(io::IO, ::MIME"text/plain", q::Quatrilateral{T}) where T
#     if T <: AbstractFloat
#         q = align(q)
#     end
#     print(io, "Quatrilateral{$T}(($(q.p1.x), $(q.p1.y)), ($(q.p2.x), $(q.p2.y)), ($(q.p3.x), $(q.p3.y)), ($(q.p4.x), $(q.p4.y)))")
# end

