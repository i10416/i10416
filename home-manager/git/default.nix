{
  enable = true;
  ignores = [
    # tmp & backup
    "*~"
    "*.swp"
    "$~*"
    "~*"
    "*tmp"
    # editor related
    ".DS_Store"
    ".vscode"
    # tools
    ".envrc"
    ".direnv"
    # security
    ".env"
    "**/.ssh/"
    "**/.gnupg/*"
    # scala
    ".bsp"
    ".bloop"
    ".log"
    ".metals"
    "target"
    "project/project"
    ".scala-build"
    # archive
    "dist"
    "result"
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
