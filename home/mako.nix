{...}:{
  services.mako = {
    enable = true;
    settings = {
      font = "JetBrainsMono Nerd Font 10";
      border-color = "#89b4fa";
      border-size = 2;
      border-radius = 8;
      background-color = "#1e1e2eE6";
      text-color = "#cdd6f4";
      default-timeout = 5000;
      width = 350;
      height = 150;
      margin = "20,20";
      padding = "15";
    };

    extraConfig = ''
      [urgency=high]
      border-color=#f38ba8
      background-color=#1e1e2e
      default-timeout=4000
    '';
  };
}
