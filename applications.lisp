(in-package :hfj)
(ql:quickload "str")

(defun string-escape (str)
  "Escape a string"
  (format nil "~S" str))

(defun named-terminal-title (name)
  "Title for named terminal"
  (format nil "tmux - ~A" name))

(defun probe-file-env-paths (name)
  "Probe file across paths in $PATH.  Returns first pathname found or nil."
  (loop for path in (str:split ":" (uiop:getenv "PATH") :omit-nulls t)
          thereis (probe-file (merge-pathnames name (make-pathname :directory path)))))

(defcommand xbacklight (args) ((:shell "Arguments: "))
  "Run xbacklight"
  (run-shell-command (format nil "xbacklight ~S" args)))

(defcommand amixer (args) ((:shell "Arguments: "))
  "Run amixer"
  (run-shell-command (format nil "amixer ~A" args)))

(defcommand lock () ()
  "Lock session"
  (run-shell-command "dm-tool lock"))

(defapp run-firefox () () ("Browser")
  "Run Firefox"
  (run-or-raise "firefox-bin" '(:class "Firefox")))

(defapp run-named-terminal (name) ((:string "Name: ")) ("Terminal")
  "Run terminal"
  (let* ((title (named-terminal-title name))
         (args (list
                "st"
                "-t" title ;; Title
                "-f" "Source Code Pro"
                "-e" "/usr/bin/tmux" "new-session" "-AD" "-s" name))
         (cmd (str:join " " (map 'list #'string-escape args))))
    (run-or-raise cmd `(:title ,title))))

(defapp run-chrome () () ("Browser (Chrome)")
  "Run Chrome"
  (run-or-raise "firejail google-chrome-stable" '(:class "Google-chrome")))

(defapp run-thunderbird () () ("Email")
  "Run Thunderbird"
  (let ((path (loop for file in '("thunderbird-bin" "thunderbird")
                      thereis (probe-file-env-paths file))))
    (when path
      (run-or-raise (namestring path) '(:class "Thunderbird")))))

(defapp run-keepassxc () () ("Passwords")
  "Run KeepassXC"
  (run-or-raise "keepassxc" '(:class "keepassxc")))

(defutil toggle-touchpad () () ("Toggle touchpad")
  "Enable/Disable touchpad"
  (run-shell-command "toggle-touchpad"))

(flet ((emacs-name-plist (&optional name)
         (let* ((title (if (and name (stringp name) (< 0 (length name)))
                           (format nil "Emacs! ~A" name)
                           (format nil "Emacs!")))
                (cmd (format nil "/usr/bin/emacs --title ~S --name ~S" title title)))
           (list :title title
                 :cmd cmd))))
  (defapp run-emacs (&optional (name "Main")) ((:string "Name: ")) ("Emacs")
    "Run Emacs"
    (let ((plist (emacs-name-plist name)))
      (run-or-raise (getf plist :cmd) `(:title ,(getf plist :title))))))

(flet ((emacsclient-name-plist (name)
         (let* ((title (format nil "Emacs - ~A" name))
                (name-str (format nil "(name . ~S)" title))
                (title-str (format nil "(title . ~S)" title))
                (form (format nil "(~A ~A)" name-str title-str))
                (args (list "/usr/bin/emacsclient" "-c" "-F" (string-escape form)))
                (cmd (str:join " " args)))
           (list :title title
                 :cmd cmd))))
  (defapp display-named-emacsclient (name) ((:string "Name: ")) ("Emacsclient")
    "Raise emacs frame with given name"
    (let ((plist (emacsclient-name-plist name)))
      (run-or-raise (getf plist :cmd) `(:title ,(getf plist :title))))))

(defapp run-yakyak () () ("IM")
  "Run Yakyak"
  (run-or-raise "yakyak" '(:class "yakyak")))
