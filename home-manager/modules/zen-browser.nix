{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

let
  cfg = config.programs.zen-browser;

  mkEngine =
    {
      name,
      alias,
      url,
    }:
    {
      name = name;
      urls = [
        {
          template = url;
        }
      ];
      definedAliases = [ alias ];
    };
in
{
  imports = [
    inputs.zen-browser.homeModules.twilight
  ];

  config = lib.mkIf cfg.enable {
    programs.zen-browser = {
      policies = {
        DisableAppUpdate = true;

        DisableFirefoxAccounts = true;
        DisableFirefoxScreenshots = true;
        DisableFirefoxStudies = true;
        DisableTelemetry = true;
        DisablePocket = true;

        DisableProfileImport = true;

        DisableSetDesktopBackground = true;
        NoDefaultBookmarks = false;

        DontCheckDefaultBrowser = true;

        HardwareAcceleration = true;

        HttpsOnlyMode = "force_enabled";

        ShowHomeButton = false;
        Homepage = {
          URL = "chrome://browser/content/blanktab.html";
          StartPage = "previous-session";
          Locked = true;
        };
        NewTabPage = false;

        AutofillAddressEnabled = false;
        AutofillCreditCardEnabled = false;

        DisableMasterPasswordCreation = true;
        OfferToSaveLogins = false;
        PasswordManagerEnabled = false;
        PrimaryPassword = false;
      };
      profiles.default = {
        preConfig = builtins.readFile "${inputs.betterfox.outPath}/zen/user.js";

        bookmarks = {
          settings = [
            {
              name = "ISEN";
              bookmarks = [
                {
                  name = "Moodle";
                  url = "https://web.isen-ouest.fr/moodle4";
                }
                {
                  name = "Aurion";
                  url = "https://web.isen-ouest.fr/webAurion";
                }
              ];
            }
            {
              name = "Filesystem Hierarchy Standard";
              url = "https://www.pathname.com/fhs/pub/fhs-2.3.html";
            }
            {
              name = "Open Source Guides";
              url = "https://opensource.guide/best-practices";
            }
            {
              name = "Gaming";
              bookmarks = [
                {
                  name = "Warframe";
                  bookmarks = [
                    {
                      name = "Warframe Wiki";
                      url = "https://wiki.warframe.com";
                    }
                    {
                      name = "Warframe Market";
                      url = "https://warframe.market";
                    }
                    {
                      name = "Overframe";
                      url = "https://overframe.gg";
                    }
                    {
                      name = "Warframe Droptables";
                      url = "https://www.warframe.com/droptables";
                    }
                  ];
                }
                {
                  name = "Minecraft";
                  bookmarks = [
                    {
                      name = "Minecraft Wiki";
                      url = "https://minecraft.wiki";
                    }
                    {
                      name = "Curseforge Minecraft";
                      url = "https://www.curseforge.com/minecraft";
                    }
                    {
                      name = "Modrinth";
                      url = "https://modrinth.com";
                    }
                    {
                      name = "Modpack Index";
                      url = "https://www.modpackindex.com";
                    }
                  ];
                }
                {
                  name = "AllKeyShop";
                  url = "https://www.allkeyshop.com";
                }
              ];
            }
            {
              name = "Server";
              bookmarks = [
                {
                  name = "Ente";
                  url = "https://ente.melois.dev";
                }
                {
                  name = "Syncthing";
                  url = "https://sync.melois.dev";
                }
              ];
            }
            {
              name = "Cloud";
              bookmarks = [
                {
                  name = "OVH";
                  url = "https://www.ovh.com";
                }
                {
                  name = "Cloudflare";
                  url = "https://dash.cloudflare.com";
                }
                {
                  name = "Clever Cloud";
                  url = "https://console.clever-cloud.com";
                }
                {
                  name = "Clever Cloud Par0";
                  url = "https://console.par0.clvrcld.net";
                }
              ];
            }
            {
              name = "iLovePDF";
              url = "https://www.ilovepdf.com";
            }
            {
              name = "Torrenting";
              url = "https://rentry.co/megathread";
            }
            {
              name = "WebAssembly";
              bookmarks = [
                {
                  name = "WIT format";
                  url = "https://github.com/WebAssembly/component-model/blob/main/design/mvp/WIT.md";
                }
                {
                  name = "WebAssembly Component Model";
                  url = "https://component-model.bytecodealliance.org";
                }
              ];
            }
            {
              name = "Nix";
              bookmarks = [
                {
                  name = "Home Manager configuration options";
                  url = "https://nix-community.github.io/home-manager/options.xhtml";
                }
                {
                  name = "NixOS configuration options";
                  url = "https://nixos.org/manual/nixos/stable/options.html";
                }
                {
                  name = "Nix package versions";
                  url = "https://lazamar.co.uk/nix-versions/";
                }
              ];
            }
            {
              name = "eDocPerso";
              url = "https://v2-app.edocperso.fr";
            }
            {
              name = "On dit chiffrer, et pas crypter";
              url = "https://chiffrer.info";
            }
            {
              name = "On dit le Wi-Fi, et pas la Wi-Fi";
              url = "https://lewifi.fr";
            }
          ];
          force = true;
        };

        extensions = {
          packages = with pkgs.nur.repos.rycee.firefox-addons; [
            buster-captcha-solver
            darkreader
            fastforwardteam
            onepassword-password-manager
            redirector
            refined-github
            sponsorblock
            ublock-origin
            violentmonkey
            wayback-machine
          ];
          force = true;
        };

        search = {
          default = "ddg";
          privateDefault = "ddg";
          engines = {
            rust-docs = mkEngine {
              name = "rust-docs";
              alias = "!rs";
              url = "https://doc.rust-lang.org/stable/std/index.html?search={searchTerms}";
            };
            docs-rs = mkEngine {
              name = "docs.rs";
              alias = "!dr";
              url = "https://docs.rs/releases/search?query={searchTerms}";
            };
            crates-io = mkEngine {
              name = "crates.io";
              alias = "!cr";
              url = "https://crates.io/search?q={searchTerms}";
            };
            nix-packages = mkEngine {
              name = "Nix Packages";
              alias = "!np";
              url = "https://search.nixos.org/packages?type=packages&query={searchTerms}";
            };
            nixos-wiki = mkEngine {
              name = "NixOS Wiki";
              alias = "!nw";
              url = "https://wiki.nixos.org/w/index.php?search={searchTerms}";
            };
          };
          force = true;
        };

        settings = {
          "browser.urlbar.suggest.clipboard" = false;
          "extensions.autoDisableScopes" = 0;

          "zen.welcome-screen.seen" = true;
          "zen.glance.enabled" = false;

          "zen.mods.auto-update" = false;
          "zen.themes.disable-all" = true;

          "zen.urlbar.behavior" = "normal";

          "zen.view.use-single-toolbar" = false;
          "zen.view.sidebar-expanded" = true;

          "zen.view.show-newtab-vertical" = true;
          "zen.view.show-newtab-button-border-top" = false;
          "zen.view.show-newtab-button-top" = true;

          "zen.view.compact.hide-tabbar" = true;
          "zen.view.compact.hide-toolbar" = false;
          "zen.view.compact.toolbar-flash-popup" = false;
          "zen.view.compact.color-toolbar" = true;
          "zen.view.compact.color-sidebar" = true;
        };
      };
    };
  };
}
