
# infinite line

struct Line{T <: Real}
    p1::Point{T}
    p2::Point{T}
end

Line{T}(p1::Point, p2::Point) where T = Line{T}(Point{T}(p1), Point{T}(p2))

function Line(p1::Point, p2::Point)
    (x, y) = Base.promote(p1.x, p2.x)
    T = typeof(x)
    return Line{T}(p1, p2)
end

Line{T}(l::Line) where T = Line{T}(l.p1, l.p2)

Base.convert(::Type{Line{T}}, l::Line) where T = Line{T}(l)


Base.length(l::Line) = dist(l.p1, l.p2)

rotate(l::Line, θ::Float64) = Line(rotate(l.p1, θ), rotate(l.p2, θ))


Base.:(+)(p::Point, l::Line) = l + p
Base.:(+)(l::Line, p::Point) = Line(l.p1 + p, l.p2 + p)
Base.:(-)(l::Line, p::Point) = l + (-p)


scale(l::Line, xs, ys) = Line(scale(l.p1, xs, ys), scale(l.p2, xs, ys))
Base.:(*)(l::Line, r::Real) = r*l
Base.:(*)(r::Real, l::Line) = Line(r*l.p1, r*l.p2)

function δ(x::Point, l::Line)
    return ((x-l.p1) ⋅ (l.p2 - l.p1)) / ((l.p2 - l.p1) ⋅ (l.p2 - l.p1))
end

function project_onto(p::Point, l::Line)

end