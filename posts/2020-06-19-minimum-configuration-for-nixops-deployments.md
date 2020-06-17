# Minimum NixOS configuration for NixOps deployments

1. [Minimal NixOS config for Nixops deployment (discourse)](https://discourse.nixos.org/t/minimal-nixos-config-for-nixops-deployment/3912)

2. [Can't deploy to NixOS #1192](https://github.com/NixOS/nixops/issues/1192) (see [hypothes.is annotations](https://github.com/NixOS/nixops/issues/1192#annotations:group:__world__) as well, under orphans for some reason)<sup>1<sup>

The [NixOps 1.8 User's Guide](https://hydra.nixos.org/build/115931128/download/1/manual/manual.html) (linked from the [NixOps repo](https://github.com/NixOS/nixops)) has very little info, [the 1.7 one](https://releases.nixos.org/nixops/nixops-1.7/manual/manual.html) is way more detailed, but they both lack some basic information.<sup>2<sup>

From link 1:

> In a standard image you need to activate ssh and add
> key  for root.  That is  the minimum  for nixops  to
> work, since it needs to root access via ssh.
>
> ```nix
> users.users.root.openssh.authorizedKeys.keys = [ <yourkey> ];
> services.openssh.enable = true;
> ```

See more at [NixOS images on Azure](https://discourse.nixos.org/t/nixos-images-on-azure/7062) discourse thread. (It's archived, just in case.)

---

So many questions:

+ **How to deploy machines  (e.g., personal laptop) with
    data partition encryption?**

  My guess is that  the partitions and encryption will
  have to  be set up  when NixOS is installed  on that
  machine, and then specify  it in the NixOps configs.
  Search for "luks" and then for "ita" in this
  [repo](https://github.com/aij/aij-nixos-config).

+ See [2].

---

[1] The problem is state.
[This hypothes.is article explains orphans](https://web.hypothes.is/help/what-are-orphans-and-where-are-they/),
and it seems that when  I made the annotation, I was
logged in  to github,  so the  checksum of  the HTML
elements in  the highlighted text (or  whatever they
use  to anchor)  differs  when opened  in a  browser
where I'm not logged in.

[2] **How to start contributing to the NixOps repo?** There's
[this discourse thread](https://discourse.nixos.org/t/any-resources-for-learning-about-nixops-development/4398)
but it barely scratches the surface. Source is king,
I guess.
