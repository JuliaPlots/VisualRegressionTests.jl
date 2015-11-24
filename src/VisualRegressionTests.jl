module VisualRegressionTests

# include this first to help with crashing??
try
  @eval using Gtk
catch err
  warn("Gtk not loaded. err: $err")
end

import Images, ImageMagick, FactCheck


@enum VisualTestStatus EXACT_MATCH CLOSE_MATCH DOES_NOT_MATCH PROCESSING_ERROR 

type VisualTest
    testFilename::AbstractString
    testImage
    referenceFilename::AbstractString
    referenceImage
    status::VisualTestStatus
    diff::Float64
    err
end

export
    compare_images

include("gui.jl")
include("imgcomp.jl")

end # module
