
# # include this first to help with crashing??
# try
#   @eval using Gtk
# catch err
#   warn("Gtk not loaded. err: $err")
# end

# # don't let pyplot use a gui... it'll crash
# # note: Agg will set gui -> :none in PyPlot
# ENV["MPLBACKEND"] = "Agg"
# try
#   @eval import PyPlot
#   info("Matplotlib version: $(PyPlot.matplotlib[:__version__])")
# end

# include("../docs/example_generation.jl")


# using Plots, FactCheck
# import Images, ImageMagick

# if !isdefined(ImageMagick, :init_deps)
#   function ImageMagick.init_deps()
#     ccall((:MagickWandGenesis,libwand), Void, ())
#   end
# end


# TODO: use julia's Condition type and the wait() and notify() functions to initialize a Window, then wait() on a condition that 
#       is referenced in a button press callback (the button clicked callback will call notify() on that condition)

# function image_comparison_tests(pkg::Symbol, idx::Int; sigma = [1,1], eps = 1e-2)
  
  # # first 
  # Plots._debugMode.on = debug
  # # info("Testing plot: $pkg:$idx:$(PlotExamples.examples[idx].header)")
  # backend(pkg)
  # backend()

  # # ensure consistent results
  # srand(1234)

  # TODO: how will we generate examples??

  # run the example
  # map(eval, PlotExamples.examples[idx].exprs)

  # # save the png
  # tmpfn = tempname() * ".png"
  # png(tmpfn)

  # # load the saved png
  # tmpimg = Images.load(tmpfn)

  # # reference image location
  # # TODO: this should be set by the user!
  # refdir = joinpath(Pkg.dir("Plots"), "test", "refimg", string(pkg))

  # try
  #   run(`mkdir -p $refdir`)
  # catch err
  #   display(err)
  # end

  # # TODO: the filename should be set by the user somehow
  # reffn = joinpath(refdir, "ref$idx.png")



function compare_images(testfn::AbstractString, reffn::AbstractString; sigma = [1,1], eps = 0.02)

    result = VisualTestResult(testfn, nothing, reffn, nothing, PROCESSING_ERROR, 1.0, nothing)

    # load the test image... if we error, return immediately
    try
        result.testImage = Images.load(testfn)
    catch err
        result.err = err
        return result
    end

    # load the ref image... if we error, return immediately
    try
        result.referenceImage = Images.load(reffn)
    catch err
        result.err = err
        return result
    end

    # we loaded both images, now do the comparison
    try

        # info("Comparing $tmpfn to reference $reffn")
      
        # # load the reference image
        # refimg = Images.load(reffn)

        # run the comparison test... a difference will throw an error
        # NOTE: sigma is a 2-length vector with x/y values for the number of pixels
        #       to blur together when comparing images
        result.diff = Images.test_approx_eq_sigma_eps(result.testImage, result.referenceImage, sigma, eps)

        # we passed!
        info("Reference image $reffn matches.  Difference: $(result.diff)")
        
        result.status = if result.diff == 0
          EXACT_MATCH
        else
          CLOSE_MATCH
        end

    catch err

        warn("Got error: $err")
        result.err = err
        result.status = DOES_NOT_MATCH

        # HACK: this will fail if the Images error message changes
        if typeof(err) == ErrorException
          msg = split(err.msg)
          if length(msg) > 2 && msg[1] == "Arrays" && msg[2] == "differ."
            result.diff = parse(Float64, msg[end-2])
          end
        end

        # warn("Image did not match reference image $reffn. err: $err")
        # # showerror(Base.STDERR, err)
        
        # if isinteractive()

        #   # if we're in interactive mode, open a popup and give us a chance to examine the images
        #   warn("Should we make this the new reference image?")
        #   compareToReferenceImage(tmpfn, reffn)
        #   # println("exited")
        #   return
          
        # else

        #   # if we rejected the image, or if we're in automated tests, throw the error
        #   rethrow(err)
        # end

    end

    result
end

Base.success(result::VisualTestResult) = result.status in (EXACT_MATCH, CLOSE_MATCH)

function test_images(testfn::AbstractString, reffn::AbstractString; popup=isinteractive(), kw...)
    result = compare_images(testfn, reffn; kw...)

    if !success(result)
        warn("Image did not match reference image $reffn. err: $(result.err)")

        if popup
            # open a popup and give us a chance to examine the images,
            # then ask to replace the reference
            warn("Should we make this the new reference image?")
            replace_refimg_dialog(testfn, reffn)
        end
    end

    result
end

function test_images(visualtest::VisualTest; popup=isinteractive(), kw...)
    visualtest.testFunction(visualtest.testFilename, visualtest.args...; visualtest.kw...)
    test_images(visualtest.testFilename, visualtest.referenceFilename; popup=popup, kw...)
end

function test_images(visualtests::AbstractVector{VisualTest}; popup=isinteractive(), kw...)
    VisualTestResult[test_images(vtest, popup=popup, kw...) for vtest in visualtests]
end


# function image_comparison_tests(pkg::Symbol; skip = [], debug = false, sigma = [1,1], eps = 1e-2)
#   for i in 1:length(PlotExamples.examples)
#     i in skip && continue
#     @fact image_comparison_tests(pkg, i, debug=debug, sigma=sigma, eps=eps) --> true
#   end
# end
