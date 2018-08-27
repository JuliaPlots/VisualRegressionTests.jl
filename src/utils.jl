# a few utility functions copied/adapted from Images.jl

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
    diffscale = max(maxabsfinite(A), maxabsfinite(B))
    diffpct = d / (length(Af) * diffscale)

    diffpct
end

sad(A::AbstractArray, B::AbstractArray) = sumdiff(abs, A, B)

function sumdiff(f, A::AbstractArray, B::AbstractArray)
    axes(A) == axes(B) || throw(DimensionMismatch("A and B must have the same indices"))
    T = promote_type(difftype(eltype(A)), difftype(eltype(B)))
    s = zero(accum(eltype(T)))
    for (a, b) in zip(A, B)
        x = convert(T, a) - convert(T, b)
        s += f(x)
    end
    s
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

"maximum absolute value in `A` ignoring `Inf` or `NaN`"
function maxabsfinite(A)
    m = -Inf
    for a in A
        v = abs(a)
        if isfinite(v) && v > m
            m = v
        end
    end
    m
end
