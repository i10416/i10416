
## Setup

### Install Nix

Install Nix

As of May 2025, you can install Nix by running the following command.

```sh
sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install)
```

### Setup nix-darwin with Flake

```sh
mkdir -p ~/.config/nix
```

```sh
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```
#### From Scrach
```sh
nix flake init -t nix-darwin/master
```

```sh
sed -i '' "s/simple/$(scutil --get LocalHostName)/" flake.nix
```

#### Clone from Remote

```sh
git clone https://github.com/i10416/i10416
```

```sh
cd i10416
nix build .#darwinConfigurations.<host name>.system
```

### Setup /etc/nix-darwin to use `darwin-rebuild` command

```sh
sudo mkdir -p /etc/nix-darwin
# OR
sudo cp -r /path/to/github.com/i10416/i10416 nix-darwin
```

```sh
sudo chown -R "$(id -nu):$(id -ng)" /etc/nix-darwin
```

### Sync

```sh
darwin-rebuild switch
# OR use specific flake with `--flake` option
darwin-rebuild switch --flake .
```

## Require a password after waking your Mac

```sh
sudo sysadminctl -screenLock immediate -password <administrator password>
```


