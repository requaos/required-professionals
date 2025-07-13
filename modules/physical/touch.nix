{
  lib,
  pkgs,
  config,
  ...
}: {
  # TODO: Make this a proper module and take this list of pam services as an option.
  security = {
    pam.services =
      lib.attrsets.genAttrs [
        "sudo"
        "i3lock"
        "lightdm"
        "login"
        "xscreensaver"
        "swaylock"
        "gdm"
      ]
      (name: {
        fprintAuth = lib.mkForce true;
        enable = lib.mkForce true;
      });
  };
  services = {
    fprintd = {
      enable = true;
      package = pkgs.fprintd.overrideAttrs {
        mesonCheckFlags = [
          "--no-suite"
          "fprintd:TestPamFprintd"
          "--no-suite"
          "fprintd:TestFprintdUtilsVerify"
          "--no-suite"
          "fprintd:FPrintdVirtualDeviceStorageTest"
          "--no-suite"
          "fprintd:FPrintdVirtualDeviceStorageClaimedTest"
          "--no-suite"
          "fprintd:FPrintdVirtualDeviceNoStorageVerificationTests"
          "--no-suite"
          "fprintd:FPrintdVirtualDeviceStorageIdentificationTests"
          "--no-suite"
          "fprintd:FPrintdVirtualDeviceClaimedTest"
        ];
      };
    };
  };
}
