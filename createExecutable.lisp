(setf SB-IMPL::*DEFAULT-EXTERNAL-FORMAT* :utf-8) ;;This was added so there's no need to change file encoding when developing on Windows
(load "packages.lisp")
(load "pesukonevahti.lisp")
#+:OS-WINDOWS (save-lisp-and-die "vahti.exe" :toplevel #'pesukonevahti:tarkasta :executable t)
#+:LINUX (save-lisp-and-die "vahti" :toplevel #'pesukonevahti:tarkasta :executable t)
