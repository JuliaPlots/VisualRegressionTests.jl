using VisualRegressionTests
using Test, Plots, Gtk

# load an image for testing
import FileIO, TestImages
img = TestImages.testimage("cameraman")

# save a temporary copy
reffn = tempname() * ".png"
FileIO.save(reffn, img)

# this is the test function, which saves an image to the given location
func = fn -> FileIO.save(fn, img)

@testset "Basic" begin
  result = test_images(VisualTest(func, reffn))
  @test isa(result, VisualTestResult)
  @test result.status == EXACT_MATCH
  @test result.err == nothing
  @test result.diff == 0
end

@testset "Macros" begin
  @visualtest func "VisualTest.png"

  @plottest plot([1.,2.,3.]) "PlotTest.png"

  @plottest begin
    plot([1.,2.,3.])
    plot!([3.,2.,1.])
  end "MorePlotTest.png"

  plotit() = plot([1.,2.,3.])
  @plottest plotit "FuncPlotTest.png"
end
