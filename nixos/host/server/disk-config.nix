{ lib, ... }:

{
  disko.devices = {
    disk = {
      # Disko processes disks alphabetically. The last disk's btrfs partition
      # runs `mkfs.btrfs` and pulls in the earlier disk's partition (declared
      # without `content`) as a second RAID1 member.
      nvme0 = {
        device = lib.mkDefault "/dev/nvme0n1";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            esp = {
              name = "ESP";
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            swap = {
              size = "8G";
              content = {
                type = "swap";
                discardPolicy = "both";
              };
            };
            btrfs = {
              size = "100%";
              # No content: claimed by nvme1's mkfs.btrfs as a RAID1 member.
            };
          };
        };
      };
      nvme1 = {
        device = lib.mkDefault "/dev/nvme1n1";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            swap = {
              size = "8G";
              content = {
                type = "swap";
                discardPolicy = "both";
              };
            };
            btrfs = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [
                  "-L"
                  "nixos"
                  "-d"
                  "raid1"
                  "-m"
                  "raid1"
                  "-f"
                  "/dev/disk/by-partlabel/disk-nvme0-btrfs"
                ];
                subvolumes = {
                  "@" = {
                    mountpoint = "/";
                    mountOptions = [
                      "compress=zstd:3"
                      "noatime"
                    ];
                  };
                  "@home" = {
                    mountpoint = "/home";
                    mountOptions = [
                      "compress=zstd:3"
                      "noatime"
                    ];
                  };
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = [
                      "noatime"
                    ];
                  };
                  "@var-log" = {
                    mountpoint = "/var/log";
                    mountOptions = [
                      "compress=zstd:3"
                      "noatime"
                    ];
                  };
                  "@srv" = {
                    mountpoint = "/srv";
                    mountOptions = [
                      "compress=zstd:3"
                      "noatime"
                    ];
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
