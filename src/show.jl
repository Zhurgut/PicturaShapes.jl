

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
