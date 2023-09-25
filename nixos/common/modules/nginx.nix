{ lib, hosts, config, ... }:
with lib;
let cfg = config.services.v.nginx;
in {
  options.services.v.nginx.autoExpose =
    mkEnableOption "generate vhosts";

  config =
    let

      proxy = url: {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = url;
          proxyWebsockets = true;
        };
      };

      hosts' =
        filter (hasAttr "exposes") (attrValues hosts.${config.networking.domain});
      exposes = { ip, exposes, ... }:
        map ({ domain, port ? 80 }: { inherit ip domain port; }) (attrValues exposes);
      mkVhost = { ip, domain, port }: {
        "${domain}" = proxy "http://${ip}:${toString port}";
      };
      vhosts = foldr (el: acc: acc // mkVhost el) { } (concatMap exposes hosts');
    in
    mkIf cfg.autoExpose {
      services.nginx.virtualHosts = vhosts;
    };
}
