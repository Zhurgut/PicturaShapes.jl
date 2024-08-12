

# just overwrite display..
function Base.show(io::IO, ::MIME"text/plain", p::Point{T}) where T <: AbstractFloat
    print(io, align(p))
end