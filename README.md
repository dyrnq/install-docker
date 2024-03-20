# install-docker.sh

This is a script to install docker binaries. It can help you quickly extract the docker binaries from various mirrors without the steps of setting up the repository.

Supports installation on more operating systems, centos, debian, ubuntu, openSUSE, Kali, archlinux, manjaro, gentoo, Alpine, voidlinux, artixlinux, antixlinux.

Support docker-compose binary installation.

Support systemd、openrc、runit.

## Quickstart

```bash
curl -fsSL https://mirror.ghproxy.com/https://raw.githubusercontent.com/dyrnq/install-docker/main/install-docker.sh | bash -s docker --mirror Tuna --version 25.0.4
```

or with docker-compose

```bash
curl -fsSL https://cdn.jsdelivr.net/gh/dyrnq/install-docker@main/install-docker.sh | bash -s docker --mirror Tuna --version 25.0.4 --with-compose --compose-version 1.29.2 --compose-mirror daocloud
```

or with docker-compose plugin

```bash
mkdir -p /usr/local/lib/docker/cli-plugins
curl -fsSL https://mirror.ghproxy.com/https://raw.githubusercontent.com/dyrnq/install-docker/main/install-docker.sh | bash -s docker \
--mirror tencent \
--version 25.0.4 \
--with-compose \
--compose-version 2.24.7 \
--compose-mirror daocloud \
--compose-prefix /usr/local/lib/docker/cli-plugins \
--systemd-mirror "ghproxy"
```

## Get

```bash
git clone --depth 1 https://github.com/dyrnq/install-docker.git
```

or

```bash
curl -fsSL -O https://raw.githubusercontent.com/dyrnq/install-docker/main/install-docker.sh

or

curl -fsSL -O https://cdn.jsdelivr.net/gh/dyrnq/install-docker@main/install-docker.sh

or

curl -fsSL -O https://mirror.ghproxy.com/https://raw.githubusercontent.com/dyrnq/install-docker/main/install-docker.sh

chmod +x ./install-docker.sh
```

## Usage

* --version

```bash
./install-docker.sh --mirror Tuna --version 25.0.4 --prefix /usr/local/bin
```

* --mirror

| mirror      | linux(x86_64)                                     |
|-------------|---------------------------------------------------|
| aliyun      | <https://mirrors.aliyun.com/docker-ce/>           |
| 163         | <https://mirrors.163.com/docker-ce/>              |
| tencent     | <https://mirrors.tencent.com/docker-ce/>          |
| huaweicloud | <https://mirrors.huaweicloud.com/docker-ce/>      |
| tuna        | <https://mirrors.tuna.tsinghua.edu.cn/docker-ce/> |
| tsinghua    | <https://mirrors.tuna.tsinghua.edu.cn/docker-ce/> |
| opentuna    | <https://opentuna.cn/docker-ce/>                  |
| ustc        | <https://mirrors.ustc.edu.cn/docker-ce/>          |
| sjtu        | <https://mirror.sjtu.edu.cn/docker-ce/>           |
| zju         | <https://mirrors.zju.edu.cn/docker-ce/>           |
| nju         | <https://mirrors.nju.edu.cn/docker-ce/>           |
| njupt       | <https://mirrors.njupt.edu.cn/docker-ce/>         |
| bfsu        | <https://mirrors.bfsu.edu.cn/docker-ce/>          |
| nwafu       | <https://mirrors.nwafu.edu.cn/docker-ce/>         |
| sustech     | <https://mirrors.sustech.edu.cn/docker-ce/>       |
| hit         | <https://mirrors.hit.edu.cn/docker-ce/>           |
| xtom        | <https://mirrors.xtom.com.hk/docker-ce/>          |
| pku         | <https://mirrors.pku.edu.cn/docker-ce/>           |
| ynu         | <https://mirrors.ynu.edu.cn/docker-ce/>           |
| bupt        | <https://mirrors.bupt.edu.cn/docker-ce/>          |
| njtech      | <https://mirrors.njtech.edu.cn/docker-ce/>        |
| qlu         | <https://mirrors.qlu.edu.cn/docker-ce/>           |

* --with-compose

```bash
./install-docker.sh --mirror Tuna --version 25.0.4 --prefix /usr/local/bin --with-compose --compose-version 1.29.2 --compose-mirror daocloud --compose-prefix /usr/local/bin
```

* --dry-run

```bash
./install-docker.sh --mirror Tuna --dry-run
```

## Command-Line Options

| Name                  | Description                                   | Default                                   |
| ----------            | ----------------                              | ----------------------                    |
| --mirror              | mirror of docker binary download url          |                                           |
| --prefix              | docker binary installation directory          | /usr/local/bin                            |
| --version             | docker binary version                         | 20.10.2                                   |
| --with-compose        | install docker-compose                        |                                           |
| --compose-prefix      | docker-compose installation directory         | /usr/local/bin                            |
| --compose-version     | docker-compose version                        | 1.28.2                                    |
| --compose-mirror      | mirror of docker-compose download url         |                                           |
| --systemd-mirror      | mirror of dockerd`s systemd unit files        | jsdelivr                                  |
| --no-systemd          | do not install dockerd`s systemd unit files   |                                           |
| --daemon-json         | daemon.json path or url                       |                                           |
| --daemon-json-prefix  | daemon.json path                              | /etc/docker                               |
| --no-daemon-json      | do not install daemon.json                    |                                           |
| --with-openrc         | will install dockerd`s init.d files           |                                           |
| --openrc-mirror       | mirror of dockerd`s init.d files              | jsdelivr                                  |
| --with-runit          | will install dockerd`s runit files            |                                           |
| --runit-mirror        | mirror of dockerd`s runit files               | jsdelivr                                  |
| --dry-run             | dry run                                       |                                           |
| --override-existing   | override existing                             |                                           |

## Tks

* [https://get.docker.com/](https://get.docker.com/)
* [https://mirrorz.org/](https://mirrorz.org/)
