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
    ignoreDups = true;
  };
}
