;;; alchemist-compile.el --- Elixir compilation functionality

;; Copyright © 2014-2015 Samuel Tonini

;; Author: Samuel Tonini <tonini.samuel@gmail.com

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

;; Elixir compilation functionality.

;;; Code:

(defgroup alchemist-compile nil
  "Elixir compilation functionality."
  :prefix "alchemist-compile-"
  :group 'alchemist)

;; Variables

(defcustom alchemist-compile-command "elixirc"
  "The shell command for elixirc."
  :type 'string
  :group 'alchemist-compile)

(defvar alchemist-compile-buffer-name "*elixirc*"
  "Name of the elixir output buffer.")

;; Private functions

(defun alchemist-compile--file (filename)
  (cond ((not (file-exists-p filename)) (error "The given file doesn't exist"))
        ((string-match "\.exs$" filename) (error "The given file is an Elixir Script"))
        (t (alchemist-compile (list alchemist-compile-command (expand-file-name filename))))))

(defun alchemist-compile--read-command (command)
  (read-shell-command "elixirc command: " (concat command " ")))

;; Public functions

(defun alchemist-compile-this-buffer ()
  "Compile the current buffer with elixirc."
  (interactive)
  (alchemist-compile--file buffer-file-name))

(defun alchemist-compile-file (filename)
  "Compile the given FILENAME."
  (interactive "Felixirc: ")
  (alchemist-compile--file (expand-file-name filename)))

(defun alchemist-compile (cmdlist)
  "Compile CMDLIST with elixirc."
  (interactive (list (alchemist-compile--read-command alchemist-compile-command)))
  (alchemist-buffer-run (alchemist-utils--build-runner-cmdlist cmdlist)
                        alchemist-compile-buffer-name))

(provide 'alchemist-compile)

;;; alchemist-compile.el ends here
