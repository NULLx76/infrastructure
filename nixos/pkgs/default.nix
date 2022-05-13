final: prev: {
  # clickhouse = prev.callPackage ./clickhouse { };
  
  v = {
    unbound = prev.unbound.override {
      withSystemd = true;
      withDoH = true;
      withDNSCrypt = true;
      withTFO = true;
    };
  };
}
