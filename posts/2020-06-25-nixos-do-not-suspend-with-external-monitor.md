# [Linux/NixOS systemd-logind] Don't suspend/sleep laptop on lid closure when external monitor is connected

`systemd`'s login manager (
[`logind`](https://www.freedesktop.org/software/systemd/man/systemd-logind.service.html)
) is responsible for this, and it can be  configured
via the
[`HandleLidSwitchDocked`](#https://www.freedesktop.org/software/systemd/man/logind.conf.htmlHandlePowerKey=)
option in
[`logind.conf`](https://www.freedesktop.org/software/systemd/man/logind.conf.html)
 (see also `man 5 logind.conf`).

## NixOS

From the available [NixOS `logind` options](https://nixos.org/nixos/options.html#services.logind) using [`services.logind.lidSwitchDocked`](https://nixos.org/nixos/options.html#services.logind.lidswitchdocked) in `/etc/nixos/configuration.nix` (see [NixOS manual](https://nixos.org/nixos/manual/)):

```nix
# /etc/nixos/configuration.nix
# ...
services.logind.lidSwitchDocked = "ignore";
# ...
```

(But this is the default, so this will just make it explicit.)

## Other Linux distributions

[`logind.conf`](https://www.freedesktop.org/software/systemd/man/logind.conf.html)
usually resides in `/etc/systemd/logind.conf` and just add the following line:

```text
[Login]
# ...
HandleLidSwitchDocked=ignore
```
