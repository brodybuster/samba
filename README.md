<div align="center">
<a href="https://github.com/brodybuster/samba"><img src="https://raw.githubusercontent.com/dockur/samba/master/.github/logo.png" title="Logo" style="max-width:100%;" width="256" /></a>
</div>
<div align="center">

</div></h1>

Docker container of [Samba](https://www.samba.org/), an implementation of the Windows SMB networking protocol.

Original container forked from [dockur/samba](https://github.com/dockur/samba).

This fork is configured to focus more on implementing a multi-user share using Samba homes shares.

## Usage  🐳

Via Docker Compose:

```yaml
services:
  samba:
    image: ghcr.io/brodybuster/samba:latest
    container_name: samba
    ports:
      - 445:445
    volumes:
      - /home/example/data:/storage
```

Via Docker CLI:

```bash
docker run -it -d -p 445:445 -v "/home/example/data:/storage" ghcr.io/brodybuster/samba:latest
```

Default credentials are samba:secret, but changing these credentials is recommended.

## Configuration ⚙️

### How do I connect to a share?

You can connect to a share by using the following address: [server-address]/[user name]

On Windows Explorer, this looks like `\\192.168.2.2\samba`, where "192.168.2.2" is replaced with the address of the server behind this container, and "samba" is replaced by the username".

By default this container is configured to host a share for user "samba" with password "secret".  

### How do I modify the default credentials or add more users?

You can change the default credentials or add more users inside the provided [users](https://github.com/brodybuster/samba/blob/master/secrets/users) file, and bind that file to `/run/secrets/users`, or use it as a Docker secret if working with Docker Swarm.

Passwords are stored as NTLM MD4 hashes. To generate a NTLM MD4 hash, consider using the following command:

`iconv -f ASCII -t UTF-16LE <(printf "password") | openssl dgst -MD4 -provider legacy | cut -d " " -f2`

replacing "password" with the desired user's password.

### How can I implement a group share?

You can implement group shares by modifying the provided [groupshares](https://github.com/brodybuster/samba/blob/master/secrets/groupshares) file, and bind that file to `/run/secrets/groupshares`, or use it as a Docker secret if working with Docker Swarm.

### How do I modify other settings?

If you need more advanced features, you can completely override the default configuration by modifying the [smb.conf](https://github.com/brodybuster/samba/blob/master/smb.conf) file in this repo, and bind your custom config to the container like this:

```yaml
volumes:
  - /example/smb.conf:/etc/samba/smb.conf
```
## Publishing  🚀

This repo now publishes the image with GitHub Actions from [`.github/workflows/docker-publish.yml`](/Users/plincoln/github/samba/.github/workflows/docker-publish.yml).

What gets published:

- Push to `master`: updates `ghcr.io/brodybuster/samba:latest` and `ghcr.io/brodybuster/samba:sha-<commit>`
- Push a tag like `v1.2.3`: additionally publishes `:v1.2.3` and `:1.2.3`

Required GitHub repository settings:

- `Settings -> Actions -> General -> Workflow permissions`: set to `Read and write permissions`

Release flow:

```bash
git push origin master
git tag v1.0.0
git push origin v1.0.0
```

The workflow builds and pushes a multi-arch image for `linux/amd64` and `linux/arm64`.

## Building  🔨

Build with BuildKit:

```bash
DOCKER_BUILDKIT=1 docker build . -t ghcr.io/brodybuster/samba:dev
```

Or have the following configuration in your `daemon.json`:
```json
{
    "features": {
        "buildkit": true
    }
}
```

Then build normally with `docker build . -t ghcr.io/brodybuster/samba:dev`.

For more information, refer to the [official Docker docs](https://docs.docker.com/build/buildkit/#getting-started).
