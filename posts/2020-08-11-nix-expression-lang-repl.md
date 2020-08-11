# Playing with the Nix expression language on the `nix repl`

```text
$ nix repl
Welcome to Nix version 2.3.6. Type :? for help.
```

These errored out as these are not functions:

```text
nix-repl> b = { s ? { a = 27;}, p ? s.a }
error: syntax error, unexpected ';', expecting ':' or '@', at (string):2:1

nix-repl> b = { s ? { a = 27;}, p ? s.a }; b.p
error: syntax error, unexpected ';', expecting ':' or '@', at (string):1:29

nix-repl> let b = { s ? { a = 27;}, p ? s.a } in  b.p
error: syntax error, unexpected IN, expecting ':' or '@', at (string):1:37

nix-repl> let b = { s ? { a = 27;}, p ? s.a }; in  b.p
error: syntax error, unexpected ';', expecting ':' or '@', at (string):1:36

nix-repl> let b = { s ? { a = 27;}, p ? s.a }:  in  b.p
error: syntax error, unexpected IN, at (string):1:39
```

Once I  realized, they  worked, and calling  them as
anonymous functions is similar to other langs:

```
nix-repl> { s ? { a = 27;}, p ? s.a }: p
«lambda @ (string):1:1»

nix-repl> ({ s ? { a = 27;}, p ? s.a }: p)
«lambda @ (string):1:2»
```

These are all equivalent, and currying works:


```
nix-repl> (square: (x: y: square y + square x) 2 7) (x: x*x)
53

nix-repl> (square: (x: y: square y + square x)) (x: x*x)
«lambda @ (string):1:11»

nix-repl> (square: (x: y: square y + square x)) (x: x*x) 2
«lambda @ (string):1:14»

nix-repl> (square: (x: y: square y + square x)) (x: x*x) 2 7
53

nix-repl> (square: x: y: square y + square x) (x: x*x) 2 7
53

```

Another round with default values:


