function compare_images(testfn::AbstractString, reffn::AbstractString; sigma = (1,1), tol = 0.02)

    result = VisualTestResult(testfn, nothing, reffn, nothing, PROCESSING_ERROR, 1.0, nothing)

    # load test and ref images... if error, return immediately
    try
        result.testImage = load(testfn)
        result.refImage  = load(reffn)
    catch err
        result.err = err
        return result
    end

    # we loaded both images, now do the comparison
    result.diff = blurdiff(result.testImage, result.refImage, sigma)

    if result.diff > tol
        result.status = DOES_NOT_MATCH
        result.err = "Images differ.  Difference: $diffpct  tolerance: $tol"
    else
        info("Reference image $reffn matches.  Difference: $(result.diff)")
        result.status = (result.diff == 0) ? EXACT_MATCH : CLOSE_MATCH
        result.err = nothing
    end

    result
end


function test_images(testfn::AbstractString, reffn::AbstractString; popup=isinteractive(), newfn = reffn, kw...)
    result = compare_images(testfn, reffn; kw...)

    if !success(result)
        warn("Image did not match reference image $reffn. err: $(result.err)")

        if popup
            # open a popup and give us a chance to examine the images,
            # then ask to replace the reference
            warn("Should we make this the new reference image?")
            replace_refimg_dialog(testfn, reffn; reffn_new = newfn)
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
