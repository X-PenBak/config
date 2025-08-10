# John1917 NixOS Config

{ config, pkgs, ... }:
 
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./packages.nix
    ];

  # System version
  system.stateVersion = "25.05";

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable gnome polkit 
  systemd = {
  user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };

  # Enable Swap 
  swapDevices = [ {
      device = "/var/lib/swapfile";
      size = 8*1024;
  } ];
  
  # OBS Virtual Camera 
  boot.extraModulePackages = with config.boot.kernelPackages; [
    v4l2loopback
  ];
  boot.extraModprobeConfig = ''
    options v4l2loopback video_nr=9 card_label=OBS exclusive_caps=1
  '';
  security.polkit.enable = true;

  # Enable VirtualBox 
  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.guest.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  
  # Chose The Kernel
  boot.kernelPackages = pkgs.linuxPackages;
  
  # Define hostname
  networking.hostName = "nixos"; 

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  /* Vietnam */
  time.timeZone = "Asia/Shanghai";

  /* United States */
  /*time.timeZone = "American/Chicago";*/

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_CTYPE="en_US.UTF-8";
    LANG="en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Environment Variables for NixOS 
  environment.sessionVariables = rec {
    terminal1 = "kitty";
    EDITOR = "nvim";
  };

  # XDG portal
  xdg.portal = { 
    enable = true; 
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ]; 
  };

  # Enable Hyprland + Other WMs 
  programs.hyprland.enable = true;
  programs.sway.enable = true;
  /* # DWM 
  services.xserver.windowManager.dwm = {
  enable = true;
  package = pkgs.dwm.overrideAttrs {
     src = ./hm-modules/suckless/suckless/dwm;
      nativeBuildInputs = with pkgs; [ #writing once works for both currently, sort of bug and feature
       xorg.libX11.dev
        xorg.libXft
        imlib2
        xorg.libXinerama
        ];
      };
   }; */
  
  # Enable Doas and Disable sudo
  security.doas.enable = true;
  security.sudo.enable = false;

  # Configure doas
  security.doas.extraRules = [{
  users = [ "colbard" ];
  keepEnv = true;
  persist = true;  
  }]; 
  
  # Enable fonts 
  fonts.packages = with pkgs; [
    cantarell-fonts
    dejavu_fonts
    source-code-pro # Default monospace font in 3.32
    source-sans
    maple-mono.NF-CN-unhinted
    font-awesome_5
  ];

  # Enable Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ]; 

  # Configure Keymap & Display Manager settings
  services = { 
    displayManager = {
      defaultSession = "hyprland"; 
    };
    xserver = {
    enable = true;
    xkb = {
      variant = "";
      layout = "us"; 
      };
      displayManager.lightdm = {
        enable = true;
        background = ./wallpapers/your-name-comet-everblush.png;
        greeters = {
         slick.enable = true;
         };
        };
    }; 
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Swaylock
  security.pam.services.swaylock.fprintAuth = false;

   # user Fish Shell
  programs.fish.enable = true;

  # set Fish shell
  users.users.colbard = {
    shell = pkgs.fish;
  };

  # 安装 Fish 相关工具
  environment.systemPackages = with pkgs; [
    fishPlugins.done            # 命令完成后自动通知
    fishPlugins.fzf-fish        # 模糊搜索集成
    fishPlugins.forgit          # Git 增强
    fishPlugins.grc             # 输出高亮
    fishPlugins.z               # 目录快速跳转
    fishPlugins.tide            # 现代提示符主题
    fishPlugins.sponge          # 防止命令历史污染
    fzf                         # 模糊查找器
    bat                         # 语法高亮查看器
    exa                         # ls 替代品
  ];

  # Fish 全局配置
  programs.fish.interactiveShellInit = ''
    # 设置默认编辑器
    set -gx EDITOR nvim
    
    # 别名
    alias ls "exa -l --group-directories-first --icons"
    alias la "exa -la --group-directories-first --icons"
    alias grep "grep --color=auto"
    alias nix-switch "sudo nixos-rebuild switch --flake ~/nix-config#nixos"
    
    # 增强 cd
    zoxide init fish | source
    
    # FZF 配置
    set -gx FZF_DEFAULT_OPTS "--height=40% --layout=reverse --border"
    set -gx FZF_DEFAULT_COMMAND "fd --type f --hidden --exclude .git"
  '';
}

  # Enable Steam 
  programs.steam = {
  enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedica   ted Server
  };

  # Override Aliases
  environment.shellAliases = {
    ls = "eza -l -x --icons --git --group-directories-first";
    rebuild-nix = "doas nixos-rebuild switch";
    rebuild-hm = "home-manager switch";
    update-nixos = "doas nix flake update /etc/nixos && doas nixos-rebuild switch";
  };

  # Enable Starship  
  programs.starship = {
    enable = true;
    # Configuration written to ~/.config/starship.toml
    settings = {
      add_newline = true;
      character = {
         success_symbol = "[󰊠   ](bold cyan)";
         error_symbol = "[󰊠   ](bold red)";
       };
      nix_shell = {
         disabled = false;
      };
       package.disabled = true;
    };
  };

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    #media-session.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.colbard = {
    isNormalUser = true;
    description = "colbard";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      firefox
      librewolf
      chromium
      thunderbird
    ];
  }; 
}
