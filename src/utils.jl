# a few utility functions copied/adapted from Images.jl

# github.com/JuliaGraphics/ColorVectorSpace.jl#abs-and-abs2
_abs(c::CT) where CT<:Color = mapreducec(v->abs(float(v)), +, zero(eltype(CT)), c)
_abs(c) = mapreducec(v->abs(float(v)), +, 0, c)

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
    diffscale = max(_abs(maximum_finite(abs, A)), _abs(maximum_finite(abs, B)))
    diffpct = d / (length(Af) * diffscale)

    diffpct
end
