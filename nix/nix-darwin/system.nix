{ ... }:
{
  system = {
    stateVersion = 5;
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };
    defaults = {
      SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;
      LaunchServices.LSQuarantine = false;
      NSGlobalDomain = {
        AppleShowScrollBars = "Always";
        AppleShowAllFiles = true;
        NSAutomaticWindowAnimationsEnabled = false;
        NSUseAnimatedFocusRing = false;
        AppleShowAllExtensions = true;
      };
      finder = {
        AppleShowAllFiles = true;
        AppleShowAllExtensions = true;
        _FXShowPosixPathInTitle = true;
      };
      dock = {
        tilesize = 48;
        autohide = false;
        launchanim = false;
        orientation = "bottom";
        show-recents = false;
      };
      trackpad = {
        Clicking = true;
        Dragging = true;
      };
    };
  };
}
