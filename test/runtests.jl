
using Test
using Shapes
using LinearAlgebra

@testset "set_eps" begin
    old_eps = Shapes.EPS
    Shapes.set_eps(2.3e-5)
    @test Shapes.EPS == 2.3e-5
    @test Shapes.DIGITS == 5
    Shapes.set_eps(old_eps)
end

@testset "pretty print" begin
    p = Point(Float64(π), Float64(π))
    ip = Point(Int8(1), Int8(2))
    println(p)
    display(p)
    println(ip)
    display(ip)
end

@testset "constructors" begin
    a = Point(1, 2)
    @test typeof(a) == Point{Int}
    @test typeof(Point(1, 2.0)) == Point{Float64}
    @test typeof(Point{Float64}(a)) == Point{Float64}

    # s = Segment(1, 2, 3, 4)
    # @test typeof(s) == Segment{Int}
    # @test typeof(Segment{Float64}(1, 2, 3, 4)) == Segment{Float64}
    # @test typeof(Segment(a, Point(1, 2.0))) == Segment{Float64}
    # @test typeof(Segment{Float64}(1, 2, Point(1, 2))) == Segment{Float64}
    # @test typeof(Segment(1, 2, Point(1, 2))) == Segment{Int}

    # l = Line(10*π, 10)
    # @test 1+l.θ ≈ 1.0
    # @test l.dist == 10
    # @test -π <= Line(-π, 0).θ < π
    # @test -π <= Line(0, 0).θ  < π
    # @test -π <= Line(π, 0).θ  < π
    # @test Line(Point(0, 1), Point(1, 1)) ≈ Line(π/2, 1)
    # @test Line(0, 1, 1, 1) == Line(Point(0, 1), 1, 1)

    # ar1 = AxisRect(1, 1, 2, 2)
    # ar2 = AxisRect(Point(1, 1), 2.0, 2)
    # ar3 = AxisRect{Float32}(ar1)
    # @test ar1 == ar2 == ar3

    # r1 = Rect(1, -1, 4*sqrt(2), 2*sqrt(2), π/4)
    # r2 = Rect(Point(1, -1), 4*sqrt(2), 2*sqrt(2), π / 4)
    # r3 = Rect(tr=Point(5, 3), br=Point(3,5), bl=Point(-1, 1))
    # r4 = Rect(tl=Point(1, -1), tr=Point(5, 3), br=Point(3,5))
    # r5 = Rect(tr=Point(1, -1), br=Point(5, 3), tl=Point(-1, 1))
    # r6 = rotate(AxisRect(0, -sqrt(2), 4*sqrt(2), 2*sqrt(2)), π/4)
    # @test typeof(r1) == typeof(r6) == Rect{Float64}
    # @test r1 ≈ r1
    # @test r1 ≈ r2
    # @test r1 ≈ r3
    # @test r1 ≈ r4
    # @test r1 ≈ r5
    # @test r1 ≈ r6

    # c1 = Circle(Point(1,1), 5)
    # c2 = Circle(1, 1.0, 4.99999999999999999)
    # c3 = Circle{Float64}(c1)
    # @test c1 == c3
    # @test c1 ≈ c2

    # e1 = Ellipse(1, 1, 1, 2)
    # e2 = Ellipse(1, 1, 2, 1, π/2)
    # e3 = Ellipse(Point(1, 1-sqrt(3)), Point(1, 1+sqrt(3)), 2)
    # e4 = Ellipse(Point(1, 1-sqrt(3)), Point(1, 1+sqrt(3)), 2.1)
    # @test e1 ≈ e2 ≈ e3
    # @test e1 ≉ e4

    # t1 = Triangle(1, 1, Point(2.0, 2), 3, 3.0)
    # t2 = Triangle(3, 3, 2, 2, 1, 1)
    # @test t1 ≈ t2
end

@testset "points" begin
    a = Point(3, 0)
    b = Point(0, 4)
    c = Point(-1, -1)
    @test dist(a, b) == 5
    @test dist(a-c, b-c) == 5
    @test dist(2a, 2b) == 10
    @test a ⋅ b == 0
    @test a ⋅ c != 0
    @test magnitude(a) == 3
    @test normalize(a) == Point(1, 0)
    @test a == a
    @test a ≈ a
    @test a != b
    @test a ≈ (a+Point(0.0000000001, 0.000000001))
    @test a ≉ b
    @test rotate(a, π) ≈ -a
end

# @testset "segments" begin
#     a = Segment(3, 0, 0, 4)
#     b = Segment(0, 0, 4, 3)
#     c = Point(48/25, 36/25)
#     # @test = c ≈ (a ∩ b)::Point{Float64}
#     @test a ≈ (rotate(b, π/2) + Point(3, 0))
#     @test dist(Point(0,0), a - c)+1 ≈ 1.0
#     @test c ∈ b
#     @test Point(0,0) ∉ a
#     @test a ∩ c == b ∩ c
#     @test c == scale(b, 10, 10) ∩ c

