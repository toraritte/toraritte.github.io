https://stackoverflow.com/questions/73074340/what-does-dot-slash-dot-mean-in-a-nix-expression/
https://discourse.nixos.org/t/how-to-build-the-nix-manual-not-the-nix-man-pages/20508


+ create an "annotated" branch in repos? The README would reflect the hash to which latest commit in the master it is still updated to

---

nixos/nix

  src/libstore/derivations.hh
  287:   FIXME: what is the Hash in this map?
  ->
    https://github.com/NixOS/nix/issues/5463
    https://github.com/NixOS/nix/pull/5556 (closed)

  src/libexpr/primops/fetchTree.cc
  185:// FIXME: document
  ->
    no issues yet

---

# Notes on consolidating Nix\* contribution guides

> See [this](https://discourse.nixos.org/t/ideas-to-make-it-easier-to-contribute-to-the-documentation/20312) Discourse thread first.

## [nixos.org: How to contribute](https://nixos.org/guides/contributing.html)

+ Dissolve "_Report an issue_" section, and move parts to respective Nix\* section

+ Re-design the 3 Nix\* sections similar to how the manuals are represented on the [nixos.org: Learn](https://nixos.org/learn.html) page (i.e., 3 columns that would fold under each other with respect to screen size)

+ Add steps on how to contribute to the nixos.org website (see section in [`NixOS/nixos-homepage`](https://github.com/NixOS/nixos-homepage) repo's README)

  + Use this as a template for the others (as they generally lack detailed instructions)

  + explain how the NixOS homepage is constructed... E.g., I presumed that the "How to Contribute" section (`contributing.html`) is located somewhere in the `NixOS/nixos-homepage` repo, but it is actually in `NixOS/nix.dev` - it is pulled in when built with `nix-shell` using the input repos specified in `flake.nix`. `shell.nix` is quite short, but it is far from easy for me to understand.

### Nix manual

+ `nix build` & co. - where does it build? (`out` dir?)
   => to a `result` symlink, see there

+ Nix source - which standard is used? what coding conventions?

+ How to build the Nix manual? `nix build` takes care of the manpages, but they don't contain info on the Nix lang itself (at least I couldn't find it) and the manual is also missing (didn't see that either)
