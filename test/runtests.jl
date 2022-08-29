using Shapes
using Test

@testset "Constructors" begin
    @test typeof(Point(1, 2)) == Point{Int}
    @test typeof(Point(1.1, 2)) == Point{Float64}
    Point{Int}(1, 2)
    Point{Float64}(1.1, 2.2)
    Point{Float64}(1.1, 2)
    Point{Float64}(1, 2)
    a12::Point{Int} = Point{Float64}(1.0, 2.0)
    Point{Float64}(a12)

    a14::Line{Int} = Line(1.0, 2.0, 3.0, 4.0)
    @test a14 == Line{Int}(Point{Int}(1, 2), Point{Int}(3, 4))
    @test a14 == Line{Int}(1, 2.0, 3, 4)
    @test a14 == Line{Int}(Line{Float64}(1.0, 2.0, 3.0, 4.0))
    @test a14 == Line(Point(1,2), Point(3,4))
    @test a14 == Line{Int}(Point(1.0, 2.0), Point(3, 4))

    a21::Segment{Int} = Segment(1.0, 2.0, 3.0, 4.0)
    @test a21 == Segment{Int}(Point{Int}(1, 2), Point{Int}(3, 4))
    @test a21 == Segment{Int}(1, 2.0, 3, 4)
    @test a21 == Segment{Int}(Segment{Float64}(1.0, 2.0, 3.0, 4.0))
    @test a21 == Segment(Point(1,2), Point(3,4))
    @test a21 == Segment{Int}(Point(1.0, 2.0), Point(3, 4))

end
