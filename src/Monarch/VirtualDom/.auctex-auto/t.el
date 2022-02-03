(TeX-add-style-hook
 "t"
 (lambda ()
   (setq TeX-command-extra-options
         "-shell-escape")
   (TeX-add-to-alist 'LaTeX-provided-package-options
                     '(("inputenc" "utf8") ("fontenc" "T1") ("embedall" "main" "include") ("Alegreya" "osf") ("sourcecodepro" "scale=0.88") ("microtype" "activate={true,nocompatibility}" "final" "tracking=true" "kerning=true" "spacing=true" "factor=2000")))
   (TeX-run-style-hooks
    "latex2e"
    "scrartcl"
    "scrartcl10"
    "inputenc"
    "fontenc"
    "xcolor"
    "hyperref"
    "embedall"
    "Alegreya"
    "AlegreyaSans"
    "sourcecodepro"
    "microtype")
   (TeX-add-symbols
    '("acr" 1)
    "acrs")
   (LaTeX-add-labels
    "sec:8hi1dcc2ab4erefrb0c8q1cai2acnc6a29-"))
 :latex)
