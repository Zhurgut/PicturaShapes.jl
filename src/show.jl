

# just overwrite display..

function Base.show(io::IO, ::MIME"text/plain", p::Point{T}) where T <: AbstractFloat
    print(io, align(p))
end

function Base.show(io::IO, ::MIME"text/plain", s::Segment{T}) where T
    x = s.p1.x, s.p1.y, s.p2.x, s.p2.y
    if T <: AbstractFloat
        x = rounded.(x)
    end
    print(io, "Segment{$T}(($(x[1]), $(x[2])) --> ($(x[3]), $(x[4])))")
end

function Base.show(io::IO, ::MIME"text/plain", l::Line)
    print(io, "Line(θ=$(l.θ), dist=$(l.dist)) ≘ ", align(Segment(l)))
end

function Base.show(io::IO, ::MIME"text/plain", a::AxisRect{T}) where T
    x = a.tl.x, a.tl.y, a.w, a.h
    if T <: AbstractFloat
        x = rounded.(x)
    end
    print(io, "AxisRect{$T}(tl=($(x[1]), $(x[2])), w=$(x[3]), h=$(x[4]))")
end

function Base.show(io::IO, ::MIME"text/plain", r::Rect{T}) where T
    c = corners(r)
    x = (c.tl, c.tr, c.br, c.bl)
    w,h = r.w, r.h
    if T <: AbstractFloat
        x = align.(x)
        w,h = rounded.((w,h))
    end
    print(io, "Rect{$T}(tl=$(x[1]), tr=$(x[2])), br=$(x[3]), bl=$(x[4]), w=$w, h=$h, θ=$(r.θ))")
end

function Base.show(io::IO, ::MIME"text/plain", c::Circle{T}) where T
    if T <: AbstractFloat
        c = Circle(align(c.center), rounded(c.radius))
    end
    print(io, "Circle{$T}(($(c.center.x), $(c.center.y)), radius=$(c.radius))")
end
