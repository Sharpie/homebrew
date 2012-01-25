Brew-Link
=========

What?
-----
Brew-Link is a distillation of the `brew link` and `brew unlink` commands from
the [Homebrew package manager][homebrew] for OS X. These commands have been
separated and re-packaged so that they will work on Linux.

Why?
----
I frequently have to install software on Linux boxes where I have no admin
privileges. This means building from source because the standard package
managers are completely unhelpful. The best tool I have found to help with
managing the installation of self-built software is [GNU Stow][stow]. However,
Stow is dumber than a bag of hammers when it comes to conflict resolution.

`brew link` and `brew unlink` do the same job with much more intelligence.

[homebrew]: http://mxcl.github.com/homebrew
[stow]: http://www.gnu.org/software/stow
