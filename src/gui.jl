
function image_widget(fn)
  img = Gtk.GtkImageLeaf(fn)
  vbox = Gtk.GtkBoxLeaf(:v)
  push!(vbox, Gtk.GtkLabelLeaf(fn))
  push!(vbox, img)
  show(img)
  vbox
end

function replace_refimg(tmpfn, reffn)
  mkpath(reffn)
  cp(tmpfn, reffn, remove_destination = true)
  info("Replaced reference image $reffn with $tmpfn")
end

"Show a Gtk popup with both images and a confirmation whether we should replace the new image with the old one"
function replace_refimg_dialog(tmpfn, reffn_old; reffn_new = reffn_old)

  # add the images
  imgbox = Gtk.GtkBoxLeaf(:h)
  push!(imgbox, image_widget(tmpfn))
  push!(imgbox, image_widget(reffn_old))

  win = Gtk.GtkWindowLeaf("Should we make this the new reference image?")
  push!(win, Gtk.GtkFrameLeaf(imgbox))

  showall(win)

  # now ask the question
  if Gtk.ask_dialog("Should we make this the new reference image?", "No", "Yes")
    replace_refimg(tmpfn, reffn_new)
  end

  destroy(win)
end
