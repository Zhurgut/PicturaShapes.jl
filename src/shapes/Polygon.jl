
points(p::Polygon{T}) where T = p.ps


function dist(p::Point, g::AbstractPolygon)
    dst = min((x->dist(x, p)).(g)...)
    if p ∈ g
        return -dst
    end
    return dst
    
end
