{ self, pkgs, ... }:
{
  time.timeZone = "Asia/Tokyo";
  system.configurationRevision = self.rev or self.dirtyRev or null;
  fonts.packages = with pkgs; [
    recursive
    (nerd-fonts.jetbrains-mono)
  ];
}
