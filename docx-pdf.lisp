;;;; -*- Mode: Common-Lisp; Author: denes.cselovszky@gmail.com -*- 
                                                                              ;

(in-package #:docx-pdf)


;;; ----------------------------------------------------------------------
;;; minden


;(defparameter *test-dir* "C:\\Users\\cselovszkid\\common-lisp\\docx-pdf\\Munka\\Dokumentumok\\")
;(defparameter *test-dir2* "C:\\Users\\cselovszkid\\common-lisp\\docx-pdf\\Munka\\Kimenet\\")


(defparameter *independent-exe* nil)


(defun appdir ()
  (namestring (lw:current-pathname)))
#|  (if *independent-exe*
      (namestring (lw:current-pathname))
    "c:\\Users\\cselovszkid\\common-lisp\\docx-pdf\\"))|#


(defparameter *rec-texts* '("Csak kiválasztott mappában"
                            "Almappákban is"))

(defparameter *src-dir*   (appdir))
(defparameter *dst-dir*   (appdir))
(defparameter *recursive* (first *rec-texts*))
(defparameter *word*      nil)
(defparameter *runningp*  nil)


(defun directoryp (pathname)
  (let ((pathname-obj
         (typecase pathname
           (string   (parse-namestring pathname))
           (pathname pathname)
           (t        nil))))
    (when pathname-obj
      (let ((name (pathname-name pathname-obj)))
        (or (null name)
            (eq name :unspecific))))))


(defun filetypep (pathname type)
  (let ((pathname-obj
         (typecase pathname
           (string   (parse-namestring pathname))
           (pathname pathname)
           (t        nil))))
    (when pathname-obj
      (string-equal (pathname-type pathname-obj) type))))


(defun docxp (pathname)
  (filetypep pathname "docx"))


(defun rebase-subdir (absolute old-base new-base)
  (let* ((absolute-str (namestring absolute))
         (old-base-str (namestring old-base))
         (new-base-str (namestring new-base))
         (old-base-len (length old-base-str)))
    (when (and (directoryp old-base-str)
               (string= (subseq absolute-str 0 old-base-len)
                        old-base-str))
      (concatenate 'string new-base-str (subseq absolute-str old-base-len)))))


(defconstant +wd-format-pdf+ 17)


(defparameter *quit* nil)
(defparameter *dump* nil)
(defparameter *step* nil)


(defun convert-file (file)
  (let* ((dst-file (namestring (make-pathname :type "pdf" :defaults
                                              (rebase-subdir file *src-dir* *dst-dir*))))
         (dst-dir  (make-pathname :name nil :type nil :defaults dst-file)))
    (funcall *dump* "~a~%~%" dst-file)
    (ensure-directories-exist dst-dir)
    (with-document (:app *word* :open (namestring file) :doc output)
      (!saveas2 output dst-file +wd-format-pdf+)))
  (funcall *quit*)
  (funcall *step*))


(defun walk-directory (directory fn)
  (let* ((dir-string (namestring (parse-namestring directory)))
         (contents   (directory dir-string))
         (files      (remove-if-not #'docxp contents))
         (dirs       (remove-if-not #'directoryp contents)))
    (when files
      (dolist (file files)
        (funcall fn file)))
    (when (and (string= *recursive* (second *rec-texts*))
               dirs)
      (dolist (dir dirs)
        (walk-directory dir fn)))))


(defparameter *number-of-files* nil)

(defun process ()
  (with-wax-errorsink
    (with-property-accessors 
      (cclet* ((*word* (com:create-object :progid "Word.Application"))
               (*number-of-files* 0))
        (walk-directory *src-dir* #'(lambda (file)
                                      (declare (ignore file))
                                      (incf *number-of-files*)))
        (with-progress ("Konverzió" quit-on-abort dump step-progress-indicator
                       *number-of-files*)
          (let ((*quit* #'quit-on-abort)
                (*dump* #'dump)
                (*step* #'step-progress-indicator))
            (walk-directory *src-dir* #'convert-file)))))))


(defun start ()
  (setf *src-dir* (appdir)
        *dst-dir* (appdir))
  (wg-window
   "\".DOCX\" dokuemntumok konvertálása \".PDF\" formátumra"
   (wg-dir-selector "Forrásfájlok mappája"
                    #'(lambda (text &rest rest)
                        (declare (ignore rest))
                        (setf *src-dir* text))
                    *src-dir*)
   (wg-dir-selector "Generált .PDF-ek mappája"
                    #'(lambda (text &rest rest)
                        (declare (ignore rest))
                        (setf *dst-dir* text))
                    *dst-dir*)
   (wg-options "Almappákban is?"
               #'(lambda (text &rest rest)
                   (declare (ignore rest))
                   (setf *recursive* text))
               *rec-texts*
               *recursive*)
   (wg-button "Konvertálás"
              #'(lambda (interface)
                  (declare (ignore interface))
                    (unless *runningp*
                      (let ((*runningp* t))
                        (process)))))))
