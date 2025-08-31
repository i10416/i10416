{
  enableUpdateCheck = false;
  userSettings = with builtins; fromJSON (readFile ./settings.json);
}