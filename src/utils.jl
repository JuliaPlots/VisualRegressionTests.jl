# a few utility functions copied/adapted from Images.jl

# github.com/JuliaGraphics/ColorVectorSpace.jl#abs-and-abs2
_abs(c::CT) where CT<:Color = mapreducec(v->abs(float(v)), +, zero(eltype(CT)), c)

"blur images `A` and `B` with `sigma` and then compute a difference"
function blurdiff(A::AbstractArray, B::AbstractArray, sigma)
    # make sure arrays have the same size
    if size(A) != size(B)
        newsize = map(max, size(A), size(B))
        if size(A) != newsize
            A = copyto!(zeros(eltype(A), newsize...), A)
        end
        if size(B) != newsize
            B = copyto!(zeros(eltype(B), newsize...), B)
        end
    end

    kern = KernelFactors.IIRGaussian(sigma)
    Af = imfilter(A, kern, NA())
    Bf = imfilter(B, kern, NA())
    d = sad(Af, Bf)
    diffscale = max(_abs(maxabsfinite(A)), _abs(maxabsfinite(B)))
    diffpct = d / (length(Af) * diffscale)

    diffpct
end

difftype(::Type{T}) where {T<:Integer} = Int
difftype(::Type{T}) where {T<:Real} = Float32
difftype(::Type{Float64}) = Float64
difftype(::Type{CV}) where {CV<:Colorant} = difftype(CV, eltype(CV))
difftype(::Type{CV}, ::Type{T}) where {CV<:RGBA,T<:Real} = RGBA{Float32}
difftype(::Type{CV}, ::Type{Float64}) where {CV<:RGBA} = RGBA{Float64}
difftype(::Type{CV}, ::Type{T}) where {CV<:BGRA,T<:Real} = BGRA{Float32}
difftype(::Type{CV}, ::Type{Float64}) where {CV<:BGRA} = BGRA{Float64}
difftype(::Type{CV}, ::Type{T}) where {CV<:AbstractGray,T<:Real} = Gray{Float32}
difftype(::Type{CV}, ::Type{Float64}) where {CV<:AbstractGray} = Gray{Float64}
difftype(::Type{CV}, ::Type{T}) where {CV<:AbstractRGB,T<:Real} = RGB{Float32}
difftype(::Type{CV}, ::Type{Float64}) where {CV<:AbstractRGB} = RGB{Float64}

accum(::Type{T}) where {T<:Integer} = Int
accum(::Type{Float32})    = Float32
accum(::Type{T}) where {T<:Real} = Float64
accum(::Type{C}) where {C<:Colorant} = base_colorant_type(C){accum(eltype(C))}
