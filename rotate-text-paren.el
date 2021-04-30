;;; rotate-text-paren.el --- Description -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2021
;;
;; Author:  <https://github.com/JakDar>
;; Created: April 20, 2021
;; Modified: April 20, 2021
;; Version: 0.0.1
;; Package-Requires: ((emacs "27.1"))
;; Homepage: https://github.com/JakDar/rotate-text.el
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;;  Description
;;
;;; Code:

(eval-when-compile (require 'cl-lib))

(defvar rotate-text-paren-pairs  '(("()" "{}" "[]"))
  "*List of paren pair groups to rotate.")


(defvar rotate-text-local-paren-pairs nil
  "*Buffer local additions to `rotate-text-paren-pairs'.")
(make-variable-buffer-local 'rotate-text-local-paren-pairs) ;TODO:bcm  use

(defvar rotate-text-paren-get-paren-data-function nil
  "Function to find paren position for current point.
Return (list :start <pos-before-start-char> :end <pos-before-end-char> :left <left-paren-char>).
Defaults to `rotate-text-paren-show-paren-get-data' if set to nil.")

(defun rotate-text-paren--symbols ()
  "For each paren group in `rotate-text-paren-pairs' return list (flattened) of parens."
  (mapcar
   (lambda (pairs)
     (mapcan
      (lambda (pair)
        (list
         (string-to-char (substring pair 0 1))
         (string-to-char (substring pair 1 2))))
      pairs)) rotate-text-paren-pairs))

(defun rotate-text-paren--left->next-pair (paren-group) ;TODO: cleanup
  "For each starting paren `PAREN-GROUP' return next paren pair we want to rotate to."
  (let ((startchars  (mapcar (lambda (pair) (substring pair 0 1) ) paren-group ))
        (rotated-pairs (cons (car (last paren-group)) (butlast paren-group))))
    (cl-mapcar #'cons startchars rotated-pairs)))

(defun rotate-text-paren-rotate-parens ()
  "Toggle parens at cursor.
Utilizes modified `rotate-text-paren-get-paren-data-function'
with smartparens or show-paren backend to find and replace them
with the other pair of brackets. This function can be easily
modified and expanded to replace other brackets. Currently,
mismatch information is ignored and mismatched parens are changed
based on the left one."
  (interactive)
  (save-excursion
    (let* ((parens (if rotate-text-paren-get-paren-data-function
                       (funcall rotate-text-paren-get-paren-data-function)
                     (progn
                       (require 'rotate-text-paren-show-paren)
                       (rotate-text-paren-show-paren-get-data))))
           (start (plist-get parens :start))
           (end (plist-get parens :end))
           (startchar (plist-get parens :left)))
      (when parens
        (let* (
               (left-to-next-pair
                (apply 'cl-concatenate 'list
                       (mapcar
                        #'rotate-text-paren--left->next-pair
                        rotate-text-paren-pairs)))
               (next-pair
                (cl-find-if
                 (lambda (pair) (string= (car pair) startchar ))
                 left-to-next-pair))
               )
          (if next-pair
              (rotate-text-paren--replace (cdr next-pair) start end)
            (message "Missing paren. starchar: [%s] , parens: [%S]"
                     startchar
                     (rotate-text-paren--left->next-pair (car rotate-text-paren-pairs)))))))))

(defun rotate-text-paren--replace (pair start end)
  "Replace parens with a new PAIR at START and END in current buffer.

A helper function for `rotate-text-paren-rotate-parens'."
  (goto-char start)
  (delete-char 1)
  (insert (substring pair 0 1))
  (goto-char end)
  (delete-char 1)
  (insert (substring pair 1 2)))


(defun rotate-text-paren-or-text(arg &optional default-string com-symbols com-words com-patterns)
  "."
  (interactive (list (if (consp current-prefix-arg)
                         -1
                       (prefix-numeric-value current-prefix-arg))))
  (if (cl-find (char-after) (flatten-list (rotate-text-paren--symbols)))
      (rotate-text-paren-rotate-parens)
    (rotate-text arg default-string com-symbols com-words com-patterns)))



(provide 'rotate-text-paren)
;;; rotate-text-paren.el ends here
