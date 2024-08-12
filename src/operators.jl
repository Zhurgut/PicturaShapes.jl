
Base.:(+)(p::Point{T}, s) where T = s + p

Base.:(+)(p1::Point{T}, p2::Point{S}) where {T, S} = Point(p1.x + p2.x, p1.y + p2.y)
Base.:(-)(p::Point{T}) where T = Point(-p.x, -p.y)
Base.:(-)(p1::Point{T}, p2::Point{S}) where {T, S} = p1 + (-p2)
Base.:(*)(s, p::Point{T}) where T  = Point(s * p.x, s * p.y)
