{lib, stdenv, makeWrapper, phpPackages, postgresql100, rakudo}:
let libs = lib.makeLibraryPath [postgresql100]; in
stdenv.mkDerivation {
    name = "adrenaline";
    src = ./src;
    buildInputs = [
        makeWrapper
        phpPackages.composer
        phpPackages.psalm
        postgresql100
        rakudo
    ];
    phases = ["unpackPhase" "buildPhase" "installPhase" "fixupPhase"];
    buildPhase = ''
        ln 'cfg/composer.json' .
        ln 'cfg/psalm.xml' .
        composer dump-autoload
        psalm
    '';
    installPhase = ''
        makeShare() {
            cp --parents "$1" "$out/share"
        }

        makePerl6Bin() {
            makeWrapper "${rakudo}/bin/perl6" "$1"                          \
                --prefix 'PERL6LIB' ',' "$out/share/lib"                    \
                --prefix 'LD_LIBRARY_PATH' ':' '${libs}'                    \
                --add-flags "$2"
        }

        makePerl6Test() {
            makeShare "test/$1.p6"
            makePerl6Bin "$out/test/$1.t" "$out/share/test/$1.p6"
        }

        mkdir -p "$out/bin" "$out/share" "$out/test" "$out/www"

        makeShare 'lib/Adrenaline/Poller/Loop.pm6'
        makeShare 'lib/Adrenaline/Poller/Monitor.pm6'
        makeShare 'lib/Adrenaline/Poller/Poll.pm6'
        makeShare 'lib/Adrenaline/Poller/Schedule.pm6'
        makeShare 'lib/Adrenaline/Poller/Status.pm6'
        makeShare 'lib/Database/PostgreSQL.pm6'

        makeShare 'bin/poller.p6'
        makePerl6Bin "$out/bin/poller" "$out/share/bin/poller.p6"

        makePerl6Test 'Adrenaline/Poller/PollTest'
        makePerl6Test 'Adrenaline/Poller/ScheduleTest'
        makePerl6Test 'Adrenaline/Poller/StatusTest'
        makePerl6Test 'Database/PostgreSQLTest'

        cp 'bin/configurator.php' "$out/www/index.php"
        find 'lib' -name '*.php' -exec cp --parents {} "$out/share" \;
        cp -R 'vendor' "$out/share"
    '';
}
