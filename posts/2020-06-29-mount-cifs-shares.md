# Mount CIFS shares from the terminal

## Ubuntu

Forget what package(s) needed to be installed but this is the command:

```text
$ sudo mount -t cifs -o username=<your-username> //<server>/<share> /mnt/<your-dir>
#      ^^^^^^^^^^^^^
```

## NixOS

After installing the `cifs-utils` package:

```text
#    VVVVVVVVVV
sudo mount.cifs -o username=<your-username> //<server>/<share> /run/mount/<your-dir>
```
