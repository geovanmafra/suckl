# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

let
  # Import Home Manager without nix-channel.
  home-manager = builtins.fetchTarball {
    url = "https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz";
  };

  # Import wallpaper from GitHub.
  wallpaper = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/geovanmafra/nixos/refs/heads/main/wallpaper.jpg";
  };
in

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix

      # Introduce a new option called home-manager.users who maps the user to Home Manager configuration.
      "${home-manager}/nixos"
    ];

  boot = {
    # Use the latest kernel.
    kernelPackages = pkgs.linuxPackages_zen; # More options available at https://nixos.wiki/wiki/Linux_kernel.

    # Load additional drivers for certain vendors (I.E: Wacom, Intel, etc.)
    initrd.unl0kr.allowVendorDrivers = true;

    # Use the systemd-boot EFI boot loader.
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;

    # Enable quiet boot.
    plymouth = {
      enable = true;
      theme = catppuccin-plymouth;
    };
  };

  networking = {
    hostName = "e14"; # Define your hostname.

    # Pick only one of the below networking options.
    # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
    networkmanager.enable = true;  # Easiest to use and most distros use this by default.

    # Configure network proxy if necessary
    # proxy.default = "http://user:password@proxy:port/";
    # proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # Open ports in the firewall.
    # firewall.allowedTCPPorts = [ ... ];
    # firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    # firewall.enable = false;
  };

  # Set your time zone.
  time.timeZone = "America/Sao_Paulo";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "br-abnt2";
    # useXkbConfig = true; # use xkb.options in tty.
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.user = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      tree
    ];
  };

  # Define a user account for Home Manager.
  home-manager.backupFileExtension = "backup";
  home-manager.users.user = { pkgs, ... }: {
    home.packages = [ pkgs.atool pkgs.httpie ];

    # Bash settings.
    programs.bash = {
      enable = true;
      profileExtra = ''
        clear > /dev/null 2>&1
        exec &> /dev/null
        if uwsm check may-start; then
          exec uwsm start hyprland-uwsm.desktop
        fi
      '';
    };
    programs.oh-my-posh = {
      enable = true;
      useTheme = "clean-detailed";
    };

    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    home.stateVersion = "25.05"; # Please read the comment before changing.
  };

  # Allow proprietary software.
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    wget
    kdePackages.dolphin
  ];

  # Some programs need SUID wrappers, can be configured further or are started in user sessions.
  programs = {
    # programs.mtr.enable = true;
    # programs.gnupg.agent = {
    #   enable = true;
    #   enableSSHSupport = true;
    # };

    # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    nano.enable = false;
    neovim = {
      enable = true;
      vimAlias = true;
      defaultEditor = true;
    };

    # Terminal emulator.
    foot = {
      enable = true;
      theme = "catppuccin-mocha";
    };

    # Browser.
    firefox = {
      enable = true;
      nativeMessagingHosts.packages = with pkgs; [ uget-integrator ];
    };
  };

  # List fonts accessible to applications.
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    nerd-fonts.meslo-lg # For Oh My Posh.
    font-awesome # For Waybar icons.
  ];

  # List services that you want to enable:
  services = {
    # Enable the X11 windowing system.
    # services.xserver.enable = true;

    # Configure keymap in X11
    # services.xserver.xkb.layout = "us";
    # services.xserver.xkb.options = "eurosign:e,caps:escape";

    # Enable CUPS to print documents.
    # services.printing.enable = true;

    # Enable sound.
    # services.pulseaudio.enable = true;
    # OR
    services.pipewire = {
      enable = true;
      pulse.enable = true;
      jack.enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
    };

    # Enable touchpad support (enabled default in most desktopManager).
    libinput.enable = true;

    # Enable the OpenSSH daemon.
    openssh.enable = true;

    # Enable autologin into TTY.
    getty = {
      autologinOnce = true;
      autologinUser = "user";
    };

    # Automounting support.
    udisks2.enable = true;

    # Battery management.
    tlp = {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

        CPU_MIN_PERF_ON_AC = 0;
        CPU_MAX_PERF_ON_AC = 100;
        CPU_MIN_PERF_ON_BAT = 0;
        CPU_MAX_PERF_ON_BAT = 20;

        # Optional helps save long term battery health.
        START_CHARGE_THRESH_BAT0 = 40; # 40 and below it starts to charge.
        STOP_CHARGE_THRESH_BAT0 = 80; # 80 and above it stops charging.
      };
    };
  };

  # List hardware services that you want to enable:
  hardware.bluetooth.enable = true;
  security.rtkit.enable = true;
  security.pam.services.hyprlock = {};

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?

}

