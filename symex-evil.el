;;; symex-evil.el --- Use Symex with Evil -*- lexical-binding: t -*-

;; Author: Siddhartha Kasivajhula <sid@countvajhula.com>
;; URL: https://github.com/drym-org/symex.el
;; Version: 2.0
;; Package-Requires: ((emacs "25.1") (evil "1.2.14") (symex "2.0"))
;; Keywords: lisp, convenience, languages

;; This program is "part of the world," in the sense described at
;; https://drym.org.  From your perspective, this is no different than
;; MIT or BSD or other such "liberal" licenses that you may be
;; familiar with, that is to say, you are free to do whatever you like
;; with this program.  It is much more than BSD or MIT, however, in
;; that it isn't a license at all but an idea about the world and how
;; economic systems could be set up so that everyone wins.  Learn more
;; at drym.org.
;;
;; This work transcends traditional legal and economic systems, but
;; for the purposes of any such systems within which you may need to
;; operate:
;;
;; This is free and unencumbered software released into the public domain.
;; The authors relinquish any copyright claims on this work.
;;

;;; Commentary:

;; Use Symex with Evil.

;;; Code:

(require 'evil)
(require 'lithium)

;; These override the definitions in the symex package, so this
;; package (symex-evil) should be loaded after symex
(defun symex-escape-higher ()
  "Exit symex mode via an \"escape\"."
  (interactive)
  (cond (evil-mode (evil-normal-state))))

(defun symex-enter-lower ()
  "Exit symex mode via an \"enter\"."
  (interactive)
  (cond (evil-mode (evil-insert-state))))

(defun symex-enter-lowest ()
  "Enter the lowest (manual) editing level."
  (interactive)
  (cond (evil-mode (evil-insert-state))))

(evil-define-state symex
  "Symex state."
  :tag " <λ> "
  :message "-- SYMEX --")

(provide 'symex-evil)
;;; symex-evil.el ends here
