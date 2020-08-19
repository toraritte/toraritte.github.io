# `with` considered harmful in Nix expressions

Expanding slightly on the [`Nix anti-patterns`](https://nix.dev/anti-patterns/language.html) sub-section, [`with attrset; ...` expression](https://nix.dev/anti-patterns/language.html#with-attrset-expression) at [nix.dev](https://nix.dev). It points to the [NixOS/nix issue #490](https://github.com/NixOS/nix/issues/490) with a more detailed discussion.

## Workarounds

Both the post and the issue lists the detrimental effects using `with` but there is only one suggestion:

```nix
let lib = something.very.long; in { lib.foo /*etc..*/ }

```

### What about using `with` to simplify input lists? (Such as `buildInputs` in `nix-shell` expressions)

That is:

```nix
{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {

  buildInputs = with pkgs; [
    # ...
  ];

  # ...
}

```

[`easy-purescript-nix`](https://github.com/justinwoo/easy-purescript-nix) provides alternatives by using [`builtins.attrValues`](https://nixos.org/nix/manual/#:~:text=builtins.attrValues):

```nix
{ pkgs ? import <nixpkgs> {} }:

let
  default = import ./default.nix {};

  buildInputs = builtins.attrValues {
    inherit (pkgs) gnumake which;

    inherit (default) purs pulp purp psc-package dhall-simple spago pscid spago2nix purty zephyr;
  };

in
pkgs.mkShell {
  buildInputs = buildInputs;
  # or
  # inherit buildInputs;
}
```
