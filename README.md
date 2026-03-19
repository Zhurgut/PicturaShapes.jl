# PicturaShapes.jl

A small package with 2D geometry shapes. Move, scale and transform shapes like Points, Lines, Rectangles and Ellipses. 


```julia
p = Point(1, 2)
(p.x, p.y) == (1, 2)

s = Segment(p, Point(3, 4)) # finite line
(s.p1, s.p2) == (p, Point(3, 4))

l = Line(p, Point(3, 4)) # infinite line

# Axis aligned rectangle with top-left at 'p', width=5 and height=3
a = AxisRect(p, 5, 3)

# Rectangle rotated counter-clockwise around p by 90°
r = Rect(p, 5, 3, π/2)

c = Circle(p, 3) # radius = 3

# Ellipse with width 2*5 and height 2*4, rotated by 45°
e = Ellipse(p, 5, 4, π/4) 
```


All shapes can be scaled, rotated and moved:
```julia
scale(Point(1, 1), 2, -3) == Point(2, -3)
rotate(Point(1, 0), π/2) == Point(0, 1)
translate(Point(0, 0), 2, 3) == Point(2, 3)
```

The signed distance of a point to any shape can be computed with the `sdf` function: 
```julia
sdf(Ellipse(0, 0, 4, 1), Point(4, 1)) ≈ 0.6875
```

Bounding boxes and axis-aligned bounding boxes can be computed via:
```julia
bounding_box(Circle(0, 0, 2))
aligned_bounding_box(Rect(1, 2, 3, 4, π/4))
```