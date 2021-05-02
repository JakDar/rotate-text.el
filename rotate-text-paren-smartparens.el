;;; rotate-text-paren-smartparens.el --- Description -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2021
;;
;; Author:  <https://github.com/JakDar>
;; Homepage: https://github.com/JakDar/rotate-text.el
;; Created: April 20, 2021
;; Modified: April 20, 2021
;; Version: 0.0.1
;; Package-Requires: ((emacs "24.3") (smartparens "1.11.0"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;;  Description
;;
;;; Code:


(require 'smartparens)
(defun rotate-text-paren-smartparens-get-data()
  "Adapter fro `sp-get-thing' to match api of `rotate-text-paren-get-paren-data-function'."
  (let* ((p  (sp-get-thing))
         (op (sp-get p :op)))
    (if (string= "" op)
        (list :start (- (sp-get p :beg) 1) :end (sp-get p :end) :left (sp-get p :prefix))
      (list :start (sp-get p :beg) :end (- (sp-get p :end) 1) :left op))))


(provide 'rotate-text-paren-smartparens)
;;; rotate-text-paren-smartparens.el ends here
