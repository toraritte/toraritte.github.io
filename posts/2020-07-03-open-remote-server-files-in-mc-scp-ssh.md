# [`scp`, `ssh`] Open remote machine's files in Midnight Commander (MC) and Vim

## 0. `ssh-agent` and `ssh-add`

Got into the habit of adding a passphrase to private
keys,  so `ssh`  commands  will keep  asking for  it
every time.
[`ssh-agent`](https://www.ssh.com/ssh/agent)
solves this problem.

## 1. Midnight Commander

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

## Current workflow

1. Open `tmux`

2. `cd` to project

3. `ssh-agent vim -S Session.vim`

4. In Vim, `:!ssh-add`

At this  point, either `:vert term`,  open `mc`, and
follow  section 1,  or  follow  section2. No  matter
which method  is used,  `ssh-agent` makes  sure that
passphrase popups won't interrupt.
