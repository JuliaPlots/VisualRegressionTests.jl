macro visualtest(testfun, refname, popup=true, tol=0.02)
  esc(quote
    vt = VisualTest($testfun, $refname)
    @test test_images(vt, popup=$popup, tol=$tol) |> success
  end)
end
