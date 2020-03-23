(load "packages.lisp")
(load "pesukonevahti.lisp")
(save-lisp-and-die "vahti" :toplevel #'pesukonevahti:tarkasta :executable t)