#     out = Segment(-3, 8, 6, -4)
#     overlaper = Segment(c, 6, -4)
#     overlap = Segment(c, 3, 0)

#     @test Shapes.overlapping_segment(a, out) ≈ a
#     @test Shapes.overlapping_segment(a, overlaper) ≈ overlap
# end

# @testset "lines" begin
#     l = Line(2, 0, 0, 2)
#     @test l ≈ Line(π/4, sqrt(2))
#     @test l + Point(0, 1) ≈ Line(3, 0, 0, 3)
#     @test 2*l ≈ Line(4, 0, 0, 4)
#     @test Shapes.orth_project(Point(2, 4), l) ≈ Point(0, 2)
#     @test Shapes.orth_project(Point(-2,0), l) ≈ Point(0, 2)
#     @test Shapes.orth_project(Point(2, 4), l) ≈ Point(0, 2)
#     @test Shapes.orth_project(Point(4, 2), l) ≈ Point(2, 0)
#     @test Shapes.orth_project(Point(0,-2), l) ≈ Point(2, 0)
#     @test dist(l, Point(2, 2)) ≈ sqrt(2)
#     @test dist(rotate(l, π/4), Point(2, 2sqrt(2))) ≈ sqrt(2)
#     @test Point(2, 0) ∈ l
#     @test Point(2, 2) ∉ l
#     @test Point(2, 0) ∩ l ≈ Point(2, 0)
#     @test l ∩ Line(0,0, 1,1) ≈ Point(1,1)
#     @test l ∩ Line(1, -1, 2, 0) ≈ Point(2, 0)
#     @test l ∩ Line(-1, 1, 0, 2) ≈ Point(0, 2)
#     @test l ∩ Line(1, 0, 1, 1) ≈ Point(1, 1)
#     p = l ∩ rotate(l, rand())
#     @test p ∈ l
#     @test Shapes.orth_project(p, l) ≈ p
#     @test dist(p, l)+1 ≈ 1
#     @test isnothing(l ∩ (l+Point(0, 1)))
#     @test isnothing(l ∩ (l+Point(-1, -1)))
#     @test l ∩ Line(-1, -1, 1, 1) ≈ Point(1, 1)
#     @test l ∩ Line(0, -2, 2, 0) ≈ Point(2, 0)
# end

# @testset "axis-rect" begin
#     a = AxisRect(-1, -1, 2, 2)
#     c = corners(a)
#     s = sides(a)
#     @test c.tl == Point(-1, -1)
#     @test c.tr == Point(1,  -1)
#     @test c.bl == Point(-1,  1)
#     @test c.br == Point(1,   1)
#     @test s.t == Segment(c.tl, c.tr)
#     @test s.l == Segment(c.tl, c.bl)
#     @test s.b == Segment(c.bl, c.br)
#     @test s.r == Segment(c.tr, c.br)
#     @test dist(Point(-2, -2), a) ≈ sqrt(2)
#     @test dist(Point(-2,  2), a) ≈ sqrt(2)
#     @test dist(Point( 2, -2), a) ≈ sqrt(2)
#     @test dist(Point( 2,  2), a) ≈ sqrt(2)
#     @test dist(Point(-2, -2), AxisRect(-1, -1, 10, 2)) ≈ sqrt(2)
#     @test dist(Point(10, -2), AxisRect(-1, -1, 10, 2)) ≈ sqrt(2)
#     @test dist(Point(5, -2), AxisRect(-1, -1, 10, 2)) ≈ 1
#     @test dist(Point(10, 0), AxisRect(-1, -1, 10, 2)) ≈ 1
#     @test dist(Point(0, 2), a) ≈ 1
#     @test dist(Point(0, -2), a) ≈ 1
#     @test dist(Point(2, 0), a) ≈ 1
#     @test dist(Point(-2, 0), a) ≈ 1
#     @test dist(Point(0,0), a) <= 0
#     @test Point(0.3, -0.234) ∈ a
#     @test isnothing(a ∩ AxisRect(-10, -10, 5, 5))
#     @test a ∩ AxisRect(-2, -2, 3, 3) ≈ a
#     @test a ∩ AxisRect(0, 0, 2, 2) ≈ AxisRect(0, 0, 1, 1)
#     @test a ∩ AxisRect(-2, -2, 2, 2) ≈ AxisRect(-1, -1, 1, 1)
#     @test a ∩ AxisRect(-2, 0, 2, 2)  ≈ AxisRect(-1, 0, 1, 1)
#     @test a ∩ AxisRect(0, -2, 2, 2)  ≈ AxisRect(0, -1, 1, 1)
#     @test a ∩ AxisRect(1, 0, 3, 3) ≈ Segment(1, 0, 1, 1)
#     @test a ∩ AxisRect(-2, 1, 2, 2) ≈ Segment(-1, 1, 0, 1)
#     @test a ∩ AxisRect(-3, -3, 2, 2) ≈ Point(-1, -1)
#     @test a ∩ AxisRect(1, -3, 2, 2) ≈ Point(1, -1)
# end

