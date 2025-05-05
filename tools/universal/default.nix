{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    nixfmt-rfc-style
    # gnu compat for osx
    coreutils
    findutils
    gnugrep
    gnused
    # signing
    gnupg
  ];
}
