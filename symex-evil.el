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

(evil-define-state symex
  "Symex state."
  :tag " <λ> "
  :message "-- SYMEX --")

(define-key evil-symex-state-map "h" 'symex-go-backward)
(define-key evil-symex-state-map "j" 'symex-go-down)
(define-key evil-symex-state-map "k" 'symex-go-up)
(define-key evil-symex-state-map "l" 'symex-go-forward)
(define-key evil-symex-state-map "gh" 'evil-backward-char)
(define-key evil-symex-state-map "gl" 'evil-forward-char)
(define-key evil-symex-state-map "(" 'symex-create-round)
(define-key evil-symex-state-map "[" 'symex-create-square)
(define-key evil-symex-state-map ")" 'symex-wrap-round)
(define-key evil-symex-state-map "]" 'symex-wrap-square)
(define-key evil-symex-state-map "C-'" 'symex-cycle-quote)
(define-key evil-symex-state-map "C-," 'symex-cycle-unquote)
(define-key evil-symex-state-map "`" 'symex-add-quoting-level)
(define-key evil-symex-state-map "C-`" 'symex-remove-quoting-level)
(define-key evil-symex-state-map "f" 'symex-traverse-forward)
(define-key evil-symex-state-map "b" 'symex-traverse-backward)
(define-key evil-symex-state-map "C-f" 'symex-traverse-forward-more)
(define-key evil-symex-state-map "C-b" 'symex-traverse-backward-more)
(define-key evil-symex-state-map "F" 'symex-traverse-forward-skip)
(define-key evil-symex-state-map "B" 'symex-traverse-backward-skip)
(define-key evil-symex-state-map "{" 'symex-leap-backward)
(define-key evil-symex-state-map "}" 'symex-leap-forward)
(define-key evil-symex-state-map "M-{" 'symex-soar-backward)
(define-key evil-symex-state-map "M-}" 'symex-soar-forward)
(define-key evil-symex-state-map "C-j" 'symex-climb-branch)
(define-key evil-symex-state-map "C-k" 'symex-descend-branch)
(define-key evil-symex-state-map "y" 'symex-yank)
(define-key evil-symex-state-map "Y" 'symex-yank-remaining)
(define-key evil-symex-state-map "p" 'symex-paste-after)
(define-key evil-symex-state-map "P" 'symex-paste-before)
(define-key evil-symex-state-map "x" 'symex-delete)
(define-key evil-symex-state-map "X" 'symex-delete-backward)
(define-key evil-symex-state-map "D" 'symex-delete-remaining)
(define-key evil-symex-state-map "c" 'symex-change)
(define-key evil-symex-state-map "C" 'symex-change-remaining)
(define-key evil-symex-state-map "C--" 'symex-clear)
(define-key evil-symex-state-map "s" 'symex-replace)
(define-key evil-symex-state-map "S" 'symex-change-delimiter)
(define-key evil-symex-state-map "H" 'symex-shift-backward)
(define-key evil-symex-state-map "L" 'symex-shift-forward)
(define-key evil-symex-state-map "M-H" 'symex-shift-backward-most)
(define-key evil-symex-state-map "M-L" 'symex-shift-forward-most)
(define-key evil-symex-state-map "K" 'symex-raise)
(define-key evil-symex-state-map "C-S-j" 'symex-emit-backward)
(define-key evil-symex-state-map "C-(" 'symex-capture-backward)
(define-key evil-symex-state-map "C-H" 'symex-capture-backward)
(define-key evil-symex-state-map "C-{" 'symex-emit-backward)
(define-key evil-symex-state-map "C-L" 'symex-capture-forward)
(define-key evil-symex-state-map "C-}" 'symex-emit-forward)
(define-key evil-symex-state-map "C-K" 'symex-emit-forward)
(define-key evil-symex-state-map "C-)" 'symex-capture-forward)
(define-key evil-symex-state-map "z" 'symex-swallow)
(define-key evil-symex-state-map "Z" 'symex-swallow-tail)
(define-key evil-symex-state-map "!" 'symex-split)
(define-key evil-symex-state-map "!" 'symex-join)
(define-key evil-symex-state-map "-" 'symex-splice)
(define-key evil-symex-state-map "o" 'symex-open-line-after)
(define-key evil-symex-state-map "O" 'symex-open-line-before)
(define-key evil-symex-state-map ">" 'symex-insert-newline)
(define-key evil-symex-state-map "<" 'symex-join-lines-backward)
(define-key evil-symex-state-map "C->" 'symex-append-newline)
(define-key evil-symex-state-map "C-<" 'symex-join-lines)
(define-key evil-symex-state-map "C-O" 'symex-append-newline)
(define-key evil-symex-state-map "J" 'symex-join-lines)
(define-key evil-symex-state-map "C-J" 'symex-collapse)
(define-key evil-symex-state-map "M-<" 'symex-collapse)
(define-key evil-symex-state-map "M->" 'symex-unfurl)
(define-key evil-symex-state-map "C-M-<" 'symex-collapse-remaining)
(define-key evil-symex-state-map "C-M->" 'symex-unfurl-remaining)
(define-key evil-symex-state-map "0" 'symex-goto-first)
(define-key evil-symex-state-map "M-h" 'symex-goto-first)
(define-key evil-symex-state-map "$" 'symex-goto-last)
(define-key evil-symex-state-map "M-l" 'symex-goto-last)
(define-key evil-symex-state-map "M-k" 'symex-goto-highest)
(define-key evil-symex-state-map "=" 'symex-tidy)
(define-key evil-symex-state-map "<tab>" 'symex-tidy)
(define-key evil-symex-state-map "C-=" 'symex-tidy-remaining)
(define-key evil-symex-state-map "C-<tab>" 'symex-tidy-remaining)
(define-key evil-symex-state-map "M-=" 'symex-tidy-proper)
(define-key evil-symex-state-map "M-<tab>" 'symex-tidy-proper)
(define-key evil-symex-state-map "A" 'symex-append-after)
(define-key evil-symex-state-map "a" 'symex-append-at-end)
(define-key evil-symex-state-map "i" 'symex-insert-at-beginning)
(define-key evil-symex-state-map "I" 'symex-insert-before)
(define-key evil-symex-state-map "w" 'symex-wrap)
(define-key evil-symex-state-map "W" 'symex-wrap-and-append)
(define-key evil-symex-state-map ";" 'symex-comment)
(define-key evil-symex-state-map "M-;" 'symex-comment-remaining)
(define-key evil-symex-state-map "H-h" 'symex-toggle-highlight)
(define-key evil-symex-state-map "." 'symex-repeat)
(define-key evil-symex-state-map "C-." 'symex-repeat-pop)
(define-key evil-symex-state-map "C-c ." 'symex-repeat-recent)
(define-key evil-symex-state-map "<return>" 'evil-insert-state)
(define-key evil-symex-state-map "<escape>" 'evil-normal-state)
(define-key evil-symex-state-map "u" 'evil-undo)
(define-key evil-symex-state-map "C-r" 'evil-redo)
(define-key evil-symex-state-map "\"" 'evil-use-register)
(define-key evil-symex-state-map "g;" 'evil-goto-last-change)
(define-key evil-symex-state-map "g," 'evil-goto-last-change-reverse)
(define-key evil-symex-state-map "gg" 'evil-goto-first-line)
(define-key evil-symex-state-map "G" 'evil-goto-line)
(define-key evil-symex-state-map "q" 'evil-record-macro)
(define-key evil-symex-state-map "@" 'evil-execute-macro)
(define-key evil-symex-state-map "m" 'evil-set-marker)
(define-key evil-symex-state-map "'" 'evil-goto-mark-line)
(define-key evil-symex-state-map "/" 'evil-search-forward)
(define-key evil-symex-state-map "?" 'evil-search-backward)
(define-key evil-symex-state-map "#" 'evil-search-word-backward)
(define-key evil-symex-state-map "*" 'evil-search-word-forward)
(define-key evil-symex-state-map "n" 'evil-search-next)
(define-key evil-symex-state-map "N" 'evil-search-previous)
(define-key evil-symex-state-map "C-d" 'evil-scroll-down)
(define-key evil-symex-state-map "C-u" 'evil-scroll-up)
(define-key evil-symex-state-map "C-]" 'evil-jump-to-tag)
(define-key evil-symex-state-map "C-i" 'evil-jump-forward)
(define-key evil-symex-state-map "C-o" 'evil-jump-backward)
(define-key evil-symex-state-map "C-p" 'evil-paste-pop)
(define-key evil-symex-state-map "C-n" 'evil-paste-pop-next)

(provide 'symex-evil)
;;; symex-evil.el ends here
