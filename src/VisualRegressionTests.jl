module VisualRegressionTests

# Gtk is optional since it's only used for the GUI popup
try
    @eval using Gtk
catch err
    warn("Gtk not loaded. err: $err")
end

import Images

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


Base.success(result::VisualTestResult) = result.status in (EXACT_MATCH, CLOSE_MATCH)

# ---------------------------------------------


export
    compare_images,
    test_images,
    VisualTest,
    VisualTestStatus,
    VisualTestResult,
    EXACT_MATCH,
    CLOSE_MATCH,
    DOES_NOT_MATCH,
    PROCESSING_ERROR

include("gui.jl")
include("imgcomp.jl")

end # module
