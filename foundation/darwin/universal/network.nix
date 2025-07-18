{ ... }:
{
  networking = {
    dns = [
      "8.8.8.8"
      "8.8.4.4"
      "1.1.1.1"
      "1.0.0.1"
      "2001:4860:4860::8888"
      "2001:4860:4860::8844"
      "2606:4700:4700::1111"
      "2606:4700:4700::1001"
      "127.0.0.1"
    ];
    search = [ "local" ];
    knownNetworkServices = [
      "Ethernet"
      "Wi-Fi"
      "Bluetooth PAN"
      "Thunderbolt Ethernet"
    ];
  };
}
