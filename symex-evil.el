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
(require 'cl-lib)
(require 'symex-ui)
(require 'symex-motions)

(defun symex-state-init ()
  "Sets up all of evil-symex-state's little changes"
  (add-hook 'symex-selection-hook #'symex-mode-highlight-selected))

(defun symex-state-cleanup ()
  "Undoes all of evil-symex-state's little changes"
  (remove-hook 'symex-selection-hook #'symex-mode-highlight-selected)
  (symex--delete-overlay))

(evil-define-state symex
  "Symex state."
  :tag " <λ> "
  :message "-- SYMEX --"
  :entry-hook (symex-state-init)
  :exit-hook (symex-state-cleanup))

(define-key evil-symex-state-map (kbd "h") 'symex-go-backward)
(define-key evil-symex-state-map (kbd "j") 'symex-go-down)
(define-key evil-symex-state-map (kbd "k") 'symex-go-up)
(define-key evil-symex-state-map (kbd "l") 'symex-go-forward)
(define-key evil-symex-state-map (kbd "gh") 'evil-backward-char)
(define-key evil-symex-state-map (kbd "gl") 'evil-forward-char)
(define-key evil-symex-state-map (kbd "(") 'symex-create-round)
(define-key evil-symex-state-map (kbd "[") 'symex-create-square)
(define-key evil-symex-state-map (kbd ")") 'symex-wrap-round)
(define-key evil-symex-state-map (kbd "]") 'symex-wrap-square)
(define-key evil-symex-state-map (kbd "C-'") 'symex-cycle-quote)
(define-key evil-symex-state-map (kbd "C-,") 'symex-cycle-unquote)
(define-key evil-symex-state-map (kbd "`") 'symex-add-quoting-level)
(define-key evil-symex-state-map (kbd "C-`") 'symex-remove-quoting-level)
(define-key evil-symex-state-map (kbd "f") 'symex-traverse-forward)
(define-key evil-symex-state-map (kbd "b") 'symex-traverse-backward)
(define-key evil-symex-state-map (kbd "C-f") 'symex-traverse-forward-more)
(define-key evil-symex-state-map (kbd "C-b") 'symex-traverse-backward-more)
(define-key evil-symex-state-map (kbd "F") 'symex-traverse-forward-skip)
(define-key evil-symex-state-map (kbd "B") 'symex-traverse-backward-skip)
(define-key evil-symex-state-map (kbd "{") 'symex-leap-backward)
(define-key evil-symex-state-map (kbd "}") 'symex-leap-forward)
(define-key evil-symex-state-map (kbd "M-{") 'symex-soar-backward)
(define-key evil-symex-state-map (kbd "M-}") 'symex-soar-forward)
(define-key evil-symex-state-map (kbd "C-j") 'symex-climb-branch)
(define-key evil-symex-state-map (kbd "C-k") 'symex-descend-branch)
(define-key evil-symex-state-map (kbd "y") 'symex-yank)
(define-key evil-symex-state-map (kbd "Y") 'symex-yank-remaining)
(define-key evil-symex-state-map (kbd "p") 'symex-paste-after)
(define-key evil-symex-state-map (kbd "P") 'symex-paste-before)
(define-key evil-symex-state-map (kbd "x") 'symex-delete)
(define-key evil-symex-state-map (kbd "X") 'symex-delete-backward)
(define-key evil-symex-state-map (kbd "D") 'symex-delete-remaining)
(define-key evil-symex-state-map (kbd "c") 'symex-change)
(define-key evil-symex-state-map (kbd "C") 'symex-change-remaining)
(define-key evil-symex-state-map (kbd "C--") 'symex-clear)
(define-key evil-symex-state-map (kbd "s") 'symex-replace)
(define-key evil-symex-state-map (kbd "S") 'symex-change-delimiter)
(define-key evil-symex-state-map (kbd "H") 'symex-shift-backward)
(define-key evil-symex-state-map (kbd "L") 'symex-shift-forward)
(define-key evil-symex-state-map (kbd "M-H") 'symex-shift-backward-most)
(define-key evil-symex-state-map (kbd "M-L") 'symex-shift-forward-most)
(define-key evil-symex-state-map (kbd "K") 'symex-raise)
(define-key evil-symex-state-map (kbd "C-S-j") 'symex-emit-backward)
(define-key evil-symex-state-map (kbd "C-(") 'symex-capture-backward)
(define-key evil-symex-state-map (kbd "C-H") 'symex-capture-backward)
(define-key evil-symex-state-map (kbd "C-{") 'symex-emit-backward)
(define-key evil-symex-state-map (kbd "C-L") 'symex-capture-forward)
(define-key evil-symex-state-map (kbd "C-}") 'symex-emit-forward)
(define-key evil-symex-state-map (kbd "C-K") 'symex-emit-forward)
(define-key evil-symex-state-map (kbd "C-)") 'symex-capture-forward)
(define-key evil-symex-state-map (kbd "z") 'symex-swallow)
(define-key evil-symex-state-map (kbd "Z") 'symex-swallow-tail)
(define-key evil-symex-state-map (kbd "!") 'symex-split)
(define-key evil-symex-state-map (kbd "!") 'symex-join)
(define-key evil-symex-state-map (kbd "-") 'symex-splice)
(define-key evil-symex-state-map (kbd "o") 'symex-open-line-after)
(define-key evil-symex-state-map (kbd "O") 'symex-open-line-before)
(define-key evil-symex-state-map (kbd ">") 'symex-insert-newline)
(define-key evil-symex-state-map (kbd "<") 'symex-join-lines-backward)
(define-key evil-symex-state-map (kbd "C->") 'symex-append-newline)
(define-key evil-symex-state-map (kbd "C-<") 'symex-join-lines)
(define-key evil-symex-state-map (kbd "C-O") 'symex-append-newline)
(define-key evil-symex-state-map (kbd "J") 'symex-join-lines)
(define-key evil-symex-state-map (kbd "C-J") 'symex-collapse)
(define-key evil-symex-state-map (kbd "M-<") 'symex-collapse)
(define-key evil-symex-state-map (kbd "M->") 'symex-unfurl)
(define-key evil-symex-state-map (kbd "C-M-<") 'symex-collapse-remaining)
(define-key evil-symex-state-map (kbd "C-M->") 'symex-unfurl-remaining)
(define-key evil-symex-state-map (kbd "0") 'symex-goto-first)
(define-key evil-symex-state-map (kbd "M-h") 'symex-goto-first)
(define-key evil-symex-state-map (kbd "$") 'symex-goto-last)
(define-key evil-symex-state-map (kbd "M-l") 'symex-goto-last)
(define-key evil-symex-state-map (kbd "M-k") 'symex-goto-highest)
(define-key evil-symex-state-map (kbd "=") 'symex-tidy)
(define-key evil-symex-state-map (kbd "<tab>") 'symex-tidy)
(define-key evil-symex-state-map (kbd "C-=") 'symex-tidy-remaining)
(define-key evil-symex-state-map (kbd "C-<tab>") 'symex-tidy-remaining)
(define-key evil-symex-state-map (kbd "M-=") 'symex-tidy-proper)
(define-key evil-symex-state-map (kbd "M-<tab>") 'symex-tidy-proper)
(define-key evil-symex-state-map (kbd "A") 'symex-append-after)
(define-key evil-symex-state-map (kbd "a") 'symex-append-at-end)
(define-key evil-symex-state-map (kbd "i") 'symex-insert-at-beginning)
(define-key evil-symex-state-map (kbd "I") 'symex-insert-before)
(define-key evil-symex-state-map (kbd "w") 'symex-wrap)
(define-key evil-symex-state-map (kbd "W") 'symex-wrap-and-append)
(define-key evil-symex-state-map (kbd ";") 'symex-comment)
(define-key evil-symex-state-map (kbd "M-;") 'symex-comment-remaining)
(define-key evil-symex-state-map (kbd "H-h") 'symex--toggle-highlight)
(define-key evil-symex-state-map (kbd ".") 'symex-repeat)
(define-key evil-symex-state-map (kbd "C-.") 'symex-repeat-pop)
(define-key evil-symex-state-map (kbd "C-c .") 'symex-repeat-recent)
(define-key evil-symex-state-map (kbd "<return>") 'evil-insert-state)
(define-key evil-symex-state-map (kbd "<escape>") 'evil-normal-state)
(define-key evil-symex-state-map (kbd "u") 'evil-undo)
(define-key evil-symex-state-map (kbd "C-r") 'evil-redo)
(define-key evil-symex-state-map (kbd "\"") 'evil-use-register)
(define-key evil-symex-state-map (kbd "g;") 'evil-goto-last-change)
(define-key evil-symex-state-map (kbd "g,") 'evil-goto-last-change-reverse)
(define-key evil-symex-state-map (kbd "gg") 'evil-goto-first-line)
(define-key evil-symex-state-map (kbd "G") 'evil-goto-line)
(define-key evil-symex-state-map (kbd "q") 'evil-record-macro)
(define-key evil-symex-state-map (kbd "@") 'evil-execute-macro)
(define-key evil-symex-state-map (kbd "m") 'evil-set-marker)
(define-key evil-symex-state-map (kbd "'") 'evil-goto-mark-line)
(define-key evil-symex-state-map (kbd "/") 'evil-search-forward)
(define-key evil-symex-state-map (kbd "?") 'evil-search-backward)
(define-key evil-symex-state-map (kbd "#") 'evil-search-word-backward)
(define-key evil-symex-state-map (kbd "*") 'evil-search-word-forward)
(define-key evil-symex-state-map (kbd "n") 'evil-search-next)
(define-key evil-symex-state-map (kbd "N") 'evil-search-previous)
(define-key evil-symex-state-map (kbd "C-d") 'evil-scroll-down)
(define-key evil-symex-state-map (kbd "C-u") 'evil-scroll-up)
(define-key evil-symex-state-map (kbd "C-]") 'evil-jump-to-tag)
(define-key evil-symex-state-map (kbd "C-i") 'evil-jump-forward)
(define-key evil-symex-state-map (kbd "C-o") 'evil-jump-backward)
(define-key evil-symex-state-map (kbd "C-p") 'evil-paste-pop)
(define-key evil-symex-state-map (kbd "C-n") 'evil-paste-pop-next)

(provide 'symex-evil)
;;; symex-evil.el ends here
