{ pkgs, ... }:
{
  time.timeZone = "Asia/Tokyo";
  fonts.packages = with pkgs; [
    recursive
    (nerd-fonts.jetbrains-mono)
  ];
}
