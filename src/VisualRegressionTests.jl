module VisualRegressionTests

# include this first to help with crashing??
try
    @eval using Gtk
catch err
    warn("Gtk not loaded. err: $err")
end

import Images, FactCheck

try
    @eval import ImageMagick
catch
    @eval function init_deps()
        ccall((:MagickWandGenesis,libwand), Void, ())
    end
    @eval import ImageMagick
end

# ---------------------------------------------

type VisualTest
    testFilename::AbstractString

    # function taking (output_filename, args...; kw...) and writing to output_filename
    testFunction::Function
    args
    kw

    referenceFilename::AbstractString
end

function VisualTest(testFunction::Function, referenceFilename::AbstractString, args...; kw...)
    VisualTest(tempname() * ".png", testFunction, args, kw, referenceFilename)
end

# ---------------------------------------------

# type VisualTests
#     referenceDirectory::AbstractString
#     tests::Vector{VisualTests}
# end

# ---------------------------------------------


@enum VisualTestStatus EXACT_MATCH CLOSE_MATCH DOES_NOT_MATCH PROCESSING_ERROR 

type VisualTestResult
    testFilename::AbstractString
    testImage
    referenceFilename::AbstractString
    referenceImage
    status::VisualTestStatus
    diff::Float64
    err
end


# ---------------------------------------------


export
    compare_images,
    test_images,
    VisualTest

include("gui.jl")
include("imgcomp.jl")

end # module
