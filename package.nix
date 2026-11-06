# E8 as its release builds it: `e8` and `e8-mcp` in bin, and on macOS E8.app
# in Applications, where nix-darwin and home-manager link it for Spotlight.
{ lib, stdenv, fetchurl, autoPatchelfHook, version, assets }:

stdenv.mkDerivation {
  pname = "e8";
  inherit version;

  src = fetchurl assets.cli;

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];
  # libgcc_s; libc and libm come with the interpreter autoPatchelfHook sets.
  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [ stdenv.cc.cc.lib ];

  dontConfigure = true;
  dontBuild = true;
  # The macOS binaries and the app are signed; stripping would break that.
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 e8 e8-mcp -t $out/bin
  '' + lib.optionalString (assets ? app) ''
    mkdir -p $out/Applications
    tar -xzf ${fetchurl assets.app} -C $out/Applications
  '' + ''
    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    [ "$(HOME=$TMPDIR E8_CONFIG_DIR=$TMPDIR/e8 $out/bin/e8 --batch --eval 'e8.message(e8.variable("e8-version"))' 2>&1)" = ${version} ]
  '';

  meta = {
    description = "An editor that works the way Emacs works, in Rust and TypeScript";
    homepage = "https://github.com/e8-editor/e8";
    license = lib.licenses.gpl3Plus;
    mainProgram = "e8";
    platforms = [ "aarch64-darwin" "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
