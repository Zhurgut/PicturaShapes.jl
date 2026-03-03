
using Test
using PicturaShapes
using LinearAlgebra
using Pictura




@testset "constructors" begin
    a = Point(1, 2)
    @test typeof(a) == Point{Int}
    @test typeof(Point(1, 2.0)) == Point{Float64}
    @test typeof(Point{Float64}(a)) == Point{Float64}
    a2::Point{Float64} = a
    @test a2 == a

    s = Segment(1, 2, 3, 4)
    @test typeof(s) == Segment{Int}
    @test typeof(Segment(a, Point(1, 2.0))) == Segment{Float64}
    @test typeof(Segment(Point(1, 2), 1, 2)) == Segment{Int}
    s2::Segment{Float64} = s
    @test s == s2
    l = Line(rand(), rand())
    s3 = Segment(l)
    @test s3 ∩ l ≈ s3

    l1 = Line(1, 0, 0, 1)
    l2 = Line(angle(Point(1,1)), sqrt(2)/2)
    @test Segment(l1) ≈ Segment(l2)
    l3 = Line(-1, 0, 0, -1)
    l4 = Line(angle(Point(-1, -1)), sqrt(2)/2)
    @test Segment(l3) ≈ Segment(l4)
    for i=1:10
        rs = Segment(randn(), randn(), randn(), randn())
        ls = Line(rs)
        @test rs ∩ ls ≈ rs
        rs = Segment(ls)
        ls = Line(rs)
        @test rs ∩ ls ≈ rs
    end

    ar1 = AxisRect(-2, -1, 4, 2)
    ar2 = AxisRect(0, 0, 4, 2, mode=:center)
    ar3 = AxisRect(0, 0, 2, 1, mode=:radius)
    ar4 = AxisRect(Point(-2, -1), Point(2, 1))
    @test typeof(ar1) == AxisRect{Int}
    @test ar1 == ar2
    @test ar1 == ar3
    @test ar1 == ar4

    r1 = Rect(Point(-4, 0), 7.2915, 3.2915, -0.42403)
    r2 = rotate(AxisRect(0,0, 7.2915026221, 3.291502622, mode=:center), -0.42403)
    rcs = corners(r1)
    r3 = Rect(tl=rcs.tl, tr=rcs.tr, bl=rcs.bl)
    r4 = Rect(0,0, 7.2915026221, 3.291502622, -0.42403, mode=:center)
    r5 = Rect(0,0, 7.2915026221/2, 3.291502622/2, -0.42403, mode=:radius)
    @test typeof(Rect(-1, -1.0f0, 1, 1, 1.0f0)) == Rect{Float32}
    @test r1 ≈ r2
    @test r1 ≈ r3
    @test r1 ≈ r4
    @test r1 ≈ r5

    c1 = Circle(Point(1,1), 5)
    c2 = Circle(1, 1.0, 4.99999999)
    c3::Circle{Float64} = c1
    @test typeof(c1) == Circle{Int}
    @test typeof(c2) == Circle{Float64}
    @test c1 == c3
    @test c1 ≈ c2

    e1 = Ellipse(1, 1, 1, 2) # TODO test constructors with focal points
    e2 = Ellipse(Point(1, 1), 2, 1, π/2)
    e3 = Ellipse(Point(1, 1-sqrt(3)), Point(1, 1+sqrt(3)), 2)
    e4 = Ellipse(Point(1, 1-sqrt(3)), Point(1, 1+sqrt(3)), 2.1)
    e5 = Ellipse(Point(1, 1), Point(2, 1), Point(1, 3))
    @test typeof(e1) == Ellipse{Int}
    @test typeof(e3) == Ellipse{Float64}
    @test e1 ≈ e2
    @test e1 ≈ e3
    @test e3 ≉ e4
    @test e1 ≈ e5

    # t1 = Triangle(1, 1, Point(2.0, 2), 3, 3.0)
    # t2 = Triangle(3, 3, 2, 2, 1, 1)
    # @test t1 ≈ t2
end

@testset "dist, translate, scale, rotate, boxes" begin
    function run(s)

        @setup begin
            size(600, 400, :fast)
            nofill()
        end

        @drawloop begin

            f = 50

            x = s
            if framecount() < f
                x = translate(s, framecount() - f/2, 50 * sin(framecount() / f))
            elseif framecount() < 2f
                x = scale(s, 0.6sin(framecount() / f) + 1, (framecount() - f + 1) / (1.5f))
            else
                x = rotate(s, framecount() / 8)
            end

            for c = 1:width(), r = 1:height()
                p = Point(c - width()/2, r - height()/2)
                if isnan(2 * abs(dist(p, x)) / width())
                    println(p)
                    println(x)
                    println(dist(p, x))
                end
                d = dist(p, x)
                if d < 0
                    strokecolor(0, 2 * abs(d) / width(), 2 * abs(d) / width())
                else
                    strokecolor(2 * abs(d) / width())
                end
                point(c-1, r-1)
            end

            if !(x isa Line)
                strokecolor(255, 0, 0, 150)
                draw(aligned_bounding_box(x, 10) + Point(width()/2, height()/2))
                strokecolor(0, 255, 0, 150)
                draw(bounding_box(x, 10) + Point(width()/2, height()/2))
            end
            
            if framecount() == 3f
                noloop()
            end
        end
    end

    p1 = Point(-70, -70)
    p2 = Point(100, 50)
    run(p1)
    run(Segment(p1, p2))
    run(Line(p1, p2))
    run(AxisRect(p1.x, p1.y, 200, 100))
    run(Rect(p1.x, p1.y, 200, 100, 0.3))
    run(Circle(p1, 100))
    run(Ellipse(p1, 200, 100, 0.3))
    run(Triangle(p1, p2, Point(-20, 80)))
    run(Triangle(Point(-20, 80), p2, p1))
    run(Quatrilateral(p1, Point(70, -60), p2, Point(-20, 80)))
    run(Quatrilateral(Point(-20, 80), p2, Point(70, -60), p1))
