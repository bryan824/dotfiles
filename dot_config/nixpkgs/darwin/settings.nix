{...}: {
  # system.defaults.alf = {
  #   globalstate = 1;
  #   allowsignedenabled = 1;
  #   allowdownloadsignedenabled = 1;
  #   stealthenabled = 1;
  # };

  system.defaults.dock = {
    autohide = false;
    expose-group-apps = false;
    mru-spaces = false;
    tilesize = 64;
    mineffect = "genie";
    orientation = "right";
  };
  # Keyboard
  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToEscape = false;

  system.defaults.NSGlobalDomain = {
    "com.apple.trackpad.scaling" = 2.5;
    AppleMeasurementUnits = "Centimeters";
    AppleMetricUnits = 1;
    AppleShowScrollBars = "Automatic";
    AppleTemperatureUnit = "Celsius";
    InitialKeyRepeat = 15;
    KeyRepeat = 2;
    NSAutomaticCapitalizationEnabled = false;
    NSAutomaticPeriodSubstitutionEnabled = false;
    _HIHideMenuBar = false;
  };

  system.defaults.loginwindow = {
    GuestEnabled = false;
    DisableConsoleAccess = true;
  };

  system.defaults.spaces.spans-displays = false;
  system.defaults.trackpad = {
    Clicking = true;
    TrackpadRightClick = true;
  };
  system.defaults.finder = {
    FXEnableExtensionChangeWarning = true;
  };
}
