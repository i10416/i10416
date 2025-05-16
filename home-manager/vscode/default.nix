{
  enable = true;
  profiles.default.userSettings = {
    "search.exclude" = {
      "**/node_modules" = true;
      "**/.direnv" = true;
    };
    "files.insertFinalNewline" = false;
    "files.eol" = "\n";
    "editor.fontSize" = 13;
    "editor.tabSize" = 2;
    "editor.fontFamily" = "\"Ricty Diminished\",Consolas, 'Courier New', monospace";
    "editor.renderWhitespace" = "boundary";
    "editor.formatOnType" = false;
    "editor.formatOnPaste" = true;
    "editor.rulers" = [ 80 ];
    "editor.bracketPairColorization.enabled" = true;
    "terminal.integrated.fontSize" = 13;
    "gitlens.hovers.currentLine.over" = "line";
    "gitlens.changes.locations" = [
      "gutter"
      "overview"
    ];
    "gitlens.hovers.changesDiff" = "line";
    "[csv]" = {
      "editor.wordWrap" = "off";
    };
  };
}