end


@testset "pretty print" begin
    function prints(s, is)
        println(s)
        display(s)
        println(is)
        display(is)
        println()
    end

    p = Point(Float64(π), Float64(π))
    ip = Point(Int8(1), Int8(2))
    prints(p, ip)

    s = Segment(p, 2p)
    is = Segment(ip, 2ip)
    prints(s, is)

    l = Line(s)
    il = Line(is)
    prints(l, il)

    a = AxisRect(p,p)
    ia = AxisRect(ip, ip)
    prints(a, ia)

    r = rotate(a, exp(1))
    ir = Rect(Point(1,2), 3,4, exp(1))
    prints(r, ir)

    c = Circle(p, exp(1))
    ic = Circle(ip, 2)
    prints(c, ic)

    e = Ellipse(p, 1/3, 1/6, exp(1))
    ie = Ellipse(ip, 3, 6, exp(1))
    prints(e, ie)

    t  = Triangle(6/2, 5/3, 4/4, 3/5, 2/6, 1/7)
    it = Triangle(((6/2, 5/3, 4/4, 3/5, 2/6, 1/7) .|> round .|> Int)...)
    prints(t, it)

    q = Quatrilateral(p,p,p,p)
    iq = Quatrilateral(ip, ip, ip, ip)
    prints(q, iq)

end

@testset "==, approx, align" begin
    e = 1e-12
    
    p1 = Point(0.2, 0.2)
    p2 = Point(0.2+e, 0.2+e)
    p3 = Point(0.3, 0.5)
    p4 = Point(0.3+e, 0.5+e)
    
    s1 = Segment(p1, p3)
    s2 = Segment(p2, p4)

    l1 = Line(p1, p3)
    l2 = Line(p2, p4)

    a1 = AxisRect(p1, p3)
    a2 = AxisRect(p2, p4)

    r1 = rotate(a1, 0.01)
    r2 = rotate(a2, 0.01)

    c1 = Circle(p1, 1)
    c2 = Circle(p2, 1+e)

    e1 = Ellipse(p1, 2, 1, 0.01)
    e2 = Ellipse(p2, 2+e, 1+e, 0.01)

    t1 = Triangle(p1, p3, Point(0, 1))
    t2 = Triangle(Point(0, 1), p2, p4)

    q1 = Quatrilateral(p1, p3, Point(0, 1), Point(0, 0.5))
    q2 = Quatrilateral(p4, Point(0+e, 1+e), Point(0+e, 0.5+e), p2)

    function f(s1, s2)
        @test s1 != s2
        @test s1 == s1
        @test s1 ≈ s2
        @test align(s1) == align(s2)
    end

    f(p1, p2)
    f(s1, s2)

    @test l1 != l2
    @test l1 == l1
    @test align(l1) == align(l2)
    
    f(a1, a2)
    f(r1, r2)
    f(c1, c2)
    f(e1, e2)
    f(t1, t2)
    f(q1, q2)
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



@testset "segments" begin # what are these tests doint?
    a = Segment(3, 0, 0, 4)
    b = Segment(0, 0, 4, 3)
    c = Point(48/25, 36/25)
    # @test = c ≈ (a ∩ b)::Point{Float64}
    @test a ≈ (rotate(b, π/2) + Point(3, 0))
    @test dist(Point(0,0), a - c)+1 ≈ 1.0
    @test c ∈ b
    @test Point(0,0) ∉ a
    @test a ∩ c == b ∩ c
    @test c == scale(b, 10, 10) ∩ c

    out = Segment(-3, 8, 6, -4)
    overlaper = Segment(c, 6, -4)
    overlap = Segment(c, 3, 0)

    @test Shapes.overlapping_segment(a, out) ≈ a
    @test Shapes.overlapping_segment(a, overlaper) ≈ overlap
end

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

@testset "Ellipse dist" begin
    e = Ellipse(0, 0, 2, 1)
    p1 = Point(2.2, 0.4)
    p2 = Point(-2.2, 0.4)
    p3 = Point(2.2, -0.4)
    p4 = Point(-2.2, -0.4)
    println(dist(p1, e))
    println(dist(p2, e))
    println(dist(p3, e))
    println(dist(p4, e))

    e = Ellipse(3, 3, 2, 1)
    p1 = Point(4, 5)
    p2 = Point(2, 5)
    p3 = Point(4, 1)
    p4 = Point(2, 1)
    println(dist(p1, e))
    println(dist(p2, e))
    println(dist(p3, e))
    println(dist(p4, e))

    for i=1:20
        θ = 4*rand()
        sx = 1/(3*randn())
        sy = 1/(3*randn())
        e = translate(Ellipse(0, 0, 2, 1, θ), sx, sy)
        p1 = translate(rotate(Point(1, 2), θ), sx, sy)
        p2 = translate(rotate(Point(-1, 2), θ), sx, sy)
        p3 = translate(rotate(Point(1, -2), θ), sx, sy)
        p4 = translate(rotate(Point(-1, -2), θ), sx, sy)
        println(dist(p1, e))
        println(dist(p2, e))
        println(dist(p3, e))
        println(dist(p4, e))
        # dist(Point(randn(), randn()), e)
    end
end


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