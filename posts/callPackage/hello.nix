# hello.nix
{
  stdenv,
  fetchzip,
  name ? "name_orig_2024_08_13"
}:

stdenv.mkDerivation {
  pname = name;
  version = "2.12.1";

  src = fetchzip {
    url = "https://ftp.gnu.org/gnu/hello/hello-2.12.1.tar.gz";
    sha256 = "";
  };
}
