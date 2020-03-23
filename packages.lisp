(in-package "COMMON-LISP-USER")
(ql:quickload '(:dexador :plump :lquery :lparallel))
(ql:quickload "mixalot")
(ql:quickload "mixalot-mp3")
(defpackage :pesukonevahti
  (:use :common-lisp :dexador :plump :lquery :lparallel :mixalot :mixalot-mp3)
  (:shadowing-import-from :dexador :get :delete)
  (:export :tarkasta))