```
nix-repl> ({ s ? { a = 27;}, p ? s.a }: p) ()
error: syntax error, unexpected ')', at (string):1:35

nix-repl> ({ s ? { a = 27;}, p ? s.a }: p)
«lambda @ (string):1:2»

nix-repl> ({ s ? { a = 27;}, p ? s.a }: p) ({})
27

nix-repl> ({ s ? { a = 27;}, p ? s.a }: p) ({2})
error: syntax error, unexpected INT, at (string):1:36

nix-repl> ({ s ? { a = 27;}, p ? s.a }: p) ({{c = 7}})
error: syntax error, unexpected '{', at (string):1:36

nix-repl> ({ s ? { a = 27;}, p ? s.a }: p) ({{c = 7;}})
error: syntax error, unexpected '{', at (string):1:36

nix-repl> ({ s ? { a = 27;}, p ? s.a }: p) ({a = 7;})
error: anonymous function at (string):1:2 called with unexpected argument 'a', at (string)
:1:1

nix-repl>

nix-repl>

nix-repl> ({ s ? { a = 27;}, p ? s.a }: p) ({2})
error: syntax error, unexpected INT, at (string):1:36

nix-repl> ({ s ? { a = 27;}, p ? s.a }: p) (2)
error: value is an integer while a set was expected, at (string):1:1

nix-repl> ({ s ? { a = 27;}, p ? s.a }: p) ({a = 7;})
error: anonymous function at (string):1:2 called with unexpected argument 'a', at (string)
:1:1

nix-repl> ({ s ? { a = 27;}, p ? s.a }: p) ({a = 7; b = 2})
error: syntax error, unexpected '}', expecting ';', at (string):1:48

nix-repl> ({ s ? { a = 27;}, p ? s.a }: p) ({a = 7; b = 2;})
error: anonymous function at (string):1:2 called with unexpected argument 'a', at (string)
:1:1

nix-repl> {a = 7;}
{ a = 7; }

nix-repl> ({ s ? { a = 27;}, p ? s.a }: p) ({{a = 7};})
error: syntax error, unexpected '{', at (string):1:36

nix-repl> ({ s ? { a = 27;}, p ? s.a }: p) ({{a = 7;}})
error: syntax error, unexpected '{', at (string):1:36

nix-repl> ({ s ? { a = 27;}, p ? s.a }: p) ({{a = 7;};})
error: syntax error, unexpected '{', at (string):1:36

nix-repl> {{a = 7;};}
error: syntax error, unexpected '{', at (string):1:2

nix-repl> ({ s ? { a = 27;}, p ? s.a }: p) ({b = {a = 7;};})
error: anonymous function at (string):1:2 called with unexpected argument 'b', at (string)
:1:1

nix-repl> { b = {a = 7;};}
{ b = { ... }; }

nix-repl> import <nixpkgs>
«lambda @ /nix/var/nix/profiles/per-user/root/channels/nixos/pkgs/top-level/impure.nix:15:
1»

nix-repl> { import <nixpkgs> }
error: syntax error, unexpected SPATH, expecting '.' or '=', at (string):1:10

nix-repl> { a = import <nixpkgs> }
error: syntax error, unexpected '}', expecting ';', at (string):1:24

nix-repl> { a = import <nixpkgs>; }
{ a = «lambda @ /nix/var/nix/profiles/per-user/root/channels/nixos/pkgs/top-level/impure.n
ix:15:1»; }

nix-repl> ({ s ? { a = 27;}, p ? s.a }: p) ({{a = 7;};})
error: syntax error, unexpected '{', at (string):1:36

nix-repl> ({ s ? { a = 27;}, p ? s.a }: p) ({})
27

nix-repl> ({ s ? { a = 27;}, p ? s.a }: p) {}
27

nix-repl> ({ s ? { a = 27;}, p ? s.a }: p) { a = 7;}
error: anonymous function at (string):1:2 called with unexpected argument 'a', at (string)
:1:1

nix-repl> ({ s ? { a = 27;}, p ? s.a }: p) { s = 7;}
error: value is an integer while a set was expected, at (string):1:24

nix-repl> ({ s ? { a = 27;}, p ? s.a }: p) { s = {a = 7};}
error: syntax error, unexpected '}', expecting ';', at (string):1:46

nix-repl> ({ s ? { a = 27;}, p ? s.a }: p) { s = {a = 7;};}
7

nix-repl> ({ s ? { a = 27;}, p ? s.a }: p) {}
27

nix-repl> ({ s ? { a = 27;}, p ? s.a }: p) { s = {c = 7;};}
error: attribute 'a' missing, at (string):1:24

 toraritte@mandarine  [~/Downloads/niv-experiments]
0 [20:32:30] ll
total 12
drwxr-xr-x 3 toraritte users 4096 Aug  6 19:22 ./
drwx------ 4 toraritte users 4096 Aug  6 19:22 ../
drwxr-xr-x 2 toraritte users 4096 Aug  6 19:22 nix/
 toraritte@mandarine  [~/Downloads/niv-experiments]
0 [20:32:36] nix repl
Welcome to Nix version 2.3.6. Type :? for help.



nix-repl> ./nix
./nix
nix-repl> ./nix/sources.
./nix/sources.json  ./nix/sources.nix
nix-repl> ./nix/sources.nix
/home/toraritte/Downloads/niv-experiments/nix/sources.nix

nix-repl> builtins.typeOf ./nix/sources.nix
"path"

nix-repl> import ./nix/sources.nix
{ __functor = «lambda @ /home/toraritte/Downloads/niv-experiments/nix/sources.nix:134:42»;
 niv = { ... }; nixpkgs = { ... }; }

nix-repl> a = 7;
error: syntax error, unexpected ';', expecting $end, at (string):1:3

nix-repl> a = 7

nix-repl> a
7

nix-repl>  a = import ./nix/sources.nix

nix-repl> a.
a.__functor  a.niv        a.nixpkgs
nix-repl> a.ni
a.niv      a.nixpkgs
nix-repl> a.ni
a.niv      a.nixpkgs
nix-repl> a.nixpkgs
{ branch = "nixos-19.09"; description = "A read-only mirror of NixOS/nixpkgs tracking the
released channels. Send issues and PRs to"; homepage = "https://github.com/NixOS/nixpkgs";
[4.7 MiB DL] downloading 'https://github.com/NixOS/nixpkgs-channels/archive/289466dd6a11c
error: download of 'https://github.com/NixOS/nixpkgs-channels/archive/289466dd6a11c65a7de4
a954d6ebf66c1ad07652.tar.gz' was interrupted
[4.7 MiB DL] downloading 'https://github.com/NixOS/nixpkgs-channels/archive/289466dd6a11c
[4.7 MiB DL]

nix-repl> builtins.typeOf "~/clones/nixpkgs/nixos/maintainers/scripts/azure-new/shell.nix"

error: interrupted by the user
[4.7 MiB DL]
nix-repl> builtins.typeOf "~/clones/nixpkgs/nixos/maintainers/scripts/azure-new/shell.nix"

"string"

nix-repl> builtins.typeOf ~/clones/nixpkgs/nixos/maintainers/scripts/azure-new/shell.nix
"path"

nix-repl> sh = import ~/clones/nixpkgs/nixos/maintainers/scripts/azure-new/shell.nix

nix-repl> sh
sh
nix-repl> sh
«lambda @ /home/toraritte/clones/nixpkgs/nixos/maintainers/scripts/azure-new/shell.nix:3:4
»

nix-repl> sh {}
error: cannot enqueue download request because the download thread is shutting down
[4.7 MiB DL]
[4.7 MiB DL]

[4.7 MiB DL]
 toraritte@mandarine  [~/Downloads/niv-experiments]
0 [20:37:06] nix repl
Welcome to Nix version 2.3.6. Type :? for help.

nix-repl> sh = import ~/clones/nixpkgs/nixos/maintainers/scripts/azure-new/shell.nix

nix-repl> sh {}

«derivation /nix/store/zbdxqggazjq7z2vc6jxhrrhjz0hq3zzl-nix-shell.drv»

nix-repl>

nix-repl> d = sh {}

nix-repl> d
d                 derivationStrict
derivation        dirOf
nix-repl> d
d                 derivationStrict
derivation        dirOf
nix-repl> d.
d.AZURE_CONFIG_DIR             d.nativeBuildInputs
d.__ignoreNulls                d.nobuildPhase
d.all                          d.out
d.args                         d.outPath
d.buildInputs                  d.outputName
d.builder                      d.outputUnspecified
d.configureFlags               d.outputs
d.depsBuildBuild               d.overrideAttrs
d.depsBuildBuildPropagated     d.passthru
d.depsBuildTarget              d.patches
d.depsBuildTargetPropagated    d.phases
d.depsHostHost                 d.propagatedBuildInputs
d.depsHostHostPropagated       d.propagatedNativeBuildInputs
d.depsTargetTarget             d.shellHook
d.depsTargetTargetPropagated   d.stdenv
d.doCheck                      d.strictDeps
d.doInstallCheck               d.system
d.drvAttrs                     d.type
d.drvPath                      d.userHook
d.meta
d.name
nix-repl> d.all
[ «derivation /nix/store/zbdxqggazjq7z2vc6jxhrrhjz0hq3zzl-nix-shell.drv» ]

nix-repl> d.
d.AZURE_CONFIG_DIR             d.nativeBuildInputs
d.__ignoreNulls                d.nobuildPhase
d.all                          d.out
d.args                         d.outPath
d.buildInputs                  d.outputName
d.builder                      d.outputUnspecified
d.configureFlags               d.outputs
d.depsBuildBuild               d.overrideAttrs
d.depsBuildBuildPropagated     d.passthru
d.depsBuildTarget              d.patches
d.depsBuildTargetPropagated    d.phases
d.depsHostHost                 d.propagatedBuildInputs
d.depsHostHostPropagated       d.propagatedNativeBuildInputs
d.depsTargetTarget             d.shellHook
d.depsTargetTargetPropagated   d.stdenv
d.doCheck                      d.strictDeps
d.doInstallCheck               d.system
d.drvAttrs                     d.type
d.drvPath                      d.userHook
d.meta
d.name
nix-repl> d.
d.AZURE_CONFIG_DIR             d.nativeBuildInputs
d.__ignoreNulls                d.nobuildPhase
d.all                          d.out
d.args                         d.outPath
d.buildInputs                  d.outputName
d.builder                      d.outputUnspecified
d.configureFlags               d.outputs
d.depsBuildBuild               d.overrideAttrs
d.depsBuildBuildPropagated     d.passthru
d.depsBuildTarget              d.patches
d.depsBuildTargetPropagated    d.phases
d.depsHostHost                 d.propagatedBuildInputs
d.depsHostHostPropagated       d.propagatedNativeBuildInputs
d.depsTargetTarget             d.shellHook
d.depsTargetTargetPropagated   d.stdenv
d.doCheck                      d.strictDeps
d.doInstallCheck               d.system
d.drvAttrs                     d.type
d.drvPath                      d.userHook
d.meta
d.name
nix-repl> d.name
"nix-shell"

nix-repl> d.out
«derivation /nix/store/zbdxqggazjq7z2vc6jxhrrhjz0hq3zzl-nix-shell.drv»

nix-repl> d.meta
{ available = true; name = "nix-shell"; outputsToInstall = [ ... ]; position = "/nix/store
/372qxm8fhc4s1fbnjmraxhg4ynb8npx7-source/pkgs/build-support/mkshell/default.nix:28"; }

nix-repl> d.shellHook
""

nix-repl> d.system
"x86_64-linux"

nix-repl> d.drv
d.drvAttrs  d.drvPath
nix-repl> d.drvPath
"/nix/store/zbdxqggazjq7z2vc6jxhrrhjz0hq3zzl-nix-shell.drv"

nix-repl> d.build
d.buildInputs  d.builder
nix-repl> d.buildInputs
[ «derivation /nix/store/jh63xd5ni28jdzzcynzlzsl95vnm2bzv-python3.7-azure-cli-2.1.0.drv» «
derivation /nix/store/20vwa6qpx8w3ar66x1fmrjlwy86c7b71-bash-4.4-p23.drv» «derivation /nix/
store/pvb0rllnpya9n9d484fibzq4mi53p754-nss-cacert-3.49.2.drv» «derivation /nix/store/j63hg
qiszz1hi4kivc4f9bgf4biplc2h-azure-storage-azcopy-10.3.2.drv» ]

nix-repl> d.nativeBuildInputs
[ ]

nix-repl> { a = 27; b = 7;}:
error: syntax error, unexpected ':', expecting $end, at (string):1:18

nix-repl> { s ? { a = 27; }, p ? s.a}: {}
«lambda @ (string):1:1»

nix-repl> ({ s ? { a = 27; }, p ? s.a}: p) {}
27

nix-repl> ({ s ? { a = 27; }, p ? s.a}: p) {{}; }
error: syntax error, unexpected '{', at (string):1:35

nix-repl> ({ s ? { a = 27; }, p ? s.a}: p) {{} }
error: syntax error, unexpected '{', at (string):1:35

nix-repl> ({ s ? { a = 27; }, p ? s.a}: p) {{s = { a = 7;};} }
error: syntax error, unexpected '{', at (string):1:35

nix-repl> ({ s ? { a = 27; }, p ? s.a}: p) {{s = { a = 7;};}
error: syntax error, unexpected '{', at (string):1:35

nix-repl> ({ s ? { a = 27; }, p ? s.a}: p) {s = { a = 7;};}
7

nix-repl> ({ s ? { a = 27; }, p ? s.a}: p) {s = {};}
error: attribute 'a' missing, at (string):1:25

nix-repl> ({ s ? { a = 27; }, p ? s.a}: p) {s = { a = 7;};}
7

nix-repl> ({ s ? { a = 27; }, p ? s.a}: p) {p = 9}
error: syntax error, unexpected '}', expecting ';', at (string):1:40

nix-repl> ({ s ? { a = 27; }, p ? s.a}: p) {p = 9;}
9

nix-repl> ({ s ? { a = 27; }, p ? s.a}: p) {s = {};}
error: attribute 'a' missing, at (string):1:25

nix-repl> ({ s ? { a = 27; }, p ? s.a}: p) {s = {}; p = 9;}
9
```
