using VisualRegressionTests
using Pkg, Test, Plots

# popup on local machine only
istravis = "TRAVIS" ∈ keys(ENV)
if !istravis
  Pkg.add("Gtk")
  using Gtk
end

# load an image for testing
import FileIO, TestImages
img = TestImages.testimage("cameraman")

# save a temporary copy
reffn = tempname() * ".png"
FileIO.save(reffn, img)

# this is the test function, which saves an image to the given location
func = fn -> FileIO.save(fn, img)

@testset "VisualRegressionTests.jl" begin
  @testset "Basic" begin
    result = test_images(VisualTest(func, reffn))
    @test isa(result, VisualTestResult)
    @test result.status == EXACT_MATCH
    @test result.err == nothing
    @test result.diff == 0
  end

  @testset "Macros" begin
    @visualtest func "VisualTest.png" !istravis

    @plottest plot([1.,2.,3.]) "PlotTest.png" !istravis

    @plottest begin
      plot([1.,2.,3.])
      plot!([3.,2.,1.])
    end "MorePlotTest.png" !istravis

    plotit() = plot([1.,2.,3.])
    @plottest plotit "FuncPlotTest.png" !istravis
  end
end
