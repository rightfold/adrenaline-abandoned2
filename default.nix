{pkgs ? import ./nix/pkgs.nix {}}:
{
    adrenaline = pkgs.callPackage ./adrenaline.nix {};
}
