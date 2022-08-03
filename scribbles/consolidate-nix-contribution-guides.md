# Nix - intensional vs extensional

Eelco:It was a terrible choice of terms. Just replace "intensional" with "content-addressed" and "extensional" with "input-addressed".

## TODOs

+ **architecture decision record** (ADR)

### "Nix path" and POSIX (`~` or tilde)

Tried to find a UNIX/Linux specification that defines the syntax of file system paths, which led me from [Path syntax rules (SO thread)](https://unix.stackexchange.com/questions/125522/path-syntax-rules) to [The Open Group Base Specifications Issue 6, IEEE Std 1003.1, 2004 Edition](https://pubs.opengroup.org/onlinepubs/009695399/), specifically to chapter [3. Definitions](https://pubs.opengroup.org/onlinepubs/009695399/) (start with sections "3.2 Absolute Pathname", "3.319 Relative Pathname" and follow the crumbs - especially to [4.11 Pathname Resolution](https://pubs.opengroup.org/onlinepubs/007904875/basedefs/xbd_chap04.html#tag_04_11)).

Bottom line is, `~` or tilde is not part of any specification and [it may be have different meaning attached to it depending on the shell](https://stackoverflow.com/questions/998626/meaning-of-tilde-in-linux-bash-not-home-directory), so it may be prudent to advise against using it.

### Nix manual re-organization

See `attemp-manual-reorg` branch in `toraritte/nix`.

> **The Nix manual should be more like a reference that the Nixpkgs manual builds upon**

A different approach to `1b23ee60a9fb662792abd031d52317e866b94771` (standardize/make_uniformunify).

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

+ attribute set
  Just the most recent post I found:
  https://discourse.nixos.org/t/attribute-set-or-set/14253

+ package set (e.g., https://nixos.wiki/wiki/Alternative_Package_Sets)

+ eelco: https://github.com/NixOS/nix/pull/6420#issuecomment-1105299320
+ [output vs build result](https://github.com/NixOS/nix/pull/6420#discussion_r919904245)
+ [store object?](https://github.com/NixOS/nix/pull/6420#discussion_r920010720)

[concept map of Nix stuff](https://github.com/NixOS/nix/pull/6420#issuecomment-1161690195)

## Documentation "layers"

Justification:

+ https://github.com/NixOS/nix/pull/6420#discussion_r918426004
+ https://github.com/NixOS/nix/pull/6420#discussion_r918432510
+ https://github.com/NixOS/nix/pull/6420#discussion_r920007881
+ 

## Remove Nixpkgs references from Nix manual

> https://github.com/NixOS/nix.dev/issues/290#issuecomment-1201862547
> One could argue that Nix "core" and Nixpkgs are separate as well: Nix "core" works with [alternatiive package sets](https://nixos.wiki/wiki/Alternative_Package_Sets), and Nixpkgs also works with alternate implementations of the Nix core functionality (e.g., [hnix](https://github.com/haskell-nix/hnix)).

+ make a separate manual for Nix CLI commands (isn't that's what man pages are for?), or at least don't mix the two: Nix "core" is a reference/gentle-ish intro that don't depend on Nixpkgs (it's a set of conventions built on top of Nix "core") and Nix CLI (... lost my momentum here, because how much do Nix CLI commands depend - if at all - on Nixpkgs? Maybe not at all, because how would alternate package sets be used?)

  + => it may still be prudent to separate the two, because the "lighthearted" intro sections showing of Nix CLI commands are built on Nix core so understanding would be crucial. So what about this:

## standardize/make_uniform Nix/Nixpkgs/NixOS manuals/project (sha1 1b23ee60a9fb662792abd031d52317e866b94771)

+ a good summary of the [Nix ecosystem on the NixOS wiki](https://nixos.wiki/wiki/Nix_Ecosystem)

## Notes on consolidating Nix\* contribution guides

### How to make it easier to contribute

> See [this](https://discourse.nixos.org/t/ideas-to-make-it-easier-to-contribute-to-the-documentation/20312) Discourse thread first.

+ important file: [`nix.dev/CONTRIBUTING.md`](https://github.com/NixOS/nix.dev/pull/265/files#diff-eca12c0a30e25b4b46522ebf89465a03ba72a03f540796c979137931d8f92055)


+ Make prominent that there are [explicit requirements for contributing](https://github.com/NixOS/nix.dev/pull/265/files#diff-eca12c0a30e25b4b46522ebf89465a03ba72a03f540796c979137931d8f92055), and for anything else, contributors may only expect a best effort from the community

  > > fricklerhandwerk
  > > Ah, that makes total sense. Actually I strongly empathize with that stance.
  > > 
  > > We should at least state the relevant skills as prerequisites (e.g. git and GitHub workflow in the prerequisites for a guide to contribute to nixpkgs). A PR to the relevant manual section is highly welcome!
  > 
  > Finding and recommending good material is another can of worms, and much less important. We could try and say the Git project is responsible to onboard new people, and reference the relevant resource that appears to do this job.
  > 
  > Love this about being explicit about requirements needed to be able to "officially" contribute!
  > 
  > It might be prudent to add that we don't discourage other ways, but we should set their expectations straight: non-PR/issue suggestions can only be expected to be resolved on a best effort basis (i.e., someone finds the time and effort "champion" these reports, or they buddy up with a more experienced member, etc.)

  A case in point:

+ From the Matrix wiki channel:
  > > nixos-wiki-rcbot
  > > [[NixOS Wiki talk:Contributing]] https://nixos.wiki/wiki/index.php?diff=7848&oldid=2946 * Toraritte * (+297) Add TODO section for article
  > toraritte
  > : the rust manual link is not valid and the Rust nightly overlay points to Mozilla's nixpkgs fork

  I have no clue which page and link in particular this refers to (because the linked log in the reply has no rust stuff), so **encourage drive-by comments** but define a process (for each documentation entity...) on where to track this progress (issues?)


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

## see stuff above..

`(new) Nix manual(s)
   ┌──────────────────────────────────────────────────────────────────────┐
   │                                                                      │
   │                                                                      │
   │  ┌──────────────────────────┐       ┌─────────────────────────────┐  │
   │  │                          │       │                             │  │
   │  │                          │       │                             │  │
   │  │     Nix core reference   │       │  Nix CLI reference          │  │
   │  │                          │       │     (a.k.a. man pages?)     │  │
   │  │                          │       │                             │  │
   │  │                          │       │                             │  │
   │  └──────────────┬───────────┘       └─────────────────┬───────────┘  │
   │                 │                                     │              │
   └─────────────────┼─────────────────────────────────────┼──────────────┘
                     │                                     │
                     │                                     │
                     │                                     │
                     │   ┌───────────────────────────┐     │
                     │   │                           │     │
                     └───►    quick start guide      ◄─────┤
   ┌─────────────┐       │                           │     │    ┌────────────┐
   │             │       │    (parts of Nix manual   │     │    │            │
   │    NixOS    │       │     already treated so)   ◄─────┼────┤  Nixpkgs   │
   │    manual   │       │                           │     │    │  manual    │
   │             │       └───────────────────────────┘     │    │            │
   └─────────┬───┘                                         │    │            │
             │                                             │    └────┬───────┘
             │                                             │         │
          ┌──▼─────────────────────────────────────────────▼─────────▼───┐
          │                                                              │
          │                                                              │
          │    guides, more in-depth intros, advanced material, etc.     │
          │                                                              │
          │         that do make the connections in-between manuals      │
          │                                                              │
          │                                                              │
          └──────────────────────────────────────────────────────────────┘



          ?
   ┌──────?──────┐
   │      ?      │  Should these manuals be split as well?
   │    Ni?OS    │  ======================================
   │    ma?ual   │  There is certainly a lot of reference-y and
   │      ?      │  guide-y stuff in both, resulting in a confusing
   └──────?──────┘  mix, making it hard to find what is needed
          ?
   ┌──────?──────┐
   │      ?      │  TODO: experiment with
   │  Nixp?gs    │
   │  manu?l     │        1. Nix/Nixpkgs/NixOS reference materials
   │      ?      │
   │      ?      │        2. Use the solid foundations of 1. create
   └──────?──────┘           the guides (as they will inevitably
          ?                  touch on the other parts of the eco-
                             system)


    How to keep reference materials "pure"?
    ---------------------------------------

    Nix manual
    ==========
    Nix "core" doesn't depend either on NixOS or Nixpkgs, and there
    is no reason to be mentioned there. The Nix CLI tools may be an
    exception as they need an example package set to be worked on
    sometimes.

    Only the notion of "package set" is intrinsic to Nix "core" and
    not to a specific implementation of it (with all the inevitable
    idiosyncrasies that come with such an implementation).

    TODO: Experiment with a "toy" package set specifically created
          for Nix CLI references. From there, guides can use Nixpkgs
          in examples to their heart's content.

          (The "toy" package set idea may be a good one because
           there could be a guide linked to show HOW to make one's
           own package set as an added benefit!)


          Of course, this entirely depends on:

    ┌──────────────────────────┐
    │┼────────────────────────┼│
    ││ Nix "core" =/= Nix CLI ││ ... or something along these lines.
    │┼────────────────────────┼│ Needs to be proven; see TODO below.
    └──────────────────────────┘

     TODO: understand

           + how to work with alternative package sets

           + how deeply coupled are Nix CLI tools with Nixpkgs


     Nixpkgs manual
     ==============

     The above section should(...) take care of Nix "core", and even
     though Nixpkgs "houses" NixOS modules, that could be taken care
     of with a link to the NixOS manual.

     Another reason for removing NixOS references is because there
     are other OSs that build on Nix "core" and package sets (maybe
     even Nixpkgs). Examples include Triton, Spectrum-OS

     Discussions that do require the mention of NixOS modules etc.
     should definitely be in NixOS manual.Nix* manuals.

     TODO Find a legitimate reason to ever mention NixOS besides that
          link to the NixOS manual.

     NixOS manual
     ============

     This is a trickier one - or is it? What is Nix's relationship
     with alternative package sets? NixOS is a truly Nix community
     thing, although it wouldn't hurt to explain hnix and alt sets.
     (However, that may be for the guides?..)``


### Distill Nixpkgs questions from the chat during the Jon Ringer Nixpkgs architecture intro

@room
 Hey all, 👋

Just a friendly reminder that the next Lecture by 
jonringer
 about The Architecture and History of Nixpkgs will begin soon!
https://discourse.nixos.org/t/jon-ringer-the-architecture-and-history-of-nixpkgs-son2022-public-lecture-series/20626?u=bjth


Jon Ringer - The Architecture and History of Nixpkgs (SoN2022 - public lecture series) - NixOS Discourse
Hey all, 👋 @armijn Gave his lecture about the history of NIxOS last Tuesday, and I’m happy to announce the next Lecture! The next lecture will be about the architecture and history of Nixpkgs, given by @jonringer. We’ll go live on Tuesday, August 2, 2022 3:00 PM (UTC). As usual, don’t miss it. 😉 The lecture can be followed live on the following platforms: NixOS - YouTube LinkedIn Owncast Instance NixOS (@nixos_org) / Twitter Recordings of the broadcasts will be published on the Ni...
Matthias Meschede changed the topic to "Owncast [https://summer.nixos.org/live/] or [https://live.nixos.org/] YouTube [https://youtu.be/TKgHazs3AMw] LinkedIn [https://www.linkedin.com/video/event/urn:li:ugcPost:6958498799543549952/] Twitter [on https://twitter.com/nixos_org come once it starts] ".
Matthias Meschede
As always: please post questions here during the talk (or on YouTube, Linkedin). We'll go through them in the end.
vdot0x23 joined the room
mightyiam
Q: do you feel the absence of static types in nixpkgs?
Matthias Meschede
Q: Do you see something in between mono-repo or breaking up everything into individual packages? E.g. would composing two or three repos of similar size than nixpkgs together work well and be useful with the current architecture?
Q: How far is flakes support on nixpkgs? What remains to be done?
Q: How far would you go with testing on nixpkgs? As much as possible?
or not 
mightyiam
 ? 😓
mightyiam
It's "mighty I am"
Bryan Honof
Ah, both 
Matthias Meschede
 and I were wrong then 😅, sorry.
mightyiam
Q: how do multiple versions of packages work at all?
a-kenji
Thanks for the talk Jon!
Q: What is the major feature that Hydra has, that other CI/CD's don't support.
mightyiam
Q: why are there occasionally failures on Hydra and how can those be eliminated or reduced?
Collin Arnett
Q: How would you improve the experience of python developers working with ML/Data science libraries in Nix? Eg. I have read your experience on onnxruntime
Matthias Meschede
Q: What resources do you need to run nixpkgs? Build machines, storage, ....
Kranzes
a-kenji
Q: What is the major feature that Hydra has, that other CI/CD's don't support.
Check out Hercules-CI!
fufexan
Q: is there anything you'd change if you were to start a Nixpkgs again?
ctem
(ctem can be pronounced "stem" :)
Q: Assuming internationalization functionality in Nix tooling, in its current form, how hospitable do you feel Nixpkgs would be to localization?
Bryan Honof
Sorry for killing the names 😅
fufexan
hey no problem 😄 also you can just call me "mihai" (pronounced me high)
infinisil
I recently started up the Nixpkgs Architecture Team, which will take a look at larger issues and design decisions in nixpkgs :D Matrix channel is 
#nixpkgs-architecture:nixos.org

Nixpkgs Architecture Team - GitHub
Nixpkgs Architecture Team has 4 repositories available. Follow their code on GitHub.
Kranzes
Q: pwease rewview my pw-awre 🥺
infinisil
Thanks for the shoutout :)
vdot0x23
Q: What upcoming feature/change to nixpkgs are you most excited about in the near future?
a-kenji
Thanks jon, it was an awesome talk!
billewanick
Since Jon brought up reviewing PRs, what goes into reviewing a PR on Nixpkgs? What things should be done, what commands run, what to look for in code, etc? A guide on how to review PRs might go a long way to get more people involved.
vdot0x23
billewanick
Since Jon brought up reviewing PRs, what goes into reviewing a PR on Nixpkgs? What things should be done, what commands run, what to look for in code, etc? A guide on how to review PRs might go a long way to get more people involved.
For common changes I have found this helpful https://nixos.org/manual/nixpkgs/stable/#chap-reviewing-contributions

NixOS - Nixpkgs 22.05 manual
Nixpkgs Manual Version 22.05 Table of Contents 1. Preface I. Using Nixpkgs 2. Global configuration 3. Overlays 4. Overriding 5. Functions reference II. Standard environment 6. The Standard Environment

### WHAT ARE NIX FETCHERS?

**TODO**: All the fetcher-stuff should be explained in a single place. This strucks a chord with `1b23ee60a9fb662792abd031d52317e866b94771` (standardize/make_uniform). How?
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
