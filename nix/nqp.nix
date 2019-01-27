{stdenv, fetchurl, moar, perl}:
stdenv.mkDerivation rec {
    name = "nqp-${version}";
    version = "2018.12";

    src = fetchurl {
        url    = "https://github.com/perl6/nqp/archive/${version}.tar.gz";
        sha256 = "086mvkly8n43616maxy9l6f0nyrpn0h9l9sb6c1sxn219rkgbj83";
    };

    buildInputs = [moar perl];
    configureScript = "perl ./Configure.pl";
    configureFlags = [
        "--backends=moar"
        "--with-moar=${moar}/bin/moar"
    ];
}
