# Serveo-like Jumpbox

Bust NAT'd networks and network filewalls to reach a local host.  Launch a "jumpbox" with [Serveo](https://jumpbox.net)-like SSH tunneling and HTTPS forwarding in AWS, instantly. 

(Just add creds!)

## Dependencies

* Terraform v0.12.24
* Ansible 2.9.6

## Quick Start

Setup your [AWS credentials and configuration according to the AWS CLI documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html) and [generate a public and private SSH key](https://help.github.com/en/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent) to use to connect to the EC2 instance.

The `Makefile` contains a bunch of handy targets that do pretty much everything using sensible defaults:

```sh
make
```

## Overrides

You can override pretty much all of "sensible defaults" by providing environment variables to the `make` command in the format `make -e ENV_NAME="env value"`.

### Set an email address for the AWS Budget notification

You can set an email address to be notified when the [AWS Budget](https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/budgets-create.html) threshold is exceeded by providing an `EMAIL` environment variable::

```sh
make -e EMAIL=youremailaddress@yourprovider.com
```

By default, this value is empty, resulting in no notifications being sent when the threshold is exceeded.

### Set the AWS Budget period start

You can set the AWS Budget effective start period to any date or time you wart by providing a `START` environment variable (format: `YYYY-mm-dd_HH:MM`) at execution:

```sh
make -e START=2020-03-01_00:00
```

By default, this value is set to the time the budget is provisioned.

**Note:** Setting en effective end period for this budget is currently not supported.  This is a monthly recurring budget.

### Use a public SSH key other than `id_rsa.pub`

You can set up the jumpbox to authorize a specific public SSH key to make SSH tunel connections by providing a value for the `SSHD_AUTHORIZED_KEY` environment variable:

```sh
make -e SSHD_AUTHORIZED_KEY="ssh-rsa blahblahblahblahblah==="
```

You can override the SSH key used to create an AWS Key Pair for mananging the underlying EC2 instance using the `KEY` environment variable:

```sh
make -e KEY="ssh-rsa supersecretbutnotreallybecauseitspublickey==="
```

By default, both of these values are set to the contents of the file `~/.ssh/id_rsa.pub`

### Allow an IP address other than your current public IP to create a tunnel

As a security measure, the provisioned jumpbox only allows SSH tunnel connections to originate from a single public IP address.  You can change the allowed IP address by providing a value for the `CIDR` environment variable:

```sh
make -e CIDR=10.123.2.44
```

By default, this retrieves the public IP address of the machine provisioning the jumpbox from [ipinfo.io](http://ipinfo.io).  This is done because this is (usually) used as a developer tool to allow public access to locally running ports.

### Set the username used to create an SSH tunnel

You can set the username that's allowed to create SSH tunnels on the jumpbox by overriding the `USER` environment variable:

```sh
make -e USER=tony.danza
```

By default, this assumes the value of the `USER` environment variable present in most UNIX systems.

### Get an TLS certificate through Let's Encrypt

You can provision and request a custom TLS certificate for the HTTPS proxy by setting the value of `CERTBOT_DOMAIN`:

```sh
make -e CERTBOT_DOMAIN="yourdomain.com"
```

By default, this value assumes the value of the public DNS of the jumpbox EC2 instance


You can change the email address the certificate is registered under by overriding the value of `CERTBOT_EMAIL`:

```sh
make -e CERTBOT_EMAIL="youremailaddress@provider.com"
```

By default, this value is set to that of `EMAIL`

You can also (optionally) pass extra arguments to the `certbot standalone` command by providing a `CERTBOT_EXTRA_ARGS` environment variable:

```sh
make -e CERTBOT_EXTRA_ARGS="--test-cert --dry-run --force-renewal"
```

### Change the local port exposed via the SSH tunnel

You can change the local port exposed via the SSH tunnel by setting the value of the `LOCAL_PORT` environment variable when invoking the `connect` target:

```sh
make -e LOCAL_PORT=8080 connect
```

By default, this is set to port `80`
