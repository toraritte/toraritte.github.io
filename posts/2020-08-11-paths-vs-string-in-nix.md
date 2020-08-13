# Paths vs strings in the Nix expression language

TODO put these together:

```text
nix-repl> "${prefix}/basic"
"/nix/store/lxj3hhrf0s4xjsnb4w8z561gxpyc4brp-examples/basic"

nix-repl> prefix + /basic
/home/toraritte/clones/nixpkgs/nixos/maintainers/scripts/azure-new/examples/basic

nix-repl> prefix + "/basic"
/home/toraritte/clones/nixpkgs/nixos/maintainers/scripts/azure-new/examples/basic
```

https://discourse.nixos.org/t/what-am-i-doing-wrong-here/2517/7
-> https://gist.github.com/layus/e2024dea364ff0dc7112d8cffe388cdf

https://gist.github.com/CMCDragonkai/de84aece83f8521d087416fa21e34df4

https://stackoverflow.com/questions/43850371/when-does-a-nix-path-type-make-it-into-the-nix-store-and-when-not

TODO Also expand on when are strings accepted when they represent paths? There are a lot of nix scripts where it is very confusing
