;;; alchemist.el --- Elixir tooling integration into Emacs

;; Copyright © 2014-2015 Samuel Tonini
;;
;; Author: Samuel Tonini <tonini.samuel@gmail.com>

;; URL: http://www.github.com/tonini/alchemist.el
;; Version: 0.15.0-cvs
;; Package-Requires: ((emacs "24"))
;; Keywords: languages, mix, elixir, elixirc, hex

;; This file is not part of GNU Emacs.

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program. If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Alchemist integrate Elixir's tooling into Emacs

;;; Code:

(defgroup alchemist nil
  "Elixir Tooling Integration Into Emacs."
  :prefix "alchemist-"
  :group 'applications
  :link '(url-link :tag "Github" "https://github.com/tonini/alchemist.el")
  :link '(emacs-commentary-link :tag "Commentary" "alchemist"))

(require 'alchemist-utils)
(require 'alchemist-project)
(require 'alchemist-buffer)
(require 'alchemist-compile)
(require 'alchemist-execute)
(require 'alchemist-mix)
(require 'alchemist-hooks)
(require 'alchemist-help)
(require 'alchemist-complete)
(require 'alchemist-message)
(require 'alchemist-iex)
(require 'alchemist-eval)
(require 'alchemist-goto)

(eval-after-load 'company
  '(progn
     (require 'alchemist-company)))

(defun alchemist-mode-hook ()
  "Hook which enables `alchemist-mode'"
  (alchemist-mode 1))

(defvar alchemist--version "0.15.0-cvs")

;;;###autoload
(defun alchemist-version (&optional show-version)
  "Display Alchemist's version."
  (interactive)
  (message "Alchemist %s" (replace-regexp-in-string "-cvs" "snapshot" alchemist--version)))

(defvar alchemist-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "C-c a t") 'alchemist-mix-test)
    (define-key map (kbd "C-c a m c") 'alchemist-mix-compile)
    (define-key map (kbd "C-c a m t f") 'alchemist-mix-test-file)
    (define-key map (kbd "C-c a m t b") 'alchemist-mix-test-this-buffer)
    (define-key map (kbd "C-c a m t .") 'alchemist-mix-test-at-point)
    (define-key map (kbd "C-c a c c") 'alchemist-compile)
    (define-key map (kbd "C-c a c f") 'alchemist-compile-file)
    (define-key map (kbd "C-c a c b") 'alchemist-compile-this-buffer)
    (define-key map (kbd "C-c a e e") 'alchemist-execute)
    (define-key map (kbd "C-c a e f") 'alchemist-execute-file)
    (define-key map (kbd "C-c a e b") 'alchemist-execute-this-buffer)
    (define-key map (kbd "C-c a h h") 'alchemist-help)
    (define-key map (kbd "C-c a h e") 'alchemist-help-search-at-point)
    (define-key map (kbd "C-c a h m") 'alchemist-help-search-marked-region)
    (define-key map (kbd "C-c a p f") 'alchemist-project-find-test)
    (define-key map (kbd "C-c a p t") 'alchemist-project-open-tests-for-current-file)
    (define-key map (kbd "C-c a p s") 'alchemist-project-toggle-file-and-tests)
    (define-key map (kbd "C-c a p o") 'alchemist-project-toggle-file-and-tests-other-window)
    (define-key map (kbd "C-c a i i") 'alchemist-iex-run)
    (define-key map (kbd "C-c a i p") 'alchemist-iex-project-run)
    (define-key map (kbd "C-c a i l") 'alchemist-iex-send-current-line)
    (define-key map (kbd "C-c a i c") 'alchemist-iex-send-current-line-and-go)
    (define-key map (kbd "C-c a i r") 'alchemist-iex-send-region)
    (define-key map (kbd "C-c a i m") 'alchemist-iex-send-region-and-go)
    (define-key map (kbd "C-c a i b") 'alchemist-iex-compile-this-buffer)
    (define-key map (kbd "C-c a v l") 'alchemist-eval-current-line)
    (define-key map (kbd "C-c a v k") 'alchemist-eval-print-current-line)
    (define-key map (kbd "C-c a v j") 'alchemist-eval-quoted-current-line)
    (define-key map (kbd "C-c a v h") 'alchemist-eval-print-quoted-current-line)
    (define-key map (kbd "C-c a v o") 'alchemist-eval-region)
    (define-key map (kbd "C-c a v i") 'alchemist-eval-print-region)
    (define-key map (kbd "C-c a v u") 'alchemist-eval-quoted-region)
    (define-key map (kbd "C-c a v y") 'alchemist-eval-print-quoted-region)
    (define-key map (kbd "C-c a v q") 'alchemist-eval-buffer)
    (define-key map (kbd "C-c a v w") 'alchemist-eval-print-buffer)
    (define-key map (kbd "C-c a v e") 'alchemist-eval-quoted-buffer)
    (define-key map (kbd "C-c a v r") 'alchemist-eval-print-quoted-buffer)
    (define-key map (kbd "M-.") 'alchemist-goto-definition-at-point)
    (define-key map (kbd "M-,") 'alchemist-goto-jump-back)
    map)
  "The keymap used when `alchemist-mode' is active.")

(easy-menu-define alchemist-mode-menu alchemist-mode-map
  "Alchemist mode menu."
  '("Alchemist"
    ("Goto"
     ["Jump to definiton at point" alchemist-goto-definition-at-point]
     ["Jump back" alchemist-goto-jump-back])
    ("Evaluate"
     ["Evaluate current line" alchemist-eval-current-line]
     ["Evaluate current line and print" alchemist-eval-print-current-line]
     ["Evaluate quoted current line" alchemist-eval-quoted-current-line]
     ["Evaluate quoted current line and print" alchemist-eval-print-quoted-current-line]
     "---"
     ["Evaluate region" alchemist-eval-region]
     ["Evaluate region and print" alchemist-eval-print-region]
     ["Evaluate quoted region" alchemist-eval-quoted-region]
     ["Evaluate quoted region and print" alchemist-eval-print-quoted-region]
     "---"
     ["Evaluate buffer" alchemist-eval-buffer]
     ["Evaluate buffer and print" alchemist-eval-print-buffer]
     ["Evaluate quoted buffer" alchemist-eval-quoted-buffer]
     ["Evaluate quoted buffer and print" alchemist-eval-print-quoted-buffer])
    ("Compile"
     ["Compile..." alchemist-compile]
     ["Compile this buffer" alchemist-compile-this-buffer]
     ["Compile file" alchemist-compile-file])
    ("Execute"
     ["Execute..." alchemist-compile]
     ["Execute this buffer" alchemist-execute-this-buffer]
     ["Execute file" alchemist-execute-file])
    ("Mix"
     ["Mix deps..." alchemist-mix-deps-with-prompt]
     ["Mix compile..." alchemist-mix-compile]
     ["Mix run..." alchemist-mix-run]
     "---"
     ["Mix test this buffer" alchemist-mix-test-this-buffer]
     ["Mix test file..." alchemist-mix-test-file]
     ["Mix test at point" alchemist-mix-test-at-point]
     "---"
     ["Mix..." alchemist-mix]
     ["Mix new..." alchemist-mix-new]
     ["Mix hex search..." alchemist-mix-hex-search]
     "---"
     ["Mix local..." alchemist-mix-local-with-prompt]
     ["Mix local install..." alchemist-mix-local-install]
     ["Mix local install (Path)..." alchemist-mix-local-install-with-path]
     ["Mix local install (URL)..." alchemist-mix-local-install-with-url]
     "---"
     ["Display mix buffer" alchemist-mix-display-mix-buffer]
     "---"
     ["Mix help..." alchemist-mix-help])
    ("IEx"
     ["IEx send current line" alchemist-iex-send-current-line]
     ["IEx send current line and go" alchemist-iex-send-current-line-and-go]
     "---"
     ["IEx send last region" alchemist-iex-send-last-sexp]
     ["IEx send region" alchemist-iex-send-region]
     ["IEx send region and go" alchemist-iex-send-region-and-go]
     "---"
     ["IEx compile this buffer" alchemist-iex-compile-this-buffer]
     ["IEx recompile this buffer" alchemist-iex-recompile-this-buffer]
     "---"
     ["IEx run" alchemist-iex-run])
    ("Project"
     ["Project find all tests" alchemist-project-find-test]
     ["Project find tests for current file" alchemist-project-open-tests-for-current-file]
     ["Project toggle between file and test" alchemist-project-toggle-file-and-tests]
     ["Project toggle between file and test in other window" alchemist-project-toggle-file-and-tests-other-window]
     "---"
     ["Project toggle compile when needed" alchemist-project-toggle-compile-when-needed
      :style toggle :selected alchemist-project-compile-when-needed])
    ("Documentation"
     ["Documentation search..." alchemist-help]
     ["Documentation search history..." alchemist-help-history]
     "---"
     ["Documentation search at point..." alchemist-help-search-at-point]
     ["Documentation search marked region..." alchemist-help-search-marked-region])
    ))

;;;###autoload
(define-minor-mode alchemist-mode
  "Toggle alchemist mode.

Key bindings:
\\{alchemist-mode-map}"
  nil
  ;; The indicator for the mode line.
  " alchemist"
  :group 'alchemist
  :global nil
  :keymap alchemist-mode-map
  (cond (alchemist-mode
         (alchemist-buffer-initialize-modeline))
        (t
         (alchemist-buffer-reset-modeline))))

(add-hook 'elixir-mode-hook 'alchemist-mode-hook)

(provide 'alchemist)

;;; alchemist.el ends here
