;;; -*- Mode: Common-Lisp; Author: denes.cselovszky@gmail.com -*- 

(in-package "CL-USER")
(load "c:\\Users\\cselovszkid\\.lispworks")
(asdf:load-system "docx-pdf")

(in-package "DOCX-PDF")
(setf *independent-exe* t)
(lw:deliver 'start
    "c:\\Users\\cselovszkid\\common-lisp\\docx-pdf\\docx-pdf_v0.01.exe"
    5
    :interface :capi
    :console :io
    :multiprocessing t
    :keep-package-manipulation t
    :keep-function-name :all
    :symbol-names-action nil
;    :keep-eval t
;    :keep-lisp-reader t
    :startup-bitmap-file nil
    :kill-dspec-table nil
    :keep-conditions :all
    :keep-debug-mode t
;    :keep-load-function t
    :compact t
    )
