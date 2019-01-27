let
    tarball = fetchTarball {
        url = "https://github.com/NixOS/nixpkgs/archive/18.09.tar.gz";
        sha256 = "1ib96has10v5nr6bzf7v8kw7yzww8zanxgw2qi1ll1sbv6kj6zpd";
    };
    config = {
        packageOverrides = pkgs: {
            moar   = pkgs.callPackage ./moar.nix {};
            nqp    = pkgs.callPackage ./nqp.nix {};
            rakudo = pkgs.callPackage ./rakudo.nix {};
        };
    };
in
    {}:
        import tarball {config = config;}
