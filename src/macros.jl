macro visualtest(testfun, refname, popup=true, tol=1e-3)
  esc(quote
    testFilename = joinpath($path, tempname() * ".png")
    $testfun(testFilename)
    @test test_images(testFilename, $refname, popup=$popup, tol=$tol) |> success
  end)
end

macro plottest(plotfun, refname, popup=true, tol=1e-3)
  esc(quote
    testFilename = joinpath($path, tempname() * ".png")
    if $plotfun isa Function
      $plotfun()
    else # function body
      $plotfun
    end
    png(testFilename)
    @test test_images(testFilename, $refname, popup=$popup, tol=$tol) |> success
  end)
end
