
# finite line

struct Segment{T <: Real}
    p1::Point{T}
    p2::Point{T}
end


function Segment(p1::Point, p2::Point)
    (x, y) = Base.promote(p1.x, p2.x)
    T = typeof(x)
    return Segment{T}(p1, p2)
end

Segment{T}(l::Segment) where T = Segment{T}(l.p1, l.p2)

Segment(x1, y1, x2, y2) = Segment(Point(x1, y1), Point(x2, y2))
Segment{T}(x1, y1, x2, y2) where T = Segment{T}(Point{T}(x1, y1), Point{T}(x2, y2))

Base.convert(::Type{Segment{T}}, l::Segment) where T = Segment{T}(l)

Segment{T}(l::Line) where T = Segment{T}(l.p1, l.p2)
Segment(l::Line) = Segment(l.p1, l.p2)

Line{T}(l::Segment) where T = Line{T}(l.p1, l.p2)
Line(l::Segment) = Line(l.p1, l.p2)



Base.length(l::Segment) = dist(l.p1, l.p2)

rotate(l::Segment, θ::Float64) = Segment(rotate(l.p1, θ), rotate(l.p2, θ))

Base.:(+)(p::Point, l::Segment) = l + p
Base.:(+)(l::Segment, p::Point) = Line(l.p1 + p, l.p2 + p)
Base.:(-)(l::Segment, p::Point) = l + (-p)

scale(l::Segment, xs, ys) = Segment(scale(l.p1, xs, ys), scale(l.p2, xs, ys))
Base.:(*)(l::Segment, r::Real) = r*l
Base.:(*)(r::Real, l::Segment) = Segment(r*l.p1, r*l.p2)

delta(x::Point, l::Segment) = delta(x, Line(l))


function dist(p::Point, l::Segment)
    δ = delta(p, Line(l))
    if 0 <= δ <= 1
        return dist(p, Line(l))
    end
    return min(dist(p, l.p1), dist(p, l.p2))
end

Base.in(p::Point, l::Segment) = (dist(p, Line(l)) < length(l)*1e-7) && (0 <= delta(p, l) <= 1)

function Base.intersect(p::Point, l::Segment)
    if p ∈ l
        return p
    else
        return nothing
    end
end


function Base.intersect(l1::Line, l2::Segment)
    i = intersect(l1, Line(l2))
    if i isa Point
        if i ∈ l2
            return i
        else
            return nothing
        end
    elseif i isa Line
        return l2
    else
        return nothing
    end
    return nothing
end

function Base.intersect(l1::Segment, l2::Segment)
    i = intersect(l1, Line(l2))
    if i isa Point
        if i ∈ l2
            return i
        else
            return nothing
        end
    elseif i isa Segment
        return overlapping_segment(l1, l2)
    else
        return nothing
    end
    return nothing
end

function overlapping_segment(l1::Segment, l2::Segment)
    δ₁ = delta(l2.p1, l1)
    δ₂ = delta(l2.p2, l1)
    δₛ = max(0, min(δ₁, δ₂))
    δₜ = min(1, max(δ₁, δ₂))
    if δₛ == δₜ
        return (δₛ-1)l.p1+δₛ*l.p2
    elseif δₛ < δₜ
        return Segment((δₛ-1)l.p1+δₛ*l.p2, (δₜ-1)l.p1+δₜ*l.p2)
    end
    return nothing
end
