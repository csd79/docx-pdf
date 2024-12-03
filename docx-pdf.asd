(defsystem "docx-pdf"
  :description "Converting .DOCX files to .PDF"
  :author      "Denes Cselovszki <denes.cselovszki@gmail.com>"
  :version     "0.01"
  :depends-on  ("ccom" "wax")
  :serial      t
  :components  ((:file "package")
                (:file "fli-templates")
                (:file "docx-pdf")))
