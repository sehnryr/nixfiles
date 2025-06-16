{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

let
  cfg = config.modules.zen-browser;
in
{
  imports = [
    inputs.zen-browser.homeModules.twilight
  ];

  options.modules.zen-browser = {
    enable = lib.mkEnableOption "enable zen-browser";
  };

  config = lib.mkIf cfg.enable {
    programs.zen-browser = {
      enable = true;
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

        DNSOverHTTPS = {
          Enabled = true;
          ProviderURL = "https://security.cloudflare-dns.com/dns-query";
          Fallback = false;
          Locked = true;
        };

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
              name = "Syncthing";
              url = "http://127.0.0.1:8384";
            }
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
                  name = "CapRover";
                  url = "https://captain.beta.melois.dev";
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
        search = {
          default = "ddg";
          privateDefault = "ddg";
          engines = {
            nix-packages = {
              name = "Nix Packages";
              urls = [
                {
                  template = "https://search.nixos.org/packages";
                  params = [
                    {
                      name = "type";
                      value = "packages";
                    }
                    {
                      name = "query";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];
              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "@np" ];
            };
            nixos-wiki = {
              name = "NixOS Wiki";
              urls = [
                {
                  template = "https://wiki.nixos.org/w/index.php";
                  params = [
                    {
                      name = "search";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];
              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "@nw" ];
            };
          };
          force = true;
        };
        settings = {
          "browser.urlbar.suggest.clipboard" = false;
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
