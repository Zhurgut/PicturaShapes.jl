


function Rect(p::Point{F}, w, h, θ, mode) where F
    if mode == :center
        tlc = rotate(Point(-w/2, -h/2), θ) + p
        Tc = promote_type(typeof(tlc.x), typeof(w), typeof(h))
        return Rect{Tc}(tlc, w, h, θ)
    elseif mode == :radius
        tlr = rotate(Point(-w, -h), θ) + p
        Tr = promote_type(typeof(tlr.x), typeof(w), typeof(h))
        return Rect{Tr}(tlr, 2w, 2h, θ)
    else # mode == corner
        T = promote_type(F, typeof(w), typeof(h))
        return Rect{T}(Point{T}(p), w, h, θ)
    end
end

Rect(x, y, w, h, θ=0.0; mode=:corner) =  Rect(Point(x, y), w, h, θ, mode)
Rect(p::Point{T}, w, h, θ=0.0; mode=:corner) where T  = Rect(p, w, h, θ, mode)
Rect(a::AxisRect{T}) where T = Rect{T}(a.tl, a.w, a.h, 0.0)

function Rect{T}(r::Rect{S}) where {T, S}
    a = AxisRect{T}(AxisRect(r.tl, r.w, r.h))
    Rect{T}(a.tl, a.w, a.h, r.θ)
end

function Rect(;tl::Union{Nothing, Point{T1}} = nothing, 
               tr::Union{Nothing, Point{T2}} = nothing, 
               bl::Union{Nothing, Point{T3}} = nothing, 
               br::Union{Nothing, Point{T4}} = nothing) where {T1, T2, T3, T4}
    nr_points = 4 - sum(isnothing.((tl, tr, bl, br)))

    nr_points >= 3 || error("not enough points, need at least 3")
    (bl != tl != tr && bl != br != tr && tl != br && tr != bl) || error("points coincide with each other, cannot construct rectangle")

    w, θ = if !isnothing(tl) && !isnothing(tr)
            dist(tl, tr), atan((tr-tl).y, (tr-tl).x)
        elseif !isnothing(bl) && !isnothing(br)
            dist(bl, br), atan((br-bl).y, (br-bl).x)
        end
    h = if !isnothing(tl) && !isnothing(bl)
            dist(tl, bl)
        elseif !isnothing(tr) && !isnothing(br)
            dist(tr, br)
        end
    if isnothing(tl)
        tl = tr + (bl-br)
    end
    return Rect(tl, w, h, θ)
end



Base.:(+)(r::Rect{T}, p::Point{S}) where {S, T} = Rect(r.tl + p, r.w, r.h, r.θ)
Base.:(-)(r::Rect{T}, p::Point{S}) where {S, T} = r + (-p)
Base.:(*)(s, r::Rect{T}) where T = Rect(s*r.tl, s*r.w, s*r.h, r.θ)


function center(r::Rect{T}) where T
    c = corners(r)
    return 0.5(c.tl + c.br)
end

function corners(r::Rect{T}) where T
    c = corners(AxisRect(Point(0,0), r.w, r.h))
    d = rotate.((c.tr, c.bl, c.br), r.θ)
    return (tl=r.tl, tr=d[1] + r.tl, bl=d[2] + r.tl, br=d[3] + r.tl)
end

function sides(r::Rect{T}) where T
    c = corners(r)
    t = Segment(c.tl, c.tr)
    l = Segment(c.tl, c.bl)
    b = Segment(c.bl, c.br)
    r = Segment(c.tr, c.br)
    return (t=t, l=l, b=b, r=r)
end




function dist(p::Point{T}, r::Rect{S}) where {T,S}
    p2 = rotate(p - r.tl, -r.θ)
    return dist(p2, AxisRect(Point(0,0), r.w, r.h))
end




function Base.:(==)(a::Rect{T}, b::Rect{S}) where {T, S}
    tl1, tr1, bl1, br1 = corners(a)
    tl2, tr2, bl2, br2 = corners(b)
    return (tr1 == tr2 && tl1 == tl2 && bl1 == bl2) ||
           (tr1 == br2 && tl1 == tr2 && bl1 == tl2) ||
           (tr1 == bl2 && tl1 == br2 && bl1 == tr2) ||
           (tr1 == tl2 && tl1 == bl2 && bl1 == br2)
end
function Base.isapprox(a::Rect{T}, b::Rect{S}) where {T, S}
    tl1, tr1, bl1, br1 = corners(a)
    tl2, tr2, bl2, br2 = corners(b)
    return (tr1 ≈ tr2 && tl1 ≈ tl2 && bl1 ≈ bl2) ||
           (tr1 ≈ br2 && tl1 ≈ tr2 && bl1 ≈ tl2) ||
           (tr1 ≈ bl2 && tl1 ≈ br2 && bl1 ≈ tr2) ||
           (tr1 ≈ tl2 && tl1 ≈ bl2 && bl1 ≈ br2)
end


rotate(r::Rect{T}, θ) where T = Rect(rotate(r.tl, θ), r.w, r.h, r.θ + θ) # around origin, the whole thing!
translate(r::Rect{T}, dx, dy) where T = Rect(r.tl + Point(dx, dy), r.w, r.h, r.θ)
function scale(r::Rect{T}, sx, sy) where T
    c = corners(r)
    if r.θ == 0
        return scale(AxisRect(r.tl, c.tr.x - c.tl.x, c.bl.y - c.tl.y), sx, sy)
    end
    if sx == sy
        Rect(tl=scale(c.tl, sx, sy), tr=scale(c.tr, sx, sy), bl=scale(c.bl, sx, sy))
    end
    return Quatrilateral(scale(c.tl, sx, sy), scale(c.tr, sx, sy), scale(c.br, sx, sy), scale(c.bl, sx, sy))
end




function Base.in(p::Point{T}, r::Rect{S}) where {T, S}
    p2 = rotate(p - r.tl, -r.θ)
    return p2 ∈ AxisRect(Point(0,0), r.w, r.h)
end




Base.intersect(p::Point{T}, r::Rect{S}) where {T, S} = p ∈ r ? p : nothing




