module VisualRegressionTests

# Gtk is optional since it's only used for the GUI popup
try
    @eval using Gtk
catch err
    @warn "Gtk not loaded. err: $err"
end

using FileIO
using ColorTypes
using ColorVectorSpace
using ImageFiltering

# ---------------------------------------------

struct VisualTest
    testFilename::AbstractString
    testFunction::Function # function taking (output_filename, args...; kw...) and writing to output_filename
    args
    kw

    refFilename::AbstractString
end

function VisualTest(testFunction::Function, refFilename::AbstractString, args...; kw...)
    VisualTest(tempname() * ".png", testFunction, args, kw, refFilename)
end

# ---------------------------------------------

@enum VisualTestStatus EXACT_MATCH CLOSE_MATCH DOES_NOT_MATCH PROCESSING_ERROR

mutable struct VisualTestResult
    testFilename::AbstractString
    testImage
    refFilename::AbstractString
    refImage
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

include("utils.jl")
include("imgcomp.jl")
include("gui.jl")

end # module
