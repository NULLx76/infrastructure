# 1. Add port info to hosts
Re-use `hosts` setup and add domain and port information to each host
```nix
{
    hostname = "overseerr";
    ip = "192.168.0.105";
    mac = "8E:21:7F:88:3A:83";
    # new stuff
    exposes = {
        requests = {
            domain = "requests.xirion.net";
            port = 3000;
        };
        ...
    };
}
```
which then can get translated to nginx config:
```nix
virtualHosts."requests.xirion.net" = proxy "http://192.168.0.105:80";
```

Ideally hosts should also be able to access their own host information more easily so
that in service config one could use `thisHost.exposes.requests.port` or similar

# 2. Authoritative nameserver
Using the definitions from (1), we can then also build authoritative DNS records
by folding over `hosts[i].exposes.requests.domain` and collating that with its realm (and therefore external IP)

This also means I should probably put the external IP in some kind of meta block per realm.

[dns.nix](https://github.com/kirelagin/dns.nix) seems to be a nice DSL for DNS stuff
