;;; symex.el --- An evil way to edit Lisp symbolic expressions as trees -*- lexical-binding: t -*-

;; Author: Siddhartha Kasivajhula <sid@countvajhula.com>
;; URL: https://github.com/drym-org/symex.el
;; Version: 2.0
;; Package-Requires: ((emacs "25.1") (seq "2.22") (symex-core "2.0") (mantra "0.1") (repeat-ring "0.1") (pubsub "0.1"))
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

;; Symex mode (pronounced sym-ex, as in symbolic expression) is a vim-
;; inspired way of editing Lisp code as trees.  Entering symex mode
;; allows you to reason about your code in terms of its structure,
;; similar to other tools like paredit and lispy.  But while in those
;; packages the tree representation is implicit, symex mode models
;; the tree structure explicitly so that tree navigations and operations
;; can be described using an expressive DSL, and invoked in a vim-
;; style modal interface.
;;
;; Under the hood, Symex mode uses paredit and Tree-Sitter for parsing
;; the code syntax tree.

;;; Code:

(require 'symex-core)

(require 'symex-repeat)
(require 'symex-ui)

(defgroup symex-mode nil
  "Point-free modal UI for Symex."
  :group 'symex)

(defcustom symex-orientation 'inverted
  "This determines the meaning of \"up\" and \"down\" in navigating code as trees.

A value of `inverted' means that more nested expressions are
considered \"lower\" and less nested expressions are \"higher.\" This
corresponds to a familiar sense of \"tree\" in programming contexts.

A value of `squirrel' means that more nested expressions are
considered \"higher,\" with the root being the \"lowest\" node, like
actual trees growing in the ground outside.  Think going down towards
the root and up towards the nest.

Note that modules in the Symex library itself use the \"squirrel\"
sense in all internal naming conventions, as this was formerly the
default (and only) orientation."
  :type 'symbol
  :group 'symex-mode)

(defcustom symex-refocus-p t
  "Whether to refocus on the selected symex when it's near the screen's edge."
  :type 'boolean
  :group 'symex-mode)

(defcustom symex-preserve-point-on-entry-p nil
  "Whether point should be preserved upon entry to Symex.

The default value of nil means that point is moved to indicate the
selected symex, in a strict fashion."
  :type 'boolean
  :group 'symex-mode)

(defun symex-mode-highlight-selected (&rest _)
  "Things to do as part of symex selection, e.g. after navigations."
  (when symex-highlight-p
    (symex--update-overlay)))

(defun symex-enter-mode ()
  "Take necessary action upon symex mode entry."
  (add-hook 'symex-selection-hook
            #'symex-mode-highlight-selected)
  (when symex-remember-branch-positions-p
    (symex--clear-branch-memory))
  (if symex-preserve-point-on-entry-p
      (symex-user-select-nearest-idempotent)
    (symex-user-select-nearest))
  ;; TODO: this concept of primitive entry should be removed.
  ;; it enables the change notifier mainly, and we should
  ;; instead do that via a symex-treesit-mode, perhaps
  ;; eliminate, in favor of a ts minor mode.
  (symex--primitive-enter)
  ;; enable parsing for repeat functionality
  (symex-repeat-enable)
  (when symex-refocus-p
    ;; smooth scrolling currently not supported
    ;; may add it back in the future
    (symex--set-scroll-margin))
  (unless (or (member major-mode (symex-get-lisp-modes))
              (symex-ts-available-p))
    (message "WARNING (Symex): Consider using a tree-sitter enabled major mode for %s."
             (buffer-name))))

(defun symex-exit-mode ()
  "Take necessary action upon symex mode exit."
  (remove-hook 'symex-selection-hook
               #'symex-mode-highlight-selected)
  (when symex-refocus-p
    (symex--restore-scroll-margin))
  (symex--delete-overlay)
  (symex--primitive-exit)
  ;; if we are exiting as part of a repeatable action
  ;; then don't suspend the symex repeat parser
  (unless (member symex--current-keys symex-repeatable-keys)
    (symex-repeat-disable)))

(defun symex-set-orientation ()
  "Initialize keybindings according to user customization of the orientation."
  (cond ((eq 'squirrel symex-orientation)
         (define-key evil-symex-state-map "k" 'symex-go-up)
         (define-key evil-symex-state-map "j" 'symex-go-down)
         (define-key evil-symex-state-map "C-j" 'symex-climb-branch)
         (define-key evil-symex-state-map "C-k" 'symex-descend-branch)
         (define-key evil-symex-state-map "M-k" 'symex-goto-highest)
         (define-key evil-symex-state-map "M-j" 'symex-goto-lowest))
        ((eq 'inverted symex-orientation)
         (define-key evil-symex-state-map "k" 'symex-go-down)
         (define-key evil-symex-state-map "j" 'symex-go-up)
         (define-key evil-symex-state-map "C-j" 'symex-descend-branch)
         (define-key evil-symex-state-map "C-k" 'symex-climb-branch)
         (define-key evil-symex-state-map "M-k" 'symex-goto-lowest)
         (define-key evil-symex-state-map "M-j" 'symex-goto-highest))
        (t (error "Invalid Symex orientation!"))))

;;;###autoload
(defun symex-modal-initialize ()
  "Initialize the modal interface."
  ;; any side effects that should happen as part of selection,
  ;; e.g., update overlay
  (unless symex-core-mode
    (symex-core-mode 1))
  ;; initialize repeat command
  (symex-repeat-initialize)
  (add-hook 'symex-editing-mode-pre-entry-hook
            #'symex-enter-mode)
  (add-hook 'symex-editing-mode-pre-exit-hook
            #'symex-exit-mode)
  (symex-set-orientation))

(defun symex-modal-disable ()
  "Disable symex modal interface."
  ;; remove all advice
  (symex-repeat-teardown))

;;;###autoload
(defun symex-mode-interface ()
  "The main entry point for editing symbolic expressions using symex mode.

Enter the symex modal interface, activating symex keybindings."
  (interactive)
  (evil-symex-state))

(defun symex-evil-initialize ()
  "Evil interconnects for Symex."
  ;; It's necessary to override all these keys because enabling normal
  ;; state in symex evil state overrides Symex's handling of counts
  ;; (though it otherwise works fine). So we must leave normal state
  ;; disabled in symex state, which necessitates redefining the
  ;; relevant bindings in symex mode explicitly.
  ;; TODO: handle other undo systems?
  
  (add-hook 'symex-editing-mode-pre-entry-hook
            #'symex--adjust-point-on-entry)
  (add-hook 'symex-editing-mode-pre-entry-hook
            #'evil-symex-state))

(defun symex-evil-disable ()
  "Disable evil interop."
  (remove-hook 'symex-editing-mode-pre-entry-hook
               #'symex--adjust-point-on-entry)
  (remove-hook 'symex-editing-mode-pre-entry-hook
               #'evil-symex-state))

;;;###autoload
(define-minor-mode symex-mode
  "An evil way to edit Lisp symbolic expressions as trees."
  :lighter " symex"
  :global t
  :group 'symex
  (if symex-mode
      (progn (symex-modal-initialize)
	     (symex-evil-initialize))
    (progn (symex-modal-disable)
	   (symex-evil-disable))))

(defun symex--adjust-point ()
  "Helper to adjust point to indicate the correct symex."
  (unless (or (bobp)
              (bolp)
              (symex-lisp--point-at-start-p)
              (looking-back "[,'`]" (line-beginning-position))
              (save-excursion (backward-char)  ; just inside symex
                              (or (symex-left-p)
                                  ;; this is to exclude the case where
                                  ;; we're inside a string, "|abc"
                                  ;; which "inverts" the code structure
                                  ;; and causes unexpected behavior when
                                  ;; navigating using Emacs's built-in
                                  ;; primitive symex motions. Unlike normal
                                  ;; forms, opening and closing delimiters
                                  ;; are not distinguished for strings and
                                  ;; so we can't specifically check for
                                  ;; "open quote," with the result that
                                  ;; in the case "abc"|, we don't always
                                  ;; select the right symex the way we
                                  ;; would with (abc)|.
                                  (symex-lisp-string-p))))
    (condition-case nil
        (backward-char)
      (error nil))))

(defun symex--adjust-point-on-entry ()
  "Adjust point context from the Emacs to the Vim interpretation.

If entering symex mode from Insert or Emacs mode, then translate point
so it indicates the appropriate symex in Symex mode.  This is necessary
because in Emacs, the symex preceding point is indicated.  In Vim, the
symex \"under\" point is indicated.  We want to make sure to select the
right symex when we enter Symex mode."
  (interactive)
  (when (or (not evil-mode)
            (member evil-state '(insert emacs))
            (not (symex-ts-available-p)))
    (symex--adjust-point)))


(provide 'symex)
;;; symex.el ends here
