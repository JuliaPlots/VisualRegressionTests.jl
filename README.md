## VisualRegressionTests

Easy regression testing for visual packages.  Automated tests compare similarity between a newly generated image
and a reference image using the Images package.  While in interactive mode, the tests can optionally pop up a
Gtk GUI window showing a side-by-side comparison of the test and reference image, and then optionally overwrite
the reference image with the test image.  This allows for straightforward regression testing of image data, even
when the "correct" images change over time.

#### Author: Thomas Breloff (@tbreloff)

[![Build Status](https://travis-ci.org/tbreloff/VisualRegressionTests.jl.svg?branch=master)](https://travis-ci.org/tbreloff/VisualRegressionTests.jl)

Setup:
```
julia> using VisualRegressionTests
julia> using Plots; gr();
```

Our test function.  Make a scatter plot using the GR backend, and save a png to the location given.
```
julia> func = fn -> begin
           scatter(rand(100), size=(300,400))
           png(fn)
       end
(anonymous function)
```

Create a reference image:
```
julia> reffn = tempname() * ".png"
"/tmp/juliaSVc8Po.png"

julia> func(reffn)
```

Now do a test.  It should fail since we're plotting different random values.
```
julia> result = test_images(VisualTest(func, reffn))
WARNING: Got error: ErrorException("Arrays differ.  Difference: 0.10559923034291491  eps: 0.02")
WARNING: Image did not match reference image /tmp/juliaSVc8Po.png. err: ErrorException("Arrays differ.  Difference: 0.10559923034291491  eps: 0.02")
WARNING: Should we make this the new reference image?
VisualRegressionTests.VisualTestResult("/tmp/juliaB4oxB0.png",RGB Images.Image with:
  data: 300x400 Array{ColorTypes.RGB{FixedPointNumbers.UFixed{UInt8,8}},2}
  properties:
    colorspace: sRGB
    spatialorder:  x y,"/tmp/juliaSVc8Po.png",RGB Images.Image with:
  data: 300x400 Array{ColorTypes.RGB{FixedPointNumbers.UFixed{UInt8,8}},2}
  properties:
    colorspace: sRGB
    spatialorder:  x y,DOES_NOT_MATCH::VisualRegressionTests.VisualTestStatus,0.10559923034291491,ErrorException("Arrays differ.  Difference: 0.10559923034291491  eps: 0.02"))

```

The result contains some useful fields, including `status`, `diff`, and `err`, as well as the filenames and `Image`s which were tested.

For automated tests, you can use `Base.success`:

```
julia> using Base.Test

julia> @test test_images(VisualTest(func, reffn), popup=false) |> success

WARNING: Got error: ErrorException("Arrays differ.  Difference: 0.10323637729974526  eps: 0.02")
WARNING: Image did not match reference image /tmp/juliaSVc8Po.png. err: ErrorException("Arrays differ.  Difference: 0.10323637729974526  eps: 0.02")
ERROR: test failed: test_images(VisualTest(func,reffn),popup=false) |> success
 in expression: test_images(VisualTest(func,reffn),popup=false) |> success
 in error at ./error.jl:21
 in default_handler at test.jl:30
 in do_test at test.jl:53
```

### Example GUI popup:

![popup](popup.png)
