;; textcat.el -- 
;; detect language using libtextcat
;; 
;; (c) VU NGOC San 2011-2017
;; http://blogperso.univ-rennes1.fr/san.vu-ngoc/public/divers/textcat.el
;;
;; Adapted from Martin Pohlack
;;;; URL: http://os.inf.tu-dresden.de/~mp26/download/flyspell-textcat.el
;;;;
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
;; GNU General Public License for more details.
;;
;; If you do not have a copy of the GNU General Public License, you
;; can obtain one by writing to the Free Software Foundation, Inc., 59
;; Temple Place - Suite 330, Boston, MA 02111-1307, USA.

;; libtextcat-2.2.tar.gz is downloaded and installed in /usr/local (see paths below)
;; ./configure --prefix=/usr/local/lib/textcat; make; sudo make install
;; cd langclass; sed -i 's|LM/|/usr/local/lib/textcat/LM/|g' conf.txt
;; cd ..
;; sudo cp src/.libs/testtextcat /usr/local/lib/textcat/
;; sudo cp -r langclass/* /usr/local/lib/textcat/


;; This can be called as follows (in your .emacs -- change the paths)
; (add-hook 'mail-mode-hook 'flyspell-mode)
; (load "$HOME/.emacs-perso/textcat.el")
; (add-hook 'flyspell-mode-hook 'textcat-change-ispell-dictionary)

;; customize this
(setq ispell-dictionary "francais")

;; and this
;;;
;; (setq textcat-to-ispell-alist
;;       '(("german" . "deutsch")
;; 	("english" . "english")
;; 	("french" . "francais")))




(defcustom textcat-to-ispell-alist
  '(("german" . "deutsch")
    ("english" . "english")
    ("french" . "francais"))
  "Maps libtextcat language names to ispell dictionary names"
  :type 'alist
  :group 'textcat)

(defcustom textcat-temp-buffer "*textcat-output*"
  "Buffer name for temporary output from external tool."
  :type 'string
  :group 'textcat)

(defcustom textcat-external-classifyier "/usr/local/lib/textcat/testtextcat"
  "Name for external classification tool."
  :type 'string
  :group 'textcat)

(defcustom textcat-external-param
  (expand-file-name "/usr/local/lib/textcat/conf.txt")
  "Parameter for external classification tool."
  :type 'string
  :group 'textcat)

(defcustom textcat-external-regexp
  "^Result == \\[?\\([a-zA-Z]+\\)\\]?.*$"
  "RegExp for extracting results from external classification tool."
  :type 'string
  :group 'textcat)

; parse whole buffer
(defun textcat-parse-buffer ()
  (interactive)
  (let ((buffer (get-buffer-create textcat-temp-buffer)))
    (save-excursion
      (set-buffer buffer)
      (erase-buffer))
    (unwind-protect
        (setq exit-status
              (call-process-region (point-min) (point-max)
                                   textcat-external-classifyier
                                   nil buffer nil
                                   textcat-external-param)))
    )
  )

; parse buffer after point
(defun textcat-parse-rest ()
  (interactive)
  (let ((buffer (get-buffer-create textcat-temp-buffer)))
    (save-excursion
      (set-buffer buffer)
      (erase-buffer))
    (unwind-protect
        (setq exit-status
              (call-process-region (point) (point-max)
                                   textcat-external-classifyier
                                   nil buffer nil
                                   textcat-external-param)))
    )
  )


(defun textcat-extract-result ()
  "Extract the result from the shell buffer."
  (save-excursion
    (set-buffer textcat-temp-buffer)
    (goto-char (point-min))
    (re-search-forward textcat-external-regexp)
    (match-string 1)
    )
  )

(defun textcat-change-ispell-dictionary ()
  "Detect language of the rest of the buffer (from current
position to end) and select corresponding ispell dictionary"
  (textcat-parse-rest)
  (let ((language (textcat-extract-result)))
    (let ((ispell-dict (cdr (assoc language textcat-to-ispell-alist))))
      (if (or (not ispell-dict)
	      ;; was not in the assoc list
	      (member ispell-dict '( "UNKNOWN", "SHORT" )))
	  (setq ispell-dict ispell-dictionary)
	nil
	)
      (message "Language detected=%s, dictionary=%s" language ispell-dict)
      (ispell-change-dictionary ispell-dict)
      )
    )
  )


(provide 'textcat)
