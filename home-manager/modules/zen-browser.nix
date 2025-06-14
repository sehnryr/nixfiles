{
  config,
  pkgs,
  lib,
  inputs,
  user,
  ...
}:

let
  cfg = config.modules.zen-browser;
in
{
  imports = [
    inputs.zen-browser.homeModules.default
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

        DisableProfileImport = true;

        DisableSetDesktopBackground = true;
        NoDefaultBookmarks = true;

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
      profiles.${user.name} = {
        preConfig = builtins.readFile "${inputs.betterfox.outPath}/zen/user.js";

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
          browser.urlbar.suggest.clipboard = false;
          zen = {
            welcome-screen.seen = true;
            glance.enabled = false;

            mods.auto-update = false;
            themes.disable-all = true;

            urlbar.behavior = "normal";

            view = {
              use-single-toolbar = false;
              sidebar-expanded = true;

              show-newtab-vertical = true;
              show-newtab-button-border-top = false;
              show-newtab-button-top = true;

              compact = {
                hide-tabbar = true;
                hide-toolbar = false;
                toolbar-flash-popup = false;
                color-toolbar = true;
                color-sidebar = true;
              };
            };
          };
        };
      };
    };
  };
}
