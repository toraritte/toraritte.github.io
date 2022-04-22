# Nix derivations and the terms ambiguous usage

<sup>My comment copied here verbatim from [pull request #6420 "_Document what Nix \*is\*_"](https://github.com/NixOS/nix/pull/6420); look for more context there.</sup>

> One example I already got stuck with is how we introduce what Nix calls "derivation".

This is a great point; I have been using Nix for years and still struggle defining it, even though the gist of it is simple. For me, the difficulty understanding it comes from the way the term has been used in the PhD thesis, the manuals, on the forum, in blog posts, etc. 

### The concept

There is the **concept** of "derivation",

+ > a component build action, which _derives_ the component from its inputs
   > <sup>([PhD thesis][1], page 27, callout 3)</sup>

+ > the store derivations describe build actions from source
   > <sup>([PhD thesis][1], page 42, paragraph 3)</sup>

These are high-level descriptions and easy to grasp, but to go further from here, one has to have knowledge about the Nix expression language which has a `derivation` primop so it can become a circular problem.

Therefore, I think the most important thing is that **once a concept/term is introduced, it should be used consistently in the entire document**, even if it means increased verbosity. E.g., using "derivation" instead of "Nix derivation expression" is shorter, but misleading (see next section). Also, **definitions should be easy to find**; a glossary with non-contradicting entries is a good start, and pointing to definitions in the text where they were first introduced would also be helpful by providing more context.

### Usage

The confusing part comes from how the **term** "derivation" is used, as it seemingly means different things depending on context:

+ An **attribute set**
   The `derivation` primop (called directly or indirectly) returns the input attribute set, enriched with extra attributes (such as `outPath`, `drvPath`, `type` ... and what else?). People mentioning to "import derivation" used to perplex me because for some reason I was missing this part.

+ **Nix derivation expression**s
   Nix expression that eventually call the `derivation` primop (directly or indirectly), instead of a Nix expression that has a supporting role (e.g., most functions in `builtins`). The [PhD thesis][1] also uses "derivation" ambiguously, but it does make the distinction explicit (emphases mine):

   > In any case, these **derivation Nix expressions** are subsequently translated to **store derivations** using the method described in this section.
   > <sup>([PhD thesis][1], page 100, section "5.4. Translating Nix expressions to store derivations", paragraph 2)</sup>

+ **store derivations**
   That is, the `drv` files in `/nix/store`.

### Nix derivation expressions vs. store derivations

TL;DR Both describe build actions to create a component/package, but 

+ a "Nix derivation expression" is usually a function (eventually calling the `derivation` primop) therefore given its inputs, the resulting componant/package can have different properties (e.g., Vim built with system clipboard or not, etc.)

+ **store derivation**  an alternative representation of the build instructions (using ATerms?) with all variability removed, stored in the Nix store as a file.

![image](https://user-images.githubusercontent.com/1965782/164262215-532b6480-1113-436e-8120-5aed16514a7c.png)

---

I think the [PhD thesis][1] is fairly underappreciated and more parts should be used from it, even though "derivation" is used ambiguously. Some examples of explanations that I found helpful and also a couple that show why the usage can be confusing (emphases mine, and the square brackets are also added by me):

+ Figure 2.12:
   > ![image](https://user-images.githubusercontent.com/1965782/164252435-9ca469e8-7d7b-48d8-a297-47e66b8153eb.png)
   > <sup>([PhD thesis][1], page 39)</sup>

   (Where it should say "Nix derivation expression" in the first bubble.)

+ > **Nix** [derivation] **expressions** are not built directly; rather, they are translated to the more primitive language of **store derivations**, which encode single component build actions.
   > <sup>([PhD thesis][1], page 39, section "2.4. Store derivations", paragraph 2)</sup>

+ > **Nix** [derivation] **expressions** are first translated to **store derivations** that live in the Nix store and that each describe a single build action with all variability removed. These **store derivations** can then be built, which results in **derivation outputs** that also live in the Nix store.
   > <sup>([PhD thesis][1], page 39, section "2.4. Store derivations", paragraph 3)</sup>
   
   Where "_derivation outputs_" are the built components/packages, I presume.

+ > What matters is that each [Nix] **derivation** [expression] is translated recursively into a **store derivation**
   > <sup>([PhD thesis][1], page 39, section "2.4. Store derivations", paragraph 4)</sup>

+ > The most important primop, indeed the raison d’être for the Nix expression language, is the primop `derivation`. It translates a _set of attributes_ describing a build action to a **store derivation**, which can then be built. The translation process is performed by the function `instantiate`, given in Section 5.4. What is relevant here is that `instantiate(as)` takes a set of attributes as, translates them to a **store derivation**, and returns an identical set of attributes, but with three attributes added: the attribute type with string value "derivation", and the attributes `drvPath` and `outPath` containing the store paths of the store derivation and its output, respectively.
   > <sup>([PhD thesis][1], page 80, paragraph 2)</sup>

+ > **Store derivations** are the result of the evaluation of high-level **Nix** [derivation] **expressions**. **Nix** [derivation] **expressions** can express variability, store derivations cannot—a store derivation encodes a single, specific, constant
build action.
   > <sup>([PhD thesis][1], page 100, section "5.4. Translating Nix expressions to store derivations", paragraph 1)</sup>


[1]: https://edolstra.github.io/pubs/phd-thesis.pdf
