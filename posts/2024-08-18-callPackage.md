# `callPackage`

Officially, `callPackage` is only [indirectly documented][1] in the [Nixpkgs manual][2], but there are efforts to get this rectified.<sup><b>0</b></sup> The closest to an official documentation is the [Package parameters and overrides with callPackage][3] article on [nix.dev][4].

<sup>\[0]: See [`nix.dev` issue #651](https://github.com/NixOS/nix.dev/issues/651), [Nixpkgs issue #36354](https://github.com/NixOS/nixpkgs/issues/36354), and [Nixpkgs PR #270696](https://github.com/NixOS/nixpkgs/pull/270696).</sup>

Below are just my notes:

## 0. Executive summary

`callPackage f attr_set` will

1. call function `f` by **automatically populating its input [attribute set][5]**
  <sup>from [attribute set][5] `attr_set` and [Nixpkgs][6] ( which contains all the available Nix packages, convenience functions, etc.)</sup>

2. return an **overridable [attribute set][5]**

## 1. Context

### 1.1 General usage

`callPackage` is used overwhelmingly on functions that produce derivations (a build recipe for a Nix package). Creating a Nix package can require a lot of dependencies that won't have to be supplied manually to the function this way.

> ASIDE  
> "_<dfn id="def-package">Nix package</dfn>_" can mean anything digital that requires assembly from one or more sources. A Nix package can be a software, a dataset, a document, a piece of configuration, etc. (The term "package" is quite overloaded, so it may mean something else entirely in other contexts.)

### 1.2 A common example use case from [Nixpkgs][6]

An important part of [Nixpkgs][6] is [`pkgs/top-level/all-packages.nix`][7] where all the available packages are listed. When the Nixpkgs repo (which is "just" a huge Nix expression) is [`import`][8]ed, all these packages (and some extra attributes) will be composed into one huge [attribute set][5]<sup><b>footnum</b></sup>. The majority of its ~40k lines either are or boil down to a `callPackage` call, such as [this][9]:

<sup>\[footnum]: ... in [here in `pkgs/top-level/stage.nix`](https://github.com/NixOS/nixpkgs/blob/b7d9ab22adfc67600328d42aa6552326be486393/pkgs/top-level/stage.nix#L149-L153). See [comment at the top](https://github.com/NixOS/nixpkgs/blob/b7d9ab22adfc67600328d42aa6552326be486393/pkgs/top-level/stage.nix#L1-L9).</sup>

```
godot_4 = callPackage ../development/tools/godot/4 { };

```

which is equivalent to

```
godot_4_nix = import ../development/tools/godot/4/default.nix;

godot_4 = callPackage ┌godot_4_nix┐ ┌{         }┐ ;
#                     │           │ │           │
#                     └─ FUNCTION ┘ └ ATTRIBUTE ┘
#                         ▲    ▲         SET
#                         │    │          │
#      "NIXPKGS"¹ ────────┘ // └──────────┘
#
```

where `"NIXPKGS"`<sup><b>1</b></sup> stands for the resulting [attribute set][5] when the huge Nix expression that is the [Nixpkgs repo][6] is evaluated (e.g., with `import <nixpkgs> {}`).

<sup>\[1]: I used quotes because [some attributes are actually omitted][11].</sup>

> ASIDE  
> A "<dfn id="def-nix-expression">Nix expression</dfn>" is any piece of code written using the [Nix language][10].

The [`godot_4_nix` function][12] has 30+ input parameters; most are dependecies (the ones with **no** default values) and some are options (the ones **with** default values, [provided with the `?` operator][13]). This means that to build the Godot 4 application, one would have to write out all the input dependencies manually - unless it is called with `callPackage`.

Thus, extensive use of `callPackage` when "pre-evaluating" package definitions (i.e., "_derivation-returning functions_") in [`pkgs/top-level/all-packages.nix`][7] cuts down on a lot of space and reduces manual labour.

> IMPORTANT  
> "_Pre-evaluation_" here does not mean that **all** attributes in [`pkgs/top-level/all-packages.nix`][7] will be evaluated on the spot when importing [Nixpkgs][6]! The [Nix language][10] uses lazy evaluation, therefore these attributes will only get evaluated when they are acutally used (e.g., in [`nix repl`][18], a Nix shell, system configuration in NixOS, etc.). 
> 
> TODO: example
> 
> What I mean by "_pre-evaluation_" is to call (or, because of Nix's laziness, schedule a call of) a "_derivation-returning function_" with the arguments it needs. This was already the practice before [`callPackage` was introduced][17], it just took up way more space and time.

Because of pre-evaluation, when a Nixpkgs package evaluated, then `callPackage` will be evaluated, producing a "_derivation attribute set_" right away - but this is where **overridability** comes in the picture: `callPackage` will also add two extra attributes<sup><b>footnum</b></sup> to the produced [attribute set][5], `override`  and `overrideDerivation`<sup><b>footnum</b></sup>, making it possible to tweak the future derivation TODO, instead of accepting the defaults.

<sup>\[footnum]: ... by eventually calling [`makeOverridable`](https://github.com/NixOS/nixpkgs/blob/1ad352fd9ea96cebc7862782fa8d0d295c68ff15/lib/customisation.nix#L131C3-L160).</sup>

<sup>\[footnum]: It is officially recommended to use `overrideAttrs` instead `overrideDerivation`. TODO link

TODO this should go elsewhere
Here's a beautifully simple explanation [how `override` and `overrideAttrs`/`overrideDerivation` differ](https://www.reddit.com/r/NixOS/comments/cn6nt4/comment/ew7bjhz/).</sup>

> TODO: override hell
> 1. see "override vs overlay nix" tab
> 2. see "override vs overrideAttrs" tab
> 3. general intro to overriding (There is Nix pill to consider though)

<sup><b>footnum</b></sup>

 See Nix Pill chapters [14](https://nixos.org/guides/nix-pills/14-override-design-pattern) and [17](https://nixos.org/guides/nix-pills/17-nixpkgs-overriding-packages). (The latter introduces the concept of "fixed point" which is used - but not mentioned - in the former.)

Evaluating "_derivation-returning functions_" with `callPackage`<sup><b>2</b></sup> cuts down on a lot of space and manual labour by "pre-evaluating", but this doesn't mean that the produced "_derivation attribute sets_" are set in stone! `callPackage` will also add an `override` attribute<sup><b>3</b></sup> and `overrideDerivation` to the returned [attribute set][5]<sup><b>4</b></sup> (if the function does return an attribute, that is) to give users the ability to redefine any of the input attributes.

<sup>\[2]: In fact, `callPackage`'s first argument doesn't have to be a function that produces a derivations at all. See Examples section.</sup>



Here's an example that proves all the points above:

```
# No semicolons because of `nix repl`.

f = let
      id = x: x;
    in
      pkgs.callPackage id { lofa = "balabab"; }

#=> { override = { ... }; overrideDerivation = ...; }

f.override { lofa = 27; miez = 9; }

#=> { lofa = 27
#=> ; miez = 9
#=> ; override = { ... }; overrideDerivation = ... ; }
```

This means that when the Nix expression comprising Nixpkgs is evaluated (e.g,. with `import <nixpkgs> {}`), then every(?) package definition (i.e., "_derivation-returning function_") in there will be called with `callPackage`. Users then either accept the defaults and build the packages as is, or create their own Nix expression and override the inputs to their heart's desire.

TODO: derivation attribute sets vs store derivations!


## 2. An informal specification

One way to write `callPackage`'s type signature:
```
callPackage ::    INPUT_1  path_to_file_with_attr_set_function
               -> INPUT_2  ...        │
               -> OUTPUT   ...        │ ( paths are `import`ed )
                                      │ (     automatically    )
                                      │
                                      ▼
callPackage ::    INPUT_1  attr_set_function            :~> package dependencies and options
               -> INPUT_2  overriding_attr_set          :~>  custom dependencies and options
               -> OUTPUT   maybe_overridable_attr_set   :~> derivation attribute set
```
where
```
attr_set_function :: initial_attr_set -> maybe_attr_set
```

> NOTE
> The Nix language is [dynamically typed][14], so this is (mostly) wishful thinking and it only serves demonstration purposes; see Examples section below.

The `callPackage` function accepts two arguments:

1. `attr_set_function`: a **Nix function** (or a file containing one) whose input can be

   + either an **[attribute set][5]** with restrictions (see "2.1.1 `initial_attr_set`")

   + or a **variable** that will be only be used in contexts that is befitting an [attribute set][5]

     ```
     pkgs = import <nixpkgs> {}

     pkgs.callPackage (i: i) {}
     #=> OK

     pkgs.callPackage (i: i // { lofa = 27; } ) {}
     #=> OK

     pkgs.callPackage (i: i + 2) {}
     #=> ERROR
     ```

2. an **[attribute set][5]** that must be a subset of the input function's input attribute set
   ```
   ```

### 2.1 What is `attr_set_function`?

Most often, `attr_set_function` tends to be a "_derivation-returning function_" to build a package where

+ the **function parameters** (in this case, `initial_attr_set`) contain the dependencies and options for building and configuring it,  and

+ the **function body** will call a Nix expression that will ultimately invoke the [`derivation` primitive](https://nix.dev/manual/nix/2.18/language/derivations). The skeleton of `attr_set_function`'s body  usually looks along the lines of

  ```
  { stdenv
  , ...
  }:

  stdenv.mkDerivation { ... }
  ```

> ASIDE  
> Then again, `callPackage`'s convenience properties (auto-call & overridability) can be taken advantage of in other situations as well. I don't have a list of such edge use cases, but would love to see some.

#### 2.1.1 `initial_attr_set`

The input for `attr_set_function` is

+ `initial_attr_set`, a regular [attribute set][5] whose attributes cannot be completely arbitrary, depending on the answer to the question:

  > **Is the attribute name present in Nixpkgs?**<sup><b>5</b></sup>
  >
  > (That is, in the evaluated Nixpkgs expression. For example, if `pkgs = import <nixpkgs> {}` and `initial_attr_set = { stdenv, cowsay }`, then `pkgs.stdenv` and `pkgs.cowsay` need to be valid expressions.)
  >
  > TODO: Does `callPackage` only look at top-level attributes?

  If the answer is

  + **yes**, attribute name is IN [Nixpkgs][6]<sup><b>5</b></sup>

    then these can stand freely, without having a [default values](https://nix.dev/manual/nix/2.18/language/constructs#functions:~:text=It%20is%20possible%20to%20provide%20default%20values%20for%20attributes) defined for them.

    ```
    (import <nixpkgs> {}).callPackage ( { lib, cowsay }@s: s ) {}
    #=> OK

    (import <nixpkgs> {}).callPackage ( { lofa }@s: s ) {}
    #=> ERROR
    ```

  + **no**, attribute name is NOT IN [Nixpkgs][6]<sup><b>5</b></sup>

    then these either must either have a [default values](https://nix.dev/manual/nix/2.18/language/constructs#functions:~:text=It%20is%20possible%20to%20provide%20default%20values%20for%20attributes) or have to be declared in `overriding_attr_set`.

    ```
    pkgs = import <nixpkgs> {}

    pkgs.callPackage ( { lofa ? 27 }@s: s ) {}
    #=> OK

    pkgs.callPackage ( { lofa }@s: s ) { lofa = 27; }
    #=> OK
    ```

  <sup>\[5]: It is actually a limited subset of [Nixpkgs][6]; see [here](https://github.com/NixOS/nixpkgs/blame/e7f2456df49b39e816e9ed71622c09a42446a581/pkgs/top-level/splice.nix#L125-L144).</sup>

### 2.2 How does `callPackage` call `attr_set_function`?

Here's the visual representation of what is happening at a very high level:

```
    ==================================================================
    === DECLARATIONS IN NIX REPL =====================================
    ==================================================================

    ATTR_SET_FUNCTION =            OVERRIDING_ATTR_SET =  ┌─┐
     ┌── { stdenv                    { lofa = 27; ────────┤ │
     ├── , lib                         cowsay = "miez"; ──┤2│
     ├── , cowsay                    }                    └┬┘
     │   , lofa ? 12                                       │
     │   }:                                                │
     │   { inherit lofa cowsay; }                          │
     ▼                                                     │
    PKGS = import <nixpkgs> {}                             │
     │ ┌─┐                                     ┌───────────┘
     └─┤1├───┐                                 │
       └─┘   │                                 │
             │                                 │
  ┌──────────────────────────────────────────────────────────────────┐
  ├          │                                 │                     │
  │          ▼                                 │                     │
  │┌────────────────┐                          ▼                     │
∙∙││PKGS.callPackage│   ATTR_SET_FUNCTION   OVERRIDING_ATTR_SET      │
: │└────────────────┘                          │           ┌─┐       │
: │               │                            └───────────┤2├────┐  │
: │               │                                        └─┘    │  │
: └──────────────────────────────────────────────────────────────────┘
b                 │                                               │
e   ==============│===============================================│===
c   === EVALUATION│STEPS =========================================│===
o   ==============│===============================================│===
m                ┌┴┐                                              │
e                │1│                                              │
s                └┬┘                                              │
:                 │                                               │
:       ATTR_SET_F│UNCTION           \  ATTR_SET_FUNCTION         │
:         {       ▼                   \   {                       │
∙∙∙∙>       stdenv = PKGS.stdenv;     /     stdenv = PKGS.stdenv; ▼
            lib    = PKGS.lib;     ┌─┐      lib    = PKGS.lib;    │
       ┌─►  cowsay = PKGS.cowsay; ─┤ ├────► cowsay = "miez";      │
       ├─►  lofa   = 12; ──────────┤2├────► lofa   = 27;          │
       │  }                        └─┘    }                      ┌┴┐
      ┌┴┐                                          │             │2│
      │2│                                          │             └┬┘
      └┬┘                                          │              │
       └───────────────────────────◄──────────────────────────────┘
                                                   │
                                                  ┌┴┐
                                                  │3│
                                                  └┬┘
                                                   ▼

                                      { cowsay = "miez";
                                        lofa   = 27;
                                        override           = {...};
                                        overrideDerivation = ...;
                                      }

PKGS = import <nixpkgs> {}    ATTR_SET_FUNCTION =  OVERRIDING_ATTR_SET =
                                {                    {
                                  stdenv               lofa   = 27;
                                , lib                  cowsay = "miez";
                                , cowsay             }
                                , lofa ? 12
                                }:
                                { inherit
                                    lofa cowsay;
                                }

PKGS.callPackage              ATTR_SET_FUNCTION    OVERRIDING_ATTR_SET

PKGS.callPackageWith PKGS     ATTR_SET_FUNCTION    OVERRIDING_ATTR_SET
```

```
PKGS = import <nixpkgs> {}      ATTR_SET_FUNCTION =  OVERRIDING_ATTR_SET =
                                  {                    {
 ││                                 stdenv               lofa   = 27;
 ││                               , lib                  cowsay = "miez";
 │:                               , cowsay             }
 │:                               , lofa ? 12                 │
 │└.......................┐       }:                          │
 │                        :       { inherit                   │
 │                        :           lofa cowsay;            │
 │                        :       }                           │
 │                        :             │                     │
 │                        :             │                     │
 ▼                        :             ▼                     ▼
                          :
PKGS.    callPackage      :     ATTR_SET_FUNCTION    OVERRIDING_ATTR_SET
                          ▼
PKGS.lib.callPackageWith "PKGS" ATTR_SET_FUNCTION    OVERRIDING_ATTR_SET
                            │                                  │
                            │                                  │
                            └────────────────────────┐         │
                                                     │         │
       1. Get ATTR_SET_FUNCTION's input parameters   │         │
                                                     │         │
          fargs = { stdenv = false;                  │         │
                    lib    = false; ─┐               │         │
                    cowsay = false;  │               │         │
                    lofa   = true;   │               │         │
                  }                  │               │         │
                                     │          ┌────┘         │
                                     ▼          ▼              │
       2. Get the intersection of `fargs` and "PKGS"           │
                                                               │
                      ┌──"PKGS"─────────────┐                  │
                      │                     │                  │
                      │           a2jmidid  │                  │
                      │           a2ps      │                  │
                      │           a52dec    │                  │
                      │            :::      │                  │
                      │            N::      │                  │
                      │            i:a      │                  │
                      │            x:t      │                  │
                      │            p:t      │                  │
             ┌──fargs─┼─────────┐  k:r      │                  │
             │        │         │  g:s      │                  │
             │        │ stdenv  │  s::      │                  │
             │        │ lib     │  :::      │                  │
             │        │ cowsay  │ zz        │                  │
             │ lofa   │         │ zziplib   │                  │
             │        │    │    │ zzuf      │                  │
             │        │    │    │           │                  │
             └────────┴─────────┴───────────┘                  │
                                                               │
                           │                    ┌──────────────┘
                           │                    │
                           ▼                    │
                                                │
                  { stdenv = "PKGS".stdenv;     │
                    lib    = "PKGS".lib;        │
                    cowsay = "PKGS".cowsay;     │
                  }                             │
                           │                    │
                           │                    │
                           ▼                    ▼
       3. Merge the intersection with OVERRIDING_ATTR_SET
          (i.e., apply OVERRIDING_ATTRS_SET over the intersection)


            ┌────────intersection────────────────┐
            │                                    │
            │     {   stdenv = "PKGS".stdenv;    │
            │         lib    = "PKGS".lib;       │
            │                                    │
            │     ┌OVERRIDING_ATTR_SET┐          │
            │     │                   ├┐         │
            │     │ { cowsay = "miez";││wsay;    │
            │     │   lofa   = 27;    ││         │
            │     │ }                 ││         │
            │     └┬──────────────────┘│         │
            │      └───────────────────┘         │
            └────────────────────────────────────┘

                            │
                            │
       4. Apply the results │ from Step 3. to ATTR_SET_FUNCTION
                            │
                            │            ┌────────────────────┐
         ATTR_SET_FUNCTION  ▼        \   │                    │
           { stdenv = "PKGS".stdenv;  \  │ { cowsay = "miez"; │
             lib    = "PKGS".lib;      \ │   lofa   = 27;     │
             cowsay = "miez";          / │ }                  │
             lofa   = 27;             /  │                    │
           }                         /   └────────────────────┘

                                                        │
                                                        │
                                                        │
       5. Make the results in Step 4. overridable       │
                                                        │
       ┌────────────────────────────────┐               │
       │                                │               │
       │  { cowsay = "miez";            │               │
       │    lofa   = 27;                │               │
       │    override           = {...}; │ ◄─────────────┘
       │    overrideDerivation = ...;   │
       │  }                             │
       │                                │
       └────────────────────────────────┘
```


### 2.3 Why is the output `maybe_overridable_attr_set`?

+ `maybe`, because

+ `overridable`, because

+ `attr_set`, because







### Level 2. More precise but also more abstruse

```
callPackage ::    ( attr_set_function | path_to_file_with_attr_set_function )
               -> constrained_attr_set
               -> ( overridable_attr_set | arbitrary_nix_value )

attr_set_function :: input_attr_set -> attr_set
```
<sup><b>The Nix language is [dynamically typed][14], so this is just a personal notation.</b></sup>

where

+ `input_attr_set` is a regular [attribute set][5] with caveats depending on whether its attributes are [Nixpkgs][6] or not:

  + **IN [Nixpkgs][6]**
    If the attribute names match attributes in the limited subset of [Nixpkgs][6] package set<sup><b>1</b></sup>, then these won't have to be specified in `constrained_attr_set` as `callPackage` will auto-populate them.

  + **NOT in [Nixpkgs][6]**
    These either must have a default value or have to be specified in `constrained_attr_set`.

+ `constrained_attr_set` is an [attribute set][5] that can only be a subset of `attr_set_function`'s input [attribute set][5].

+ `overridable_att_set` - See [this section][15] of the `nix.dev` tutorial.

### Level 3. Source

https://github.com/NixOS/nixpkgs/blame/e7f2456df49b39e816e9ed71622c09a42446a581/pkgs/top-level/splice.nix#L125-L144

```
  splicedPackagesWithXorg = splicedPackages // builtins.removeAttrs splicedPackages.xorg [
    "callPackage"
    "newScope"
    "overrideScope"
    "packages"
  ];

  # ...

  callPackage = pkgs.newScope { };
  callPackages = ...;
  newScope = extra: lib.callPackageWith (splicedPackagesWithXorg // extra);
```
<sup>`callPackages` (note the extra `s`!) is also defined here, but omitted it, lest I muddy the waters even more.</sup>

[`callPackageWith`][16] is quite long, so only posting the link, but the resources in the question explain the nitty-gritty - and the core of it is this line:

```nix
callPackage = f: args:
  f ((builtins.intersectAttrs (builtins.functionArgs f) pkgs) // args);
```
<sup> ... and [this is an email from 2009][17] that introduces it.</sup>


### Examples

The term `pkgs` below will refer to the [Nixpkgs][6] package set. Such as the result of any of the following calls in [`nix repl`][18]:

* `pkgs = import `[`<nixpkgs>`](https://stackoverflow.com/q/47379654/1498178)` {}`

* `pkgs = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/06278c77b5d162e62df170fec307e83f1812d94b.tar.gz") {}`

* ... and so on

(The semicolon is missing from the end of the Nix expressions to make it easier to try them out in `nix repl`.)


TODO: put the texts BEFORE the examples
* ✅
  ```
  pkgs.callPackage ({ lib, stdenv }: { ... }) {}
  ```
  `lib` and `stdenv` are valid attributes in [Nixpkgs][6], so these will be auto-populated from there. Roughly equivalent to:
  `pkgs.callPackage ({ lib, stdenv }: ... }) { lib = pkgs.lib; stdenv = pkgs.stdenv; }`

* ✅
  ```
  pkgs.callPackage ({ lib, stdenv, lofa ? 27 }: { ... }) {}
  ```
  Same things apply as in the previous item, except that [Nixpkgs][6] has no `lofa` attribute, but there is a default value provided for it, so it will work.

* ✅
  ```
  ( pkgs.callPackage
      ({ lib, stdenv, lofa }: { inherit lofa lib; })
      { lofa = 27; lib = "whatever"; }
  )
  ```
  Same as in previous item, but attributes `lofa` and `lib` are explicitly provided.

* ✅
  ```
   f = let
         id = x: x;
       in
         pkgs.callPackage id { lofa = "balabab"; }

   #=> { override = { ... }; overrideDerivation = ...; }

   f.override { lofa = 27; miez = 9; }

   #=> { lofa = 27
   #=> ; miez = 9
   #=> ; override = { ... }; overrideDerivation = ... ; }
  ```
  `callPackage`'s input function (1st parameter) is called with an [attribute set][5], so this still works - and it becomes overridable too.

* ❌
  ```
  pkgs.callPackage (i: i + 2) {}
  ```
  `callPackage` will choke because `i` will be an [attribute set][5] and the `+` operator will try to coerce it into a string.

*
  ```
  pkgs.callPackage (i: 2) {} #=> 2
  ```
  `callPackage` does not care if an [attribute set][5] is returned or not, but only [attribute sets][5] will be made overridable (for obvious reasons).

* ❌
  ```
  pkgs.callPackage ({ lib, stdenv, lofa }: { inherit lofa; }) {}
  ```
  will raise `error: Function called without required argument "lofa"`.

* ✅
  ```
  $ echo "{lib, stdenv, lofa ? 27}: {inherit lofa;}" > f.nix

  $ nix repl

  nix-repl> pkgs = import <nixpkgs> {}
  nix-repl> pkgs.callPackage ./f.nix {}
  ```
  Providing a valid file system path containing a Nix expression (that conforms to what `callPackage` is accepting) works too as the file will be automatically imported first.

nix-repl> pkgs.callPackage ({ stdenv, lib, lofa ? 27 }: lofa) {}
27

nix-repl> pkgs.callPackage ({ stdenv, lib, lofa ? 27 }: lofa) {lofa = 9;}
9

nix-repl> pkgs.callPackage ({ stdenv, lib, lofa ? 27 }: lofa) {lofa = 9; miez = 8; }
error: anonymous function at «string»:1:19 called with unexpected argument 'miez'

       at /nix/store/h8ankbqczm1wm84libmi3harjsddrcqx-nixpkgs/nixpkgs/lib/customisation.nix:80:16:

           79|     let
           80|       result = f origArgs;
             |                ^
           81|

nix-repl> pkgs.callPackage (x: x) { lofa = 27; }
{ lofa = 27; override = { ... }; overrideDerivation = «lambda @ /nix/store/h8ankbqczm1wm84libmi3harjsddrcqx-nixpkgs/nixpkgs/lib/customisation.nix:95:32»; }

nix-repl> pkgs.callPackage ({miez ? 7}: x) { lofa = 27; }
error: undefined variable 'x'

       at «string»:1:31:

            1| pkgs.callPackage ({miez ? 7}: x) { lofa = 27; }
             |                               ^

nix-repl> pkgs.callPackage ({miez ? 7}@x: x) { lofa = 27; }
error: anonymous function at «string»:1:19 called with unexpected argument 'lofa'

       at /nix/store/h8ankbqczm1wm84libmi3harjsddrcqx-nixpkgs/nixpkgs/lib/customisation.nix:80:16:

           79|     let
           80|       result = f origArgs;
             |                ^
           81|

nix-repl> pkgs.callPackage ({}: x) { lofa = 27; }
error: undefined variable 'x'

       at «string»:1:23:

            1| pkgs.callPackage ({}: x) { lofa = 27; }
             |                       ^

nix-repl> pkgs.callPackage ({}: {}) { lofa = 27; }
error: anonymous function at «string»:1:19 called with unexpected argument 'lofa'

       at /nix/store/h8ankbqczm1wm84libmi3harjsddrcqx-nixpkgs/nixpkgs/lib/customisation.nix:80:16:

           79|     let
           80|       result = f origArgs;
             |                ^
           81|

nix-repl> pkgs.callPackage ({}: {miez = 9; }) {  }
{ miez = 9; override = { ... }; overrideDerivation = «lambda @ /nix/store/h8ankbqczm1wm84libmi3harjsddrcqx-nixpkgs/nixpkgs/lib/customisation.nix:95:32»; }

nix-repl> pkgs.callPackage (x: {miez = 9; }) {  }
{ miez = 9; override = { ... }; overrideDerivation = «lambda @ /nix/store/h8ankbqczm1wm84libmi3harjsddrcqx-nixpkgs/nixpkgs/lib/customisation.nix:95:32»; }


The result of `attr_set_function` is usually a Nix derivation expression (which is an attribute set denoting a derivation - or something like it; look this up).

---

\[1]: https://github.com/NixOS/nixpkgs/blame/e7f2456df49b39e816e9ed71622c09a42446a581/pkgs/top-level/splice.nix#L140-L144


  [1]: https://nixos.org/manual/nixpkgs/stable/#function-library-lib.customisation.callPackageWith
  [2]: https://nixos.org/manual/nixpkgs/stable/
  [3]: https://nix.dev/tutorials/callpackage
  [4]: https://nix.dev/
  [5]: https://nix.dev/manual/nix/stable/language/values#attribute-set
  [6]: https://nix.dev/reference/glossary#term-Nixpkgs
  [7]: https://github.com/NixOS/nixpkgs/blob/95f084845baf7f87ce8fd9f1caed84186132aa96/pkgs/top-level/all-packages.nix
  [8]: https://nix.dev/tutorials/nix-language#import
  [9]: https://github.com/NixOS/nixpkgs/blob/95f084845baf7f87ce8fd9f1caed84186132aa96/pkgs/top-level/all-packages.nix#L8280C3-L8280C58
  [10]: https://nix.dev/manual/nix/2.23/language/
  [11]: https://github.com/NixOS/nixpkgs/blame/e7f2456df49b39e816e9ed71622c09a42446a581/pkgs/top-level/splice.nix#L125-L144
  [12]: https://github.com/NixOS/nixpkgs/blob/55f73f0566d8db00b8ec108e7351f5fd01e98990/pkgs/development/tools/godot/4/default.nix#L1-L35
  [13]: https://nix.dev/tutorials/nix-language.html#functions
  [14]: https://nix.dev/tutorials/nix-language.html
  [15]: https://nix.dev/tutorials/callpackage#overrides
  [16]: https://github.com/NixOS/nixpkgs/blob/7370c67890fb6ae18bad28496a684294ec1b3f88/lib/customisation.nix#L212-L269
  [17]: https://www.mail-archive.com/nix-dev@cs.uu.nl/msg02624.html
  [18]: https://nix.dev/manual/nix/2.18/command-ref/new-cli/nix3-repl
