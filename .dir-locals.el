;;; Directory Local Variables            -*- no-byte-compile: t -*-
;;; For more information see (info "(emacs) Directory Variables")

((nix-mode . ((eval . (when (bound-and-true-p my-nix-format-on-save-mode)
			(my-nix-format-on-save-mode -1))))))
