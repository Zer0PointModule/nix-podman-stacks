{
  config,
  lib,
  ...
}: let
  name = "readmeabook";
  storage = "${config.nps.storageBaseDir}/${name}";
  mediaStorage = "${config.nps.mediaStorageBaseDir}";

  cfg = config.nps.stacks.${name};

  category = "Media & Downloads";
  description = "Audiobook Automation";
  displayName = "ReadMeABook";
in {
  imports = import ../mkAliases.nix config lib name [name];

  options.nps.stacks.${name} = {
    enable = lib.mkEnableOption name;
  };
  config = lib.mkIf cfg.enable {
    services.podman.containers.${name} = {
      image = "ghcr.io/kikootwo/readmeabook:1.0.6";

      volumeMap = {
        config = "${storage}/config:/app/config";
        cache = "${storage}/cache:/app/cache";

        media = "${mediaStorage}:/media";
        pgData = "${storage}/pgdata:/var/lib/postgresql/data";
        redis = "${storage}/redis:/var/lib/redis";
      };

      extraEnv = {
        PUID = config.nps.defaultUid;
        PGID = config.nps.defaultGid;
        PUBLIC_URL = cfg.containers.${name}.traefik.serviceUrl;
      };

      port = 3030;
      traefik.name = name;
      homepage = {
        inherit category;
        name = displayName;
        settings = {
          inherit description;
          icon = "read-me-a-book";
        };
      };
      glance = {
        inherit category description;
        name = displayName;
        id = name;
        icon = "di:read-me-a-book";
      };
    };
  };
}
