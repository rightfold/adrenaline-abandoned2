{stdenv, fetchurl, nqp, perl}:
stdenv.mkDerivation rec {
    name = "rakudo-${version}";
    version = "2018.12";

    src = fetchurl {
        url    = "https://rakudo.org/dl/rakudo/${name}.tar.gz";
        sha256 = "1yl4llqym7fkw61grw388s37fbdwj4kcw99fajla5wnlmywh5fv7";
    };

    buildInputs = [nqp perl];
    configureScript = "perl ./Configure.pl";
    configureFlags = [
        "--backends=moar"
        "--with-nqp=${nqp}/bin/nqp"
    ];
}
