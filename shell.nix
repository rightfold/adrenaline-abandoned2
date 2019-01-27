{pkgs ? import ./nix/pkgs.nix {}}:
{
    sqitch = pkgs.sqitchPg;
}
