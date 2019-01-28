{ stdenv, php }:
stdenv.mkDerivation rec {
    name = "psalm-${version}";
    version = "3.0.12";
    src = builtins.fetchurl {
        url = "https://github.com/vimeo/psalm/releases/download/${version}/psalm.phar";
        sha256 = "1bdrhd66q443l20rkp67p9iaa3a4pmnb0k22p4swk18rnvlfh86h";
    };
    buildInputs = [php];
    phases = ["installPhase"];
    installPhase = ''
        mkdir -p $out/bin $out/share
        cp ${src} $out/share/psalm.phar
        cat <<EOF > "$out/bin/psalm"
        #!/bin/sh
        export PATH="${php}/bin:\$PATH"
        exec php $out/share/psalm.phar "\$@"
        EOF
        chmod +x $out/bin/psalm
    '';
}
