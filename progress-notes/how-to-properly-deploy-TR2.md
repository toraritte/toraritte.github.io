# SFTB: How to properly deploy TR2?

Been down this road before so picking up the thread (or more like re-tracing my steps) from [NixOS images on Azure](https://discourse.nixos.org/t/nixos-images-on-azure/7062).

## 2022
### 2022-09-06: NixOS on Azure

The premise was to use configure TR2 (FreeSWITCH + Erlang script) on NixOS, and deploy it on Azure, but that is put on hold because

> The Azure platform SLA applies to virtual machines running the Linux OS only when one of the [endorsed distributions](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/endorsed-distros) is used.

(See [this reply](https://discourse.nixos.org/t/nixos-images-on-azure/7062/22) in the above Discourse thread for context.)

> QUESTION: How does one add NixOS to the Azure Marketplace to make it an "endorsed distribution"?

> HISTORICAL NOTE
>
> Before moving on: did spend some time on Cole Mickens' [`azure-new`](https://github.com/NixOS/nixpkgs/tree/master/nixos/maintainers/scripts/azure-new) script, and the result is [society-for-the-blind/nixos-azure-deploy](https://github.com/society-for-the-blind/nixos-azure-deploy). It may already be obsolete as he already wrote a follow-up that is a [Rust-based and flakified version](https://github.com/colemickens/flake-azure-demo/tree/dev) of `azure-new`.
>
> The latest (and probably most up-to-date) contender is [Plommonsorbet/nixos-azure-gen-2-vm-example](https://github.com/Plommonsorbet/nixos-azure-gen-2-vm-example).
>
> Notable mentions along this journey:
>
> + [colemickens/nixcfg](https://github.com/colemickens/nixcfg/) (Cole Mickens' configuration repo)
>
> + [nix-community/nixos-generators](https://github.com/nix-community/nixos-generators)
>   > The nixos-generators project allows to take the same NixOS configuration, and generate outputs for different target formats.
>
> + [nixpkgs/azure-vhd-utils](https://pkgs.on-nix.com/nixpkgs/azure-vhd-utils/)
>
>   > Go package to read Virtual Hard Disk (VHD) file, a CLI interface to upload local VHD to Azure storage and to inspect a local VHD
>
> + [Why Choose Gen2? aka Timeline for Gen2 Disk Encryption? #52340](https://github.com/MicrosoftDocs/azure-docs/issues/52340)
>
> + [sauryadas/NixOS_Azure](https://github.com/sauryadas/NixOS_Azure)
>
> + [Awesome Nix](https://nix-community.github.io/awesome-nix/)

### 2022-09-07: Use Nix on Linux to deploy TR2

Current Linux choice is Debian, because

> Debian (preferred) The development team uses and builds against Debian. They recommend Debian because of its operationally stable, yet updated, kernel and wide library support.\
> <sup>[from FreeSWITCH docs](https://freeswitch.org/confluence/display/FREESWITCH/Installation)</sup>

Did [a search for `manage system services with nix`](https://www.google.com/search?q=manage+system+services+with+nix&oq=manage+system+services+with+nix+&aqs=chrome..69i57j33i160l4j33i299.10263j0j4&sourceid=chrome&ie=UTF-8), and the first result was [How does Nix manage SystemD modules on a non-NixOS?](https://unix.stackexchange.com/questions/349199/how-does-nix-manage-systemd-modules-on-a-non-nixos) on UNIX & Linux Stackexchange.

### 2022-09-08: systemd, Disnix

Tons of great info in there that I'm unable to absorb yet, so created the Discourse thread [How does Nix manage SystemD modules on a non-NixOS?](https://discourse.nixos.org/t/how-does-nix-manage-systemd-modules-on-a-non-nixos/21499) to track similar topics from Discourse which, surprisingly, have very little information on this matter.

Opened as many tabs as I could from the search (obviously..), and one of the results was from Sander van der Burg's blog, an article titled [Using the Nix process management framework as an infrastructure deployment solution for Disnix](http://sandervanderburg.blogspot.com/2021/03/using-nix-process-management-framework.html). ([annotations](./assets/2021-03-12_Using-the-Nix-process-management-framework-as-an-infrastructure-deployment-solution-for-Disnix.pdf))<sup><b>♠</b></sup>

<sup>\[♠]: First, here's the [JavaScript snippet](https://gist.github.com/toraritte/419f9012e62fc05486acdf7b1e272341) used to format Sander's blogspot articles to be properly print them to PDF to do annotations with Xodo. Second, there may be no annotation in there because I accidentally deleted the file, and syncthing diligently propagated that change across every devices. (TODO: set up versioning and/or add a crontab entry to back up periodically.)</sup>

Got stuck quickly because I'm missing the basics, so jumped over to [Disnix: A toolset for distributed deployment](https://sandervanderburg.blogspot.com/2011/02/disnix-toolset-for-distributed.html), where Sander first announced Disnix ([annotations](./assets/2011-02-16_Disnix--A-toolset-for-distributed-deployment.pdf)).

The Disnix intro article above doesn't mention systemd (it was written only a couple months after systemd was announced), but services come up a lot, and most other posts I skimmed talk heavily about systemd. That is another topic I know little about, so switched again to learn it.
