{ pkgs ? import <nixpkgs> { } }: with pkgs; mkShell { buildInputs = [ cask emacs27-nox ]; }
