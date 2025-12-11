{
  pname,
  version,
  src,
  meta,
  binaryName,
  desktopName,
  self,
  buildFHSEnv,
  makeDesktopItem,
  lib,
  stdenv,
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
  writeScript,
  pipewire,
  libxkbcommon,
  mesa,
  python3,
  runCommand,
  libunity,
  speechd-minimal,
  wayland,
  branch,
  withOpenASAR ? false,
  openasar,
  withVencord ? false,
  vencord,
  withEquicord ? false,
  equicord,
  withMoonlight ? false,
  moonlight,
  withTTS ? true,
  enableAutoscroll ? false,
  # Disabling this would normally break Discord.
  # The intended use-case for this is when SKIP_HOST_UPDATE is enabled via other means,
  # for example if a settings.json is linked declaratively (e.g., with home-manager).
  disableUpdates ? true,
  # Make disabling the Chromium sandbox opt-in; recent Electron no longer needs this.
  disableChromiumSandbox ? false,
  commandLineArgs ? "",
}:

let
  discordMods = [
    withVencord
    withEquicord
    withMoonlight
  ];
  enabledDiscordModsCount = builtins.length (lib.filter (x: x) discordMods);

  disableBreakingUpdates =
    runCommand "disable-breaking-updates.py"
      {
        pythonInterpreter = "${python3.interpreter}";
        configDirName = lib.toLower binaryName;
        meta.mainProgram = "disable-breaking-updates.py";
      }
      ''
        mkdir -p $out/bin
        cp ${./disable-breaking-updates.py} $out/bin/disable-breaking-updates.py
        substituteAllInPlace $out/bin/disable-breaking-updates.py
        chmod +x $out/bin/disable-breaking-updates.py
      '';

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

      mkdir -p $out/opt/${binaryName}
      cp -a ./. $out/opt/${binaryName}
      cd $out/opt/${binaryName}

      ${lib.optionalString withOpenASAR ''
        cp -f ${openasar} resources/app.asar
      ''}
      ${lib.optionalString withVencord ''
        mv resources/app.asar resources/_app.asar
        mkdir resources/app.asar
        echo '{"name":"discord","main":"index.js"}' > resources/app.asar/package.json
        echo 'require("${vencord}/patcher.js")' > resources/app.asar/index.js
      ''}
      ${lib.optionalString withEquicord ''
        mv resources/app.asar resources/_app.asar
        mkdir resources/app.asar
        echo '{"name":"discord","main":"index.js"}' > resources/app.asar/package.json
        echo 'require("${equicord}/desktop/patcher.js")' > resources/app.asar/index.js
      ''}
      ${lib.optionalString withMoonlight ''
        mv resources/app.asar resources/_app.asar
        mkdir resources/app
        echo '{"name":"discord","main":"injector.js","private": true}' > resources/app/package.json
        echo 'require("${moonlight}/injector.js").inject(require("path").join(__dirname, "../_app.asar"));' > resources/app/injector.js
      ''}

      runHook postInstall
    '';
  };

  fhsEnv = buildFHSEnv {
    name = "${pname}-fhs";

    targetPkgs =
      pkgs:
      [
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
      ]
      ++ lib.optionals withTTS [ speechd-minimal ];

    multiPkgs = pkgs: [
      alsa-lib
      libpulseaudio
    ];

    runScript = writeScript "${pname}-wrapper" ''
      #!${stdenv.shell}
      set -euo pipefail

      ${lib.optionalString disableUpdates ''
        ${lib.getExe disableBreakingUpdates}
      ''}

      if [[ -n "''${XDG_DATA_DIRS:-}" ]]; then
        export XDG_DATA_DIRS="${gtk3}/share/gsettings-schemas/${gtk3.name}/:''${XDG_DATA_DIRS}"
      else
        export XDG_DATA_DIRS="${gtk3}/share/gsettings-schemas/${gtk3.name}/"
      fi

      extraArgs=()
      if [[ -n "''${NIXOS_OZONE_WL:-}" && -n "''${WAYLAND_DISPLAY:-}" ]]; then
        extraArgs+=(--ozone-platform=wayland --enable-features=WaylandWindowDecorations --enable-wayland-ime=true)
      fi

      ${lib.optionalString enableAutoscroll ''
        extraArgs+=(--enable-blink-features=MiddleClickAutoscroll)
      ''}

      ${lib.optionalString disableChromiumSandbox ''
        extraArgs+=(--no-sandbox --disable-gpu-sandbox)
      ''}

      ${lib.optionalString withTTS ''
        if [[ "''${NIXOS_SPEECH:-default}" != "False" ]]; then
          export NIXOS_SPEECH=True
          extraArgs+=(--enable-speech-dispatcher)
        else
          unset NIXOS_SPEECH
        fi
      ''}

      cmd=(
        ${discordDir}/opt/${binaryName}/${binaryName}
      )
      cmd+=("''${extraArgs[@]}")
      ${lib.optionalString (commandLineArgs != "") ''
        cmd+=(${lib.escapeShellArg commandLineArgs})
      ''}

      exec "''${cmd[@]}" "$@"
    '';
  };

  desktopItem = makeDesktopItem {
    name = pname;
    exec = binaryName;
    icon = pname;
    inherit desktopName;
    genericName = meta.description;
    categories = [
      "Network"
      "InstantMessaging"
    ];
    mimeTypes = [ "x-scheme-handler/discord" ];
    startupWMClass = "discord";
  };
in
assert lib.assertMsg (
  enabledDiscordModsCount <= 1
) "discord: Only one of Vencord, Equicord or Moonlight can be enabled at the same time";
stdenv.mkDerivation {
  inherit
    pname
    version
    meta
    ;

  dontUnpack = true;
  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mkdir -p $out/share/applications
    mkdir -p $out/share/pixmaps
    mkdir -p $out/share/icons/hicolor/256x256/apps

    ln -s ${fhsEnv}/bin/${pname}-fhs $out/bin/${binaryName}
    # Without || true the install would fail on case-insensitive filesystems
    ln -s ${fhsEnv}/bin/${pname}-fhs $out/bin/${lib.strings.toLower binaryName} || true

    ln -s ${discordDir}/opt/${binaryName}/discord.png $out/share/pixmaps/${pname}.png
    ln -s ${discordDir}/opt/${binaryName}/discord.png $out/share/icons/hicolor/256x256/apps/${pname}.png

    ln -s ${desktopItem}/share/applications/${pname}.desktop $out/share/applications/

    runHook postInstall
  '';

  passthru = {
    # make it possible to run disableBreakingUpdates standalone
    inherit disableBreakingUpdates;
    updateScript = ./update.py;

    tests = {
      withVencord = self.override {
        withVencord = true;
      };
      withEquicord = self.override {
        withEquicord = true;
      };
      withMoonlight = self.override {
        withMoonlight = true;
      };
      withOpenASAR = self.override {
        withOpenASAR = true;
      };
    };
  };
}
