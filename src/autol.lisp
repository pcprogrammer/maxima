(in-package "MAXIMA")

;; These are the helper functions for autoloading.
;; The actual autoloading data is in src/max_ext.lisp
;(aload "plot.o")

(defun aload (file &aux *load-verbose* tem tried)
  (let ((in file)
	($system  (list  '(mlist)
			 #+kcl (concatenate 'string si::*system-directory*
					    "../src/foo.{o,lsp,lisp}"))))
    (declare (special $system))
    (setq tem ($file_search1 file '((mlist)
				    $file_search_lisp
				    $system)))
    (and tem (load tem))))

(defun $aload_mac (file &aux *load-verbose* tem tried)
  (let ((in file)
	($system  (list  '(mlist)
			 #+kcl (concatenate 'string si::*system-directory*
					    "../{src,share,share1,sharem}/foo.{mc,mac}"))))
    (declare (special $system))
    (setq tem ($file_search1 file '((mlist)
				    $FILE_SEARCH_MAXIMA
				    $system)))
    (and tem ($load tem))))






;for defun,defmfun
(defun autof (fun file)
  (unless (fboundp fun)
   (setf (symbol-function fun)
     	  #'(lambda (&rest l)
	              (aload file)
		      (apply fun l)))))

;for defmacro
(defun autom (fun file)
    (unless (fboundp fun)
	  (setf (macro-function fun)
		  #'(lambda (&rest l)
		      (aload file)
		      (funcall (macro-function fun)
			       (cons fun l) nil)))))
;for defmspec
(defun auto-mspec (fun file )
  (unless (get fun 'mfexpr*)
  (setf (get fun 'mfexpr*)
		 #'(lambda (l)
		     (aload file)
		     (funcall (get fun 'mfexpr*) l)))))

;foo(x,y):=..
(defun auto-mexpr (fun file)
    (unless (mget fun 'mexpr)
          (mputprop fun
              `((LAMBDA) ((MLIST) ((MLIST) |_l|))
                   ((MPROGN) ((aload) ',file ) (($APPLY) ',fun |_l|)))
	      'mexpr)
	      ))

;foo(x,y):=..
(defun $auto_mexpr (fun file)
    (unless (mget fun 'mexpr)
          (mputprop fun
              `((LAMBDA) ((MLIST) ((MLIST) |_l|))
                   ((MPROGN) (($aload_mac) ',file ) (($APPLY) ',fun |_l|)))
	      'mexpr)
	      ))



