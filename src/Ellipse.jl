
struct Ellipse
    c::Point{Float64}
    rx::Float64 # along x axis
    ry::Float64 # along y axis
    θ::Float64
end


function horizontal_bounds(e::Ellipse)
    θ = mod(e.θ, π)
    if θ == 0    return Line(e.c + Point(0, e.ry), e.c - Point(0, e.ry)) end
    if θ == π/2  return Line(e.c + Point(0, e.rx), e.c - Point(0, e.rx)) end
    s = sin(e.θ) / cos(e.θ)
    x = (e.rx^2*s) / sqrt(e.ry^2 + s^2*e.rx^2)
    # x = s / (sqrt(e.rx^2 * e.ry^2 + s^2/e.rx^2))
    # print(s, ", ", x, ", ")
    y = e.ry * sqrt(1 - (x/e.rx)^2)

    top = rotate(Point(x, y), e.θ)
    return Line(e.c + top, e.c - top)
end