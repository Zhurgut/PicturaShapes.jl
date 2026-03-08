

struct Rect{T} <: AbstractQuatrilateral{T}
    tl::Point{T}
    w::T
    h::T
    θ::Float64
end



Rect(p::Point, w, h, θ; mode=:corner) = Rect(p, w, h, θ, mode)
Rect(x, y, w, h, θ; mode=:corner)     = Rect(Point(x, y), w, h, θ, mode)


function Rect(p::Point{P}, w::W, h::H, θ, mode::Symbol) where {P, W, H}
    a = AxisRect(Point(0,0), w, h, mode=mode)
    tl = rotate(a.tl, θ)
    T = promote_type(typeof(tl.x), P, W, H)
    return Rect{T}(Point{T}(tl + p), T(a.w), T(a.h), Float64(θ))
end


function Rect(diagonal::Segment, other::Point)
    tl, br, bl = if is_on_right_side(diagonal, other)
        diagonal.p1, diagonal.p2, other
    else 
        diagonal.p2, diagonal.p1, other
    end
    w = sdf(br, bl)
    h = sdf(tl, bl)
    θ = angle(br - bl)
    return Rect(tl, w, h, θ)
end


function Rect(;tl::Union{Nothing, Point} = nothing, 
               tr::Union{Nothing, Point} = nothing, 
               bl::Union{Nothing, Point} = nothing, 
               br::Union{Nothing, Point} = nothing)
    
    nr_points = 4 - sum(isnothing.((tl, tr, bl, br)))
    if nr_points < 3 error("not enough points, need at least 3") end

    if isnothing(tl)
        tl = tr + (bl - br)
    elseif isnothing(tr)
        tr = tl + (br - bl)
    elseif isnothing(bl)
        bl = br + (tl - tr)
    end

    return Rect(Segment(tr, bl), tl)
end

Base.convert(::Type{Rect{T}}, s::Rect) where T = Rect{T}(Point{T}(s.tl), T(s.w), T(s.h), s.θ)
Rect{T}(r) where T = convert(Rect{T}, r)






function center(r::Rect)
    c = corners(r)
    return 0.5(c.tl + c.br)
end

function corners(r::Rect, type::Type{T}=Float64) where T
    c = corners(AxisRect(Point(0,0), r.w, r.h))
    a,b,e,f = rotate(c.tl, r.θ), rotate(c.tr, r.θ), rotate(c.bl, r.θ), rotate(c.br, r.θ)
    d = a + r.tl, b + r.tl, e + r.tl, f + r.tl
    return (tl=Point{T}(d[1]), tr=Point{T}(d[2]), bl=Point{T}(d[3]), br=Point{T}(d[4]))
end

function sides(r::Rect)
    c = corners(r)
    t = Segment(c.tl, c.tr)
    l = Segment(c.bl, c.tl)
    b = Segment(c.br, c.bl)
    r = Segment(c.tr, c.br)
    return (t, l, b, r)
end



function sdf(p::Point, r::Rect)
    p2 = rotate(p - r.tl, -r.θ)
    return sdf(p2, AxisRect(Point(0,0), r.w, r.h))
end



rotate(r::Rect, θ)         = Rect(rotate(r.tl, θ), r.w, r.h, mod2pi(r.θ + θ)) # around origin, the whole thing!
translate(r::Rect, dx, dy) = Rect(r.tl + Point(dx, dy), r.w, r.h, r.θ)
function scale(r::Rect, sx, sy)
    c = corners(r)
    if sx < 0 <= sy || sy < 0 <= sx
        return Quatrilateral(scale(c.tl, sx, sy), scale(c.bl, sx, sy), scale(c.br, sx, sy), scale(c.tr, sx, sy))
    end
    return Quatrilateral(scale(c.tl, sx, sy), scale(c.tr, sx, sy), scale(c.br, sx, sy), scale(c.bl, sx, sy))
end


function simplify(r::Rect)
    if r.θ == 0 || r.θ == 2π
        return AxisRect(r.tl, r.w, r.h)
    end
    return nothing
end




function Base.in(p::Point, r::Rect)
    p2 = rotate(p - r.tl, -r.θ)
    return p2 ∈ AxisRect(Point(0,0), r.w, r.h)
end





