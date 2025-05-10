{
  launchd.user.agents = {
    "docker-pruning" = {
      command = "/usr/local/bin/docker system prune -f";
      serviceConfig = {
        StartCalendarInterval = [
          {
            Hour = 12;
            Minute = 0;
          }
        ];
      };
    };
  };
}
