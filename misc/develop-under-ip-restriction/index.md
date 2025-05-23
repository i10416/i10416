# Notes on Development under IP Restriction

Imagine the situation where you have an API accessible only from the white-listed ip addresses.
We have VPC that consists of public subnets and private subnets with NAT + EIP.

In order to proxy requests so that they go through the private NAT + EIP without compromising the security, we deploy an EC2 instance in private subnet and connect to it via SSM session.

## Create a Key Pair for EC2

```sh
ssh-keygen -t rsa -b 2048
```

## Setup SSH proxy command
Add this block to `~/.ssh/config`
This calls `aws ssm ...` command when `ssh` or `scp` command is invoked.

```
Host i-* mi-*
    ProxyCommand sh -c "aws ssm start-session --target %h --document-name AWS-StartSSHSession --parameters 'portNumber=%p'"
```

## Setup SSH Tunneling

Listen traffic on your favorite port(e.g. 10080).

```sh
ssh -i /path/to/private/key USER@HOST -D 10080
```

Some tools allow developers to use proxy on request.
For example, the following curl request goes through your HOST before the destination.

```sh
curl --proxy socks5://localhost:10080 -X GET https://example.com/under/ip/restriction
```

If you need to intercept arbitrary TCP traffic, use `proxychains-ng`

proxychains.conf

```
[ProxyList]
socks5 127.0.0.1 10080
```

Now, you can proxy TCP traffic using `proxychains4 <any command you'd like to run>`