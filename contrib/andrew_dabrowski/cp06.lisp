(require 'mydefs)

(defparameter *scaleInc* 1)

(defvar upperFreq)
(setf upperFreq 12600)

(defun harmonics (pt)
  (let ((f1 (freqofnote pt)))
    (mapcar #'(lambda (n)
		(* f1 n))
	    (mydefs:number-sequence :from 1 :to (floor (/ upperFreq f1))))))

(defun harmonicunion (lst1 lst2)
  (let ((lst (sort (remove-duplicates (append lst1 lst2)) #'<=)))
    (harmonicUnionAux (cdr lst) (list (car lst)))))

(defun harmonicUnionAux (lst cur &optional (res nil))
  (if (null lst)
      (append res (list cur))
      (let ((hd (car lst))
	    (tl (cdr lst))
	    (curfreq (car cur)))
	(if (freqCloseQ hd curfreq)
	    (harmonicUnionAux tl (cons hd cur) res)
	    (harmonicUnionAux tl (list hd) (cons cur res))))))

(defun harmonicmash (nt1 nt2)
  (let* ((harms (mapcar #'length 
			(harmonicunion (harmonics nt1) 
				       (harmonics nt2))))
	 (cutharms (last harms))
	 (redharms (mapcar #'log cutharms))
;;	 (sqharms (mapcar #'(lambda (x) (* x x)) redharms))
	 )
    ;;(mydefs:hiya redharms)
    (* (apply #'+ redharms)
       1)))

(defun harmonicsChord (lst &optional (res nil))
  (if (null lst)
      (remove-duplicates res)
      (let ((hd (car lst))
	    (tl (cdr lst)))
	(harmonicsChord tl 
			(append res (harmonics hd))))))

(defun freqCloseQ (x y)
  (< (abs (log (/ x y) 2)) (* (/ 1 12) (/ *scaleInc* 2))))

(defun overtonematch (f1 f2 &optional (ovs '(1 1)))
  (let ((f1ov (* f1 (first ovs)))
	(f2ov (* f2 (second ovs))))
    (if (freqCloseQ f1ov f2ov)
	ovs
	(if (< f1ov f2ov)
	    (overtonematch f1 f2 (list (1+ (first ovs)) (second ovs)))
	    (overtonematch f1 f2 (list (first ovs) (1+ (second ovs))))))))

(defun freqOfNote (nt)
  (* 440 (expt 2 (/ (- nt 69) 12))))

(defun noteOfFreq (frq)
  (+ 69 (* 12 (log (/ frq 440) 2))))

(defun overtonediss (int start)
	  (overtonedissFreq (freqOfNote start)
			    (freqOfNote (+ start int))))

(defun overtonedissFreq (f1 f2)
  (log 
   (apply #'*
	  (overtonematch f1 f2))
   2)
  )

(defun dissonance (pits foc)
  (let ((dlst (mapcar #'(lambda (p)
			  (overtonediss (- p foc) foc))
		      pits)))
    ;;(mydefs:hiya dlst)
    (apply #'+ dlst)))

(defun dissonanceFreq (frqs foc)
  (let ((dlst (mapcar #'(lambda (p)
			  (overtonedissFreq p foc))
		      frqs)))
    ;;(mydefs:hiya dlst)
    (apply #'+ dlst)))

;; (defun dissonance (pits foc)
;;   (let ((dlst (mapcar #'(lambda (p)
;; 			  (harmonicmash p foc))
;; 		      pits)))
;;     (apply #'+ dlst)))
	 
(defun dissonance2 (p1 p2)
  (dissonance (list p1) p2))

(defun dissonanceChord (pits)
  (if (null pits)
      "empty"
      (let ((len (list-length pits))
	    (diss (mapcar #'(lambda (p)
			      (dissonance pits p))
			  pits)))
	;;(mydefs:hiya diss)
	(/ (apply #'+ diss) len))))

(defun dissonanceChordFreq (frqs)
  (if (null frqs)
      "empty"
      (let ((len (list-length frqs))
	    (diss (mapcar #'(lambda (p)
			      (dissonanceFreq frqs p))
			  frqs)))
;;	(/ (apply #'+ diss) (/ (* len (1+ len)) 2))
	(/ (apply #'max diss) len))))

(defstruct note tm ch pt dr (vl 64))

(defun listenForCmds ()
  (let (cmd res)
    (loop
       (with-open-file (in "/home/dabrowsa/lisp/fifo/in"
			   :direction :input)
	 (setq cmd (read-line in)))
       (mydefs:hiya cmd)
       (setq res (eval (read-from-string cmd)))
       )))

(defun noteToString (nt)
  (multiple-value-bind (p b) (floor (note-pt nt))
    (let ((pit (if (< b .5) p (1+ p)))
	  (chn (bendChan (note-ch nt) b))
	  (drn (format nil "~F" (note-dr nt))))
      (concatenate 'string 
		   "p"
		   (write-to-string pit)
		   "t"
		   (write-to-string (note-tm nt))	       
		   "c"
		   (write-to-string chn)
		   "d"
		   drn
		   "v"
		   (write-to-string (note-vl nt))))))


(defun phraseToKeyStrLst (lst
			  &key (wrapChannels t) (numchans 16))
  (let* ((srtlst (sort (copy-list lst) (lambda (n1 n2) (<= (note-tm n1) (note-tm n2)))))
	 (chchlst (mapcar #'(Lambda (nt)
	 		      (let* ((oldch (note-ch nt))
				     (newnt (copy-note nt))
				     (modch (mod oldch numchans)))
	 			(setf (note-ch newnt) (if (= modch 0)
							  numchans
							  modch))
	 			newnt))
	 		  srtlst)))
    (mapcar #'noteToString chchlst)))

(defun phraseToKeyFile (lst fn
			&key (wrapChannels t) (numchans 16))
  (let ((outlst (phraseToKeyStrLst lst :wrapChannels wrapChannels :numchans numchans)))
    ;;(mydefs:hiya chchlst)
    (with-open-file (out fn 
			 :direction :output 
			 :if-exists :supersede 
			 :if-does-not-exist :create)
      (phraseToKeyFileAux out outlst))))

(defun bendChan (chan bnd)
  (let ((res (+ 1
		(* *scaleInc* (- chan 1))
		(* bnd *scaleInc*))))
    ;; (if (equal res 0)
    ;; 	(mydefs:hiya (list chan bnd)))
    (cond ((< res 10) res)
	  ((<= 10 res 15) (1+ res))
	  ((> res 15) 10))))

(defun phraseToKeyFileAux (strm lst)
  (if (null lst)
      (progn
	(write-char #\return strm)
	(write-char #\linefeed strm))
      (let ((hd (car lst))
	    (tl (cdr lst)))
	;;	(mydefs:hiya hd)
	(write-string hd strm)
	(write-string " " strm)
	(phraseToKeyFileAux strm tl))))

(defun quickPhrase (lst &optional (tim 0) (res nil) (prevdur nil))
  (if (null lst)
      res
      (let ((hd (car lst))
	    (tl (cdr lst)))
	(let ((pit (if (listp hd)
		       (car hd)
		       hd))
	      (dur (if (listp hd)
		       (cadr hd)
		       prevdur)))
	  (quickPhrase tl 
		       (+ tim dur) 
		       (if (equalp pit "r")
			   res
			   (append res 
				   (list (make-note :tm tim :ch 1 :pt pit :dr dur))))
		       dur)))))
	    

(defun delayPhrase (ph del)
  (mapcar
   (lambda (nt) 
     (let ((tim (note-tm nt))
	   (newnt (copy-note nt)))
       (setf (note-tm newnt) (+ tim del))
       newnt))
   ph))

(defun transposePhrase (ph int &optional (addfun #'+))
  (mapcar
   (lambda (nt) 
     (let ((pit (note-pt nt))
	   (newnt (copy-note nt)))
       (setf (note-pt newnt) (funcall addfun pit int))
       newnt))
   ph))

(defun chchan (ph chn)
  (mapcar
   (lambda (nt) 
     (let ((newnt (copy-note nt)))
       (setf (note-ch newnt) chn)
       newnt))
   ph))

(defun combine (ph1 ph2 del int)
  (sortPhrase (append ph1 (transposePhrase (delayPhrase ph2 del) int))))

(defun sortPhrase (ph)
  (sort (copy-list ph) (lambda (n1 n2) (<= (note-tm n1) (note-tm n2)))))

(defun intervalSeq (ph)
  (let* ((phrase (copy-list ph))
	 (tim (note-tm (car phrase))))
    (intervalSeqAux tim nil phrase nil)))
    

(defun intervalSeqAux (tm ls ph res)
;;  (mydefs:hiya tm)
  (if (and (null ls) (null ph))
      res
      (let ((nts (mapcar 
		  #'(lambda (lst) (subseq lst 0 3))
		  ls))
	    (dur (if (null ls)
		     1000000
		     (apply #'min (mapcar #'third ls)))))
	(if (null ph)
	    (let ((newls (remove-if 
			  #'(lambda (itm)
			      (= dur (third itm)))
			  ls)))
	      (intervalSeqAux (+ tm dur) newls nil (append res (list (list nts dur)))))
	    (let ((phcar (car ph))
		  (phtail (cdr ph)))
	      (let ((ccur (note-ch phcar))
		    (tcur (note-tm phcar))
		    (pcur (note-pt phcar))
		    (dcur (note-dr phcar)))
		(if (= tm tcur)
		    (let ((newls (append ls (list (list ccur pcur dcur)))))
		      (intervalSeqAux tm newls phtail res))
		    (let* ((newd (min dur (- tcur tm)))
			   (newres (append res (list (list nts newd))))
			   (gap (- tcur tm newd))
			   (newls (remove-if 
				   #'(lambda (itm) (equalp 0 (third itm)))
				   (mapcar #'(lambda (itm)
					       (let* ((newitm (copy-list itm))
						      (old (third newitm)))
						 (setf (third newitm) (- old newd))
						 newitm))
					   ls))))
		      (if (> gap 0)
			  (let ((newt (+ tm newd)))
			    (intervalSeqAux newt newls ph newres))
			  (let ((newt (+ tm newd))
				(newnewls (append newls (list (list ccur pcur dcur)))))
			    (intervalSeqAux newt newnewls phtail newres)))))))))))
				
(defun dissSeqCh (chseq bc tc &optional (res nil))
  (if (null chseq)
      res
      (let ((carch (first (first chseq)))
	    (cdrch (cdr chseq)))
	(let ((tcnote (find tc carch :key #'first))
	      (bcnote (remove-if-not 
		       #'(lambda (itm) (= (car itm) bc))
		       carch)))
	  (if (null tcnote)
	      (dissSeqCh cdrch bc tc (append res '(0)))
	      (let ((nt (second tcnote))
		    (chrd (mapcar #'second bcnote)))
		(let* ((len (list-length chrd))
		       (curdiss (if (> len 0)
				    (dissonance chrd nt)
				    "empty")))
		  (dissSeqCh cdrch bc tc (append res (list curdiss))))))))))

(defun cumdelta (lst &optional (res 0))
  (if (< (list-length lst) 2)
      res
      (let ((hd (car lst))
	    (subhd (cadr lst))
	    (tl (cdr lst)))
	(let ((newres (if (and (numberp hd)
			      (numberp subhd))
			 (abs (- hd subhd))
			 0)))
	  (cumdelta tl (+ res newres))))))

(defvar scoreChdRatio)

(setf scoreChdRatio(/ 1 4))

(defun cpScore08 (chlst chs)
  (let* ((chdseq (mapcar #'first chlst))
	 (chdpitseq (mydefs:mapAtLevel #'second 2 chdseq))
	 (chdseqdisslist (mapcar #'dissonanceChord chdpitseq))
	 (chdseqscore (cumdelta chdseqdisslist))
	 (bchs (remove-if 
		#'(lambda (n) (member n chs))
		(remove-duplicates (mapcar #'first (apply #'append chdseq)))))
	 (twochs (apply #'append (mydefs:outerproduct chs bchs)))
	 (disslist (mapcar 
		    #'(lambda (itm) (dissSeqCh chlst (first itm) (second itm)))
		    twochs))
	 (blst (mapcar 
		#'(lambda (cs) 
		    (mapcar
		     #'(lambda (chd)
			 (mydefs:cases
			  #'(lambda (itm) (= (first cs) (first itm)))
			  #'second
			  chd))
		     chdseq))
		twochs))
	 (vlst (mapcar 
		#'(lambda (cs) 
		    (mapcar
		     #'(lambda (chd)
			 (mydefs:cases
			  #'(lambda (itm) (= (second cs) (first itm)))
			  #'second
			  chd))
		     chdseq))
		twochs))
	 (arglst (mydefs:transpose (list disslist blst vlst)))
	 (scorelist (mapcar 
		     #'(lambda (arg)
			 (dissResolveScoreV arg 6 3 5 4))
		     arglst)))
    ;;(mydefs:hiya scorelist)
    (+ (* scoreChdRatio chdseqscore) 
       (* (- 1 scoreChdRatio) 
	  (/ (apply #'+ scorelist) (- (list-length bchs) .5))))))

(defun dissResolveScoreV (lst hi hires lo lores)
  (let ((dlst (first lst))
	(blst (second lst))
	(vlst (third lst)))
    (if (< (list-length dlst) 2)
	0
	(let ((cardiss (car dlst))
	      (cdrdiss (cdr dlst))
	      (carvce (if (null (car vlst))
			  "na"
			  (car (car vlst))))
	      (cdrvce (cdr vlst))
	      (carbse (if (null (car blst))
			  "na"
			  (car (car blst))))
	      (cdrbse (cdr blst)))
	  (dissResolveScoreVAux cdrdiss cdrbse cdrvce cardiss carbse carvce 0 0
				(dissonance '(60) (+ 60 hi))
				(dissonance '(60) (+ 60 hires))
				(dissonance '(60) (+ 60 lo))
				(dissonance '(60) (+ 60 lores)))))))

(defvar attenuateFP)

(setf attenuateFP 2)

(defun attenuate01 (x)
;;  (* 2 (sqrt (abs x))))
  (* .5 (abs x)))
;;  0)

(defun attenuate (x)
  (let* ((diff (- attenuateFP x))
	 (sq (* diff diff)))
    (- attenuateFP (/ sq attenuateFP))))
     

(defvar unitpenalty 32)

(defun penalty (n)
  (- (* n unitpenalty)))

(defun dissResolveScoreVAux (dlst blst vlst prevdiss prevbse prevvce
			     sgn res hi hires lo lores)
  (if (null dlst)
      (let ((deltares (if (equal prevdiss "empty")
			  0
			  (if (>= prevdiss hi)
			      (penalty 2)
			      0))))
	(+ res deltares))
      (let ((newsgn (if (equal prevdiss "empty")
			0
			(if (>= prevdiss hi)
			    -1
			    (if (<= prevdiss lo)
				1
				(if (or (and (= sgn -1)
					     (>= prevdiss hires))
					(and (= sgn 1)
					     (<= prevdiss lores)))
				    sgn
				    0)))))
	    (cardiss (car dlst))
	    (cdrdiss (cdr dlst))
	    (carvce (if (null (car vlst))
			"na"
			(car (car vlst))))
	    (cdrvce (cdr vlst))
	    (carbse (if (null (car blst))
			"na"
			(car (car blst))))
	    (cdrbse (cdr blst)))
	(let* ((deltadiss (if (or (equal cardiss "empty")
				 (equal prevdiss "empty"))
			      "na"
			      (- cardiss prevdiss)))
	       (deltavce (if (or (equal carvce "na")
				 (equal prevvce "na"))
			     0
			     (- carvce prevvce)))
	       (deltabse (if (or (equal carbse "na")
				 (equal prevbse "na"))
			     0
			     (- carbse prevbse)))
	       (deltares (+ (if (equal cardiss 0)
				(penalty .5)
				0)
			    (if (equal prevdiss "empty")
				0
				(if (equal cardiss "empty")
				    (if (= newsgn -1)
					(let ((phdiss (if (equal carbse "na")
							  (dissonance (list carvce)
								      prevbse)
							  (dissonance (list carbse)
								      prevvce))))
					  (if (< phdiss prevdiss)
					      (* .5 (attenuate (- phdiss prevdiss)))
					      ;;0
					      (penalty 2)))
					0)
				    (if (or (< (* deltadiss newsgn) 0)
					    (and (not (= newsgn 0))
						 (= deltadiss 0)))
					(penalty 1)
					(+ (if (or (>= newsgn 0)
						   (<= deltavce 2))
					       (attenuate deltadiss)
					       (penalty 1.5))
					   (if (or (>= newsgn 0)
						   (<= deltabse 2))
					       (attenuate deltadiss)
					       (penalty 1.5))
					   (if (and (< newsgn 0)
						    (or (and (numberp carvce)
							     (numberp prevbse)
							     (numberp prevvce)
							     (< (* (- carvce prevbse) 
								   (- prevvce prevbse))
								0))
							(and (numberp carvce)
							     (numberp carbse)
							     (numberp prevvce)
							     (< (* (- carvce carbse) 
								   (- prevvce carbse))
								0))
							(and (numberp cardiss)
							     (numberp carvce)
							     (numberp prevbse)
							     (not (= cardiss 0))
							     (= carvce prevbse))))
					       (penalty 1.5)
					       0)
					   ;;; vce jumping base
					   (if (and (< newsgn 0)
						    (or (and (numberp carvce)
							     (numberp prevbse)
							     (numberp prevvce)
							     (betweenOct carvce prevbse prevvce))
							(and (numberp carvce)
							     (numberp carbse)
							     (numberp prevvce)
							     (betweenOct carvce carbse prevvce))))
					       (penalty 1)
					       0)
					   ;;; base jumping vce
					   (if (and (< newsgn 0)
						    (or (and (numberp carbse)
							     (numberp prevbse)
							     (numberp prevvce)
							     (betweenOct carbse prevvce prevbse))
							(and (numberp carvce)
							     (numberp carbse)
							     (numberp prevbse)
							     (betweenOct prevbse carvce carbse))))
					       (penalty 1)
					       0)
					   (if (and (< newsgn 0)
						    (or (and (numberp carbse)
							     (numberp prevvce)
							     (numberp prevbse)
							     (< (* (- carbse prevvce) 
								   (- prevbse prevvce))
								0))
							(and (numberp carbse)
							     (numberp carvce)
							     (numberp prevbse)
							     (< (* (- carbse carvce) 
								   (- prevbse carvce))
								0))
							(and (numberp cardiss)
							     (numberp carbse)
							     (numberp prevvce)
							     (not (= cardiss 0))
							     (= carbse prevvce))))
					       (penalty 1.5)
					       0))))))))
	  (dissResolveScoreVAux cdrdiss cdrbse cdrvce cardiss carbse carvce
				newsgn (+ res deltares) hi hires lo lores)))))

(defun timeExtremes (ph)
  (let ((ts (mapcar #'note-tm ph))
	(ds (mapcar #'note-dr ph)))
    (list (apply #'min ts) (apply #'max (mapcar #'+ ts ds)))))


(defun timeExtFun (ph del)
  (let* ((extrs (timeExtremes ph))
	 (mn (+ (first extrs) del))
	 (mx (+ (second extrs) del 12)))
    #'(lambda (nt)
	(and (<= mn (+ (note-tm nt) (note-dr nt)))
	     (<= (note-tm nt) mx)))))
		      
(defun phraseLength (phr)
  (if phr (apply #'- (reverse (timeextremes phr)))))

(defun fitCounterpoint (base voices delays 
			&key (memlen 10) (timeinc 24) (intmin -5) (intmax 6)
			(intinc (/ 1 *scaleInc*)) (timetolerance 48) (scoreFun #'cpScore08))
  (let ((best (make-list memlen :initial-element '(-1000000 nil nil nil))))
;;    (mydefs:hiya delays)
    (do* ((vcscur voices (cdr vcscur))
	  (vcur (car vcscur) (car vcscur))
	  (vcurlen (phraseLength vcur) (phraseLength vcur)))
	 ((null vcscur))
      (let ((tchs (remove-duplicates (mapcar #'note-ch vcur))))
	(do* ((dcur (first delays) (+ dcur timeinc)))	    
	     ((> dcur (second delays)))
	  (let ((timefn (timeExtFun vcur dcur)))
	    (do* ((icur intmin (+ icur intinc)))
		 ((> icur intmax))
;; 	      	  (mydefs:hiya dcur)
;; 	      	  (mydefs:hiya icur)
	      (let* (
		     (curcomboInit (combine base vcur dcur icur))
		     (curcombo (remove-if-not timefn curcomboInit))
		     (curchdseq (intervalSeq curcombo))
		     (curCPscore (Funcall scoreFun curchdseq tchs))
		     (currootscore (scoreroots curchdseq))
		     (curscore (+ curCPscore currootscore))
		     (curtuple (list curscore dcur icur curcomboInit (+ dcur vcurlen)))
		     (prev (remove-if-not 
			    #'(lambda (itm)
				(and (numberp (second itm))
				     (< (abs (- (second itm) dcur)) timetolerance)
				     (= (third itm) icur)))
			    best)))
		(if (null prev)
		    (let* ((nbest (cons curtuple best))
			   (snbest (sort nbest #'<= :key #'first)))
		      (setf best (cdr snbest)))
		    (let* ((loclist (cons curtuple prev))
			   (locbestlist (sort loclist #'>= :key #'first))
			   (locbest (car locbestlist)))
		      (if (equal locbest curtuple)
			  (let ((newbest (cons curtuple 
					       (remove-if 
						#'(lambda (itm) (member itm prev))
						best))))
			    (setf best (append newbest
					       (make-list (- memlen (list-length newbest))
							  :initial-element '(-1000000 nil nil nil))))))))))))))
    (sort best #'>= :key #'first)))

(defun callFCP (base addend &key (reflect nil) (stretch 1.125) (numsubstr 0) 
		(lenbase (phraseLength base)))
  (let* ((deltm (- lenbase (phraseLength addend)))
	 (delays (if (> deltm 0)
		     (list 0 deltm)
		     (list deltm 0)))
	 (strs (mapcar #'(lambda (x) (expt stretch x)) 
		       (mydefs:number-sequence :from (- numsubstr) :to numsubstr)))
	 (stradd (mapcar #'(lambda (x) (expandphrase addend x)) strs))
	 (newadd (if reflect
		     (apply #'append (mapcar reflect stradd))
		     stradd))
	 (reslst (fitCounterpoint base newadd delays))
	 (phrlst (mapcar #'fourth reslst)))
    ;;(mydefs:hiya phrlst)
    (with-open-file (out "/home/dabrowsa/lisp/fifo/out"
			 :direction :output
			 :if-exists :append)
      (loop for v in phrlst do
	   (phraseToKeyFileAux out (phraseToKeyStrLst v))))))
		      
(defun invertPhrase (ph &optional (center nil))
  (let* ((pts (mapcar #'note-pt ph))
	 (mx (apply #'max pts))
	 (mn (apply #'min pts))
	 (cnt (if center
		  center
		  (/ (+ mn mx) 2))))
    (mydefs:cases #'(lambda (nt) t) 
		  #'(lambda (nt)
		      (let ((newnt (copy-note nt))
			    (oldp (note-pt nt)))
			(setf (note-pt newnt) (- (* 2 cnt) oldp))
			newnt))
		  ph)))

(defun invertIntSeq (seq)
  (mydefs:mapAtLevel #'- 3 seq))
		
(defun retroPhrase (ph)
  (let* ((phsrt (sortPhrase ph))
	 (mn (note-tm (car phsrt)))
	 (mx (+ (note-tm (car (last phsrt))) 
		(note-dr (car (last phsrt)))))
	 (newph (mapcar #'(lambda (nt)
			    (let ((newnt (copy-note nt))
				  (oldt (note-tm nt))
				  (oldd (note-dr nt)))
			      (setf (note-tm newnt) (- (+ mx mn) (+ oldt oldd)))
			      newnt))
			ph)))
    (sortphrase newph)))

(defun retroInvertIntSeq (seq)
  (let ((ones (reverse (mapcar #'first seq)))
	(twos (reverse (mapcar #'second seq))))
    (mapcar #'list 
	    (mydefs:right-rotate ones)
	    (mydefs:right-rotate (mydefs:right-rotate twos)))))

(defun retroInvertPhrase (ph)
  (invertPhrase (retroPhrase ph)))

(defun retroIntSeq (seq)
  (invertIntSeq (retroInvertIntSeq seq)))

(defun reflectPhrase (ph)
  (let ((inv (invertPhrase ph)))
    (list ph inv (retroPhrase ph) (retrophrase inv))))

(defun reflectPhraseInv (ph)
  (let ((inv (invertPhrase ph)))
    (list ph inv)))

(defun reflectIntSeq (seq)
  (list seq
	(invertIntSeq seq)
	(retroIntSeq seq)
	(retroInvertIntSeq seq)))

(defun nthwrap (n lst)
  (let ((ind (mod n (list-length lst))))
    (nth ind lst)))
       
(defun spinCP (ph numvce numiter fileloc 
	       &key (timeinc 24) (endinc '(.2 .2)) (timedel 48) (init ph) 
	       (voices (reflectPhrase ph))
	       (intervalrange '(-5 6))
	       (span "end")
	       (voiceorder nil)
	       (skeleton nil)
	       (intseq (if (null skeleton)
			   nil
			   (reflectIntSeq skeleton)))
	       (newchans nil)
	       (expandfun #'(lambda (tme ind) 1.0))
	       (transposefun #'(lambda (tme ind) 0))
	       (voicesfun #'(lambda (tme ind) voices))
	       (tessiturafun #'(lambda (x) x))
	       (expandparams '(1 1 2)))
  (let (best 
	maxchan
	(prevend 0)
	(base init)
	(intmin (first intervalrange))
	(intmax (second intervalrange))
	(voicetime (second (timeextremes (first (funcall voicesfun 0 0)))))
	(lenorder (list-length voiceorder))
	(initmaxtime (- (second (timeExtremes init)) timeinc)))
    (setf maxchan (apply #'max (mapcar #'note-ch base)))
    (do ((i 1 (1+ i)))
	((if (>= numiter 0)
	     (> i numiter)
	     (> prevend (- (phraselength init) timeinc))))
      ;;      (mydefs:hiya base)
      (let* ((nwch (if newchans
		       (+ (* numvce (floor (/ (1- i) 
					      (list-length newchans))))
			  (1- (nthwrap i newchans)))
		       (+ maxchan i)))
	     (baselen (phraselength init))
	     (tme (/ prevend baselen))
	     (ind (/ i numiter))
	     (timeincscaled (* timeinc (funcall expandfun tme ind)))
	     (nowvoices (funcall voicesfun tme ind))
	     (chchvoices (mapcar #'(lambda (ph) 
				    (chchan ph nwch))
				(if (null voiceorder)
				    (if (null intseq)
					nowvoices
					(apply #'append 
					       (mapcar #'(lambda (ph insq)
							   (tonalVariants ph :intseq insq))
						       nowvoices
						       intseq)))
				    (let* ((ind (mod i lenorder))
					   (vind (nth ind voiceorder)))
				      (if (null intseq)
					  (list (nth vind nowvoices))
					  (tonalVariants 
					   (nth vind nowvoices)
					   :intseq (nth vind intseq)))))))
	     (curvoices (let* ((rho (coerce (funcall expandfun tme ind)
					    'single-float))
			       (trint (funcall transposefun tme ind)))
			  ;; (mydefs:hiya trint)
			  (mapcar #'(lambda (phr)
				      (transposephrase (expandphrase phr rho) trint))
				  chchvoices))))
	(setf best 
	      (fitCounterpoint base 
			       (funcall tessiturafun (apply #'expandrange curvoices expandparams))
			       (if (string= span "end")
				   (let ((maxtime (second (timeExtremes base))))
				     (list (+ (* (first endinc) voicetime) (- maxtime voicetime))
					   (- maxtime (* (second endinc) voicetime))))
				   (if (string= span "all")
				       (let ((maxtime initmaxtime))
					 (list timeincscaled
					       (- maxtime timeincscaled)))
				       (if (string= span "segment")
					   (let ((segtime 
						  (* timedel
						     (round 
						      (/ initmaxtime numiter)
						      timedel))))
					     (list (* segtime (1- i)) (* segtime i)))
					   (if (string= span "melody")
					       (list prevend (+ prevend timeincscaled))))))
			       :timeinc timedel
			       :intmin intmin
			       :intmax intmax))
	(setf base (fourth (first best)))
	;; (if (< (note-tm (first base)) 0)
	;;     (format t (write-to-string base)))
	(setf prevend (fifth (first best)))
	;;(mydefs:hiya (first best))
	;;(mydefs:hiya prevend)
	(format t "i = ~d completed~%" i)))
    (phraseToKeyFile base
		     (concatenate 'string
				  fileloc
				  ".k")
		     :numchans numvce)
    base))


(defun expandPhrase (ph rho)
  (let ((fxd (first (timeextremes ph))))
    (mapcar #'(lambda (nt)
		(let ((newnt (copy-note nt))
		      (oldtm (note-tm nt))
		      (olddr (note-dr nt)))
		  (setf (note-tm newnt) (+ fxd (* (- oldtm fxd) rho)))
		  (setf (note-dr newnt) (* olddr rho))
		  newnt))
	    ph)))



(defvar intervalEqs '((0) (1 2) (3 4) (5) (6)))

(defun intEq (n)
  (let* ((r (mod n 12))
	 (d (floor (/ n 12)))
	 (k (if (> r 6)
		(- 12 r)
		r))
	 (sgn (if (> r 6)
		  -1
		  1))
	 (clss (find k intervalEqs :test #'member)))
    (mapcar #'(lambda (x)
		(+ (* 12 d) 
		   (if (< sgn 0)
		       (- 12 x)
		       x)))
	    clss)))

(defun intervalclassSeq (ptsq)
  (let* ((frsts (mapcar #'intEq
			(mapcar #'-
				(cdr ptsq)
				ptsq)))
	 (scnds (mapcar #'intEq
			(mapcar #'- 
				(cdr (cdr ptsq))
				ptsq)))
	 (slctscnds (mapcar #'(lambda (lst)
				(if (or (= (list-length lst) 2)
					(= (mod (car lst) 12) 6))
				    nil
				    lst))
			    scnds)))
    (mydefs:transpose (list (append '(nil) frsts)
			    (append '(nil nil) slctscnds)))))

(defun melsub (phr pts)
  (let ((sublst (mydefs:transpose (list phr pts))))
    (mapcar #'(lambda (itm)
		(let ((newnt (copy-note (car itm)))
		      (pt (cadr itm)))
		  (setf (note-pt newnt) pt)
		  newnt))
	    sublst)))
	 
(defun tonalVariants (ph &key (intseq (intervalclassseq (mapcar #'note-pt ph))))
  (let* ((srtphr (sortPhrase ph))
	 (newnt (note-pt (car srtphr))))
    (let ((mels (tonalVariantsAux nil newnt (cdr intseq) (list newnt))))
      (mapcar #'(lambda (mel)
		  (melsub srtphr mel))
	      mels))))

(defun tonalVariantsAux (n1 n2 ints var)
  (if (null ints)
      (list var)
      (let* ((frst (caar ints))
	     (scnd (cadar ints))
	     (next1 (mapcar #'(lambda (x) (+ x n2))
			    frst))
	     (next2 (mapcar #'(lambda (x) (+ x n1))
			    scnd))
	     (next (if (null next2)
		       next1
		       (intersection next1 next2))))
	(if (null next)
	    nil
	    (let ((reslst (mapcar #'(lambda (p)
				      (tonalVariantsAux n2 p (cdr ints) 
							(append var (list p))))
				  next)))
	      var
	      (apply #'append reslst))))))

(defun betweenOct (n1 n2 n3)
  (or (let ((n2mod (+ n1 (mod (- n2 n1) 12))))
	(<= n1 n2mod n3))
      (let ((n2mod (+ n3 (mod (- n2 n3) 12))))
	(<= n3 n2mod n1))))

(defun rootOfChord (lst &optional (atleast 0))
  (if (or (null lst)
	  (< (list-length lst) atleast))
      "r"
      (let ((bestval 1000000)
	    (minpit (apply #'min lst))
	    bestpit)
	(do ((pit (- minpit 1) (1- pit)))
	    ((< pit (- minpit 18)) bestpit)
	  (let ((cur (dissonance lst pit)))
	    ;;	(mydefs:hiya cur)
	    (if (< cur bestval)
		(progn
		  (setf bestpit pit)
		  (setf bestval cur))))))))

(defun countInt (lst &optional (res #(0 0 0 0 0 0 0)))
  (if (null lst)
      res
      (let ((hd (car lst))
	    (tl (cdr lst)))
	(let ((num (aref res hd))
	      (cpres (copy-seq res)))
	  (setf (aref cpres hd) (1+ num))
	  (countInt tl cpres)))))

(defun reduceIntervals (lst)
  (mapcar #'(lambda (n)
	      (if n
		  (let ((m (mod n 12)))
		    (if (< m 7)
			m
			(- 12 m)))))
	  lst))

(defun countIntSkeleton (lst &optional (res #(0 0 0 0 0 0 0)))
  (if (null lst)
      res
      (let ((hd (caar lst))
	    (tl (cdr lst)))
	(let ((len (list-length hd)))
	  (if (null hd)
	      (countIntSkeleton tl res)
	      (let ((cnt (countInt (reduceIntervals hd))))
;;		(mydefs:hiya cnt)
		(countIntSkeleton tl (mydefs:vector+ (mydefs:scalar* (/ 1 len) cnt) res))))))))
	  
(defun probnorm (vct)
  (let ((s (apply #'+ (coerce vct 'list))))
    (mydefs:scalar* (/ 1 s) vct)))

(defun addroots (phr &optional (newch (1+ (apply #'max (mapcar #'note-ch phr)))))
  (let* (
	 (chdseq (intervalSeq phr))
	 (roots (quickphrase (mapcar #'(lambda (lst)
					 (list 
					  (rootOfChord (mapcar #'second (first lst)))
					  (second lst)))
				     chdseq))))
;;    (mydefs:hiya newch)
    (sortphrase (append phr (chchan roots newch)))))

(defun mixdown (phr chns)
  (mapcar #'(lambda (nt)
	      (let ((newnt (copy-note nt))
		    (oldch (note-ch nt)))
		(let* ((redch (mod oldch chns))
		       )
		  (setf (note-ch newnt) redch)
		  newnt)))
	  phr))

(defun compareVct (v1 v2)
  (let ((l1 (coerce v1 'list))
	(l2 (coerce v2 'list)))
    (let* ((rat (mapcar #'/ l1 l2))
	   (lnrat (mapcar #'log rat))
	   (absln (mapcar #'abs lnrat)))
      (apply #'+ absln))))

(defun scoreroots (chds &key (scorefn #'rootscore02))
  (let* ((tmp1 (mapcar #'first chds))
	 (chds (mydefs:mapAtLevel #'second 2 tmp1))
	 (roots (mapcar #'(lambda (chd)
			    (rootOfChord chd 3))
			chds))
	 (redrts (reduceIntervals (diff1 roots))))
    ;;(mydefs:hiya redrts)
    ;;(mydefs:hiya (mapcar scorefn redrts))
    (apply #'+ (mapcar scorefn redrts))))
  

(defun diff1 (lst)
  (mapcar #'(lambda (n1 n2)
	      (if (and (numberp n1)
		       (numberp n2))
		  (- n1 n2)))
	  (cdr lst)
	  lst))


;;FIX!!
(defun rootscore01 (nt)
  (case nt
    ((nil) 0)
    ((5) (* unitpenalty 1))
    ((1 6) (* unitpenalty -1))
    ((2) (* unitpenalty 0))
    ((3 4) (* unitpenalty .5))
    ((0) 0)))

(defparameter rootScoreCon (/ (rootscore01 5) (overtonediss 5 60)))

(defun rootscore02 (nt)
  (if (null nt)
      0
      (* rootScoreCon
	 (overtonediss nt 20))))

(defun getPhraseFromFile (flnm)
  (with-open-file (instrm flnm
			  :direction :input)
    (let ((newstr (read-line instrm)))
      (eval (read-from-string newstr)))))

(defun subphrases (phr &optional (sublen 4))
  (let ((srtphr (sortphrase phr)))
    (do* ((lst srtphr (cdr lst))
	  (new (subseq lst 0 sublen) 
	       (subseq lst 0 sublen))
	  (newtime (note-tm (first new)) 
		   (note-tm (first new)))
	  (res (list (delayphrase new (- newtime))) 
	       (cons (delayphrase new (- newtime)) res)))
	 ((<= (list-length lst) sublen) res))))

(defun subphrasesFromList (lst &optional (sublen 4))
  (apply #'append (mapcar #'(lambda (ph)
			      (subphrases ph sublen))
			  lst)))

(defun transposeDiatonic (nt int scale)
  (let* ((rednt (mod nt 12))
	 (pos (position rednt scale)))
    (if pos
	(let ((newpos (+ pos int)))
	  (let ((oct (floor (/ newpos 7)))
		(redpos (mod newpos 7)))
	    (let* ((newnt (nth redpos scale))
		   (redint (- newnt rednt)))
	      (+ nt redint (* 12 oct))))))))

(defun transposeDiatonicPhrase (phr int scale)
  (transposephrase phr int
		   #'(lambda (nt int)
		       (transposeDiatonic nt int scale))))

(defun transposeDiatonicAllPhrase (phr scale)
  (let ((ints (mydefs:number-sequence :to 6)))
    (mapcar #'(lambda (int)
		(transposeDiatonicPhrase phr int scale))
	    ints)))

(defvar cmajor)

(setf cmajor '(0 2 4 5 7 9 11))

(defun makeDiatonicPhraseList (phr &key (scale cmajor) 
			       (center 62) (expand 1) (transpose 0))
  (let* ((transcale (mapcar #'(lambda (p) (+ p transpose)) scale))
	 (newscale (sort (mapcar #'(lambda (p) (mod p 12)) transcale)
			 #'<))
	 (lst0 (expandphrase (transposephrase phr transpose) expand))
	 (lst1 (list lst0
		     (transposeDiatonicPhrase 
		      (invertphrase lst0 (+ transpose center)) 
		      5 newscale)))
	 (lst2 (append lst1 (mapcar #'retrophrase lst1)))
	 (lst3 (apply #'append 
		      (mapcar #'(lambda (phr)
				  (transposeDiatonicAllPhrase phr newscale))
			      lst2))))
    lst3))

(defvar cHarmMinor)

(setf cHarmMinor '(0 2 3 5 7 9 11))

(defun makePhaseFun (av mx &key (start 0) (end (* 2 pi)))
  (let ((amp (- mx av))
	(frc (- end start)))
    #'(lambda (x) 
	(+ av 
	   (* amp
	      (cos (+ start
		      (* frc
			 x))))))))


(defun makePhaseFunT (av mx &key (start 0) (end (* 2 pi)))
  (let ((pfn (makePhaseFun av mx :start start :end end)))
    #'(lambda (tme ind)
	(funcall pfn tme))))

(defun makePhaseFunI (av mx &key (start 0) (end (* 2 pi)))
  (let ((pfn (makePhaseFun av mx :start start :end end)))
    #'(lambda (tme ind)
	(funcall pfn ind))))

(defun makeStepFun (lst &optional 
		    (weights (make-list (list-length lst) :initial-element 1)))
  (let* ((tot (apply #'+ weights))
	 (wtlst (mapcar #'(lambda (x)
			     (/ x tot))
			 weights))
	 (cutlst (partsums wtlst)))
    ;; (format t (write-to-string cutlst))
    #'(lambda (x)
	(let ((n (list-length (remove-if #'(lambda (y) (>= y x)) cutlst))))
	  (nth n lst)))))

(defun partsums (lst &optional (res nil) (prev 0))
  (if (null lst)
      res
      (let* ((hd (car lst))
	     (tl (cdr lst))
	     (new (+ hd prev)))
	(partsums tl (append res (list new)) new))))

(defun makeStepFunT (lst &optional 
		     (weights (make-list (list-length lst) :initial-element 1)))
  (let ((sfn (makeStepFun lst weights)))
    #'(lambda (tme ind)
	(funcall sfn tme))))

(defun makeStepFunI (lst &optional 
		     (weights (make-list (list-length lst) :initial-element 1)))
  (let ((sfn (makeStepFun lst weights)))
    #'(lambda (tme ind)
	(funcall sfn ind))))

(defun transposeScale (int &optional (scale cmajor))
  (let* ((intscale (mapcar #'(lambda (p) (+ p int)) scale))
	 (newscale (mapcar #'(lambda (p) (mod p 12)) intscale)))
    (sort newscale #'<)))

(defun tessitura (phr mn mx)
  (let* ((pts (mapcar #'note-pt phr))
	 (mn1 (apply #'min pts))
	 (mx1 (apply #'max pts)))
    (cond 
      ((< mn1 mn) (transposephrase phr 12))
      ((> mx1 mx) (transposephrase phr -12))
      (t phr))))

(defun tessituraMap (phrlst mn mx)
  (mapcar #'(lambda (phr)
	      (tessitura phr mn mx))
	  phrlst))

(defun fluteTess (phrlst)
  (tessituraMap phrlst 60 96))  

(defun celloTess (phrlst)
  (tessituraMap phrlst  0 65))

(defun engHornTess (phrlst)
  (tessituraMap phrlst  52 81))

(defun clarinetTess (phrlst)
  (tessituraMap phrlst  52 84))

(defun violaTess (phrlst)
  (tessituraMap phrlst  48 88))

(defun violinTess (phrlst)
  (tessituraMap phrlst  55 105))

(defun adjustVelocity (phr rat)
  (mapcar #'(lambda (nt)
	      (let* ((newnt (copy-note nt))
		     (oldvel (note-vl nt))
		     (newvel (round (* rat oldvel))))
		(setf (note-vl newnt) newvel)
		newnt))
	  phr))

(defun zeroPhrase (phr)
  (let ((strt (first (timeextremes phr))))
    (delayphrase phr (- strt))))

(defun expandrange (phrlst start stop factor)
  (mydefs:outerproduct phrlst
		       (mydefs:number-sequence :from start
					       :to stop
					       :inc factor
					       :incop #'*)
		       #'expandphrase
		       t))

(defun entropyTerm (p) 
  (if (> p 0 )
      (* (- p) (log p 2))
      0))


(defun entropyOfList ( lst )
  (let* ((tot (apply #'+ lst))
	 (prbs (mapcar (lambda (x) (/ x tot))
		       lst))
	 (ents (mapcar #'entropyTerm prbs)))
    (apply #'+ ents)
))

(defun itemsToFreqAux (phr res m)
  (if (null phr)
      res
      (let* ((hd (car phr))
	     (tl (cdr phr))
	     
	     (ntmd (mod hd m)))
	(setf (nth ntmd res) (1+ (nth ntmd res)))
	(itemsToFreqAux tl res m))))
  

(defun melodyToNoteFreq (phr)
  (let* ((pts (mapcar #'note-pt phr))
	 (len (* *scaleInc* 12))
	 (tab (make-list len :initial-element 0))
	 (ptsx (mapcar (lambda (p) (* *scaleInc* p)) pts)))
      (itemsToFreqAux ptsx tab len)))

(defun melodyToIntervalFreq (phr)
  (let* ((pts (mapcar #'note-pt phr))
	 (succ (cdr pts))
	 (ints (mapcar #'- succ pts))
	 (intsx (mapcar (lambda (p) (* *scaleInc* p)) ints))
	 (len (* *scaleInc* 24))
	 (tab (make-list len :initial-element 0)))
    (itemsToFreqAux intsx tab len)))

(defun entropyScore (ent num tim &key (idealRate 1) (cons -1))
  (let* ((rate (/ (* ent num) tim))
	 (diff (- (+ (log *scaleInc* 2) idealRate) rate)))
    (* cons diff diff)))

(defun melodyScore (phr)
  (let ((tlen (/ (- (apply #'- (timeextremes phr))) 192))
	(numnts (length phr))
	(noteEnt (entropyOfList (melodyToNoteFreq phr)))
	(intervalEnt (entropyOfList (melodyToIntervalFreq phr)))
	(w1 0.5)
	(w2 1)
	(noteRate 17)
	(intervalRate 20)
	)   
    (* w2
       (+ (* w1 (entropyScore noteEnt numnts tlen :idealRate noteRate :cons -1))
	  (* (- 1 w1) (entropyScore intervalEnt numnts tlen :idealRate intervalRate :cons -1))))
))




(defun tweakNote (ph1 melbeg nt pitdel melend &key (deltaP t))
  (if (null nt)
      melbeg
      (let ((newnt (copy-note nt)))
	(setf (note-pt newnt) 
	      (if deltaP
		  (+ pitdel (note-pt newnt))
		  pitdel))
	(sortPhrase (append ph1 melbeg (list newnt) melend))
	)))

(defun tweakMelody (base melody 
		    &key  (pitchRadius (* 2 *scaleInc*)) (scoreCPFun #'cpScore08)
		      (intinc (/ 1 *scaleInc*))  (scoreMelFun #'melodyScore))
  (let ((melWeight 700)
	)

    (do* ((melcur melody (cdr melcur))
	  (melbeg nil (tweakNote nil melbeg ntcur (second best) nil))
	  (ntcur (car melcur) (car melcur))
	  (best '(-1000000000 nil) '(-1000000000 nil))		  
	  ;;(vcurlen (phraseLength vcur) (phraseLength vcur))
	  )
	 ((null melcur) melbeg)
      (let ((tchs (remove-duplicates (mapcar #'note-ch melcur))))
	;;(mydefs:hiya melbeg)
	(do* ((icur (- pitchRadius) (+ icur intinc)))
	     ((> icur pitchRadius))
	  
	  ;;(mydefs:hiya icur)
	  ;;(mydefs:hiya melcur)

	  (let* (
		 (curcombo (tweakNote base melbeg ntcur icur (cdr melcur)))
		 (curmel (tweakNote nil melbeg ntcur icur (cdr melcur)))
		 (curchdseq (intervalSeq curcombo))
		 (curCPscore (Funcall scoreCPFun curchdseq tchs))
		 (curMelScore (Funcall scoreMelFun curmel))
		 ;;(currootscore (scoreroots curchdseq))
		 (curscore (+ curCPscore  (* melWeight curMelScore)))
		 
		 )
	    (if ( > curscore (car best))
		(setq best (list curscore icur))
		)
	    ;;(mydefs:hiya icur)
	    ;;(mydefs:hiya best)
	    ;;(mydefs:hiya curcombo)
	    ))))
    ))

(defun makePitchList (mel del)
  (mapcar #'(lambda (nt)
	      (+ (note-pt nt) del))
	  mel))


(defun tweakMelodyRepeat (base melody 
			  &key  (fileout nil) (pitchRadius 1) (scoreCPFun #'cpScore08)
			    (intinc (/ 1 *scaleInc*))  (scoreMelFun #'melodyScore)
			    (limited nil))
  (let* ((melWeight 700)
	 (best '(-1000000000 nil))
	 (radius (* intInc pitchRadius))
	 (lowpitches (makePitchList melody (- radius)))
	 )
    (let ((tweakedMel 
	   (do* ((bestmel melody)
		 (iter 1 (+ iter 1))
		 (stop nil)
		 )
		(stop bestmel)
	     (format t "iterations: ~s~%" iter)
	     (format t "score: ~s~%" (car best))
	     (setq stop t)
	     (do* ((melcur (copy-list bestmel) (cdr melcur))
		   (lowpit (if limited 
			       lowpitches  
			       (makePitchList melcur (- radius)))
			   (cdr lowpit))
		   (bestcur bestmel (cdr bestcur))
		   (melbeg nil (tweakNote nil melbeg ntcur (second best) nil :deltaP nil))
		   (ntcur (car melcur) (car melcur))
		   
		   ;;(vcurlen (phraseLength vcur) (phraseLength vcur))
		   )
		  ((null melcur) (setq bestmel melbeg))
	       (let* ((tchs (remove-duplicates (mapcar #'note-ch melcur)))
		      (lowp (car lowpit))
		      (highp (+ lowp (* 2 radius))))
		 ;;(mydefs:hiya melbeg)
		 (do* ((pitcur lowp (+ pitcur intinc)))
		      ((> pitcur highp))
		   
		   ;;(mydefs:hiya icur)
		   ;;(mydefs:hiya melcur)

		   (let* (
			  (curcombo (tweakNote base melbeg ntcur pitcur (cdr bestcur) :deltaP nil))
			  (curmel (tweakNote nil melbeg ntcur pitcur (cdr bestcur) :deltaP nil))
			  (curchdseq (intervalSeq curcombo))
			  (curCPscore (Funcall scoreCPFun curchdseq tchs))
			  (curMelScore (Funcall scoreMelFun curmel))
			  (currootscore (scoreroots curchdseq))
			  (curscore (+ curCPscore currootscore (* melWeight curMelScore)))
			  
			  )
		     (if (>= curscore (car best))
			 (progn ;;(format t "as good")
			   (if (> curscore (car best))
			       (setq stop nil))
			   (setq best (list curscore pitcur))
			   ))
		     ;;(mydefs:hiya icur)
		     ;;(mydefs:hiya best)
		     ;;(mydefs:hiya curscore)
		     ;;(mydefs:hiya curmel)
		     ;;(mydefs:hiya curcombo)
		     )))
	       )
	     )))
      (let ((result (combine tweakedMel base 0 0)))
	(if fileout
	    (phraseToKeyFile result fileout)
	    (values tweakedMel (car best))
	    ))
      )
    ))

(defun tweakDualUpdate (old)
  (multiple-value-bind (new score) (tweakMelodyRepeat (car old) (second old) :pitchRadius (* 2 (/ 1 *scaleInc*)))
    (list new (car old) score)))
  

(defun tweakDual (melA melB &key  (fileout nil))
  (let* ((historyLen 4)
	 (resultLen 10)
	 (result (do* ((oldscores (make-list historyLen :initial-element -1000000001)
				  (cons newscore (butlast oldscores)))
		       
		       (curduet (list melA melB -1000000000) (tweakDualUpdate curduet))
		       (history (list (subseq curduet 0 2)) (cons (subseq curduet 0 2) history))
		       (newscore -1000000000 (third curduet)))
		      ((<= newscore (car (last oldscores))) 
		       (if (> (length history) resultLen)
			   (subseq history 0 resultLen)
			   history)
		       ))))
    (if fileout
	(phraseToKeyFile (combine (caar result) 
				  (cadar result)
				  0 0) 
			 fileout)
	(mapcar #'(lambda (lst)
		    (combine (first lst) (second lst) 0 0))
		result))))



(defun callTweakDual (melA melB)
  (let ((reslst (tweakDual melA melB)))
    ;;(mydefs:hiya reslst)
    (with-open-file (out "/home/dabrowsa/lisp/fifo/out"
			 :direction :output
			 :if-exists :append)
      ;;(mydefs:hiya reslst)
      (loop for v in reslst do
	   ;;(mydefs:hiya v)
	   (phraseToKeyFileAux out (phraseToKeyStrLst v))))))

(defun callTweakSingle (melA melB &key (limited nil))
  (let* ((res (tweakMelodyRepeat melA melB :limited limited))
	 (rescmb (combine res melA 0 0)))
    ;;(mydefs:hiya reslst)
    (with-open-file (out "/home/dabrowsa/lisp/fifo/out"
			 :direction :output
			 :if-exists :append)
      ;;(mydefs:hiya res)
      (phraseToKeyFileAux out (phraseToKeyStrLst rescmb)))))

(defun makeShearFun (m) 
  (let* ((a (* (- 4) (- m 0.5)))
	 (b (- 1 a)))
    (lambda (tm) (+ (* a tm tm) (* b tm)))))

(defun shearNoteFun (fun)
  (lambda (nt)
    (let* ((ont (note-tm nt))
	   (offt (+ ont (note-dr nt)))
	   (funont (funcall fun ont))
	   (funofft (funcall fun offt))
	   (dur (- funofft funont))
	   (newnt (copy-note nt))
	   )
      (setf (note-tm newnt) funont)
      (setf (note-dr newnt) dur)
      newnt
      )))
		 
(defun shearPhrase (phr m)
  (let* ((fun01 (makeShearFun m))
	 (tex (timeExtremes phr))
	 (fun   (mydefs:makeScaledFun fun01 0 (second tex)))
	 (ntfun (shearNoteFun fun))
	 )
    (mapcar ntfun phr)))


(defun shearMelodyRepeat (base melody 
			  &key  (fileout nil)  (scoreCPFun #'cpScore08)
			    (timefrac 1/32)  )
  ;;(mydefs:hiya melody)
  (let ((historyLen 10)
	(history nil)
	(best (list -1000000000 melody))
	(tchs (remove-duplicates (mapcar #'note-ch melody)))
	(delay (- (first (timeExtremes melody))
		  (first (timeExtremes base))))
	)
    ;;(mydefs:hiya delay)
    (let (
	  (shearedMel 
	   (do* ((bestshear (second best) (second best))
		 
		 (iter 1 (+ iter 1))
		 (stop nil)
		 )
		(stop bestshear)
	     (format t "iterations: ~s~%" iter)
	     (format t "score: ~s~%" (car best))
	     (setq stop t)
	     
		  
	       
		 ;;(mydefs:hiya melbeg)
		 (do* ((mcur 3/8 (+ mcur timefrac)))
		      ((> mcur 5/8))
		   
		   ;;(mydefs:hiya icur)
		   ;;(mydefs:hiya melcur)

		   (let* ((curshear (shearPhrase bestshear mcur))
			  (curcombo (combine base curshear delay 0))
			  
			  (curchdseq (intervalSeq curcombo))
			  (curCPscore (Funcall scoreCPFun curchdseq tchs))
			  
			  
			  (curscore curCPscore)
			  
			  )
		     (mydefs:hiya curscore)
		     (if (> curscore (car best))
			 (progn ;;(format t "as good")
			   (setq history (cons curcombo history))
			   (setq stop nil)
			   (setq best (list curscore curshear))
			   ))
		     ;;(mydefs:hiya icur)
		     ;;(mydefs:hiya best)
		     ;;(mydefs:hiya curscore)
		     ;;(mydefs:hiya curmel)
		     ;;(mydefs:hiya curcombo)
		     )))
	       
	     ))
      ;;(mydefs:hiya history)
      (if fileout
	  (let ((result (combine shearedMel base delay 0)))
	    (phraseToKeyFile result fileout))
	  (if (> (length history) historyLen)
	      (subseq history 0 historyLen)
	      history)
	  ))
      )
    )

(defun callShear (melA melB)
  (let ((reslst (shearMelodyRepeat melA melB)))
    ;;(mydefs:hiya reslst)
    (with-open-file (out "/home/dabrowsa/lisp/fifo/out"
			 :direction :output
			 :if-exists :append)
      ;;(mydefs:hiya reslst)
      (loop for v in reslst do
	   ;;(mydefs:hiya v)
	   (phraseToKeyFileAux out (phraseToKeyStrLst v))))))

