
function image_widget(fn)
  img = Gtk.GtkImageLeaf(fn)
  vbox = Gtk.GtkBoxLeaf(:v)
  push!(vbox, Gtk.GtkLabelLeaf(fn))
  push!(vbox, img)
  show(img)
  vbox
end

function replace_refimg(tmpfn, reffn)
  cmd = `cp $tmpfn $reffn`
  run(cmd)
  info("Replaced reference image with: $cmd")
end

"Show a Gtk popup with both images and a confirmation whether we should replace the new image with the old one"
function replace_refimg_dialog(tmpfn, reffn)

  # add the images
  imgbox = Gtk.GtkBoxLeaf(:h)
  push!(imgbox, image_widget(tmpfn))
  push!(imgbox, image_widget(reffn))

  win = Gtk.GtkWindowLeaf("Should we make this the new reference image?")
  push!(win, Gtk.GtkFrameLeaf(imgbox))

  showall(win)

  # now ask the question
  if Gtk.ask_dialog("Should we make this the new reference image?", "No", "Yes")
    replace_refimg(tmpfn, reffn)
  end

  destroy(win)
end
