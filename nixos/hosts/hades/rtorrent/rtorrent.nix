{ config, lib, pkgs, ... }: {
  services.rtorrent = {
    enable = true;
    port = 54945; # Port Forwarded in mullvad
    downloadDir = "/mnt/storage/torrents/r";
    package = pkgs.jesec-rtorrent;
    configText = let cfg = config.services.rtorrent;
    in pkgs.lib.mkForce ''
      # rTorrent runtime directory (cfg.basedir) [default: "$HOME/.local/share/rtorrent"]
      method.insert = cfg.basedir, private|const|string, (cat,"${cfg.dataDir}/")

      # Default download directory (cfg.download) [default: "$(cfg.basedir)/download"]
      method.insert = cfg.download, private|const|string, (cat,"${cfg.downloadDir}")

      # RPC Socket
      method.insert = cfg.rpcsock, private|const|string, (cat,"${cfg.rpcSocket}")

      # Log directory (cfg.logs) [default: "$(cfg.basedir)/log"]
      method.insert = cfg.logs,     private|const|string, (cat,(cfg.basedir),"log/")
      method.insert = cfg.logfile,  private|const|string, (cat,(cfg.logs),"rtorrent-",(system.time),".log")

      # Torrent session directory (cfg.session) [default: "$(cfg.basedir)/.session"]
      method.insert = cfg.session,  private|const|string, (cat,(cfg.basedir),".session/")

      # Watch (drop to add) directories (cfg.watch) [default: "$(cfg.basedir)/watch"]
      method.insert = cfg.watch,    private|const|string, (cat,(cfg.basedir),"watch/")

      # Create directories
      fs.mkdir.recursive = (cat,(cfg.basedir))

      fs.mkdir = (cat,(cfg.download))
      fs.mkdir = (cat,(cfg.logs))
      fs.mkdir = (cat,(cfg.session))

      fs.mkdir = (cat,(cfg.watch))
      fs.mkdir = (cat,(cfg.watch),"/load")
      fs.mkdir = (cat,(cfg.watch),"/start")

      # Drop to "$(cfg.watch)/load" to add torrent
      schedule2 = watch_load, 11, 10, ((load.verbose, (cat, (cfg.watch), "load/*.torrent")))

      # Drop to "$(cfg.watch)/start" to add torrent and start downloading
      schedule2 = watch_start, 10, 10, ((load.start_verbose, (cat, (cfg.watch), "start/*.torrent")))

      # Listening port for incoming peer traffic
      network.port_range.set = ${toString cfg.port}-${toString cfg.port}
      network.port_random.set = no

      # Distributed Hash Table and Peer EXchange
      dht.mode.set = disable
      dht.port.set = 6881
      protocol.pex.set = yes

      # UDP tracker support
      trackers.use_udp.set = yes

      # Peer settings
      throttle.max_uploads.set = 100
      throttle.max_uploads.global.set = 250
      throttle.min_peers.normal.set = 20
      throttle.max_peers.normal.set = 60
      throttle.min_peers.seed.set = 30
      throttle.max_peers.seed.set = 80
      trackers.numwant.set = 80

      protocol.encryption.set = allow_incoming,try_outgoing,enable_retry

      # Limits for file handle resources, this is optimized for
      # an `ulimit` of 1024 (a common default). You MUST leave
      # a ceiling of handles reserved for rTorrent's internal needs!
      network.max_open_files.set = 600
      network.max_open_sockets.set = 300

      # Memory resource usage (increase if you have a large number of items loaded,
      # and/or the available resources to spend)
      pieces.memory.max.set = 1800M
      network.xmlrpc.size_limit.set = 32M

      # Basic operational settings
      session.path.set = (cat, (cfg.session))
      directory.default.set = (cat, (cfg.download))
      log.execute = (cat, (cfg.logs), "execute.log")

      # Other operational settings
      encoding.add = utf8
      system.umask.set = 0027
      system.cwd.set = (directory.default)
      #schedule2 = low_diskspace, 5, 60, ((close_low_diskspace, 500M))
      #pieces.hash.on_completion.set = no

      # HTTP and SSL
      network.http.max_open.set = 50
      network.http.dns_cache_timeout.set = 25

      #network.http.ssl_verify_peer.set = 1
      #network.http.ssl_verify_host.set = 1

      # Run the rTorrent process as a daemon in the background
      system.daemon.set = true

      # XML-RPC interface
      network.scgi.open_local = (cat,(cfg.rpcsock))
      schedule = scgi_group,0,0,"execute.nothrow=chown,\":rtorrent\",(cfg.rpcsock)"
      schedule = scgi_permission,0,0,"execute.nothrow=chmod,\"g+w,o=\",(cfg.rpcsock)"

      # Logging:
      #   Levels = critical error warn notice info debug
      #   Groups = connection_* dht_* peer_* rpc_* storage_* thread_* tracker_* torrent_*
      print = (cat, "Logging to ", (cfg.logfile))
      log.open_file = "log", (cfg.logfile)
      log.add_output = "debug", "log"
    '';
  };
}

