
Fetch a Git repo.

## 0. Types

> **improvement ideas**:
> +  Make "Types" section collapsible and add hover tooltip to expand type mentions in the descriptive portion of this reference.
>
> + Fix table 2.3-1's vertical header to the left so that it doesn't scroll out of screen
>
> + Link footnotes
>
> **...and questions**:
> + How to treat ancillary texts?
> + Levels of detail?

**referenceToGitRepo** = **URL** | **path** | **gitArgs**
<br>

**URL** = **httpURL** | **httpsURL** | **ftpURL** | **fileURL**\
&nbsp;&nbsp;Supported code hosting services: GitHub, GitLab, SourceHut.

**httpURL** = [string](TODO)\
&nbsp;&nbsp;Needs to conform to the `http://` URI scheme (see [RFC 9110, section 4.2](https://datatracker.ietf.org/doc/html/rfc9110#section-4.2)).

**httpsURL** = [string](TODO)\
&nbsp;&nbsp;Needs to conform to the `https://` URI scheme (see [RFC 9110, section 4.2](https://datatracker.ietf.org/doc/html/rfc9110#section-4.2)).

**ftpURL** = [string](TODO)\
&nbsp;&nbsp;Needs to conform to the `ftp://` URI scheme (see [RFC 1738, section 3.2](https://datatracker.ietf.org/doc/html/rfc1738#section-3.2)).

**webLikeURLs** = **httpURL** | **httpsURL** | **ftpURL**

**fileURL** = `"file://"` + **fileURLPathPart**\
**fileURLPathPart** = [string](TODO)\
&nbsp;&nbsp;**fileURLPathPart** is a shorthand for **fileURL** (i.e., it will be prefixed with `"file://"` during evaluation) therefore both need to conform to the `file://` URI scheme (see [the path syntax of RFC 8089](https://datatracker.ietf.org/doc/html/rfc8089#section-2)).
<br>

**path** = [Nix path](TODO) | **fileURLPathPart**\
&nbsp;&nbsp;
<br>

**gitArgs** :: [attribute set](TODO) =\
&nbsp;&nbsp;{ `url` :: (**URL** | **path**);\
&nbsp;&nbsp;&nbsp;&nbsp;[ `name` :: [string](TODO) ? `"source"` ];\
&nbsp;&nbsp;&nbsp;&nbsp;[ `ref` :: **gitReference** ? `"HEAD"` ];\
&nbsp;&nbsp;&nbsp;&nbsp;[ `rev` :: **gitFullCommitHash** ? ? ];\
&nbsp;&nbsp;&nbsp;&nbsp;[ `submodules` :: [boolean](TODO) ? `false` ];\
&nbsp;&nbsp;&nbsp;&nbsp;[ `shallow` :: [boolean](TODO) ? `false` ];\
&nbsp;&nbsp;&nbsp;&nbsp;[ `allRefs` :: [boolean](TODO) ? `false` ];\
&nbsp;&nbsp;}

**webLikeGitArgs** :: [attribute set](TODO) = 
&nbsp;&nbsp;(Erlang-y)&nbsp;&nbsp;**gitArgs**#{ `url` ::  **webLikeURLs**; }
&nbsp;&nbsp;(Haskell-y) **gitArgs** { `url` :: **webLikeURLs**; }

**pathLikeGitArgs** :: [attribute set](TODO) =
&nbsp;&nbsp;(Erlang-y)&nbsp;&nbsp;**gitArgs**#{ `url` :: (**path** | **fileURL**); }
&nbsp;&nbsp;(Haskell-y) **gitArgs**#{ `url` :: (**path** | **fileURL**); }

**webLike** = **webLikeURLs** | **webLikeGitArgs**
&nbsp;&nbsp;Argument that is a URL or has a URL member conforming to the `http://`, `https://`, and `ftp://` URI schemes.

**pathLike** = **path** | **fileURL** | **pathLikeGitArgs**
&nbsp;&nbsp;Argument that resolves or has a member that resolves to a file system path.

**gitReference** = [string](TODO)\
&nbsp;&nbsp;Needs to be valid [Git reference](https://git-scm.com/book/en/v2/Git-Internals-Git-References).

**gitFullCommitHash** = [string](TODO)\
&nbsp;&nbsp;Has to be full SHA-1 ([for now](https://git-scm.com/docs/hash-function-transition/) object name (40-byte hexadecimal string) that refers to an existing commit in the repo.
<br>

**storeResult** :: [attribute set](TODO)  =\
&nbsp;&nbsp;{ `lastModified` :: ?;\
&nbsp;&nbsp;&nbsp;&nbsp;`lastModifiedDate` :: ?;\
&nbsp;&nbsp;&nbsp;&nbsp;`narHash` :: ?;\
&nbsp;&nbsp;&nbsp;&nbsp;`outPath` :: **nixStorePath**;\
&nbsp;&nbsp;&nbsp;&nbsp;`rev` :: **gitFullCommitHash**;\
&nbsp;&nbsp;&nbsp;&nbsp;`revCount` :: ?;\
&nbsp;&nbsp;&nbsp;&nbsp;`shortRev` :: ?;\
&nbsp;&nbsp;&nbsp;&nbsp;`submodules` :: [boolean](TODO);\
&nbsp;&nbsp;}

## 1. Behaviour

`builtins.fetchGit` behaves differently when called with **pathLike** or **webLike** arguments.

### 1.1 "Web-like" semantics: **webLike** arguments

This section applies to any argument that uses URLs conforming to the `http://`, `https://`, and `ftp://` URI schemes. (The `file://` URI scheme is omitted on purpose, and is discussed in the next section titled "_2. "Path-like" semantics: Calling `fetchGit` with **pathLike** arguments_".)

When called 

+ with **webLikeURLs** type arguments, the latest commit (or HEAD) of the repo's default branch (typically called `main` or `master`) will be fetched.

  Examples:

  ```text
  fetchGit "https://github.com/NixOS/nix"
  fetchGit "https://git.sr.ht/~rycee/configurations"
  fetchGit "https://gitlab.com/rycee/home-manager"
  ```

+ with **webLikeGitArgs** attribute set,

  + if only the mandatory `url` attribute is specified (or an attribute set with `url` and any other optional attributes that are equivalent to their default values), then the behaviour is the same as with **webLikeURLs** above

    ```text
    fetchGit { url = "https://github.com/NixOS/nix"; }

    # is the same as

    fetchGit {
      url = "https://github.com/NixOS/nix";
      ref = "HEAD";
      rev = "<SHA-1 hash of the latest commit of the NixOS/nix repo's master branch>"
      submodules = false;
      shallow = false;
      allRefs = false;
    }
    ```

  + otherwise the end results may be different, and possible deviations are described in the sections below for each optional attribute.

### 1.2 "Path-like" semantics: Calling `fetchGit` with **pathLike** arguments

Calls with **pathLike** arguments  attempt to fetch a repo in a directory on a local or remote file system. The target project may be  under active development so their status and state may need to be determined before trying to copy the repo to the Nix store.

#### 1.2.1 Git repository characteristics

That is, characteristics that `fetchGit` cares about.

##### 1.2.1.1 Status

A Git repo can be

+ **dirty**, if there are _modified tracked files_ and/or _staged changes_; _**untracked** content_ does not count.

+ **clean**, if the output of [`git diff-index HEAD`](https://git-scm.com/docs/git-diff-index) is empty. (If there are only untracked files in `git status`, the repo is **clean**.)

##### 1.2.1.2 State

The state of a repo is determined by where the [HEAD reference][2.1.2-0] points to at the moment when the repo is fetched.

For example, if you are on branch `BRANCH`, then HEAD points to `ref/heads/BRANCH` (the same goes with tags). When the repo is in "detached HEAD" state, HEAD is simply an alias to the commit that has been checked out.

[2.1.2-0]: https://git-scm.com/book/sv/v2/Git-Internals-Git-References#ref_the_ref

#### 1.2.2. Call `fetchGit` with [`Nix path`](TODO), `fileURL`, or `fileURLPathPart`

Sample calls to demonstrate:

+ via [Nix path](TODO):\
  `fetchGit ~/clones/nix`

+ via **fileURL**:\
  `fetchGit "file:///home/nix_user/clones/nix"`

+ via **fileURLPathPart**:\
  `fetchGit "/home/nix_user/clones/nix"`

| state \\ status | **dirty** | **clean** |
| ---                 | ---       | ---       |
| **on `BRANCH`** | Copy directory contents verbatim<sup><b>2.2-1</b></sup>   | Fetch<sup><b>2.2-2</b></sup> BRANCH of repo   |   |
| **at `TAG`** |  Copy directory contents verbatim<sup><b>2.2-1</b></sup> | Fetch<sup><b>2.2-2</b></sup> repo at `TAG` |
| **detached HEAD** |  Copy directory contents verbatim<sup><b>2.2-1</b></sup> | Fetch<sup><b>2.2-2</b></sup> repo at HEAD |

<sup>Table 2.2-1</sup>

<sup>\[2.2-1]: See [`src/libfetchers/git.cc`#`445`](https://github.com/NixOS/nix/blob/86fcd4f6923b3a8ccca261596b9db0d8c0a873ec/src/libfetchers/git.cc#L445-L452).

<sup>\[2.2-2]: See [`src/libfetchers/git.cc`#`fetch()`](https://github.com/NixOS/nix/blob/86fcd4f6923b3a8ccca261596b9db0d8c0a873ec/src/libfetchers/git.cc#L393), line [556](https://github.com/NixOS/nix/blob/86fcd4f6923b3a8ccca261596b9db0d8c0a873ec/src/libfetchers/git.cc#L556).</sup>

#### 1.2.3 Call via `pathLikeGitArgs` attribute set

This means one of the following:

  + via { `url` :: [Nix path](TODO) }
    `fetchGit { url = ~/clones/nix; ... }`

  + via { `url` :: **fileURLPathPart** }
    `fetchGit { url = "/home/nix_user/clones/nix"; ... }`

  + via { `url` :: **fileURL** }
    `fetchGit { url = "file:///home/nix_user/clones/nix"; ... }`

It is clear from section "2.2. Call `fetchGit` with [`Nix path`](TODO), `fileURL`, or `fileURLPathPart`" that `fetchGit`'s path-like semantics doesn't care where HEAD points to; what matters is the status of the Git repo, hence the simplified table below.

> NOTE
>
> `gitArgs`'s `rev` and `ref` attributes are described in the subsequent sections, but they needed to be addressed here as they change call results significantly.

<table>
  <caption>Table 2.3-1</caption>
  <tr>
    <th><i>State</i></th>
    <td>HEAD</td>
    <td>HEAD</td>
    <td>HEAD</td>
    <td>HEAD</td>
  </tr>
  <tr>
    <th><i>Status</i></th>
    <td>dirty</td>
    <td>clean</td>
    <td>irrelevant<sup><b>2.3-1</b></sup></td>
    <td>irrelevant<sup><b>2.3-1</b></sup></td>
 </tr>
  <tr>
    <th><i><code>rev</code><br>attribute</i></th>
    <td>omitted</td>
    <td>omitted</td>
    <td>present</td>
    <td>omitted</td>
 </tr>
 <tr>
    <th><i><code>ref</code><br>attribute</i></th>
    <td>omitted</td>
    <td>omitted</td>
    <td>irrelevant<sup><b>2.3-2</b></sup></td>
    <td>present</td>
 </tr>
 <tr>
    <th><i>Outcome</i></th>
    <td>Verbatim copy</td>
    <td>Fetch repo at HEAD</td>
    <td>Ignore changes<br>and<br>fetch repo at <code>rev</code> commit</td>
    <td>Ignore changes<br>and<br>fetch repo at <code>ref</code> branch / tag</td>
 </tr>
 <tr>
    <th><i>Example argument</i></th>
    <td><pre>{ url = "file:///home/user/nix; }</pre></td>
    <td><pre>{ url = "/home/user/nix; }</pre></td>
    <td>
<pre>
{ url = ./.;
  rev = "6692c9c6e231b1dfd5594dd59b32001b70060f19";
}
</pre>
    </td>
    <td>
<pre>
{ url = ./nix;
  ref = "my-branch";
}
</pre>
    </td>
 </tr>
</table>

<sup>\[2.3-1]: When `ref` or `rev` is present, the intention is probably to fetch a known good state from the repo's past history, thus most recent changes are not relevant (neither the status of the repo).</sup>

<sup>\[2.3-2]: When `rev` (i.e., commit hash) is specified, `ref` is ignored (present or not), because it has higher specificity (i.e., a reference will need to be resolved and its value may change with time, but a commit hash will always point to the same exact state during the lifetime of a Git repo. (TODO: right?)</sup>

As a corollary, here are some tips:

+ If you need to fetch a local repo, calling `fetchGit` with `ref` (branch or tag) or `rev` (commit hash) will make sure that a repo is fetched with a predictable content, ignoring any changes that may have been made since you last touched it.

+ If you are packaging a project under active development and want to test changes without commiting, you'll probably want to call `fetchGit` simply with the mandatory `url` attribute (or any of the formats in section 2.2).

## 2. **gitArgs** attributes

#### 3.1 `url` (mandatory)

When only the `url` attribute is provided in **gitArgs** then `fetchGit`'s behaviour matches the descriptions in sections "1. Calling `fetchGit` with a URL" and "2. Calling `fetchGit` with a path" above (along with the examples).

Optional attributes may change the default behaviour though, and these are discussed in their respective sections below.

#### 3.2 `name` (optional)\

The name part of the [Nix store path](https://nixos.org/manual/nix/stable/introduction.html#introduction) where the Git repo's content will be copied to.

**_Default value_**: `"source"`

```text
nix-repl> builtins.fetchGit { url = ./.; }
{ ...; outPath = "/nix/store/zwp1brk7ndhls3br4hk4h9xhpii17zs5-source"; ...; }

nix-repl> builtins.fetchGit { url = ./.; name = "miez"; }
{ ...; outPath = "/nix/store/zwp1brk7ndhls3br4hk4h9xhpii17zs5-miez"; ...; }
```

### 3.3 `rev` (optional)\

The `rev` attribute is used to refer to a specific commit, and only accepts the full SHA-1 Git object name (40-byte hexadecimal string).

**_Default value_**: Depends on `ref` (see next section if anything is unclear):

+ if `ref` is present **and** it is a branch reference, then the `rev` attribute's value will become the most recent commit's hash of that branch (i.e., the HEAD of that branch).

+ if `ref` is omitted, then

```text
nix-repl> builtins.fetchGit {
            url = "https://github.com/nixos/nix";
            rev = "21c443d4fd0dc4e28f4af085aef711d5ce30c5e8";
          }
{ lastModified = 1657612105;
  lastModifiedDate = "20220712074825";
  narHash = "sha256-pxFb+Ogd/nKuvpVZEbRjfj/tW12p/B9QbBZ1vfHOaj8=";
  outPath = "/nix/store/kp89i9r0p3i7g8zzrpir4djxd1hb7zgx-source";
  rev = "21c443d4fd0dc4e28f4af085aef711d5ce30c5e8";
  revCount = 12402;
  shortRev = "21c443d";
  submodules = false;
 }
```

### 3.4 `ref` (optional)\

Needs to be valid [Git reference](https://git-scm.com/book/en/v2/Git-Internals-Git-References).

> WARNING
>
> By default, the `ref` value is prefixed with `refs/heads/`. After Nix 2.3.0, it will not be prefixed with `refs/heads/` if `ref` starts with `refs/`.


+ `submodules` (optional)

+ `shallow` (optional)

+ `allRef` (optional)



  - `ref` (optional)\
    The git ref to look for the requested revision under. This is
    often a branch or tag name. Defaults to `HEAD`.


  - `rev` (optional)\
    The [Git revision](https://git-scm.com/docs/git-rev-parse#_specifying_revisions) to fetch.\
    *Default value*: if the `ref` attribute (see above) is specified,

  - `submodules` (optional)\
    A Boolean parameter that specifies whether submodules should be
    checked out. Defaults to `false`.

  - `shallow` (optional)\
    A Boolean parameter that specifies whether fetching a shallow clone
    is allowed. Defaults to `false`.
    NOTE [`git clone --depth=1 <url>` creates a shallow clone](https://github.blog/2020-12-21-get-up-to-speed-with-partial-clone-and-shallow-clone/#:~:text=git%20clone%20%2D%2Ddepth%3D1%20%3Curl%3E%C2%A0creates%20a%C2%A0shallow%20clone)

    QUESTION How does this affect rev and ref? this is what i think

    + "no ref, no rev": ref=HEAD rev=resolve(HEAD)
+++++++++clean repo:  only diff is revCount
        The store hash stayed the same! Probably because .git is never copied - but then what is the point of this switch because then it will always be shallow. 
        https://stackoverflow.com/questions/11497457/git-clone-without-git-directory
        QUESTION also, if .git is never copied, what is the point of revcount?
        NOTE should be called commitCount

        nix-repl> builtins.fetchGit { url = ~/shed/my-project; }
        { lastModified = 1658846311; lastModifiedDate = "20220726143831"; narHash = "sha256-Yph6eCPxkG4TeoDAh/W6xaG+j5oFAui80c1FMYaGPTY="; outPath = "/nix/store/waffpfm7xrfyh1yj60v4phaf49ccyjd0-source"; rev = "5f45e9c854941c72deb9d36fb3e95e4feb4d698f"; revCount = 5; shortRev = "5f45e9c"; submodules = false; }
        nix-repl> builtins.fetchGit { url = ~/shed/my-project; shallow = true; }
        { lastModified = 1658846311; lastModifiedDate = "20220726143831"; narHash = "sha256-Yph6eCPxkG4TeoDAh/W6xaG+j5oFAui80c1FMYaGPTY="; outPath = "/nix/store/waffpfm7xrfyh1yj60v4phaf49ccyjd0-source"; rev = "5f45e9c854941c72deb9d36fb3e95e4feb4d698f"; revCount = 0; shortRev = "5f45e9c"; submodules = false; }
        ---------

+++++++++dirty repo: completely identical outputs

        nix-repl> builtins.fetchGit { url = ./.; }                 
        warning: Git tree '/home/toraritte/clones/nix' is dirty
        { lastModified = 1658888196; lastModifiedDate = "20220727021636"; narHash = "sha256-bcPz3nYp1zK0HwwBqEybsxpDs5V7TPGUP3RE3Myd8zM="; outPath = "/nix/store/g0mrkf6vq0w6qzbkj03f4z3qhx18w50n-source"; rev = "0000000000000000000000000000000000000000"; revCount = 0; shortRev = "0000000"; submodules = false; }

        nix-repl> builtins.fetchGit { url = ./.; shallow = true; }
        warning: Git tree '/home/toraritte/clones/nix' is dirty
        { lastModified = 1658888196; lastModifiedDate = "20220727021636"; narHash = "sha256-bcPz3nYp1zK0HwwBqEybsxpDs5V7TPGUP3RE3Myd8zM="; outPath = "/nix/store/g0mrkf6vq0w6qzbkj03f4z3qhx18w50n-source"; rev = "0000000000000000000000000000000000000000"; revCount = 0; shortRev = "0000000"; submodules = false; }

+++++++++stopping this experiment here because adding rev and/or ref doesn't make a difference: only revCount will differ

  - `allRefs` (optional)\
    Whether to fetch all refs of the repository. With this argument being
    true, it's possible to load a `rev` from *any* `ref` (by default only
    `rev`s from the specified `ref` are supported).

    NOTE allRefs also seems kind of pointless

nix-repl> builtins.fetchGit { url = ~/shed/my-project; allRefs = true; ref = "main";}
{ lastModified = 1658846059; lastModifiedDate = "20220726143419"; narHash = "sha256-FQUE8ek9uoyMy
uGjQirYVc5B16X1Uq/k5e4LH+yv4S4="; outPath = "/nix/store/3ra7y3vsnbz707nq8r2d5p7k4irmiwrp-source";
 rev = "c277976fce0b2b32b954a66d4345730b5b08f1db"; revCount = 3; shortRev = "c277976"; submodules
 = false; }

nix-repl> builtins.fetchGit { url = ~/shed/my-project; ref = "main";}                 
{ lastModified = 1658846059; lastModifiedDate = "20220726143419"; narHash = "sha256-FQUE8ek9uoyMy
uGjQirYVc5B16X1Uq/k5e4LH+yv4S4="; outPath = "/nix/store/3ra7y3vsnbz707nq8r2d5p7k4irmiwrp-source";
 rev = "c277976fce0b2b32b954a66d4345730b5b08f1db"; revCount = 3; shortRev = "c277976"; submodules
 = false; }

nix-repl> builtins.fetchGit { url = "https://github.com/nixos/nix"; } 
{ lastModified = 1658489272; lastModifiedDate = "20220722112752"; narHash = "sha256-z0ov/NPT8egao
DUVw4i5SuKcx6t7YZbL7lzdOBsP1sA="; outPath = "/nix/store/z13wfalqlfshjbkx5kwwgfm3350xnpdx-source";
 rev = "280543933507839201547f831280faac614d0514"; revCount = 12454; shortRev = "2805439"; submod
ules = false; }

nix-repl> builtins.fetchGit { url = "https://github.com/nixos/nix"; allRef = true; }
error: unsupported Git input attribute 'allRef'

nix-repl> builtins.fetchGit { url = "https://github.com/nixos/nix"; allRefs = true; }
{ lastModified = 1658489272; lastModifiedDate = "20220722112752"; narHash = "sha256-z0ov/NPT8egao
DUVw4i5SuKcx6t7YZbL7lzdOBsP1sA="; outPath = "/nix/store/z13wfalqlfshjbkx5kwwgfm3350xnpdx-source";
 rev = "280543933507839201547f831280faac614d0514"; revCount = 12454; shortRev = "2805439"; submod
ules = false; }

#####################

Only 2 uses of `allRefs` in the entirety of Nixpkgs: TODO i don't think it matters if used or not; except if `fetchGit` used "improperly" -> see issue below

0 [07:38:22] ag 'allRefs' .
pkgs/development/tools/yarn2nix-moretea/yarn2nix/lib/generateNix.js
54:          allRefs = true;

pkgs/development/tools/poetry2nix/poetry2nix/mk-poetry-dep.nix
179:                allRefs = true;

#####################

https://github.com/NixOS/nix/issues/5128
but the error makes sense as an SHA-1 hash **is not** a valid reference

nix-repl> builtins.fetchGit { ref = "db1442a0556c2b133627ffebf455a78a1ced64b9"; rev = "db1442a055
6c2b133627ffebf455a78a1ced64b9"; url = "https://github.com/tmcw/leftpad"; } 
fetching Git repository 'https://github.com/tmcw/leftpad'fatal: couldn't find remote ref refs/hea
ds/db1442a0556c2b133627ffebf455a78a1ced64b9
error: program 'git' failed with exit code 128



nix-repl> builtins.fetchGit { ref = "db1442a0556c2b133627ffebf455a78a1ced64b9"; rev = "db1442a055
6c2b133627ffebf455a78a1ced64b9"; url = "https://github.com/tmcw/leftpad"; allRefs = true; }
warning: could not update mtime for file '/home/toraritte/.cache/nix/gitv3/0240dfgnkwmgqs7sma8rns
8wlwxiv40b1lddl2sg2i0hnw7ym5c0/refs/heads/db1442a0556c2b133627ffebf455a78a1ced64b9': No such file
 or directory
{ lastModified = 1493781506; lastModifiedDate = "20170503031826"; narHash = "sha256-0DbZHwAdvEUiH
o3brZyyxw0WdNQOsQwGZZz4tboN3v8="; outPath = "/nix/store/8frq54wwgi63wqgkc7p6yrcljlx4zwzh-source";
 rev = "db1442a0556c2b133627ffebf455a78a1ced64b9"; revCount = 5; shortRev = "db1442a"; submodules
 = false; }

nix-repl> 

nix-repl> 

nix-repl> builtins.fetchGit { ref = "db1442a0556c2b133627ffebf455a78a1ced64b9"; url = "https://gi
fetching Git repository 'https://github.com/tmcw/leftpad'fatal: couldn't find remote ref refs/hea
ds/db1442a0556c2b133627ffebf455a78a1ced64b9
error: program 'git' failed with exit code 128

nix-repl> builtins.fetchGit { rev = "db1442a0556c2b133627ffebf455a78a1ced64b9"; url = "https://gi
{ lastModified = 1493781506; lastModifiedDate = "20170503031826"; narHash = "sha256-0DbZHwAdvEUiH
o3brZyyxw0WdNQOsQwGZZz4tboN3v8="; outPath = "/nix/store/8frq54wwgi63wqgkc7p6yrcljlx4zwzh-source";
 rev = "db1442a0556c2b133627ffebf455a78a1ced64b9"; revCount = 5; shortRev = "db1442a"; submodules
 = false; }


Here are some examples of how to use `fetchGit`.

- To fetch a private repository over SSH:

  ```nix
  builtins.fetchGit {
    url = "git@github.com:my-secret/repository.git";
    ref = "master";
    rev = "adab8b916a45068c044658c4158d81878f9ed1c3";
  }
  ```

- To fetch an arbitrary reference:

  ```nix
  builtins.fetchGit {
    url = "https://github.com/NixOS/nix.git";
    ref = "refs/heads/0.5-release";
  }
  ```

- If the revision you're looking for is in the default branch of
  the git repository you don't strictly need to specify the branch
  name in the `ref` attribute.

  However, if the revision you're looking for is in a future
  branch for the non-default branch you will need to specify the
  the `ref` attribute as well.

  ```nix
  builtins.fetchGit {
    url = "https://github.com/nixos/nix.git";
    rev = "841fcbd04755c7a2865c51c1e2d3b045976b7452";
    ref = "1.11-maintenance";
  }
  ```

  > **Note**
  >
  > It is nice to always specify the branch which a revision
  > belongs to. Without the branch being specified, the fetcher
  > might fail if the default branch changes. Additionally, it can
  > be confusing to try a commit from a non-default branch and see
  > the fetch fail. If the branch is specified the fault is much
  > more obvious.

- If the revision you're looking for is in the default branch of
  the git repository you may omit the `ref` attribute.

  ```nix
  builtins.fetchGit {
    url = "https://github.com/nixos/nix.git";
    rev = "841fcbd04755c7a2865c51c1e2d3b045976b7452";
  }
  ```

- To fetch a specific tag:

  ```nix
  builtins.fetchGit {
    url = "https://github.com/nixos/nix.git";
    ref = "refs/tags/1.9";
  }
  ```

- To fetch the latest version of a remote branch:

  ```nix
  builtins.fetchGit {
    url = "ssh://git@github.com/nixos/nix.git";
    ref = "master";
  }
  ```

  > **Note**
  >
  > Nix will refetch the branch in accordance with
  > the option `tarball-ttl`.

  > **Note**
  >
  > This behavior is disabled in *Pure evaluation mode*.
