macro visualtest(testfun, refname, popup=true, tol=0.02)
  esc(quote
    testFilename = tempname()*".png"
    $testfun(testFilename)
    @test test_images(testFilename, $refname, popup=$popup, tol=$tol) |> success
  end)
end

macro plottest(plotfun, refname, popup=true, tol=0.02)
  esc(quote
    testFilename = tempname()*".png"
    if $plotfun isa Function
      $plotfun()
    else # function body
      $plotfun
    end
    png(testFilename)
    @test test_images(testFilename, $refname, popup=$popup, tol=$tol) |> success
  end)
end
