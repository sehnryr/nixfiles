{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage rec {
  pname = "pi-web";
  version = "0.8.8";

  src = fetchFromGitHub {
    owner = "agegr";
    repo = "pi-web";
    rev = "v${version}";
    hash = "sha256-wPNgxImAmy16IGrxt0uCD53RQU8388z/6Sh7ipnG0Qc=";
  };

  # npm's bundled dependencies intentionally omit resolved/integrity fields,
  # but fetchNpmDeps currently attempts to parse them as standalone packages.
  patches = [ ./pi-web-lock.patch ];

  postPatch = ''
    substituteInPlace app/layout.tsx \
      --replace-fail 'import { Noto_Sans_Mono } from "next/font/google";' "" \
      --replace-fail 'const notoSansMono = Noto_Sans_Mono({' 'const notoSansMono = ({' \
      --replace-fail 'className={`''${notoSansMono.variable} notranslate`}' 'className="notranslate"'
  '';

  npmDepsHash = "sha256-e/8Rh+k3jYO8NGH0caOyrNBh4mXUElXjUW8BcHqFXOE=";
  npmDepsFetcherVersion = 2;
  npmFlags = [ "--legacy-peer-deps" ];

  meta = {
    description = "Web UI for the pi coding agent";
    homepage = "https://github.com/agegr/pi-web";
    license = lib.licenses.mit;
    mainProgram = "pi-web";
  };
}
