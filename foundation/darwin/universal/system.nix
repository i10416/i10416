{
  self,
  userKeyMapping ? [ ],
  stateVersion ? 6,
  ...
}:
{
  system = {
    # for backwards compatibility
    stateVersion = stateVersion;
    # Set Git commit hash for darwin-version.
    configurationRevision = self.rev or self.dirtyRev or null;
    keyboard = {
      # See https://developer.apple.com/library/archive/technotes/tn2450/_index.html
      inherit userKeyMapping;
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };
    defaults = {
      SoftwareUpdate.AutomaticallyInstallMacOSUpdates = false;
      LaunchServices.LSQuarantine = false;
      NSGlobalDomain = {
        AppleShowScrollBars = "Always";
        AppleShowAllFiles = true;
        NSAutomaticWindowAnimationsEnabled = false;
        NSUseAnimatedFocusRing = false;
        AppleShowAllExtensions = true;
        AppleInterfaceStyle = "Dark";
        NSAutomaticCapitalizationEnabled = false;
        "com.apple.sound.beep.volume" = 0.0;
        "com.apple.sound.beep.feedback" = 0;
      };
      finder = {
        AppleShowAllFiles = true;
        AppleShowAllExtensions = true;
        _FXShowPosixPathInTitle = true;
        CreateDesktop = false;
        ShowPathbar = true;
        ShowStatusBar = true;
      };
      dock = {
        tilesize = 48;
        autohide = false;
        launchanim = false;
        orientation = "bottom";
        show-recents = false;
        mineffect = "scale";
      };
      WindowManager = {
        EnableStandardClickToShowDesktop = false;
      };
      loginwindow = {
        GuestEnabled = false;
        SHOWFULLNAME = true;
      };
      trackpad = {
        Clicking = true;
        Dragging = true;
      };
      CustomUserPreferences = {
        "com.apple.finder" = {
          # When performing a search, search the current folder by default
          FXDefaultSearchScope = "SCcf";
        };
      };
    };
  };
  security.pam.services.sudo_local.touchIdAuth = true;
}
