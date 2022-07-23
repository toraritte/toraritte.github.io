## done links
https://stackoverflow.com/questions/73074340/what-does-dot-slash-dot-mean-in-a-nix-expression/
https://discourse.nixos.org/t/how-to-build-the-nix-manual-not-the-nix-man-pages/20508

## Ideas

+ create an "annotated" branch in repos? The README would reflect the hash to which latest commit in the master it is still updated to

## formulate general documentation ideas

+ include all learned from Modern C (plus annotations)
  (maybe add to nix-book repo? a good destination candidate would be https://github.com/NixOS/nix-book/issues/18)

## to understand

+ move nixos configuration to flakes

+ upgrade nix version on nixos (with and without flakes)

+ https://discourse.nixos.org/t/how-to-build-the-nix-manual-not-the-nix-man-pages/20508
  => decipher the command `nix build nix/2.10.2\#nix^doc`

## documentation gaps

+ https://nixos.wiki/wiki/Documentation_Gaps

+ nixos/nix

  src/libstore/derivations.hh
  287:   FIXME: what is the Hash in this map?
  ->
    https://github.com/NixOS/nix/issues/5463
    https://github.com/NixOS/nix/pull/5556 (closed)

  src/libexpr/primops/fetchTree.cc
  185:// FIXME: document
  ->
    no issues yet

+ is it documented that `+` also works with attr sets and the output can be string?
  see `nixos/nixos-homepage`'s `shell.nix` where the `src = builtins.fetchGit ./.` is the input argument to `flake-compat` (in the end, it will be called as `src + "flake.lock"`)

  ```text
  nix-repl> builtins.fetchGit ./.
  { lastModified = 1658545606; lastModifiedDate = "20220723030646"; narHash = "sha256-8+QY2L9gvgnvzeI0cXBWTfawRCZYhkGBYX+WxbxRrqg="; outPath = "/nix/store/zwp1brk7ndhls3br4hk4h9xhpii17zs5-source"; rev = "0000000000000000000000000000000000000000"; revCount = 0; shortRev = "0000000"; submodules = false; }

  nix-repl> ./.     
  /home/toraritte/clones/nixos-homepage

  nix-repl> src = builtins.fetchGit ./.

  nix-repl> src + "/flake.lock"
  "/nix/store/zwp1brk7ndhls3br4hk4h9xhpii17zs5-source/flake.lock"
  ```

### WHAT ARE NIX FETCHERS?
  what does "fetch" mean in the context of Nix lang builtins? Does it literally copies upon invocation or just signals intention? E.g., `builtins.fetchGit` return an attr set with an `outPath` attribute - does it mean that whatever we tried to fetch is already in the store?
  => It does get copied into the store, just check `outPath` with `ls`

#### builtin vs Nixpkgs fetchers
Also there are **builtin** fetchers and one's defined in Nixpkgs, all discussed in isolation without any comparison. The (`fetchgit` vs `builtins.fetchGit`)[https://discourse.nixos.org/t/difference-between-fetchgit-and-fetchgit/3619] is very informative.

### `flakeRef#..` (e.g., `nix build nix/2.10.2\#nix^doc`)

https://discourse.nixos.org/t/how-to-build-the-nix-manual-not-the-nix-man-pages/20508
=> NobbZ recommended [the Nix manual's "7.5.1." section (Installables)](https://nixos.org/manual/nix/stable/command-ref/new-cli/nix.html?highlight=installable#installables) to start decipher the `...#..^..` string, but it is very incomplete. The part before `#` is referred to as `flakeRef` and it can be a "git URL", but not sure where the full docs are for referring to branches and not just tags, or how to switch to the cloned repos remote e.g., `nixos/nix` will seek that repo, but what if I forked it so I would like use a `flakeRef` to `toraritte/nix`?.. Right now `.#nix^doc` works to show local changes (I think; can't confirm it yet.)

## glossary (for globally used terminology)

This is of utmost necessity! Guides, blog posts, man pages, manual sections etc. teem with ambiguities. Any new material should be started with a clean slate.

## Unify Nix/Nixpkgs/NixOS manuals/projects

+ https://github.com/NixOS/nix-book/issues/12

+ a good summary of the [Nix ecosystem on the NixOS wiki](https://nixos.wiki/wiki/Nix_Ecosystem)

## Notes on consolidating Nix\* contribution guides

> See [this](https://discourse.nixos.org/t/ideas-to-make-it-easier-to-contribute-to-the-documentation/20312) Discourse thread first.

### [nixos.org: How to contribute](https://nixos.org/guides/contributing.html)

+ Dissolve "_Report an issue_" section, and move parts to respective Nix\* section

+ Re-design the 3 Nix\* sections similar to how the manuals are represented on the [nixos.org: Learn](https://nixos.org/learn.html) page (i.e., 3 columns that would fold under each other with respect to screen size)

+ Add steps on how to contribute to the nixos.org website (see section in [`NixOS/nixos-homepage`](https://github.com/NixOS/nixos-homepage) repo's README)

  + Use this as a template for the others (as they generally lack detailed instructions)

  + explain how the NixOS homepage is constructed... E.g., I presumed that the "How to Contribute" section (`contributing.html`) is located somewhere in the `NixOS/nixos-homepage` repo, but it is actually in `NixOS/nix.dev` - it is pulled in when built with `nix-shell` using the input repos specified in `flake.nix`. `shell.nix` is quite short, but it is far from easy for me to understand.

### Nix manual

+ `nix build` & co. - where does it build? (`out` dir?)
   => to a `result` symlink, see there

+ Nix source - which standard is used? what coding conventions?

+ How to build the Nix manual?
  => https://discourse.nixos.org/t/how-to-build-the-nix-manual-not-the-nix-man-pages/20508
