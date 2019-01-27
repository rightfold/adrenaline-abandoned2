{pkgs ? import ./nix/pkgs.nix {}}:
{
    poller = pkgs.callPackage ./poller.nix {};
}
