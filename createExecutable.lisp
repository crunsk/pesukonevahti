(load "packages.lisp")
(load "pesukonevahti.lisp")
#+:OS-WINDOWS (save-lisp-and-die "vahti.exe" :toplevel #'pesukonevahti:tarkasta :executable t)
#+:LINUX (save-lisp-and-die "vahti" :toplevel #'pesukonevahti:tarkasta :executable t)
