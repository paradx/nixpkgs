{
  lib,
  stdenvNoCC,
  fetchurl,
  dpkg,
  makeWrapper,
  electron,
  asar,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "proton-pass";
  version = "1.23.1";

  src = fetchurl {
    url = "https://proton.me/download/pass/linux/x64/proton-pass_${finalAttrs.version}_amd64.deb";
    hash = "sha256-D4OFHL9AS8oAwMZHoXaDpHKfMBQEaOd18eWAwVW4EJA=";
  };

  dontConfigure = true;
  dontBuild = true;

  nativeBuildInputs = [
    dpkg
    makeWrapper
    asar
  ];

  # Rebuild the ASAR archive with the assets embedded
  preInstall = ''
    asar extract usr/lib/proton-pass/resources/app.asar tmp
    cp -r usr/lib/proton-pass/resources/assets/ tmp/
    rm usr/lib/proton-pass/resources/app.asar
    asar pack tmp/ usr/lib/proton-pass/resources/app.asar
    rm -fr tmp
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/proton-pass
    cp -r usr/share/ $out/
    cp -r usr/lib/proton-pass/resources/app.asar $out/share/proton-pass/
    runHook postInstall
  '';

  preFixup = ''
    makeWrapper ${lib.getExe electron} $out/bin/proton-pass \
      --add-flags $out/share/proton-pass/app.asar \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}" \
      --set-default ELECTRON_IS_DEV 0 \
      --inherit-argv0
  '';

  meta = {
    description = "Desktop application for Proton Pass";
    homepage = "https://proton.me/pass";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [
      luftmensch-luftmensch
      massimogengarelli
      sebtm
    ];
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    mainProgram = "proton-pass";
  };
})
