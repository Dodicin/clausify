;;;; 808292 Habbash Nassim

;
; --- Formula validity control
;

(defun termp (x)
	(or
		(constp x)
		(varp x)
		(funcp x)
		(predp x)))

(defun constp (x)
	(if (listp x) nil
	(or	
		(numberp x)
		(letterp x))))

(defun letterp (x)
 	(not (parse-integer (symbol-name x) :start 0 :end 1 :junk-allowed t)))

(defun varp (x)
	(if (listp x) nil
	(char= #\? (char (symbol-name x) 0))))

(defun funcp (x)
	(and
		(listp x) 
		(symbolp (first x)) 
		(termp (rest x))))
(defun predp (x)
	(or
		(letterp x)
		(funcp x)))

;
; --- Rewrite rules
;