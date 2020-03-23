(in-package :pesukonevahti)

(defvar *cookie-jar* (cl-cookie:make-cookie-jar))

(defparameter *mixer* nil) ;;*mixer* is used to play notification sound

(defun fun-dex-post-contents (vs vsg ev)
  (dex:post "https://ilmarinen.vuorosi.fi/Default.aspx" 
	    :content 
	    (acons "__EVENTTARGET"  "ctl00$ContentPlaceHolder1$btOK"
		   (acons "__VIEWSTATE"  vs
			  (acons "__VIEWSTATEGENERATOR"  vsg 
				 (acons "__EVENTVALIDATION"  ev
					( acons "ctl00$ContentPlaceHolder1$tbPassword"  (nth 2 sb-ext:*posix-argv*)
						(acons "ctl00$ContentPlaceHolder1$tbUsername" (nth 1 sb-ext:*posix-argv*)
						       (acons "ctl00$MessageType"  "ERROR" '())))))))
		            
			  :cookie-jar *cookie-jar*))

(defun fun-dex-post-varaa (vs vsg ev)
	   (dex:post "https://ilmarinen.vuorosi.fi/Booking/Prechoices.aspx"
		     :content 
		     (acons "__EVENTTARGET"  "ctl00$ContentPlaceHolder1$dgForval$ctl02$ctl00"
		       (acons "__VIEWSTATE"  vs
		       (acons "__VIEWSTATEGENERATOR"  vsg 
			      (acons "__EVENTVALIDATION"  ev
				     (acons "ctl00$ContentPlaceHolder1$tbPassword"  (nth 2 sb-ext:*posix-argv*)
						(acons "ctl00$ContentPlaceHolder1$tbUsername" (nth 1 sb-ext:*posix-argv*)
		       '(	       
		       ("ctl00$ContentPlaceHolder1$Repeater1$ctl01$imgPos" . "0%+0%")
			 ("ctl00$MessageType" . "ERROR")))))))) :cookie-jar *cookie-jar*))

(defun fun-dex-post-portal (vs vsg ev)
  (dex:post "https://ilmarinen.vuorosi.fi/Portal.aspx" 
	    :content 
	    (acons "__EVENTTARGET"  "ctl00$LinkBooking"
		   (acons "__VIEWSTATE"  vs
			  (acons "__VIEWSTATEGENERATOR"  vsg 
				 (acons "__EVENTVALIDATION"  ev
					(acons "ctl00$ContentPlaceHolder1$tbPassword"  (nth 2 sb-ext:*posix-argv*)
					       (acons "ctl00$ContentPlaceHolder1$tbUsername" (nth 1 sb-ext:*posix-argv*)
		       '(("ctl00$ContentPlaceHolder1$Repeater1$ctl01$imgPos" . "0%+0%")
			 ("ctl00$MessageType" . "ERROR")))))))) :cookie-jar *cookie-jar*))

(defun fun-dex-post-portal-status (vs vsg ev)
	   (dex:post "https://ilmarinen.vuorosi.fi/Portal.aspx" 
		     :content 
		     (acons "__EVENTTARGET"  "ctl00$LinkStatus"
		       (acons "__VIEWSTATE"  vs
		       (acons "__VIEWSTATEGENERATOR"  vsg 
			      (acons "__EVENTVALIDATION"  ev
				     (acons "ctl00$ContentPlaceHolder1$tbPassword"  (nth 2 sb-ext:*posix-argv*) (acons "ctl00$ContentPlaceHolder1$tbUsername"  (nth 1 sb-ext:*posix-argv*) 
		       '(      
		       ("ctl00$ContentPlaceHolder1$Repeater1$ctl01$imgPos" . "0%+0%")
			 ("ctl00$MessageType" . "ERROR")))))))) :cookie-jar *cookie-jar*))

(defun tarkasta ()
  (let ((vs) (vsg) (ev) (vs2) (vsg2) (ev2) (vs3) (vsg3) (ev3) (*request*) (*parsed-content*)
	(*login*) (*parsed-content-login*) (*request-varaa*) (*parsed-content-varaa*) (*request-ajat*) (*parsed-content-ajat*) )

    (setf *mixer* (mixalot:create-mixer))
;;pyydetään aloitussivu
    (setf *request*
	  (dex:post "https://ilmarinen.vuorosi.fi/Default.aspx"
		    :content (acons "ctl00$ContentPlaceHolder1$tbPassword" (nth 2 sb-ext:*posix-argv*) (acons "ctl00$ContentPlaceHolder1$tbUsername" (nth 1 sb-ext:*posix-argv*) '())) :cookie-jar *cookie-jar*))
;;parsetaan sisältö
(setf *parsed-content* (lquery:$ (initialize *request*)))


(setf vs (aref (lquery-funcs:val (lquery:$ *parsed-content* "#__VIEWSTATE")) 0))
(setf vsg (aref (lquery:$ *parsed-content* "#__VIEWSTATEGENERATOR" (attr :value)) 0 ))
(setf ev (aref (lquery-funcs:val (lquery:$ *parsed-content* "#__EVENTVALIDATION")) 0))

;tallennan sisäänkirjautumisrequestin komennolla
(setf *login* (fun-dex-post-contents vs vsg ev))
;parsetaan uusi request *login* muuttujasta komennolla
(setf *parsed-content-login* (lquery:$ (initialize *login*)))

;Haetaan uudet parametrien arvot komennolla
    (setf vs2 (aref (lquery-funcs:val (lquery:$ *parsed-content-login* "#__VIEWSTATE")) 0))
	       (setf vsg2 (aref (lquery:$ *parsed-content-login* "#__VIEWSTATEGENERATOR" (attr :value)) 0 ))
	       (setf ev2 (aref (lquery-funcs:val (lquery:$ *parsed-content-login* "#__EVENTVALIDATION")) 0))


;tein funktion, jolla pääsee portaaliin, kun tätä funktiota kutsuu muuttujilla vs2 vsg2 ev2


;tallensin kutsun tuloksen muuttujaan *request-varaa*

(setf *request-varaa* (fun-dex-post-portal-status vs2 vsg2 ev2))

;parsetaan request-varaa
    (setf *parsed-content-varaa* (lquery:$ (initialize *request-varaa*)))
    (format t "Verrataan ajanhetkellä~%")
    (let ((aika (multiple-value-list (decode-universal-time (get-universal-time) -2))))
      (format t "~a:~a ~a.~a.~a~%" 
	      (nth 2 aika) (nth 1 aika) (nth 3 aika) (nth 4 aika) (nth 5 aika)))
;;;    (format t "usr: ~a pass: ~a" (nth 1 sb-ext:*posix-argv*) (nth 2 sb-ext:*posix-argv*))
    (if (not (search "käynn" (string-downcase (aref (lquery:$ *parsed-content-varaa* "#ctl00_ContentPlaceHolder1_Repeater1_ctl00_Repeater2_ctl00_MaskGrpTitle" (text)) 0)))
	     ) (progn
		 (format t "Kone vapaana!~%")
		 (mixalot:mixer-add-streamer *mixer*
					     (mixalot-mp3:make-mp3-streamer (namestring (merge-pathnames (user-homedir-pathname) #P"tervehdys.mp3"))));;get tervehdys.mp3 from homedirectory
		 (sleep 5) ;;Sleep command is here so that sound message will be played. Before message was not played. I assume it was because function ended before message got played.
					     )
	   (format t "Kone käynnissä~%")
	  )
    
    (mixalot:destroy-mixer *mixer*)
    ))
