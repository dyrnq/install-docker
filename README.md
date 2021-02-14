# install-docker.sh


## Quickstart
```bash
curl -fsSL https://cdn.jsdelivr.net/gh/dyrnq/install-docker@main/install-docker.sh | bash -s docker --mirror Tuna --version 20.10.3 --with-compose --compose-version 1.28.2 --compose-mirror daocloud
```

## Get
```bash
git clone --depth 1 https://github.com/dyrnq/install-docker.git
```
```bash
curl -fsSL -O https://raw.githubusercontent.com/dyrnq/install-docker/main/install-docker.sh

curl -fsSL -O https://cdn.jsdelivr.net/gh/dyrnq/install-docker@main/install-docker.sh

curl -fsSL -O https://ghproxy.com/https://raw.githubusercontent.com/dyrnq/install-docker/main/install-docker.sh

chmod +x ./install-docker.sh
```

## Usage

* --version
```bash
./install-docker.sh --mirror Tuna --version 20.10.3 --prefix /usr/local/bin
```
* --dry-run
```bash
./install-docker.sh --mirror Tuna --dry-run
```
* --mirror

| mirror             |linux(x86_64)                                                                   |
| -------            | ------------------------------------------------------------------------------ |
| aliyun             |<https://mirrors.aliyun.com/docker-ce/linux/static/stable/x86_64/>              |
| 163                |<https://mirrors.163.com/docker-ce/linux/static/stable/x86_64/>                 |
| tencent            |<https://mirrors.tencent.com/docker-ce/linux/static/stable/x86_64/>             |
| huaweicloud        |<https://mirrors.huaweicloud.com/docker-ce/linux/static/stable/x86_64/>         |
| tuna               |<https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/static/stable/x86_64/>    |
| tsinghua           |<https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/static/stable/x86_64/>    |
| ustc               |<https://mirrors.ustc.edu.cn/docker-ce/linux/static/stable/x86_64/>             |
| sjtu               |<https://mirror.sjtu.edu.cn/docker-ce/linux/static/stable/x86_64/>              |
| zju                |<https://mirrors.zju.edu.cn/docker-ce/linux/static/stable/x86_64/>              |
| nju                |<https://mirrors.nju.edu.cn/docker-ce/linux/static/stable/x86_64/>              |
| njupt              |<https://mirrors.njupt.edu.cn/docker-ce/linux/static/stable/x86_64/>            |
| bfsu               |<https://mirrors.bfsu.edu.cn/docker-ce/linux/static/stable/x86_64/>             |
| nwafu              |<https://mirrors.nwafu.edu.cn/docker-ce/linux/static/stable/x86_64/>            |
| sustech            |<https://mirrors.sustech.edu.cn/docker-ce/linux/static/stable/x86_64/>          |
| hit                |<https://mirrors.hit.edu.cn/docker-ce/linux/static/stable/x86_64/>              |
| xtom               |<https://mirrors.xtom.com.hk/docker-ce/linux/static/stable/x86_64/>             |

* --with-compose
```bash
./install-docker.sh --mirror Tuna --version 20.10.3 --prefix /usr/local/bin --with-compose --compose-version 1.28.2 --compose-mirror daocloud --compose-prefix /usr/local/bin
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
| --no-daemon-json      | do not install daemon.json                    |                                           |
| --daemon-json-prefix  | daemon.json path                              | /etc/docker                               |
| --dry-run             | dry run                                       |                                           |

## Tks
* [https://get.docker.com/](https://get.docker.com/)
* [https://mirrorz.org/](https://mirrorz.org/)