{
  enable = true;
  enableCompletion = true;
  oh-my-zsh = {
    enable = true;
    plugins = [ "git" ];
    theme = "robbyrussell";
  };
  syntaxHighlighting.enable = true;
  sessionVariables = {
    EDITOR = "vim";
  };
  history = {
    append = true;
    save = 10000;
    size = 10000;
    share = true;
    ignoreDups = true;
  };
  historySubstringSearch = {
    enable = true;
  };
}
