
# infinite line

struct Line{T <: Real}
    p1::Point{T}
    p2::Point{T}
end


function Line(p1::Point, p2::Point)
    (x, y) = Base.promote(p1.x, p2.x)
    T = typeof(x)
    return Line{T}(p1, p2)
end

Line{T}(l::Line) where T = Line{T}(l.p1, l.p2)

Line(x1, y1, x2, y2) = Line(Point(x1, y1), Point(x2, y2))
Line{T}(x1, y1, x2, y2) where T = Line{T}(Point{T}(x1, y1), Point{T}(x2, y2))

Base.convert(::Type{Line{T}}, l::Line) where T = Line{T}(l)


Base.length(l::Line) = dist(l.p1, l.p2)

rotate(l::Line, θ::Float64) = Line(rotate(l.p1, θ), rotate(l.p2, θ))


Base.:(+)(p::Point, l::Line) = l + p
Base.:(+)(l::Line, p::Point) = Line(l.p1 + p, l.p2 + p)
Base.:(-)(l::Line, p::Point) = l + (-p)


scale(l::Line, xs, ys) = Line(scale(l.p1, xs, ys), scale(l.p2, xs, ys))
Base.:(*)(l::Line, r::Real) = r*l
Base.:(*)(r::Real, l::Line) = Line(r*l.p1, r*l.p2)

function delta(x::Point, l::Line)
    return ((x-l.p1) ⋅ (l.p2 - l.p1)) / ((l.p2 - l.p1) ⋅ (l.p2 - l.p1))
end

function project_onto(p::Point, l::Line)
    δ = delta(p, l)
    return l.p1 + δ*(l.p2-l.p1)
end

dist(p::Point, l::Line) = dist(p, project_onto(p, l))

Base.in(p::Point, l::Line) = dist(p, l) < length(l)*1e-7

function Base.intersect(p::Point, l::Line)
    if p ∈ l
        return p
    else
        return nothing
    end
end


function Base.intersect(l1::Line, l2::Line)
    s,t = l1.p1, l1.p2
    p,q = l2.p1, l2.p2

    @fastmath begin

        if q.x - p.x == 0 # vertical line
            return intersect_x(l1, p.x)
        elseif q.y - p.y == 0 # horizontal line
            return intersect_y(l1, p.y)
        end

        iy = 1 / (q.y-p.y)
        ix = 1 / (q.x-p.x)
        denominator = (iy*t.y - iy*s.y) - (ix*t.x - ix*s.x)

        if abs(denominator) < 1e-8 # lines are parallel
            if s ∈ l2 return l1 end # lines are on each other
            return nothing
        end

        id = 1/denominator
        dx = id*ix
        dy = id*iy
        δ = (dx*s.x - dx*p.x) - (dy*s.y - dy*p.y)

        return (1-δ)s + δ*t

    end
end

function intersect_x(l::Line, x)
    if l.p1.x == l.p2.x
        if l.p1.x == x
            return l
        else
            return nothing
        end
    end
    i = 1/(l.p2.x-l.p1.x)
    δ = i*x-i*l.p1.x
    return (1-δ)*l.p1 + δ*l.p2
end

function intersect_y(l::Line, y)
    if l.p1.y == l.p2.y
        if l.p1.y == y
            return l
        else
            return nothing
        end
    end
    i = 1/(l.p2.y-l.p1.y)
    δ = i*y-i*l.p1.y
    return (1-δ)*l.p1 + δ*l.p2
end