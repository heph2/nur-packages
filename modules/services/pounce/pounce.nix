{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.pounce;
  defaultUser = "pounce";
  configFile = pkgs.writeText "pounce" ''
    ${optionalString (cfg.sslCa != null) "local-ca = "+cfg.sslCa}
    local-host = ${cfg.hostAddress}
    local-port = ${toString cfg.hostPort}
    local-priv = ${cfg.sslKey}
    local-cert = ${cfg.sslCert}
    join = ${concatStringsSep "," cfg.joinChannels}
    ${optionalString (cfg.hashedPass != "") "local-pass = "+cfg.hashedPass}
    host = ${cfg.ircHost}
    port = ${toString cfg.ircHostPort}
    user = ${cfg.ircUser}
    nick = ${cfg.ircNick}
    ${optionalString (cfg.certFP != null) "client-cert = "+cfg.certFP+"\nsasl-external"}  
    ${optionalString (cfg.ircPass != "") "pass = "+cfg.ircPass}
    ${cfg.extraConfig}
  '';
in
{
  options = {
    services.pounce = {
      
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
        Whether to enable Pounce
        '';
      };

      user = mkOption {
        default = "pounce";
        example = "john";
        type = types.str;
        description = ''
          The name of an existing user account to use to own the Pounce server
          process. If not specified, a default user will be created.
        '';
      };

      group = mkOption {
        default = defaultUser;
        example = "users";
        type = types.str;
        description = ''
          Group to own the Pounce process.
        '';
      };

      dataDir = mkOption {
        default = "/var/lib/pounce";
        example = "/home/john/.pounce";
        type = types.path;
        description = ''
          Configuration directory
        '';
      };

      package = mkOption {
        type = types.package;
        default = pkgs.pounce;
        defaultText = "pkgs.pounce";
      };
      
      hostAddress = mkOption {
        type = types.str;
        default = "127.0.0.1";
        description = ''
         Where pounce should listen for incoming connections
        '';
      };

      hostPort = mkOption {
        type = types.int;
        default = 6697;
        description = ''          
        '';
      };

      sslCa = mkOption {
        type = types.nullOr types.path;
        default = null;
        example = "~/.config/pounce/pouncecert.pem";
        description = ''
          Path for TLS Certificate for CertFP. Needed
          for logging to Pounce password-less.
        '';
      };

      sslKey = mkOption {
        type = types.nullOr types.path;
        default = null;
        example = "/etc/letsencrypt/cert/private.key";
        description = ''
          Path to server TLS certificate key.
        '';
      };

      sslCert = mkOption {
        type = types.nullOr types.path;
        default = null;
        example = "/etc/letsencrypt/cert/cert.crt";
        description = ''
           Path to server TLS certificate.
        '';
      };

      certFP = mkOption {
        type = types.nullOr types.path;
        default = null;
        example = "/etc/pounce/libera-user.pem";
        description = ''
           Path to certFP certificate for login to IRC server
        '';
      };

      # If you want to use password, you need to generate it with pounce -x
      hashedPass = mkOption {
        type = types.str;
        default = "";
        description = ''
        '';
      };

      ircHost = mkOption {
        type = types.str;
        default = "";
        description = ''
        '';
      };

      ircHostPort = mkOption {
        type = types.int;
        default = 6697;
        description = ''
        '';
      };

      joinChannels = mkOption {
        type = types.listOf types.str;
        default = [];
        description = ''
        '';
      };

      ircUser = mkOption {
        type = types.str;
        default = "";
        description = ''
        '';
      };

      ircNick = mkOption {
        type = types.str;
        default = "";
        description = ''
        '';
      };

      ircPass = mkOption {
        type = types.str;
        default = "";
        description = ''
        '';
      };
            
      extraConfig = mkOption {
        type = types.lines;
        default = "";
        description = "Extra configuration";
      };      
    };
  };

  config = mkIf cfg.enable {

    systemd.services.pounce = {
      description = "Pounce";    
      after = [ "network-online.target" ];
      wantedBy  = [ "multi-user.target" ];
      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        ExecStart = "${pkgs.pounce}/bin/pounce ${cfg.dataDir}/configs/pounce.conf";
        Restart = "always";
        RuntimeDirectory = "pounce";
        RuntimeDirectoryMode = "0700";
      };
      preStart = ''
        mkdir -p ${cfg.dataDir}/configs
         rm -f ${cfg.dataDir}/configs/pounce.conf
         cp --no-preserve=ownership --no-clobber ${configFile} ${cfg.dataDir}/configs/pounce.conf
         chmod u+rw ${cfg.dataDir}/configs/pounce.conf
      '';
    };
    
    users.users = optionalAttrs (cfg.user == defaultUser) {
      ${defaultUser} =
        { description = "Pounce server daemon owner";
          group = cfg.group;
          home = cfg.dataDir;
          isNormalUser = true;
          createHome = true;          
        };
      };

    users.groups = optionalAttrs (cfg.user == defaultUser) {
      ${defaultUser} =
       {
         members = [ defaultUser ];
       };
    };
  };
}
