{stdenv, fetchurl, perl}:
stdenv.mkDerivation rec {
    name = "MoarVM-${version}";
    version = "2018.12";

    src = fetchurl {
        url    = "https://moarvm.org/releases/${name}.tar.gz";
        sha256 = "0fv98712k1gk56a612388db1azjsyabsbygav1pa3z2kd6js4cz4";
    };

    buildInputs = [perl];
    configureScript = "perl ./Configure.pl";
    configureFlags = [];
}
