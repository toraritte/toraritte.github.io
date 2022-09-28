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

### 2022-09-26: systemd still, and tr2-dev

#### systemd

Finished reading and annotating the (only) systemd book I could find, [Linux Service Management Made Easy with systemd](https://www.amazon.com/Linux-Service-Management-Made-systemd/dp/1801811644); it has tons of good info, but the style made me almost quit, and clarity is not it's strongest suit.

There's still plenty of good resources, will continue there.

#### tr2-dev

Finally summoned the courage to re-create the TR2 service to use it as a backup and as a development server; it will nice not to hack on the production server:) Hoping to nixify the whole process, and maybe even to create a NixOS counterpart (as it is currently running on Debian).

##### Step 1. Re-create TR2

1. Set up new Debian VM.

2. [Install Nix](https://nixos.org/download.html) by using the multi-user installation.

  > QUESTION Why does SELinux need to be disabled? And how does one check if it is enabled?

3. `nix-shell -pv git`

4. Clone the [access-news/phone-service](https://github.com/access-news/phone-service) GitHub repo.

  ```text
  mkdir clones
  cd clones
  git clone https://github.com/access-news/phone-service.git
  ```

5. Follow the [FreeSWITCH wiki's Debian install instructions](https://freeswitch.org/confluence/display/FREESWITCH/Debian) up to the installation, but stop before that because:

  > WARNING: Use `sudo su` to execute the commands in the root shell; at least, prefixing these with `sudo` doesn't always seem to work because of all the redirections going on. While this is not ideal (no logs, etc.), this way it **will** work, and only doing this to re-establish understanding of the project anyway before trying to nixify it.

  > ```text
  > TOKEN=YOURSIGNALWIRETOKEN
  > ```
  >
  > (Go [here](https://freeswitch.org/confluence/display/FREESWITCH/HOWTO+Create+a+SignalWire+Personal+Access+Token) to get the token.)
  >
  > ```text
  > apt-get update && apt-get install -y gnupg2 wget lsb-release
  >
  > wget --http-user=signalwire --http-password=$TOKEN -O /usr/share/keyrings/signalwire-freeswitch-repo.gpg https://freeswitch.signalwire.com/repo/deb/debian-release/signalwire-freeswitch-repo.gpg
  >
  > echo "machine freeswitch.signalwire.com login signalwire password $TOKEN" > /etc/apt/auth.conf
  > chmod 600 /etc/apt/auth.conf
  > echo "deb [signed-by=/usr/share/keyrings/signalwire-freeswitch-repo.gpg] https://freeswitch.signalwire.com/repo/deb/debian-release/ `lsb_release -sc` main" > /etc/apt/sources.list.d/freeswitch.list
  > echo "deb-src [signed-by=/usr/share/keyrings/signalwire-freeswitch-repo.gpg] https://freeswitch.signalwire.com/repo/deb/debian-release/ `lsb_release -sc` main" >> /etc/apt/sources.list.d/freeswitch.list
  > ```

  Didn't bother with the warning below, just went ahead and installed it, because this is what I did in the past apparently based on [`deploy.bash`](https://github.com/access-news/phone-service/blob/6b49f27a8d6831aa917d59e632694d135966f937/deploy.bash) (which renames the vanilla config in `/etc/freeswitch` to `/etc/freeswitch_old`).

  > ```text
  > # you may want to populate /etc/freeswitch at this point.
  > # if /etc/freeswitch does not exist, the standard vanilla configuration is deployed
  > apt-get update && apt-get install -y freeswitch-meta-all
  > ```

c("outbound_erl2/content"), c("outbound_erl2/filog"), c("outbound_erl2/fs"), c("outbound_erl2/futil"), c("outbound_erl2/ivr"), c("outbound_erl2/menus"), c("outbound_erl2/tts"), c("outbound_erl2/user_db"), filog:start(), user_db:start(), content:start
().

6. Test out the install

  ```text
  sudo service freeswitch start
  fs_cli
  ```
  > NOTE / QUESTION: The `freeswitch` group and user are added by the installer automatically. Does the Nix package takes care of this too? Probably does because there is a systemd service for it in Nixpgks, and it is probably (and hopefully) not started as root.

7. Copy the config from TR2 to TR2-DEV

   That would mostly mean `/etc/freeswitch`, but it is more nuanced than that, because Google's TTS is also used in the service at the moment, so there is a JSON file for authenticating for that, and some Lua stuff. The latter was supposed to be dropped, but forgot if I already did, and never updated to docs, so...

   QUESTION: How are the phone numbers 916.732.4000 and 800.665.4667 configured? (This part is crucial, because I didn't want to set up a backup that disrupts the service in production.)

   ANSWER: Will annotate the relevant config files and document it here as well, but the real answer is that this is set up in the SignalWire Dashboard (i.e., in our case, at [sftb.signalwire.com](https://sftb.signalwire.com)); the [`mod_signalwire`](https://sftb.signalwire.com/phone_numbers) explains this in details, but re-iterating here just in case:

  1. Generate a token in `fs_cli` with the `signalwire token` command.

  2. Create a new SignalWire integration (go to "Integrations" on the [Dashboard](https://sftb.signalwire.com)); enter the token when asked for it, and fill out the forms. (NOTE: An outgoing phone number needs to be specified even if there will be no outgoing calls.)

  3. Go to "Phone Numbers" > (click on number) > "Edit Settings", and add the connector/integration for the desired FreeSWITCH instance.

  The config files seem to play little role here for TR2 at the moment, but will dive into them just in case.

  ---

  QUESTION: Started looking at the API, and was wondering if a FreeSWITCH instance is necessary at all? Could it be recreated in JavaScript/TypeScript, and just done with it?

  ---

  QUESTION: How to send texts? Would probably be a good thing for authentication purposes later on.

  ---

