# Call `nix-shell` with path (e.g., to use the latest `NixOS/nixpkgs` clone)

First of all, pinning this here because I rarely use
`nix-shell` without  a `shell.nix`  file, so  I keep
forgetting the syntax (plus,
[the syntax of Nix's command line tools is wildly inconsistent](https://github.com/NixOS/nix/issues/459)
), and spend extra time finding this tweet:

> I shared  my screen  with a  coworker and  during an
> exploratory session I wanted  to demonstrate two new
> operators in  Node v14  (?. and  ??), so  I casually
> did:
>
> ```text
> nix-shell -I nixpkgs=channel:nixos-unstable -p nodejs-14_x
> ```
>
> Now coworker's reaction is *mindblown*.

([Twitter post from Susan Potter](https://twitter.com/SusanPotter/status/1260544743097892866))

## Rationale

It is faster (as it  uses a local Nix expression; in
this case,  the `NixOS/nixpkgs` clone), and  some of
the new  packages are only present  there (or you're
using a branch other than the channel ones, etc.).

## Specify (Nix expression) path for `nix-env` with `-f`

The output without the path:

```text
$ nix-env -qaP 'erlang*'
# ...
nixos.erlangR20            erlang-20.3.8.9
nixos.erlangR21            erlang-21.3.8.3
nixos.erlang               erlang-22.1.7
# ...
```

```text
$ nix-env -f ~/clones/nixpkgs/ -qaP 'erlang*'
# ...
nixos.erlangR20            erlang-20.3.8.9
nixos.erlangR21            erlang-21.3.8.3
nixos.erlang               erlang-22.1.7
# ...
=== >>> erlangR23            erlang-23.0.2  <<<====
```

## Use `-I nixpgks=[path]` with `nix-shell` for the same effect

`nix-shell` does not have a `-f` switch, and
[`NixOS/nix` issue #459](https://github.com/NixOS/nix/issues/459)
has been raised for just this reason. The
[current workaround](https://github.com/NixOS/nix/issues/459#issuecomment-71530305)
is to use `-I`.

```text
$ nix-shell -p erlangR23
error: undefined variable 'erlangR23' at (string):1:94
(use '--show-trace' to show detailed location information)
```

```text
0 [18:28:26] nix-shell -I nixpkgs=~/clones/nixpkgs -p erlangR23

[nix-shell:~/clones/toraritte.github.io]$
```

## Inconsistencies with `-I`

I  assumed  that  `nix-env`'s  `-f`  and  `-I`  thus
would be  redundant, but the latter  doesn't seem to
use  the given  path (or  uses it  differently) than
`nix-shell`:

```text
$ nix-env -I nixpkgs=~/clones/nixpkgs -qaP 'erlang*'
# ...
nixos.erlang_odbc_javac    erlang-22.1.7-javac-odbc
nixos.erlang_odbc          erlang-22.1.7-odbc

$ nix-env -f ~/clones/nixpkgs/ -qaP 'erlang*'
# ...
erlang_odbc_javac    erlang-22.3-javac-odbc
erlang_odbc          erlang-22.3-odbc
erlangR23            erlang-23.0.2
```

From `man nix-env`:
> --file / -f path
>     Specifies the Nix expression (designated below as the
>     active Nix expression) used by the --install, --upgrade,
>     and --query --available operations to obtain derivations.
>     The default is ~/.nix-defexpr.
>
>     If the argument starts with http:// or https://, it is
>     interpreted as the URL of a tarball that will be downloaded
>     and unpacked to a temporary location. The tarball must
>     include a single top-level directory containing at least a
>     file named default.nix.
>
> (...)
>
> -I path
>     Add a path to the Nix expression search path. This option
>     may be given multiple times. See the NIX_PATH environment
>     variable for information on the semantics of the Nix search
>     path. Paths added through -I take precedence over NIX_PATH.


The definition of `-I` in `man nix-shell` is the same.
