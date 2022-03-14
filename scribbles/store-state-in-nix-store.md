Nix solves the issue of reproducible builds and it can also be used to set up a fresh machine, but if I want to carry over all my data and sync them, I will need to install other tools (e.g., syncthing, rclone, etc.).

The Nix store can hold any kinds of data (see NixOS discourse thread [What are interesting, unique, and/or non-standard uses of Nix?](https://discourse.nixos.org/t/what-are-interesting-unique-and-or-non-standard-uses-of-nix/12977)), so why not user data (i.e., state)?

Was thinking along the lines of event sourcing over an "immutable" store, the Nix store; using quotes because it is not truly immutable, otherwise one couldn't do garbage collection (which comes in handy because one also wouldn't keep all state changes to their data anyway). Event sourcing uses **projection**s to show the model of the accumulated events (to put it in a sloppy way) so in this case (i.e., Nix store with data snippets/events), the latest/main projection would always be total sum of all data "shards" in the Nix store.

## Issues

* Enable **data garbage collection**: deleted files will keep taking up space in the Nix store; helpful if one wants to restore them at one point, but some files need to stay deleted. (*How?* "Compress down" to the current main projection, and keep the shards in the Nix store that are still referenced. Sounds simple but pretty sure it's not.)

* Add option to **exclude data/state at install**: E.g., need to setup a new laptop/VM/etc. with the same settings for testing so data will be unnecessary and will just prolong installation.

* (personal) What data to include? Would be nice to carry around all my music, books, etc. but even though storage gets cheaper and cheaper, I'm still not there financially.

* **secrets**
