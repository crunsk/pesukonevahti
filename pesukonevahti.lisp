(in-package :pesukonevahti)

(defvar *cookie-jar* (cl-cookie:make-cookie-jar))

(defvar *username* "")
(defvar *password* "")

(defparameter *mixer* nil) ;;*mixer* is used to play notification sound

(defun fun-dex-post-contents (vs vsg ev)
  (dex:post "https://ilmarinen.vuorosi.fi/Default.aspx" 
	    :content 
	    (acons "__EVENTTARGET"  "ctl00$ContentPlaceHolder1$btOK"
		   (acons "__VIEWSTATE"  vs
			  (acons "__VIEWSTATEGENERATOR"  vsg 
				 (acons "__EVENTVALIDATION"  ev
					( acons "ctl00$ContentPlaceHolder1$tbPassword"  *password*
						(acons "ctl00$ContentPlaceHolder1$tbUsername" *username*
						       (acons "ctl00$MessageType"  "ERROR" '())))))))
		            
			  :cookie-jar *cookie-jar*))

(defun fun-dex-post-varaa (vs vsg ev)
	   (dex:post "https://ilmarinen.vuorosi.fi/Booking/Prechoices.aspx"
		     :content 
		     (acons "__EVENTTARGET"  "ctl00$ContentPlaceHolder1$dgForval$ctl02$ctl00"
		       (acons "__VIEWSTATE"  vs
		       (acons "__VIEWSTATEGENERATOR"  vsg 
			      (acons "__EVENTVALIDATION"  ev
				     (acons "ctl00$ContentPlaceHolder1$tbPassword"  *password*
						(acons "ctl00$ContentPlaceHolder1$tbUsername" *username*
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
					(acons "ctl00$ContentPlaceHolder1$tbPassword"  *password*
					       (acons "ctl00$ContentPlaceHolder1$tbUsername" *username*
		       '(("ctl00$ContentPlaceHolder1$Repeater1$ctl01$imgPos" . "0%+0%")
			 ("ctl00$MessageType" . "ERROR")))))))) :cookie-jar *cookie-jar*))

(defun fun-dex-post-portal-status (vs vsg ev)
	   (dex:post "https://ilmarinen.vuorosi.fi/Portal.aspx" 
		     :content 
		     (acons "__EVENTTARGET"  "ctl00$LinkStatus"
		       (acons "__VIEWSTATE"  vs
		       (acons "__VIEWSTATEGENERATOR"  vsg 
			      (acons "__EVENTVALIDATION"  ev
				     (acons "ctl00$ContentPlaceHolder1$tbPassword"  *password* (acons "ctl00$ContentPlaceHolder1$tbUsername"  *username* 
		       '(      
		       ("ctl00$ContentPlaceHolder1$Repeater1$ctl01$imgPos" . "0%+0%")
			 ("ctl00$MessageType" . "ERROR")))))))) :cookie-jar *cookie-jar*))
(defun tallenna-kirjautumistiedot ()
  "Save arguments given at cli to global variables"
  (setf *username* (nth 1 sb-ext:*posix-argv*)) ;get first argument which was given at command line
  (setf *password* (nth 2 sb-ext:*posix-argv*)) ; get second argument
  )

(defun kayttajatunnukset-annettu (username password)
"Returns T if parameters contain more than 0 characters."
  (and (>= (length username) 1) (>= (length password) 1)))

(defun print-current-time ()
(let* ((aika (multiple-value-list (decode-universal-time (get-universal-time) -2)))
		      (tunnit (nth 2 aika))
		      (minuutit (nth 1 aika))
		      (paiva (nth 3 aika)) 
		      (kuukausi  (nth 4 aika))
		      (vuosi (nth 5 aika)))
	    (format t "~a:~a ~a.~a.~a~%" 
		    tunnit minuutit paiva kuukausi vuosi)))

(defun is-free (picklist-text)
  "Returns true if picklist-text does not contain string 'käynn'. If machine would be reserved and running the picklist-text should contain string 'Pesula (Varattu, käynnistetty)'. Search is case-insensitive."
  (let ((pesula-status (string-downcase picklist-text)))
    (not (search "käynn" pesula-status))))

(defun tarkasta ()
  (let ((vs)
	(vsg)
	(ev)
	(vs2)
	(vsg2)
	(ev2)
	(request)
	(parsed-content)
	(login)
	(parsed-content-login)
	(request-varaa)
	(parsed-content-varaa)
	(has-credentials)
	(pesula-status));;save text of Pesula picklist field from Status page (https://ilmarinen.vuorosi.fi/Machine/MachineGroupStat.aspx)
    
    (tallenna-kirjautumistiedot)
    (setf has-credentials (kayttajatunnukset-annettu *username* *password*))

    (if has-credentials
	(progn
	  (MIXALOT:MAIN-THREAD-INIT) ;; have to call this onn windows in order to not have error "	  (MIXALOT:MAIN-THREAD-INIT) ;; have to call this in windows in order...". This has to be called before creating a mixer. I struggled for a bit before realizing this. Even tried using trivial-main-thread as well.
	  (setf *mixer* (mixalot:create-mixer))

	  ;;pyydetään aloitussivu
	  (setf request
		(dex:post "https://ilmarinen.vuorosi.fi/Default.aspx"
			  :content (acons "ctl00$ContentPlaceHolder1$tbPassword" *password* (acons "ctl00$ContentPlaceHolder1$tbUsername" *username* '())) :cookie-jar *cookie-jar*))
	  ;;parsetaan sisältö
	  (setf parsed-content (lquery:$ (initialize request)))
	  
	  
	  (setf vs (aref (lquery-funcs:val (lquery:$ parsed-content "#__VIEWSTATE")) 0))
	  (setf vsg (aref (lquery:$ parsed-content "#__VIEWSTATEGENERATOR" (attr :value)) 0 ))
	  (setf ev (aref (lquery-funcs:val (lquery:$ parsed-content "#__EVENTVALIDATION")) 0))
	  
	  ;;;;tallennan sisäänkirjautumisrequestin komennolla
	  (setf login (fun-dex-post-contents vs vsg ev))
	  ;;;;parsetaan uusi request login muuttujasta komennolla
	  (setf parsed-content-login (lquery:$ (initialize login)))
	  
	  ;;;;;Haetaan uudet parametrien arvot komennolla
	  (setf vs2 (aref (lquery-funcs:val (lquery:$ parsed-content-login "#__VIEWSTATE")) 0))
	  (setf vsg2 (aref (lquery:$ parsed-content-login "#__VIEWSTATEGENERATOR" (attr :value)) 0 ))
	  (setf ev2 (aref (lquery-funcs:val (lquery:$ parsed-content-login "#__EVENTVALIDATION")) 0))
	  
	  
	   ;;;;tein funktion, jolla pääsee portaaliin, kun tätä funktiota kutsuu muuttujilla vs2 vsg2 ev2
	   ;;;;;tallensin kutsun tuloksen muuttujaan request-varaa
	  
	  (setf request-varaa (fun-dex-post-portal-status vs2 vsg2 ev2))
	  
					;parsetaan request-varaa
	  (setf parsed-content-varaa (lquery:$ (initialize request-varaa)))

	  ;;;;save text of Pesula picklist field from Status page (https://ilmarinen.vuorosi.fi/Machine/MachineGroupStat.aspx)
	  (setf pesula-status (string-downcase (aref (lquery:$ parsed-content-varaa "#ctl00_ContentPlaceHolder1_Repeater1_ctl00_Repeater2_ctl00_MaskGrpTitle" (text)) 0)))
	  
	  (format t "Verrataan ajanhetkellä~%")
	  (print-current-time)
	  (if (is-free pesula-status)
	      (progn
		(format t "Kone vapaana!~%")
		(mixalot:mixer-add-streamer *mixer*
					    (mixalot-mp3:make-mp3-streamer (namestring (merge-pathnames (user-homedir-pathname) #P"tervehdys.mp3"))));;get tervehdys.mp3 from homedirectory
		(sleep 5) ;;Sleep command is here so that sound message will be played. Before message was not played. I assume it was because function ended before message got played.
		)
	      (format t "Kone käynnissä~%")
	      )
	  
	  (mixalot:destroy-mixer *mixer*)
	  )
	(print "Sinun tulee antaa käyttäjätunnus ja salasana komennon argumentteina")
	)))




(defun test-is-free ()
  "Test whether is-free function works. Test cases:
Machine is free: 'Pesula (Vapaa)'.
Machine is taken: 'Pesula (Varattu, käynnistetty)'."
  (if (is-free "Pesula (Vapaa)")
      (print "'Pesula (Vapaa)' working");;Pesula is vapaa => should return t
      (print "'Pesula (Vapaa)' not working")) 
  (if (is-free "Pesula (käynnistetty)")
      (print "'Pesula (käynnistetty)' not working");;pesula is in use => should return nil
      (print "'Pesula (käynnistetty)' working")))
    
  
