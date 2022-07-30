
Fetch a Git repo.

## 0. Types

> **improvement ideas**:
> +  Make "Types" section collapsible and add hover tooltip to expand type mentions in the descriptive portion of this reference.
>
> + Fix table 2.3-1's vertical header to the left so that it doesn't scroll out of screen
>
> + Link footnotes
>
> + Make typespec notes less prominent (italics doesn't seem to do much. CSS?)
>
> **...and questions**:
> + How to treat ancillary texts?
> + Levels of detail?

**referenceToGitRepo** = **URL** | **path** | **gitArgs**
<br>

**URL** :: [string](TODO) = **httpURL** | **httpsURL** | **ftpURL** | **fileURL**\
&nbsp;&nbsp;Supported code hosting services: GitHub, GitLab, SourceHut.

**httpURL** = [string](TODO)\
&nbsp;&nbsp;Needs to conform to the `http://` URI scheme (see [RFC 9110, section 4.2](https://datatracker.ietf.org/doc/html/rfc9110#section-4.2)).

**httpsURL** = [string](TODO)\
&nbsp;&nbsp;Needs to conform to the `https://` URI scheme (see [RFC 9110, section 4.2](https://datatracker.ietf.org/doc/html/rfc9110#section-4.2)).

**ftpURL** = [string](TODO)\
&nbsp;&nbsp;Needs to conform to the `ftp://` URI scheme (see [RFC 1738, section 3.2](https://datatracker.ietf.org/doc/html/rfc1738#section-3.2)).

**webLikeURL** :: [string](TODO) = **httpURL** | **httpsURL** | **ftpURL**

**fileURL** :: [string](TODO) = `"file://"` + **fileURLPathPart**\
**fileURLPathPart** = [string](TODO)\
&nbsp;&nbsp;**fileURLPathPart** is a shorthand for **fileURL** (i.e., it will be prefixed with `"file://"` during evaluation) therefore both need to conform to the `file://` URI scheme (see [the path syntax of RFC 8089](https://datatracker.ietf.org/doc/html/rfc8089#section-2)).
<br>

**path** = [Nix path](TODO) | **fileURLPathPart**\
<br>

**gitArgs** :: [attribute set](TODO) =\
&nbsp;&nbsp;{ `url` :: (**URL** | **path**);\
&nbsp;&nbsp;&nbsp;&nbsp;[ `name` :: [string](TODO) ? `"source"` ];\
&nbsp;&nbsp;&nbsp;&nbsp;[ `ref` :: **gitReference** ? `"HEAD"` ];\
&nbsp;&nbsp;&nbsp;&nbsp;[ `rev` :: **gitFullCommitHash** ? <`ref` dereferenced> ];\
&nbsp;&nbsp;&nbsp;&nbsp;[ `submodules` :: [boolean](TODO) ? `false` ];\
&nbsp;&nbsp;&nbsp;&nbsp;[ `shallow` :: [boolean](TODO) ? `false` ];\
&nbsp;&nbsp;&nbsp;&nbsp;[ `allRefs` :: [boolean](TODO) ? `false` ];\
&nbsp;&nbsp;}

**webLikeGitArgs** :: [attribute set](TODO) = 
&nbsp;&nbsp;(Erlang-y)&nbsp;&nbsp;**gitArgs**#{ `url` ::  **webLikeURL**; }
&nbsp;&nbsp;(Haskell-y) **gitArgs** { `url` :: **webLikeURL**; }

**pathLikeGitArgs** :: [attribute set](TODO) =
&nbsp;&nbsp;(Erlang-y)&nbsp;&nbsp;**gitArgs**#{ `url` :: (**path** | **fileURL**); }
&nbsp;&nbsp;(Haskell-y) **gitArgs**#{ `url` :: (**path** | **fileURL**); }

**webLike** = **webLikeURL** | **webLikeGitArgs**
&nbsp;&nbsp;Argument that is a URL or has a URL member conforming to the `http://`, `https://`, and `ftp://` URI schemes.

**pathLike** = **path** | **fileURL** | **pathLikeGitArgs**
&nbsp;&nbsp;Argument that resolves or has a member that resolves to a file system path.

**gitReference** = [string](TODO)\
&nbsp;&nbsp;Needs to be valid [Git reference][Git-refs].

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

### 1.1 "Web-like" semantics

These sections describe the behaviour of `builtins.fetchGit` when called with **webLike** arguments:

+ [1.1.1 **webLikeURL** type argument](TODO): string that conforms to the `http://`, `https://`, and `ftp://` URI schemes.

+ [1.1.2 **webLikeGitArgs** type argument](TODO): same as **gitArgs** attribute set, except that the mandatory `url` attribute value is a **webLikeURL**

#### 1.1.1 `webLikeURL` type argument

> NOTE
>
> The `file://` URI scheme is omitted on purpose, and is discussed in section [1.2 "Path-like" semantics](TODO).

<table>
  <caption>Table 1.1.1-1 <code>builtins.fetchGit <a href="TODO">string</a></code></caption>
  <thead>
    <tr>
      <td colspan="2"></td>
      <th scope="col">String format</th>
      <th scope="col">Outcome</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th rowspan="3" scope="rowgroup"><b>webLikeURL</b></th>
      <th scope="row"><b>httpURL</b></th>      
      <td><code>"<a href="https://datatracker.ietf.org/doc/html/rfc9110#section-4.2">http</a>://..."</code></td>      
      <td rowspan="3">The latest commit (or <a href="https://git-scm.com/book/sv/v2/Git-Internals-Git-References#ref_the_ref">HEAD</a>)<br>of the repo's default branch<br>(typically called <code>main</code> or<br><code>master</code>) will be fetched.<br></td>
    </tr>
    <tr>
      <th scope="row"><b>httpsURL</b></th>      
      <td><code>"<a href="https://datatracker.ietf.org/doc/html/rfc9110#section-4.2">https</a>://..."</code></td>      
    </tr>
    <tr>
      <th scope="row"><b>ftpURL</b></th>      
      <td><code>"<a href="https://datatracker.ietf.org/doc/html/rfc1738#section-3.2">ftp</a>://..."</code></td>      
    </tr>
  </tbody>
</table>

  HTTPS examples with the supported code hosting sites:

  ```text
  builtins.fetchGit "https://github.com/NixOS/nix"
  builtins.fetchGit "https://git.sr.ht/~rycee/configurations"
  builtins.fetchGit "https://gitlab.com/rycee/home-manager"
  ```

#### 1.1.2 `webLikeGitArgs` type argument

> NOTE
>
> [`gitArgs`](TODO) attributes [`rev`](TODO) and [`ref`](TODO) will only be discussed in subsequent sections, but they also needed to be addressed here because of the significant role they play regarding the call results.

<table>
  <caption>Table 1.1.2-1 <code>builtins.fetchGit <a href="TODO">attribute set</a></code></caption>
  <thead>
    <tr>
      <th scope="col" colspan="3"><a href="TODO"><b>gitArgs</b><br>attributes</a></th>
      <th scope="col" rowspan="2">Outcome</th>
      <th scope="col" rowspan="2">Example argument</th>
      <th scope="col" rowspan="2">Example resolved to full <b>webLikeGitArgs</b> attribute set</th>
    </tr>
    <tr>
      <th scope="col"><a href="TODO"><code>url</code><br>attribute</a><br>(<i>mandatory</i>)</th>
      <th scope="col"><a href="TODO"><code>rev</code><br>attribute</a><br>&nbsp;&nbsp;&nbsp;(<i>optional</i>)&nbsp;&nbsp;&nbsp;</th>
      <th scope="col"><a href="TODO"><code>ref</code><br>attribute</a><br>&nbsp;&nbsp;&nbsp;(<i>optional</i>)&nbsp;&nbsp;&nbsp;</th>
    </tr>
  </thead>
  <tbody>
    <tr> <!-- ROW 1 -->
      <td rowspan="3"><b>webLikeURL</b></td>
      <td>omitted<sup><b>1.1.2-1</b></sup></td>
      <td>omitted<br>(or default value of HEAD used)</td>
      <td>Same as<pre>builtins.fetchGit <b>webLikeURL</b></pre>(see <a href="TODO">Table 1.1.1-1</a> above)</td>
      <td>
<pre>
{ url = "https://github.com/nixos/nix"; }
</pre>
      </td>
      <td>
<pre>
{
  url = "https://github.com/NixOS/nix";
  name = "source";
  ref = "HEAD";
  rev = "&lt;SHA-1 commit hash of HEAD&gt;"
  submodules = false;
  shallow = false;
  allRefs = false;
}
</pre>
      </td>
    </tr>
    <tr> <!-- ROW 2 -->
      <td>present</td>
      <td>ignored<sup><b>1.1.2-2</b></sup></td>
      <td>Fetch repo at <code>rev</code> commit</td>
      <td>
<pre>
{ url = "https://github.com/nixos/nix";
  rev = "be4654c344f0745d4c2eefb33a878bd1f23f6b40";
}
</pre>
      </td>
      <td>
<pre>
{ url = "https://github.com/nixos/nix";
  name = "source";
  ref = ""
  rev = "be4654c344f0745d4c2eefb33a878bd1f23f6b40";
  submodules = false;
  shallow = false;
  allRefs = false;
}
</pre>
      </td>
    </tr>
    <tr> <!-- ROW 3 -->
      <td>omitted<sup><b>1.1.2-1</b></sup></td>
      <td>present</td>
      <td>Fetch repo at <code>ref</code> branch / tag</td>
      <td>
<pre>
{ url = "https://github.com/nixos/nix";
  ref = "refs/tags/2.10.3";
}
</pre>
      </td>
      <td>
<pre>
{ url = "https://github.com/nixos/nix";
  name = "source";
  ref = "refs/tags/2.10.3";
  rev = "309c2e27542818b74219d6825e322b8965c7ad69";
  submodules = false;
  shallow = false;
  allRefs = false;
}
</pre>
      </td>
    </tr>
  </tbody>
</table>

<sup>\[1.1.2-1]: See section [3.3 `rev`](TODO)

<sup>\[1.1.2-2]: See section [3.4 `ref`](TODO)

### 1.2 "Path-like" semantics

Calls with **pathLike** arguments  attempt to fetch a repo in a directory on a local or remote file system. The target repo may be a project under active development so their status and state may need to be determined before trying to copy the repo to the [Nix store](TODO).

#### 1.2.1 Git repository characteristics

That is, characteristics that `builtins.fetchGit` cares about.

##### 1.2.1.1 Status

The **status** of a Git repo is

+ **dirty**, if there are _modified tracked files_ and/or _staged changes_.
  (_Untracked content_ does not count.)

+ **clean**, if the output of [`git diff-index HEAD`](https://git-scm.com/docs/git-diff-index) is empty. (If there are only untracked files in `git status`, the repo is **clean**.)

##### 1.2.1.2 State

The **state** of a Git repo is the specific commit where the [HEAD reference][HEAD] points to (directly or indirectly) at the moment when the repo is fetched.

<sup>Directly, if the repo is in a "detached HEAD" state, and indirectly when the commit is also the target of [other references][Git-refs] as shown on the figure below.</sup>

<figure class="image">
  <img src="https://i.imgur.com/sxrqy4j.png" alt="Visualized Git repo showing two branches and HEAD points to a commit that is tagged and is also the head of a branch.">
  <figcaption>1.2.1.2-1. State of a Git repo</figcaption>
</figure>

[HEAD]: https://git-scm.com/book/sv/v2/Git-Internals-Git-References#ref_the_ref
[Git-refs]: https://git-scm.com/book/sv/v2/Git-Internals-Git-References

#### 1.2.2. Argument of type [`Nix path`](TODO), `fileURL`, or `fileURLPathPart`

<table>
  <caption>Table 1.2.2-1</caption>
  <thead>
    <tr>
      <td rowspan="2" colspan="2"></td>
      <th scope="col" colspan="2"><a href="TODO">STATUS</a></th>
      <th rowspan="2">De-reference process</th>
    </tr>
    <tr>
      <th scope="col"><b>dirty</b></th>
      <th scope="col"><b>clean</b></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th rowspan="3"><a href="TODO">STATE</a></th>
      <th scope="row"><b>on <code>BRANCH</code></b></th>      
      <td>Copy directory contents verbatim</td>      
      <td>Fetch repo at HEAD of <code>BRANCH</code></td>      
      <td>HEAD -> <code>refs/heads/BRANCH</code> -> &lt;SHA-1 commit hash&gt;</td>      
    </tr>
    <tr>
      <th scope="row"><b>at <code>TAG</code></b></th>      
      <td>Copy directory contents verbatim</td>      
      <td>Fetch repo at <code>TAG</code></td>      
      <td>HEAD -> <code>refs/tags/TAG</code> -> &lt;SHA-1 commit hash&gt;</td>      
    <tr>
      <th scope="row"><b>detached HEAD</b></th>      
      <td>Copy directory contents verbatim</td>      
      <td>Fetch repo at HEAD</td>      
      <td>HEAD -> &lt;SHA-1 commit hash&gt;</td>      
    </tr>
  </tbody>
</table>

In fact, the state rows could have easily been ignored as what matters is the specific commit at the end of the de-reference process.

Example calls:

+ via [Nix path](TODO):\
  `builtins.fetchGit ~/clones/nix`

+ via **fileURL**:\
  `builtins.fetchGit "file:///home/nix_user/clones/nix"`

+ via **fileURLPathPart**:\
  `builtins.fetchGit "/home/nix_user/clones/nix"`

#### 1.2.3 `pathLikeGitArgs` type argument

This means one of the following:

  + via { `url` :: [Nix path](TODO) }
    `builtins.fetchGit { url = ~/clones/nix; ... }`

  + via { `url` :: **fileURLPathPart** }
    `builtins.fetchGit { url = "/home/nix_user/clones/nix"; ... }`

  + via { `url` :: **fileURL** }
    `builtins.fetchGit { url = "file:///home/nix_user/clones/nix"; ... }`

The following table takes advantage of the fact that [state](TODO) is simply determined by the current value of the [HEAD reference][HEAD]:

> NOTE
>
> [`gitArgs`](TODO) attributes [`rev`](TODO) and [`ref`](TODO) will only be discussed in subsequent sections, but they also needed to be addressed here because of the significant role they play regarding the call results.

<table>
  <caption>Table 1.2.3-1.</caption>
  <thead>
    <tr>
      <th scope="col" rowspan="2">&nbsp;&nbsp;&nbsp;&nbsp;<a href="TODO"><b>STATUS</a>&nbsp;&nbsp;&nbsp;&nbsp;</th>
      <th scope="col" colspan="3"><a href="TODO"><b>gitArgs</b><br>attributes</a></th>
      <th scope="col" rowspan="2">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Outcome&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</th>
      <th scope="col" rowspan="2">Example argument</th>
    </tr>
    <tr>
      <th scope="col"><a href="TODO"><code>url</code><br>attribute</a><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(<i>mandatory</i>)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</th>
      <th scope="col"><a href="TODO"><code>rev</code><br>attribute</a><br>&nbsp;&nbsp;&nbsp;(<i>optional</i>)&nbsp;&nbsp;&nbsp;</th>
      <th scope="col"><a href="TODO"><code>ref</code><br>attribute</a><br>&nbsp;&nbsp;&nbsp;(<i>optional</i>)&nbsp;&nbsp;&nbsp;</th>
    </tr>
  </thead>
  <tbody>
    <tr> <!-- ROW 1 -->
      <td><a href="TODO">dirty</a></td>
      <td rowspan="4">&nbsp;&nbsp;<b><a href="TODO">Nix path</a></b><br>| <b>fileURLPathPart</b><br>| <b>fileURL</b><br><br>(See examples at the top of this section.)</td>
      <td>omitted<sup><b>1.2.3-1</b></sup></td>
      <td>omitted<br>(or default value of HEAD used)</td>
      <td>Copy directory contents verbatim</td>
      <td rowspan="2">
<pre>
{ url = "https://github.com/nixos/nix"; }
</pre>
      </td>
    </tr>
    <tr> <!-- ROW 2 -->
      <td><a href="TODO">clean</a></td>
      <td>omitted<sup><b>1.2.3-1</b></sup></td>
      <td>omitted<br>(or default value of HEAD used)</td>
      <td>Fetch repo at HEAD</td>
    </tr>
    <tr> <!-- ROW 3 -->
      <td>ignored<sup><b>1.2.3-2</b></sup></td>
      <td>present</td>
      <td>ignored<sup><b>1.2.3-3</b></sup></td>
      <td>Ignore changes (if any) and fetch repo at <code>rev</code> commit</td>
      <td>
<pre>
{ url = "https://github.com/nixos/nix";
  rev = "be4654c344f0745d4c2eefb33a878bd1f23f6b40";
}
</pre>
      </td>
    </tr>
    <tr> <!-- ROW 4 -->
      <td>ignored<sup><b>1.2.3-2</b></sup></td>
      <td>omitted<sup><b>1.2.3-1</b></sup></td>
      <td>present</td>
      <td>Ignore changes (if any) and fetch repo at <code>ref</code> tag / branch</td>
      <td>
<pre>
{ url = "https://github.com/nixos/nix";
  ref = "refs/tags/2.10.3";
}
</pre>
      </td>
    </tr>
</table>

<sup>\[1.2.3-1]:  See section [3.3 `rev`](TODO)

<sup>\[1.2.3-2]: When `ref` or `rev` is present, the intention is probably to fetch a known state from the repo's past history, thus most recent changes are not relevant (neither the status of the repo).</sup>

<sup>\[1.2.3-3]: See section [3.4 `ref`](TODO)

As a corollary, here are some tips:

+ If you need to fetch a local repo, calling `builtins.fetchGit` with `ref` (branch or tag) or `rev` (commit hash) will make sure that a repo is fetched with a predictable content, ignoring any changes that may have been made since you last touched it.

+ If you are packaging a project under active development and want to test changes without commiting, you'll probably want to call `builtins.fetchGit` with `{ url = ...; }` or the specified in [1.2.2. Argument of type [`Nix path`](TODO), `fileURL`, or `fileURLPathPart`](TODO). 

## 2. **gitArgs** attributes

Reminder:

**gitArgs** :: [attribute set](TODO) =\
&nbsp;&nbsp;{ `url` :: (**URL** | **path**);\
&nbsp;&nbsp;&nbsp;&nbsp;[ `name` :: [string](TODO) ? `"source"` ];\
&nbsp;&nbsp;&nbsp;&nbsp;[ `ref` :: **gitReference** ? `"HEAD"` ];\
&nbsp;&nbsp;&nbsp;&nbsp;[ `rev` :: **gitFullCommitHash** ? <`ref` dereferenced> ];\
&nbsp;&nbsp;&nbsp;&nbsp;[ `submodules` :: [boolean](TODO) ? `false` ];\
&nbsp;&nbsp;&nbsp;&nbsp;[ `shallow` :: [boolean](TODO) ? `false` ];\
&nbsp;&nbsp;&nbsp;&nbsp;[ `allRefs` :: [boolean](TODO) ? `false` ];\
&nbsp;&nbsp;}

### 3.1 `url` (mandatory)

<table>
  <tbody>
    <tr>
      <th scope="row">Description</th>
      <td>This attribute is covered extensively in section <a href="TODO">1. Behaviour</a> (specifically, in sections <a href="TODO">1.1.2 <b>webLikeGitArgs</b> type argument</a> and <a href="TODO">1.2.3 <b>pathLikeGitArgs</b> type argument</a>).</td>
    </tr>
    <tr>
      <th scope="row">Type</th>
      <td><a href="TODO">string</a></td>
    </tr>
    <tr>
      <th scope="row">Default value</th>
      <td>none</td>
    </tr>
</table>

### 3.2 `name` (optional)

<table>
  <tbody>
    <tr>
      <th scope="row">Description</th>
      <td>The name part of the <a href="https://nixos.org/manual/nix/stable/introduction.html#introduction">Nix store path</a> where the Git repo's content will be copied to.</td>
    </tr>
    <tr>
      <th scope="row">Type</th>
      <td><a href="TODO">string</a></td>
    </tr>
    <tr>
      <th scope="row">Default value</th>
      <td><code>"source"</code></td>
    </tr>
</table>

Examples:

```text
nix-repl> builtins.fetchGit { url = ./.; }
{ ...; outPath = "/nix/store/zwp1brk7ndhls3br4hk4h9xhpii17zs5-source"; ...; }

nix-repl> builtins.fetchGit { url = ./.; name = "miez"; }
{ ...; outPath = "/nix/store/zwp1brk7ndhls3br4hk4h9xhpii17zs5-miez"; ...; }
```

### 3.3 `rev` (optional)

<table>
  <tbody>
    <tr>
      <th scope="row">Description</th>
      <td>The <code>rev</code> attribute is used to refer to a specific commit by the full SHA-1 Git object name (40-byte hexadecimal string) - or as it is more colloquially called, the <b>commit hash</b>.</td>
    </tr>
    <tr>
      <th scope="row">Type</th>
      <td><a href="TODO">string</a></td>
    </tr>
    <tr>
      <th scope="row">Additional<br>constraints</th>
      <td>40-byte hexadecimal SHA-1 string</td>
    </tr>
    <tr>
      <th scope="row">Default value</th>
      <td>The dereferenced value of the Git reference held by the <code>ref</code> attribute. (See next section.)</td>
    </tr>
</table>

Sections [1.1.2 **webLikeGitArgs** type argument](TODO) and [1.2.3 **pathLikeGitArgs** type argument](TODO)) in [1. Behaviour](TODO) describe the prevailing behaviour `builtins.fetchgit` when the `rev` attribute is used.

> NOTE
>
> Specifying the `rev` attribute will render the `ref` attribute irrelevant no matter if it is included in the input attribute set or not. See next section for more.

### 3.4 `ref` (optional)

<table>
  <tbody>
    <tr>
      <th scope="row">Description</th>
      <td>The <code>ref</code> attribute accepts a <a href="https://git-scm.com/book/sv/v2/Git-Internals-Git-References">Git reference</a> that is present in the target repo.
      </td>
    </tr>
    <tr>
      <th scope="row">Type</th>
      <td><a href="TODO">string</a></td>
    </tr>
    <tr>
      <th scope="row">Additional<br>constraints</th>
      <td>See <a href="https://git-scm.com/book/sv/v2/Git-Internals-Git-References">Git reference</a> syntax</td>
    </tr>
    <tr>
      <th scope="row">Default value</th>
      <td><code>"HEAD"</code></td>
    </tr>
</table>

> WARNING
>
> By default, the `ref` value is prefixed with `refs/heads/`. After Nix 2.3.0, it will not be prefixed with `refs/heads/` if `ref` starts with `refs/`.

#### 3.3.1 [`ref` attribute](TODO) ignored when the `rev` attribute is provided

The `rev` attribute (i.e., the commit hash) has higher specificity; a `ref` reference will need to be resolved and its value may change with time, but a commit hash will always point to the same exact commit object and thus to the same state of the the repo during the lifetime of a Git repo. (TODO: right?)

---

TODO/NOTE: Stopping here for now to wait for the resolution of [comment on Nix issue #5128](https://github.com/NixOS/nix/issues/5128#issuecomment-1198254451)

Here are some examples of how to use `builtins.fetchGit`.

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

TODO: move this to the end
<sup>\[2.2-1]: See [`src/libfetchers/git.cc`#`445`](https://github.com/NixOS/nix/blob/86fcd4f6923b3a8ccca261596b9db0d8c0a873ec/src/libfetchers/git.cc#L445-L452).

<sup>\[2.2-2]: See [`src/libfetchers/git.cc`#`fetch()`](https://github.com/NixOS/nix/blob/86fcd4f6923b3a8ccca261596b9db0d8c0a873ec/src/libfetchers/git.cc#L393), line [556](https://github.com/NixOS/nix/blob/86fcd4f6923b3a8ccca261596b9db0d8c0a873ec/src/libfetchers/git.cc#L556).</sup>





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

Only 2 uses of `allRefs` in the entirety of Nixpkgs: TODO i don't think it matters if used or not; except if `builtins.fetchGit` used "improperly" -> see issue below

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


