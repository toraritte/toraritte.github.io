# Nix - intensional vs extensional

Eelco:It was a terrible choice of terms. Just replace "intensional" with "content-addressed" and "extensional" with "input-addressed".

## done links
+ https://discourse.nixos.org/t/what-does-warning-git-tree-a-path-is-dirty-mean-exactly/20568

+ https://discourse.nixos.org/t/rev-and-ref-attributes-in-builtins-fetchgit-and-maybe-flakes-too/20588

+ https://stackoverflow.com/questions/73145810/how-do-git-revisions-and-references-relate-to-each-other

lecture: https://www.youtube.com/watch?v=t6goF1dM3ag

## TODOs

### Nix manual re-organization

> **The Nix manual should be more like a reference that the Nixpkgs manual builds upon**

A different approach to `1b23ee60a9fb662792abd031d52317e866b94771` (unify).

+ move "5.1. A Simple Nix Expression" from Nix manual to Nixpkgs manual
  reason: Nixpkgs is a set of conventions around Nix (what? core? language? what would you call Nix lang + CLI tools + Nix store together?) but it is not essential to introduce the concept. This section is more about how to build a package using the Nixpkgs conventions so it should be there instead of burdening the reader.

  + try to remove as much Nixpkgs reference as possible (only leave the necessary ones)

  + => research how to use Nix without Nixpkgs
    + https://nixos.wiki/wiki/Alternative_Package_Sets
    + https://www.reddit.com/r/NixOS/comments/e417gy/using_nix_without_nixpkgs/

