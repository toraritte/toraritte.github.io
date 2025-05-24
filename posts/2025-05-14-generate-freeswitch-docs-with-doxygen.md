# How to generate documentation for the FreeSWITCH source code with Doxygen

## 1. "Install" Doxygen

```
nix-shell -I nixpkgs=https://github.com/NixOS/nixpkgs/archive/865c1cb0e921c173e88be7d4cddaee651b79bbfe.tar.gz -p doxygen graphviz
```

+ `graphviz` is needed to generate the graph-related content (this is also noted in the `Doxyfile` snippet below).

+ The timestamp of the above Nixpkgs commit is `2025-05-15T00:46:48.000Z`.

   > NOTE  
   > Keep forgetting this post about [how to pin packages with `nix-shell`](https://unix.stackexchange.com/questions/741682/how-to-pin-a-package-version-with-nix-shell).

## 2. Generate and then tweak the Doxygen configuration

   > NOTE  
   > The end result will (or should) be this [Doxyfile](./2025-05-14-generate-freeswitch-docs-with-doxygen/Doxyfile). Was thinking about including the results in this repo, but the size of the generated output was 1.6 GB...

1. Enter the FreeSWITCH directory

2. Generate the configuration

   ```
   doxygen -g
   ```

3. Plug in the following values:

   ```
   PROJECT_NAME = FreeSWITCH

   # This may already be a long list, but
   # make sure  that these are definitely
   # listed:
   FILE_PATTERNS = *.c *.h

   INPUT =
   OUTPUT_DIRECTORY = ../<your-dir>

   RECURSIVE = YES
   EXTRACT_ALL = YES
   EXTRACT_PRIVATE = YES
   EXTRACT_STATIC = YES
   SOURCE_BROWSER = YES
   GENERATE_HTML = YES
   GENERATE_LATEX = NO
   GENERATE_XML = NO
   ```

   Leaving [`INPUT`][2] empty means to scan the current directory (i.e., the [FreeSWITCH repo][1]'s root). `src` holds the main code, but `libs` has all the supporting data structures and functions FreeSWITCH is built on.

   It is recommended to set [`OUTPUT_DIRECTORY`][3] somewhere outside the [FreeSWITCH repo][1], because code editors such as VS Code can start scanning it and might even crash (just the generated graphs alone are around 70,000).

   Here is the [reference documentation of the Doxygen configuration options][4].

[1]: https://github.com/signalwire/freeswitch
[2]: https://www.doxygen.nl/manual/config.html#cfg_input
[3]: https://www.doxygen.nl/manual/config.html#cfg_output_directory
[4]: https://www.doxygen.nl/manual/config.html

## 3. Run Doxygen

```
doxygen Doxyfile
```

Finally, open the generated docs:

```
open html/index.html
```
