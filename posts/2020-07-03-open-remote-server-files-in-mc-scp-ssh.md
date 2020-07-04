# [`scp`, `ssh`] Open remote machine's files in Midnight Commander (MC) and Vim

## 0. `ssh-agent` and `ssh-add`

Got into the habit of adding a passphrase to private
keys,  so `ssh`  commands  will keep  asking for  it
every time.
[`ssh-agent`](https://www.ssh.com/ssh/agent)
solves this problem, and makes  sure that passphrase
popups won't interrupt.

## 1. Current workflow

1. Open `tmux`

2. `cd` to project

3. `ssh-agent vim -S Session.vim`

4. In Vim, `:!ssh-add`

5. Continue with either Vim or Midnight Commander (or both)

## 1. `scp` in `Midnight Commander

As of version 4.8.23:

 1. Open  either `Left` or  `Right`  on  the top  menu
(**press F9** if using mouse is not an option)

 2. Select `Shell link...`

 3. Type  in   the    connection   in    the   format
**`username@hostname`** (e.g., `lofa@1.2.3.4`)

Mostly taken from
[here](http://wiki.blue-panel.com/index.php/Midnight_Commander_(en)#SCP_Client)
. There is
[this question](https://unix.stackexchange.com/questions/12649/how-to-scp-in-mc-and-remember)
asking how to make this permanent.

## 2. Vim

Using

```text
:Lexplore scp://<server>/<path>
```

For example:
```text
:Lexplore scp://1.2.3.4//home/toraritte/clones/
```

The extra  `/` (instead of the  `:`) is **crucial**!
Type `:h  scp` for more  info (which is an  alias to
`:h netrw`).

Prefer using `Lexplore`  (see `:h Lexplore`) because
it gives the layout I prefer (i.e., a fixed vertical
file browser on the left).

## 2.1 Issues

Whenever I select a file  the Vim tab gets messed up
upon opening  (e.g., the file browser  split becomes
blank, the  opened file's  lines show up  funky), so
just  press  <kbd>CTRL</kbd>-<kbd>L</kbd> to  redraw
the screen (see `:h CTRL-L`).