+ Rename "5.2.1 Values" (Data types?) and re-organize content so that different types could be linked (e.g., `fetchGit` accepts a file system path; would be nice to link to that part to show how it differs from the shell notation for example)
  + ... and find all references in the Nix manual that refers to data types as "values"...
  + add anchors to the section of each type to be able to share (e.g., link to "path"); this is already done for builtins (e.g., [`fetchGit`](https://nixos.org/manual/nix/stable/expressions/builtins.html#builtins-fetchGit)) and those are generated from the C++ source.

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

### `flakeRef#..` (e.g., `nix build nix/2.10.2\#nix^doc`)

Clean up flakes documentation because right now it is a huge mess. See some historical notes below that redundant to this, but starting over:

+ `flakeRef#attrPath` can be many things but couldn't figure out most of the possibilites based on the docs such as [the Nix manual's "7.5.1." section (Installables)](https://nixos.org/manual/nix/stable/command-ref/new-cli/nix.html?highlight=installable#installables) and the Discourse announcements, such as [Nix 2.9.0 released](https://discourse.nixos.org/t/nix-2-9-0-released/19407):

+ `nix/<git-tag>#nix.doc` => this pre-Nix 2.9 syntax, but couldn't find how to add references to git tags/branches, but apparently it works. Or the period in `nix.doc` - what is the period? For post-Nix 2.9 it looks like `nix^doc` - why the change from period to caret?

+ `path:/path/to/where/exactly#nix.doc` - path to `flake.nix`? I also didn't see mentioning that relative paths work too; e.g., `path:.#nix^doc`

TODO: definitely look at the source (at different tags...) to properly document the evolution and also what else is possible (e.g., `builtins.fetchGit` also takes a file path but it was never documented)

https://discourse.nixos.org/t/how-to-build-the-nix-manual-not-the-nix-man-pages/20508
=> NobbZ recommended [the Nix manual's "7.5.1." section (Installables)](https://nixos.org/manual/nix/stable/command-ref/new-cli/nix.html?highlight=installable#installables) to start decipher the `...#..^..` string, but it is very incomplete. The part before `#` is referred to as `flakeRef` and it can be a "git URL", but not sure where the full docs are for referring to branches and not just tags, or how to switch to the cloned repos remote e.g., `nixos/nix` will seek that repo, but what if I forked it so I would like use a `flakeRef` to `toraritte/nix`?.. Right now `.#nix^doc` works to show local changes (I think; can't confirm it yet.)



## glossary (for globally consistent terminology)

This is of utmost necessity! Guides, blog posts, man pages, manual sections etc. teem with ambiguities. Any new material should be started with a clean slate.

Just the most recent post I found:
+ https://discourse.nixos.org/t/attribute-set-or-set/14253

## Unify Nix/Nixpkgs/NixOS manuals/project (sha1 1b23ee60a9fb662792abd031d52317e866b94771)

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

  + is it possible (and if not, is there a way) to build the Nix manual without compiling Nix from scratch? it takes ~20 mins in this machine...

  + When building the Nix manual, I just found two outputs with the same name (`result-doc`) but different timestamps and at different places (one at `nix/result-doc`, the other at `nix/doc/manual/result-doc` - I presume the location of the result symlinks depend on where `nix build` is called from.

### WHAT ARE NIX FETCHERS?

**TODO**: All the fetcher-stuff should be explained in a single place. This strucks a chord with `1b23ee60a9fb662792abd031d52317e866b94771` (unify). How?
  + **step 1.** blog/discourse post

  what does "fetch" mean in the context of Nix lang builtins? Does it literally copies upon invocation or just signals intention? E.g., `builtins.fetchGit` return an attr set with an `outPath` attribute - does it mean that whatever we tried to fetch is already in the store?
  => It does get copied into the store, just check `outPath` with `ls`

#### builtin vs Nixpkgs fetchers
Also there are **builtin** fetchers and one's defined in Nixpkgs, all discussed in isolation without any comparison. The [ `fetchgit` vs `builtins.fetchGit` ](https://discourse.nixos.org/t/difference-between-fetchgit-and-fetchgit/3619) is very informative.

See also [Why is fetchTarball not mentioned in “Chapter 11. Fetchers” of the Nixpkgs manual?](https://discourse.nixos.org/t/why-is-fetchtarball-not-mentioned-in-chapter-11-fetchers-of-the-nixpkgs-manual/15319)

Another: https://ryantm.github.io/nixpkgs/builders/fetchers/

#### `fetchGit` (and probably other `git`-related) docs are wrong/misleading
https://discourse.nixos.org/t/rev-and-ref-attributes-in-builtins-fetchgit-and-maybe-flakes-too/20588

this sentiment may apply to https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-flake.html too

+ fetchGit path behaviour differs whether repo is "dirty" or not!

```text
0 [18:11:01] nix repl
Welcome to Nix 2.10.3. Type :? for help.

# COMMENT: fetches the **modified** repo (does not have to be staged or committed!; checked out branch irrelevant)
# (current branch in `shell.nixes` is `main`)
                   fetchGit path
nix-repl> builtins.fetchGit {url=./.;}   
warning: Git tree '/home/toraritte/clones/nix' is dirty
{ lastModified = 1658169134; lastModifiedDate = "20220718183214"; narHash = "sha256-D0KvHm9rKOHb
DciCshul7e3b2PoYRqWZRdbkyn/9Iao="; outPath = "/nix/store/pjkcjgj04nvxg8q87zbwm9axpc93c3yr-source
"; rev = "0000000000000000000000000000000000000000"; revCount = 0; shortRev = "0000000"; submodu
les = false; }

nix-repl> builtins.fetchGit {url=./.;}
warning: Git tree '/home/toraritte/clones/nix' is dirty
{ lastModified = 1658169134; lastModifiedDate = "20220718183214"; narHash = "sha256-Vw4lSkslmDIR
cHQEO7uSiEV53vYJszVWXeHmFE4/Pww="; outPath = "/nix/store/74b2zy6vrh463mrbr4p7mwrvjg75967b-source
"; rev = "0000000000000000000000000000000000000000"; revCount = 0; shortRev = "0000000"; submodu
les = false; }

nix-repl> builtins.fetchGit {url="~/clones/nix";}
error: file:// URL 'file://~/clones/nix' has unexpected authority '~'

nix-repl> builtins.fetchGit "/home/toraritte/clones/nix"
nix-repl> builtins.fetchGit "file:///home/toraritte/clones/nix"
nix-repl> builtins.fetchGit {url="/home/toraritte/clones/nix";}
nix-repl> builtins.fetchGit {url="file:///home/toraritte/clones/nix";}
warning: Git tree '/home/toraritte/clones/nix' is dirty
{ lastModified = 1658169134; lastModifiedDate = "20220718183214"; narHash = "sha256-Vw4lSkslmDIR
cHQEO7uSiEV53vYJszVWXeHmFE4/Pww="; outPath = "/nix/store/74b2zy6vrh463mrbr4p7mwrvjg75967b-source
"; rev = "0000000000000000000000000000000000000000"; revCount = 0; shortRev = "0000000"; submodu
les = false; }

# COMMENT: fetches the HEAD of the checked-out branch of the repo
# (current branch in `shell.nixes` is `main`)
                   fetchGit path
nix-repl> builtins.fetchGit /home/toraritte/clones/shell.nixes
{ lastModified = 1651372838;
 lastModifiedDate = "20220501024038";
 narHash = "sha256-ejxD1ZjnbRBsvi5NJYhLPQ9FGgORFD/kH10boQxqjVI=";
 outPath = "/nix/store/x6zcxzmjc340n5ycmgqylvw1j2pg0jkn-source";
 rev = "f9af46639a9bb5fb22705ebdfd25783866e22c0f";
 revCount = 36;
 shortRev = "f9af466";
 submodules = false;
 }

# COMMENT: fetches the HEAD of the checked-out branch of the repo
# (current branch in `shell.nixes` is `lynx`)
                   fetchGit path
nix-repl> builtins.fetchGit ~/clones/shell.nixes
{ lastModified = 1619560320;
 lastModifiedDate = "20210427215200";
 narHash = "sha256-xEgHQPHIrpeTZ7tyTBQuyOAnXqwao4jdvfXPyaE+qME=";
 outPath = "/nix/store/09066xpin73wxvh1cip5acvd3ajs5x0v-source";
 rev = "db8f5696874640d7e905dfb77c7b91da75325a22";
 revCount = 23;
 shortRev = "db8f569";
 submodules = false;
 }

# COMMENT: fetches the HEAD of the checked-out branch of the repo
# (current branch in `shell.nixes` is `lynx`)
                   fetchGit {url = <path>;}
nix-repl> builtins.fetchGit {url="/home/toraritte/clones/shell.nixes";}
{ lastModified = 1619560320;
 lastModifiedDate = "20210427215200";
 narHash = "sha256-xEgHQPHIrpeTZ7tyTBQuyOAnXqwao4jdvfXPyaE+qME=";
 outPath = "/nix/store/09066xpin73wxvh1cip5acvd3ajs5x0v-source";
 rev = "db8f5696874640d7e905dfb77c7b91da75325a22";
 revCount = 23;
 shortRev = "db8f569";
 submodules = false;
 }

# COMMENT: fetches the HEAD of the specified branch
# (current branch in `shell.nixes` is `lynx`)
                   fetchGit {url = <path>; ref=<branch>;}
nix-repl> builtins.fetchGit {url="/home/toraritte/clones/shell.nixes"; ref="main"; }
{ lastModified = 1619560320;
 lastModifiedDate = "20210427215200";
 narHash = "sha256-xEgHQPHIrpeTZ7tyTBQuyOAnXqwao4jdvfXPyaE+qME=";
 outPath = "/nix/store/09066xpin73wxvh1cip5acvd3ajs5x0v-source";
 rev = "f9af46639a9bb5fb22705ebdfd25783866e22c0f";
 revCount = 23;
 shortRev = "db8f569";
 submodules = false;
 }

# COMMENT: supposed to fetch commit under a specific branch (which statement doesn't make sense: a commit can be part of multiple branches, but its content is the same) so it just fetches the commit and one can use `ref` as documnetation to self
# (current branch in `shell.nixes` is `lynx`)
                   fetchGit {url = <path>; ref=<branch>; rev;}
nix-repl> builtins.fetchGit {url="/home/toraritte/clones/shell.nixes"; ref="lynx"; rev="477c852";}
error: hash '477c852' has wrong length for hash type 'sha1'

# COMMENT: supposed to fetch commit under a specific branch (which statement doesn't make sense: a commit can be part of multiple branches, but its content is the same) so it just fetches the commit and one can use `ref` as documnetation to self
+ COMMENT: added twist: the commit in `rev` is not part of the "lynx" branch at all, so `ref` in this case can even be misleading
# (current branch in `shell.nixes` is `lynx`)
                   fetchGit {url = <path>; ref=<branch>; rev;}
nix-repl> builtins.fetchGit {url="/home/toraritte/clones/shell.nixes"; ref="lynx"; rev="477c852d
dd3875913063aed86ca38130b1a7f02f";}
{ lastModified = 1633137713;
 lastModifiedDate = "20211002012153";
 narHash = "sha256-T6xyyIKDKWsQ/L28DTIG3Hwmd1CMXf6znt9ciLfwL8c=";
 outPath = "/nix/store/r7ynyabyvlsxy6z3jisip26m40lb9m38-source";
 rev = "477c852ddd3875913063aed86ca38130b1a7f02f";
 revCount = 32;
 shortRev = "477c852";
 submodules = false;
 }

# COMMENT: fetches the HEAD of the default branch of the repo
                   fetchGit URL
nix-repl> builtins.fetchGit "https://github.com/toraritte/shell.nixes/"         
{ lastModified = 1651372838;
 lastModifiedDate = "20220501024038";
 narHash = "sha256-ejxD1ZjnbRBsvi5NJYhLPQ9FGgORFD/kH10boQxqjVI=";
 outPath = "/nix/store/x6zcxzmjc340n5ycmgqylvw1j2pg0jkn-source";
 rev = "f9af46639a9bb5fb22705ebdfd25783866e22c0f";
 revCount = 36;
 shortRev = "f9af466";
 submodules = false;
 }

                   fetchGit { url; name; }
nix-repl> builtins.fetchGit {url = "https://github.com/toraritte/shell.nixes/"; name = "balabab"
{ lastModified = 1651372838;
 lastModifiedDate = "20220501024038";
 narHash = "sha256-ejxD1ZjnbRBsvi5NJYhLPQ9FGgORFD/kH10boQxqjVI=";
 outPath = "/nix/store/2m5v1pv74h3y75ma430vcl05c52qk8sl-balabab";
 rev = "f9af46639a9bb5fb22705ebdfd25783866e22c0f";
 revCount = 36;
 shortRev = "f9af466";
 submodules = false;
 }

                   fetchGit { url; ref=<branch>; }
nix-repl> builtins.fetchGit {url = "https://github.com/toraritte/shell.nixes/"; ref="lynx";}
{ lastModified = 1619560320;
 lastModifiedDate = "20210427215200";
 narHash = "sha256-xEgHQPHIrpeTZ7tyTBQuyOAnXqwao4jdvfXPyaE+qME=";
 outPath = "/nix/store/09066xpin73wxvh1cip5acvd3ajs5x0v-source";
 rev = "db8f5696874640d7e905dfb77c7b91da75325a22";
 revCount = 23;
 shortRev = "db8f569";
 submodules = false;
 }

                   fetchGit { url; ref=<branch>; rev; }
nix-repl> builtins.fetchGit {url = "https://github.com/toraritte/shell.nixes/"; ref="lynx"; rev = "93eec99"; }
error: hash '93eec99' has wrong length for hash type 'sha1'

                   fetchGit { url; ref=<branch>; rev; }
nix-repl> builtins.fetchGit {url = "https://github.com/toraritte/shell.nixes/"; ref="lynx"; rev = "93eec99cfd7fe195a87294f844799f09ca7479b4"; }
{ lastModified = 1567342803;
 lastModifiedDate = "20190901130003";
 narHash = "sha256-xVYRmth/pS4UTMVr7+5YYL5eNn70UhvHQgvwMcotsms=";
 outPath = "/nix/store/9spbll1al33y6a46s7fssgrv97a6dvis-source";
 rev = "93eec99cfd7fe195a87294f844799f09ca7479b4";
 revCount = 1;
 shortRev = "93eec99";
 submodules = false;
 }

                   fetchGit { url; rev; }
nix-repl> builtins.fetchGit {url = "https://github.com/toraritte/shell.nixes/"; rev = "93eec99cfd7fe195a87294f844799f09ca7479b4"; }
{ lastModified = 1567342803;
 lastModifiedDate = "20190901130003";
 narHash = "sha256-xVYRmth/pS4UTMVr7+5YYL5eNn70UhvHQgvwMcotsms=";
 outPath = "/nix/store/9spbll1al33y6a46s7fssgrv97a6dvis-source";
 rev = "93eec99cfd7fe195a87294f844799f09ca7479b4";
 revCount = 1;
 shortRev = "93eec99";
 submodules = false;
 }

                   fetchGit { url; ref=<branch>; }
nix-repl> builtins.fetchGit {url = "https://github.com/toraritte/shell.nixes/"; ref="main";}    
{ lastModified = 1651372838;
 lastModifiedDate = "20220501024038";
 narHash = "sha256-ejxD1ZjnbRBsvi5NJYhLPQ9FGgORFD/kH10boQxqjVI=";
 outPath = "/nix/store/x6zcxzmjc340n5ycmgqylvw1j2pg0jkn-source";
 rev = "f9af46639a9bb5fb22705ebdfd25783866e22c0f";
 revCount = 36;
 shortRev = "f9af466";
 submodules = false;
 }

                   fetchGit { url; ref=<tag>; }
nix-repl> builtins.fetchGit {url = "https://github.com/nixos/nix/"; ref="refs/tags/2.5.0";} 
{ lastModified = 1639426486;
 lastModifiedDate = "20211213201446";
 narHash = "sha256-mht9vFZjtd5/6fntbj39zCts6MTr4Y+ct+fcsBgb1YM=";
 outPath = "/nix/store/h59v90iv2wm4q910zr5rzjg0in90az4r-source";
 rev = "678fd180c2ed2946b7dc3b72717a2fef9d793517";
 revCount = 11186;
 shortRev = "678fd18";
 submodules = false;
 }

                   fetchGit { url; ref=<tag>; }
nix-repl> builtins.fetchGit {url = "https://github.com/toraritte/nix/"; ref="2.5.0";} 
fetching Git repository 'https://github.com/toraritte/nix/'fatal: couldn't find remote ref refs/heads/2.5.0
error: program 'git' failed with exit code 128

                   fetchGit { url; ref=<tag>; }
nix-repl> builtins.fetchGit {url = "https://github.com/toraritte/nix/"; ref="tags/2.5.0";}
fetching Git repository 'https://github.com/toraritte/nix/'fatal: couldn't find remote ref refs/heads/tags/2.5.0
error: program 'git' failed with exit code 128

                   fetchGit { url; ref=<branch>; }
nix-repl> builtins.fetchGit {url = "https://github.com/toraritte/shell.nixes/"; ref="main";}
{ lastModified = 1651372838;
 lastModifiedDate = "20220501024038";
 narHash = "sha256-ejxD1ZjnbRBsvi5NJYhLPQ9FGgORFD/kH10boQxqjVI=";
 outPath = "/nix/store/x6zcxzmjc340n5ycmgqylvw1j2pg0jkn-source";
 rev = "f9af46639a9bb5fb22705ebdfd25783866e22c0f";
 revCount = 36;
 shortRev = "f9af466";
 submodules = false;
 }

                   fetchGit { url; ref=<branch>; rev;}
nix-repl> builtins.fetchGit {url = "https://github.com/toraritte/shell.nixes/"; ref="main"; rev="HEAD~2";}
error: hash 'HEAD~2' has wrong length for hash type 'sha1'

                   fetchGit { url; ref=<branch>; rev;}
nix-repl> builtins.fetchGit {url = "https://github.com/toraritte/shell.nixes/"; ref="main"; rev="~2";}     
error: hash '~2' has wrong length for hash type 'sha1'

                   fetchGit { url; ref=<branch>; }
nix-repl> builtins.fetchGit { url = "https://github.com/nixos/nix.git"; ref = "1.11-maintenance"; }    
{ lastModified = 1513097282;
 lastModifiedDate = "20171212164802";
 narHash = "sha256-ADdqRhaDnbfz5zG2focW23XzO/drNhF8njiigkD38ew=";
 outPath = "/nix/store/ikvsz4nrkmn6lf4cxy6zw5hjhcfjk2l1-source";
 rev = "33d58a19041b77f9b9d11719c679b4cbff162a57";
 revCount = 4533;
 shortRev = "33d58a1";
 submodules = false;
 }

                   fetchGit { url; ref=<branch>; rev; }
nix-repl> builtins.fetchGit { url = "https://github.com/nixos/nix.git"; ref = "1.11-maintenance"; rev = "841fcbd04755c7a2865c51c1e2d3b045976b7452"; }
{ lastModified = 1047475944;
 lastModifiedDate = "20030312133224";
 narHash = "sha256-pQpattmS9VmO3ZIQUFn66az8GSmB4IvYhTTCFn6SUmo=";
 outPath = "/nix/store/0ccnxa25whszw7mgbgyzdm4nqc0zwnm8-source";
 rev = "841fcbd04755c7a2865c51c1e2d3b045976b7452";
 revCount = 1;
 shortRev = "841fcbd";
 submodules = false;
 }

                   fetchGit { url; rev; }
nix-repl> builtins.fetchGit { url = "https://github.com/nixos/nix.git";  rev = "841fcbd04755c7a2865c51c1e2d3b045976b7452";}
{ lastModified = 1047475944;
 lastModifiedDate = "20030312133224";
 narHash = "sha256-pQpattmS9VmO3ZIQUFn66az8GSmB4IvYhTTCFn6SUmo=";
 outPath = "/nix/store/0ccnxa25whszw7mgbgyzdm4nqc0zwnm8-source";
 rev = "841fcbd04755c7a2865c51c1e2d3b045976b7452";
 revCount = 1;
 shortRev = "841fcbd";
 submodules = false;
 }

nix-repl> 

nix-repl> builtins.fetchGit { url = "https://github.com/nixos/nix.git";  rev = "841fcbd"; }     
error: hash '841fcbd' has wrong length for hash type 'sha1'

nix-repl> 
```
