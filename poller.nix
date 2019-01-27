{stdenv, makeWrapper, rakudo}:
stdenv.mkDerivation {
    name = "poller";
    src = ./src;
    buildInputs = [makeWrapper rakudo];
    phases = ["unpackPhase" "installPhase" "fixupPhase"];
    installPhase = ''
        makeShare() {
            cp --parents "$1" "$out/share"
        }

        makeBin() {
            makeWrapper "${rakudo}/bin/perl6" "$1"                          \
                --prefix 'PERL6LIB' ',' "$out/share/lib"                    \
                --add-flags "$2"
        }

        makeTest() {
            makeShare "test/$1.p6"
            makeBin "$out/test/$1.t" "$out/share/test/$1.p6"
        }

        mkdir -p "$out/share" "$out/bin" "$out/test"

        makeShare 'lib/Adrenaline/Poller/Monitor.pm6'
        makeShare 'lib/Adrenaline/Poller/Poll.pm6'

        makeShare 'bin/poller.p6'
        makeBin "$out/bin/poller" "$out/share/bin/poller.p6"

        makeTest 'Adrenaline/Poller/PollTest'
    '';
}
