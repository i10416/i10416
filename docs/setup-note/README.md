
## Setup

### Install Nix

Install Nix

### Setup nix-darwin with Flake

```sh
mkdir -p ~/.config/nix
```

```sh
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

```sh
sudo mkdir -p /etc/nix-darwin
```

```sh
sudo chown "$(id -nu):$(id -ng)" /etc/nix-darwin
```

```sh
cd /etc/nix-darwin
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

### Sync

```sh
darwin-rebuild switch
```

## Require a password after waking your Mac

```sh
sudo sysadminctl -screenLock immediate -password <administrator password>
```


