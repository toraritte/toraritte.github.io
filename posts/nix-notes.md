# Nix issues to investigate further (maybe even RFC candidates)

## Package naming is not consistent

Why hasn't it been standardized? This section was triggered by [this HN comment](https://news.ycombinator.com/item?id=26751238):

> Also for searching packages I always end up looking on the website. Using the built-in search you have to do some weird incantations that aren't easy to remember and you still don't get the full list of packages that are related.
>
> It also doesn't help that the package names are random. There's no standard format it seems: gcc 9 is "gcc9" while clang 9 is "clang_9". Why not have packages be <namespace>.<package>.<major[.minor[.build]]> or any other standard convention.
>
> Then you could also say you want a certain version of a package instead of having a name for each. Or a minimum version.
>
> Maybe we need a wrapper around nix that exposes a user friendly interface.

See ongoing discussions in the topic:

+ [Nixpkgs issue #93327: There isn't a clear canonical way to refer to a specific package version.](https://github.com/NixOS/nixpkgs/issues/93327)

+ [Nixpkgs issue #11052: Naming of packages](https://github.com/NixOS/nixpkgs/issues/11052)

+ [Nixpkgs issue #11052: Naming of packages](https://github.com/NixOS/nixpkgs/issues/11052)

+ [Discourse: Clarification on Package Names and Versions](https://discourse.nixos.org/t/clarification-on-package-names-and-versions/9819)
