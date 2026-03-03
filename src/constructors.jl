


"""
Point
"""









"""
Segment
"""










"""
Line
"""










"""
AxisRect
"""









"""
Rect
"""




"""
Circle
"""








"""
Ellipse
"""










"""
Triangle
"""
function Triangle(p1::Point{T1}, p2::Point{T2}, p3::Point{T3}) where {T1, T2, T3}
    T = promote_type(T1, T2, T3)
    return Triangle{T}(Point{T}(p1), Point{T}(p2), Point{T}(p3))
end

Triangle(x1, y1, x2, y2, x3, y3) = Triangle(Point(x1, y1), Point(x2, y2), Point(x3, y3))










"""
Quatrilateral
"""
function Quatrilateral(p1::Point{T1}, p2::Point{T2}, p3::Point{T3}, p4::Point{T4}) where {T1, T2, T3, T4}
    T = promote_type(T1, T2, T3, T4)
    return Quatrilateral{T}(Point{T}(p1), Point{T}(p2), Point{T}(p3), Point{T}(p4))
end

Quatrilateral(x1, y1, x2, y2, x3, y3, x4, y4) = Quatrilateral(Point(x1, y1), Point(x2, y2), Point(x3, y3), Point(x4, y4))





