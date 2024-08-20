{
  __darwinAllowLocalNetworking = false;
  __ignoreNulls = true;
  __impureHostDeps = [
    "/bin/sh"
    "/usr/lib/libSystem.B.dylib"
    "/usr/lib/system/libunc.dylib"
    "/dev/zero"
    "/dev/random"
    "/dev/urandom"
    "/bin/sh"
  ];
  __propagatedImpureHostDeps = [ ];
  __propagatedSandboxProfile = [ "" ];
  __sandboxProfile = "";
  __structuredAttrs = false;
  all = <CODE>;
  args = [
    "-e"
    /nix/store/h8ankbqczm1wm84libmi3harjsddrcqx-nixpkgs/nixpkgs/pkgs/stdenv/generic/default-builder.sh
  ];
  buildInputs = [ ];
  builder = "/nix/store/ncw57j62jmhsi8l019anl1k8a13g0ykw-bash-5.2-p15/bin/bash";
  cmakeFlags = [ ];
  configureFlags = [ ];
  depsBuildBuild = [ ];
  depsBuildBuildPropagated = [ ];
  depsBuildTarget = [ ];
  depsBuildTargetPropagated = [ ];
  depsHostHost = [ ];
  depsHostHostPropagated = [ ];
  depsTargetTarget = [ ];
  depsTargetTargetPropagated = [ ];
  doCheck = false;
  doInstallCheck = false;
  drvAttrs = {
    # ...
  };
  drvPath = "/nix/store/riyf1584pvnbg1sw1j4rwrayvjz98q76-hello-2.12.1.drv";
  inputDerivation = <CODE>;
  mesonFlags = [ ];
  meta = <CODE>;
  name = "hello-2.12.1";
  nativeBuildInputs = [ ];
  out = <CODE>;
  outPath = <CODE>;
  outputName = "out";
  outputs = "";
  override = <CODE>;
  overrideAttrs = <CODE>;
  overrideDerivation = <CODE>;
  passthru = { };
  patches = [ ];
  pname = "hello";
  propagatedBuildInputs = [ ];
  propagatedNativeBuildInputs = [ ];
  src = "";
  stdenv = "";
  strictDeps = false;
  system = "aarch64-darwin";
  type = "derivation";
  userHook = null;
  version = "2.12.1";
}
# «derivation /nix/store/riyf1584pvnbg1sw1j4rwrayvjz98q76-hello-2.12.1.drv»
