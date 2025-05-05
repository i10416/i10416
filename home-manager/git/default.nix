{
  enable = true;
  ignores = [
    # vim
    "*~"
    "*.swp"
    # editor related
    ".DS_Store"
    ".vscode"
    # tools
    ".envrc"
    ".direnv"
    # security
    ".env"
    # scala
    ".bsp"
    ".log"
    ".metals"
    "target"
    "project/project"
    ".scala-build"
  ];
  userName = "i10416";
  userEmail = "ito.yo16uh90616@gmail.com";
  lfs.enable = true;
  extraConfig = {
    color = {
      ui = "auto";
    };
    init = {
      defaultBranch = "main";
    };
  };
}
