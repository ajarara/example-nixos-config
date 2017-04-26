# see this post for details: https://jarmac.org/time-machine.html       
{ config, pkgs, ... }:
  let
    timeMachineDir = "/backup";
    user = "macUser";
    sizeLimit = "262144";
  in {
  services.avahi = {
    enable = true;
    publish = {
      enable = true;
      userServices = true;
    };
  };

  services.netatalk = {
    enable = true;
    extraConfig = ''
      mimic model = TimeCapsule6,106  # show the icon for the first gen TC
      log level = default:warn
      log file = /var/log/afpd.log
      hosts allow = 192.168.1.0/24
    [${user}'s Time Machine]
      path = ${timeMachineDir}
      valid users = ${user}
      time machine = yes
      vol size limit = ${sizeLimit}
    '';
  };

  users.extraUsers.macUser = { name = "${user}"; group = "users"; };
  systemd.services.macUserSetup = {
    description = "idempotent directory setup for ${user}'s time machine";
    requiredBy = [ "netatalk.service" ];
    script = ''
     mkdir -p ${timeMachineDir}
      chown ${user}:users ${timeMachineDir}  # making these calls recursive is a switch
      chmod 0750 ${timeMachineDir}           # away but probably computationally expensive
      '';
  };

  networking.firewall.allowedTCPPorts = [ 548 636 ];
}
