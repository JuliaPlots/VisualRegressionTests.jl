using VisualRegressionTests
using Test

# load an image for testing
import FileIO, TestImages
img = TestImages.testimage("cameraman")

# save a temporary copy
reffn = tempname() * ".png"
FileIO.save(reffn, img)

# this is the test function, which saves an image to the given location
func = fn -> FileIO.save(fn, img)

# do the test
result = test_images(VisualTest(func, reffn))

@test isa(result, VisualTestResult)
@test result.status == EXACT_MATCH
@test result.err == nothing
@test result.diff == 0
