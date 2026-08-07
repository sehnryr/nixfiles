{
  lib,
  stdenv,
  fetchurl,
  buildFHSEnv,
  makeDesktopItem,
  writeScript,
  writers,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  cairo,
  cups,
  dbus,
  expat,
  fontconfig,
  freetype,
  gdk-pixbuf,
  glib,
  gtk3,
  libcxx,
  glibc,
  libdrm,
  libglvnd,
  libnotify,
  libpulseaudio,
  libuuid,
  libva,
  libX11,
  libXScrnSaver,
  libXcomposite,
  libXcursor,
  libXdamage,
  libXext,
  libXfixes,
  libXi,
  libXrandr,
  libXrender,
  libXtst,
  libxcb,
  libxshmfence,
  libgbm,
  nspr,
  nss,
  pango,
  systemdLibs,
  libappindicator-gtk3,
  libdbusmenu,
  pipewire,
  libxkbcommon,
  mesa,
  libunity,
  speechd-minimal,
  wayland,
}:

let
  pname = "discord";
  version = "1.0.152";

  src = fetchurl {
    url = "https://stable.dl2.discordapp.net/apps/linux/${version}/discord-${version}.tar.gz";
    hash = "sha256-xB5/UORKDJo9CCLcM6F4XYBdUTIjJuDqPg7Vss/jjpM=";
  };

  disableBreakingUpdates = writers.writePython3Bin "disable-breaking-updates" {
    flakeIgnore = [ "E501" ];
  } (builtins.readFile ./disable-breaking-updates.py);

  discordDir = stdenv.mkDerivation {
    name = "${pname}-${version}-dir";
    inherit src;

    dontPatchELF = true;
    dontStrip = true;
    dontPatchShebangs = true;
    dontBuild = true;
    dontConfigure = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out/opt/discord
      cp -a ./. $out/opt/discord
      runHook postInstall
    '';
  };

  fhsEnv = buildFHSEnv {
    name = "${pname}-fhs";

    targetPkgs = _: [
      libcxx
      glibc
      systemdLibs
      libpulseaudio
      libdrm
      libgbm
      stdenv.cc.cc.lib
      alsa-lib
      atk
      at-spi2-atk
      at-spi2-core
      cairo
      cups
      dbus
      expat
      fontconfig
      freetype
      gdk-pixbuf
      glib
      gtk3
      libglvnd
      libnotify
      libX11
      libXcomposite
      libXcursor
      libXdamage
      libXext
      libXfixes
      libXi
      libXrandr
      libXrender
      libXtst
      libXScrnSaver
      libxcb
      libxshmfence
      libuuid
      libva
      nspr
      nss
      pango
      pipewire
      libxkbcommon
      mesa
      libappindicator-gtk3
      libdbusmenu
      libunity
      wayland
      speechd-minimal
    ];

    multiPkgs = _: [
      alsa-lib
      libpulseaudio
    ];

    runScript = writeScript "${pname}-wrapper" ''
      #!${stdenv.shell}
      set -euo pipefail

      ${lib.getExe disableBreakingUpdates}

      export XDG_DATA_DIRS="${gtk3}/share/gsettings-schemas/${gtk3.name}/''${XDG_DATA_DIRS:+:$XDG_DATA_DIRS}"

      extraArgs=()
      if [[ -n "''${NIXOS_OZONE_WL:-}" && -n "''${WAYLAND_DISPLAY:-}" ]]; then
        extraArgs+=(--ozone-platform=wayland --enable-features=WaylandWindowDecorations --enable-wayland-ime=true)
      fi

      if [[ "''${NIXOS_SPEECH:-default}" != "False" ]]; then
        export NIXOS_SPEECH=True
        extraArgs+=(--enable-speech-dispatcher)
      else
        unset NIXOS_SPEECH
      fi

      exec ${discordDir}/opt/discord/discord "''${extraArgs[@]}" "$@"
    '';
  };

  desktopItem = makeDesktopItem {
    name = pname;
    exec = "discord";
    icon = pname;
    desktopName = "Discord";
    genericName = "All-in-one cross-platform voice and text chat for gamers";
    categories = [
      "Network"
      "InstantMessaging"
    ];
    mimeTypes = [ "x-scheme-handler/discord" ];
    startupWMClass = "discord";
  };
in
stdenv.mkDerivation {
  inherit pname version;

  dontUnpack = true;
  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/applications $out/share/pixmaps $out/share/icons/hicolor/256x256/apps

    ln -s ${fhsEnv}/bin/${pname}-fhs $out/bin/discord
    ln -s ${discordDir}/opt/discord/discord.png $out/share/pixmaps/discord.png
    ln -s ${discordDir}/opt/discord/discord.png $out/share/icons/hicolor/256x256/apps/discord.png
    ln -s ${desktopItem}/share/applications/${pname}.desktop $out/share/applications/

    runHook postInstall
  '';

  meta = {
    description = "All-in-one cross-platform voice and text chat for gamers";
    homepage = "https://discordapp.com/";
    license = lib.licenses.unfree;
    mainProgram = "discord";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
