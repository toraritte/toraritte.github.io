# [Ubuntu, NixOS] Resize the `/run` directory (and temporarily increase swap size)

A  Nix  custom image  build  kept  failing with  the
message `No space left  on device` on Ubuntu 18.04.4
LTS,  and was  able to  track it  down using  `watch
-n  -1  "df  -h"`   while  running  the  build.  The
culprit  ended up  being a  `/run` mountpoint  (more
specifically, `/run/user/1000`) and, indirectly, the
swap space.

This is how it looked like before:

``` text
Filesystem                   Size  Used Avail Use% Mounted on
...
tmpfs                        785M   28K  785M   1% /run/user/1000
...
```
The sections  below do not go  how I chronologically
figured things  out, but how  I wish I  had stumbled
upon things.

> On NixOS, instead of the steps below, the process would have been simply
>
> 1.   to   edit   the   `services.logind.extraConfig`
> attribute in `/etc/nixos/configuration.nix`:
>
> ```nix
>   services.logind.extraConfig = ''
>     RuntimeDirectorySize=12G
>     HandleLidSwitchDocked=ignore
>   '';
> ```
>
> 2. Rebuild configuration (e.g., with `sudo nixos-rebuild switch`).
>
> More info:
> + https://nixos.org/nixos/options.html#services.logind.extraconfig
> + https://releases.nixos.org/nix-dev/2015-July/017657.html

## 1. What is `/run`? <sup>(Baby don't hurt me)</sup>

[This](https://lwn.net/Articles/436012/)
is the authoriative answer, but
[this Quora answer](https://www.quora.com/What-is-the-significance-of-the-run-directory-in-Linux)
sums it up:

> `/run` is the "early bird" equivalent to `/var/run`,
> in  that it's  meant for  system daemons  that start
> very  early  on  (e.g.   `systemd`  and  `udev`)  to
> store  temporary runtime  files like  PID files  and
> communication  socket  endpoints,  while  `/var/run`
> would be used by  late-starting daemons (e.g. `sshd`
> and Apache).
>
> Traditional  `/var/run` was  an actual  directory on
> disk, which meant the  underlying filesystem may not
> have  been  mounted at  the  point  `systemd` et  al
> needed  to  write stuff  into  it.  Making `/run`  a
> tmpfs (i.e. RAM-based) filesystem neatly solved this
> problem and  eliminated the need  to clean it  up on
> the next boot.
>
> Of  course, having  two runtime  scratch directories
> struck many as  being a bit much, so  in many modern
> Linux  distros,  `/var/run`  is just  a  symlink  to
> `/run`.

## 2. `tmpfs`

[kernel.org/doc/Documentation/filesystems/tmpfs.txt](https://www.kernel.org/doc/Documentation/filesystems/tmpfs.txt):

> Everything in  tmpfs is temporary in  the sense that
> no files will be created  on your hard drive. If you
> unmount a tmpfs  instance, everything stored therein
> is lost.
>
> tmpfs  puts  everything  into  the  kernel  internal
> caches  and grows  and  shrinks  to accommodate  the
> files it contains and is able to swap unneeded pages
> out to swap space. It  has maximum size limits which
> can be  adjusted on  the fly  via `mount  -o remount
> ...`

Also, "_tmpfs lives completely in the page cache and
on swap_".

<sup>(TODO:  Read  kernel  docs   more  often.  Heart  of
Darkness can wait.)</sup>

## 3. Resize `/run` mountpoints

According to the
[`tmpfs` documentation](https://www.kernel.org/doc/Documentation/filesystems/tmpfs.txt)
, "_`tmpfs` has three mount options for sizing"_ where
**size** is

> The  limit   of  allocated  bytes  for   this  tmpfs
> instance. The  default is half of  your physical RAM
> without swap.  If you oversize your  tmpfs instances
> the machine will deadlock since the OOM handler will
> not be able to free that memory.

That  is to  say, it  can be  set to  an arbitrarily
large size, but  make sure that there  is enough RAM
or  swap  space  (or combination thereof), so adjust
the latter if needed (see 4. below).

In my case,  I set it to 15 GB  for starters, and it
was enough.

```sh
sudo mount -o remount,size=15G,noatime /run/user/1000
```

## 4. Adjust swap space

### 4.1 Temporarily

Used [this Askubuntu answer](https://askubuntu.com/questions/178712/how-to-increase-swap-space/534090#534090) in the following way:

Check current swap:

```text
$ free -th
              total        used        free      shared  buff/cache   available
Mem:           7.7G        4.6G        253M        985M        2.8G        1.8G
Swap:          975M          0B        975M
Total:         8.6G        4.6G        1.2G

$ sudo swapon -s
Filename                                Type            Size    Used    Priority
/dev/dm-2                               partition       999420  3840    -2
```

Setting up the swap file, and turning it on:

```text
$ sudo touch /temp_swap_15G.img
$ sudo fallocate -l 15G /temp_swap_15G.img
$ sudo mkswap /temp_swap_15G.img

# `-p` is the priority; the default is -2 and anything
# higher will be used first
$ sudo swapon -p 27 /temp_swap_15G.img
```

Checking the results:

```text
$ sudo swapon -s
Filename                                Type            Size    Used    Priority
/dev/dm-2                               partition       999420  4352    -2
/temp_swap_15G.img                      file            15728636        0       27
```

### 4.2 Permanently

StackExchange answers (snapshots available on archive.org):

* https://askubuntu.com/questions/178712/how-to-increase-swap-space
* https://askubuntu.com/questions/226520/how-can-i-modify-the-size-of-swap-with-lvm-partitions

This is a troubleshooting one for the LVM one:
* https://serverfault.com/questions/733407/insufficient-free-space-x-extents-needed-but-only-y-available
