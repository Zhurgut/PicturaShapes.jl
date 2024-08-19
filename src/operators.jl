
Base.:(+)(s, p::Point{T}) where T = p + s

Base.:(+)(p1::Point{T}, p2::Point{S}) where {T, S} = Point(p1.x + p2.x, p1.y + p2.y)
Base.:(-)(p::Point{T}) where T = Point(-p.x, -p.y)
Base.:(-)(p1::Point{T}, p2::Point{S}) where {T, S} = p1 + (-p2)
Base.:(*)(s, p::Point{T}) where T  = Point(s * p.x, s * p.y)

Base.:(+)(p::Point{T}, s) where T = translate(s, p.x, p.y)
Base.:(-)(s, p::Point{T}) where T = s + (-p)
Base.:(*)(m, s::AbstractShape{T}) where T  = scale(s, m, m)


Base.:(*)(m, l::Line) = Line(l.θ, m*l.dist) # dont need to convert to segment in this case, compare scale(Line, sx, sy)

Base.:(*)(s, r::Rect{T}) where T = Rect(s*r.tl, s*r.w, s*r.h, r.θ) # dont need Quatrilateral

Base.:(*)(s, e::Ellipse{T}) where T = Ellipse(s * e.center, s * e.radius_x, s * e.radius_y, e.θ)