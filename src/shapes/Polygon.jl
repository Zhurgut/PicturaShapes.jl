
points(p::Polygon{T}) where T = p.ps


function dist(p::Point, g::AbstractPolygon)
    s = sides(g)
    
end
