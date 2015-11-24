
function makeImageWidget(fn)
  img = Gtk.GtkImageLeaf(fn)
  vbox = Gtk.GtkBoxLeaf(:v)
  push!(vbox, Gtk.GtkLabelLeaf(fn))
  push!(vbox, img)
  show(img)
  vbox
end

function replaceReferenceImage(tmpfn, reffn)
  cmd = `cp $tmpfn $reffn`
  run(cmd)
  info("Replaced reference image with: $cmd")
end

"Show a Gtk popup with both images and a confirmation whether we should replace the new image with the old one"
function compareToReferenceImage(tmpfn, reffn)

  # add the images
  imgbox = Gtk.GtkBoxLeaf(:h)
  push!(imgbox, makeImageWidget(tmpfn))
  push!(imgbox, makeImageWidget(reffn))

  win = Gtk.GtkWindowLeaf("Should we make this the new reference image?")
  push!(win, Gtk.GtkFrameLeaf(imgbox))

  showall(win)

  # now ask the question
  if Gtk.ask_dialog("Should we make this the new reference image?", "No", "Yes")
    replaceReferenceImage(tmpfn, reffn)
  end

  destroy(win)
end