# @testset "rect" begin
#     r = Rect(1, -1, 4*sqrt(2), 2*sqrt(2), π/4)
#     c = corners(r)
#     @test c.tl ≈ Point(1, -1)
#     @test c.tr ≈ Point(5, 3)
#     @test c.bl ≈ Point(-1, 1)
#     @test c.br ≈ Point(3, 5)
#     @test dist(Point(1, -2), r) ≈ 1
#     @test dist(Point(-2, 1), r) ≈ 1
#     @test dist(Point(3, 6), r) ≈ 1
#     @test dist(Point(6, 3), r) ≈ 1
#     @test dist(Point(4, 0), r) ≈ sqrt(2)
#     @test dist(Point(5, 5), r) ≈ sqrt(2)
#     @test r+Point(1, -1) ≈ Rect(Point(2, -2), 4*sqrt(2), 2*sqrt(2), π/4)
#     @test rotate(r, π) ≈ scale(r, -1, -1)
#     @test Point(1, 1) ∩ r == Point(1, 1)
#     @test Point(4, 3) ∈ r
#     @test Point(1, 4) ∉ r
# end

# @testset "circle" begin
#     c = Circle(Point(1,1), 5)
#     @test 0 < dist(Point(4, -4), c) < 1
#     @test 0 < dist(Point(6, -2), c) < 1
#     l = Line(-π/4, 3*sqrt(2))
#     @test (l + Point(1, 1)) ∩ Circle(1, 1, 3*sqrt(2)) ≈ (Point(3, -3) + Point(1, 1))
#     @test (l + Point(1, 0)) ∩ Circle(1, 0, 3*sqrt(2)) ≈ (Point(3, -3) + Point(1, 0))
#     @test (l + Point(-1, 2)) ∩ Circle(-1, 2, 3*sqrt(2)) ≈ (Point(3, -3) + Point(-1, 2))
#     @test c ∩ Line(-2, -3, 5, -2) ≈ Segment(-2, -3, 5, -2)  
#     @test Point(3, 5) ∈ c
#     @test Point(4, 5) ∈ c
#     @test Point(5, 5) ∉ c
# end

# @testset "ellipse" begin
#     e = Ellipse(1, 1, 1, 2)
#     mj, mn = Shapes.axes(e)
#     mind = dist(Point(1, 1), e)
#     for i=1:20
#         p = Point(1 + 2randn(), 1 + 3randn())
#         @test dist(p, e) >= mind
#         @test !((p ∉ e) ⊻ (dist(p, e) >= 0))
#     end
#     @test mj ≈ Segment(1, -1, 1, 3)
#     @test mn ≈ Segment(0, 1, 2, 1)
#     @test dist(Point(1, -2), e) ≈ 1
#     @test dist(Point(-1, 1), e) ≈ 1
#     @test dist(e, Point(3, 1)) ≈ 1
#     @test dist(e, Point(1, 4)) ≈ 1
#     @test 0 < dist(e, Point(2, 3)) < 1
#     @test Point(1.01, 2.9) ∈ e
#     @test Point(0.9, -1) ∉ e
    
#     scale(e - Point(1, 1), 2, 1) ≈ Ellipse(0, 0, 2, 2)
# end


# @testset "triangle" begin
#     t = Triangle(0, 0, 1, 0, 0, 1)
#     tt = scale(rotate(translate(t, -1, -1), π), 2, 3)
#     @test tt ≈ Triangle(2, 0, 0, 3, 2, 3)
#     @test t != tt
#     @test Point(0.25, 0.25) ∈ t
#     @test Point(0.25, 0.25) ∉ tt
#     @test Point(1, 2) ∈ tt
#     @test dist(Point(1, 1), t) ≈ sqrt(0.5)
#     @test dist(Point(3, 2), tt) ≈ 1
#     @test dist(Point(3, 4), tt) ≈ sqrt(2)
#     @test scale(t, 3, 3) ∩ Line(0, 2, 2, 1) ≈ Segment(0, 2, 2, 1)
#     t = Triangle(0, 0, 0, 1, 1, 0) # reverse order
#     @test tt ≈ Triangle(2, 0, 0, 3, 2, 3)
#     @test t != tt
#     @test Point(0.25, 0.25) ∈ t
#     @test Point(0.25, 0.25) ∉ tt
#     @test Point(1, 2) ∈ tt
#     @test dist(Point(1, 1), t) ≈ sqrt(0.5)
#     @test dist(Point(3, 2), tt) ≈ 1
#     @test dist(Point(3, 4), tt) ≈ sqrt(2)
#     @test scale(t, 3, 3) ∩ Line(0, 2, 2, 1) ≈ Segment(0, 2, 2, 1)
# end


# Quatrilateral
# Polygon