(require 'evil)

(require 'symex-evil-support)
(require 'symex-ui)
(require 'symex-interop)

(defvar symex-editing-mode-map (make-sparse-keymap))

(define-minor-mode symex-editing-mode
  "Minor mode to modulate keybindings in symex evil state."
  :lighter "symex"
  :keymap symex-editing-mode-map)

(evil-define-state symex
  "Symex state."
  :tag " <λ> "
  :message "-- SYMEX --"
  :enable (normal)
  :exit-hook (symex-exit-mode))

;; TODO: others that could accept a count argument:
;; shift, join, emit, capture
;; insert and append newline, simple insert/append
(defvar symex--evil-keyspec
  '(("h" . symex-go-backward)
    ("j" . symex-go-down)
    ("k" . symex-go-up)
    ("l" . symex-go-forward)
    ("(" . symex-create-round)
    ("[" . symex-create-square)
    ("{" . symex-create-curly)
    ("<" . symex-create-angled)
    (")" . symex-wrap-round)
    ("]" . symex-wrap-square)
    ("}" . symex-wrap-curly)
    (">" . symex-wrap-angled)
    ("f" . symex-traverse-forward)
    ("b" . symex-traverse-backward)
    ("F" . symex-traverse-forward-skip)
    ("B" . symex-traverse-backward-skip)
    ("C-h" . symex-leap-backward)
    ("C-l" . symex-leap-forward)
    ("C-M-h" . symex-soar-backward)
    ("C-M-l" . symex-soar-forward)
    ("C-k" . symex-climb-branch)
    ("C-j" . symex-descend-branch)
    ("y" . symex-yank)
    ("p" . symex-paste-after)
    ("P" . symex-paste-before)
    ("x" . symex-delete)
    ("c" . symex-change)
    ("C" . symex-clear)
    ("s" . symex-replace)
    ("S" . symex-change-delimiter)
    ("H" . symex-shift-backward)
    ("L" . symex-shift-forward)
    ("K" . paredit-raise-sexp) ; revisit kb
    ("C-S-j" . symex-emit-backward)
    ("C-(" . symex-capture-backward)
    ("C-S-h" . symex-capture-backward)
    ("C-{" . symex-emit-backward)
    ("C-S-l" . symex-capture-forward)
    ("C-}" . symex-emit-forward)
    ("C-S-k" . symex-emit-forward)
    ("C-)" . symex-capture-forward)
    ("z" . symex-swallow)
    ("Z" . symex-swallow-tail)
    ("e" . symex-evaluate)
    ("E" . symex-evaluate-pretty)
    ("d" . symex-evaluate-definition)
    ("M-e" . symex-eval-recursive)
    ("T" . symex-evaluate-thunk)
    (":" . eval-expression)
    ("t" . symex-switch-to-scratch-buffer)
    ("M" . symex-switch-to-messages-buffer)
    ("r" . symex-repl)
    ("R" . symex-run)
    ("X" . symex-run)
    ("|" . lispy-split)
    ("m" . symex-join)
    ("\\" . symex-splice)
    ("o" . symex-open-line-after)
    ("O" . symex-open-line-before)
    ("n" . symex-insert-newline)
    ("C-S-o" . symex-append-newline)
    ("J" . symex-join-lines)
    ("M-J" . symex-collapse)
    ("N" . symex-join-lines-backwards)
    ("0" . symex-goto-first)
    ("M-h" . symex-goto-first)
    ("$" . symex-goto-last)
    ("M-l" . symex-goto-last)
    ("M-j" . symex-goto-lowest)
    ("M-k" . symex-goto-highest)
    ("=" . symex-tidy)
    ("<tab>" . symex-tidy)
    ("M-=" . symex-tidy-proper)
    ("A" . symex-append-after)
    ("a" . symex-insert-at-end)
    ("i" . symex-insert-at-beginning)
    ("I" . symex-insert-before)
    ("w" . symex-wrap)
    ("g" . evil-jump-to-tag)   ; not needed
    ("G" . evil-jump-backward) ; not needed
    (";" . symex-comment)
    ("C-;" . symex-eval-print) ; weird pre-offset (in both)
    ("s-;" . symex-evaluate)
    ("H-h" . symex--toggle-highlight) ; treats visual as distinct mode
    ("?" . symex-describe)
    ("<return>" . symex-enter-lower)
    ("C-<escape>" . symex-enter-lower)
    ("<escape>" . symex-escape-higher)
    ("C-g" . symex-escape-higher))
  "Key specification for symex evil state.")

(symex--define-evil-keys-from-spec symex--evil-keyspec
                                   symex-editing-mode-map)

(defun symex-enable-editing-minor-mode ()
  "Enable symex minor mode."
  (symex-editing-mode 1))

(defun symex-disable-editing-minor-mode ()
  "Disable symex minor mode."
  (symex-editing-mode -1))



(provide 'symex-evil)
;;; symex-evil.el ends here
