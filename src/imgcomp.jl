
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

    end

    result
end


# -----------------------------------------------------

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

