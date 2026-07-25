{inputs, lib, ...}@top: let
  recordType = lib.types.submodule {
    options = {
      name = lib.mkOption {
        type = lib.types.str;
        description = "DNS name (or @ for zone apex).";
      };
      type = lib.mkOption {
        type = lib.types.enum [
          "A" "AAAA" "CNAME" "MX" "TXT" "NS" "CAA"
          "SRV" "SVCB" "HTTPS" "PTR" "TLSA" "SSHFP"
        ];
      };
      content = lib.mkOption {
        type = lib.types.str;
      };
      ttl = lib.mkOption {
        type = lib.types.int;
        default = 1;  # 1 = auto; required when proxied
      };
      proxied = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
      priority = lib.mkOption {
        type = lib.types.nullOr lib.types.int;
        default = null;
        description = "Required for MX, SRV, URI.";
      };
      comment = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
      };
      tags = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
      };
    };
  };

  zoneType = lib.types.submodule ({ name, ... }: {
    options = {
      zoneId = lib.mkOption {
        type = lib.types.str;
        description = "Cloudflare zone ID for ${name}.";
      };
      records = lib.mkOption {
        type = lib.types.attrsOf recordType;
        default = { };
        description = ''
          DNS records for this zone. Attribute names are used as terraform
          resource keys, so keep them unique across all hosts contributing
          to the same zone (e.g. prefix with the hostname).
        '';
      };
    };
  });
in {
  imports = [
    inputs.terranix.flakeModule
  ];

  options.cloudflare.zones = lib.mkOption {
    type = lib.types.attrsOf zoneType;
    default = { };
    description = "Cloudflare zones and their DNS records.";
  };

  config.perSystem = {pkgs, config, lib, ...}:
    let
      terraform = pkgs.opentofu;

      sanitize = s: builtins.replaceStrings [ "." "-" ] [ "_" "_" ] s;
      resourceKey = zone: res: "${sanitize zone}__${sanitize res}";

      # Flatten { zones."x".records.y = {...}; } into a single
      # resource.cloudflare_dns_record attrset.
      allRecords = lib.concatMapAttrs
        (zoneName: zone:
          lib.mapAttrs'
          (recName: r:
            lib.nameValuePair (resourceKey zoneName recName)
            ({
              zone_id = zone.zoneId;
              inherit (r) name type content ttl proxied;
            }
              // lib.optionalAttrs (r.priority != null) { inherit (r) priority; }
              // lib.optionalAttrs (r.comment  != null) { inherit (r) comment; }
              // lib.optionalAttrs (r.tags != [])       { inherit (r) tags; }))
          zone.records)
        top.config.cloudflare.zones;

      terranixModule = {
        terraform.required_providers.cloudflare = {
          source = "cloudflare/cloudflare";
          version = "~> 5";
        };
        provider.cloudflare = { };
        resource.cloudflare_dns_record = allRecords;
      };
    in {
      packages.cloudflare-tf-config =
        config.terranix.terranixConfigurations.cloudflare.result.terraformConfiguration;

      terranix.terranixConfigurations.cloudflare = {
        terraformWrapper.package = terraform;
        modules = [ terranixModule ];
      };
    };
}
