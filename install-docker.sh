#!/usr/bin/env bash
set -Eeo pipefail


DEFAULT_DOWNLOAD_URL="https://download.docker.com"
DEFAULT_PREFIX=/usr/local/bin
DEFAULT_VERSION="20.10.2"
DEFAULT_COMPOSE_VERSION="1.28.2"
DEFAULT_COMPOSE_DOWNLOAD_URL="https://github.com/docker/compose"
DEFAULT_COMPOSE_PREFIX=${DEFAULT_PREFIX}
# The channel to install from:
#   * nightly
#   * test
#   * stable
#   * edge (deprecated)
DEFAULT_CHANNEL_VALUE="stable"
DEFAULT_SYSTEMD_DOCKER_SERVICE="https://cdn.jsdelivr.net/gh/docker/docker-ce@master/components/engine/contrib/init/systemd/docker.service"
DEFAULT_SYSTEMD_DOCKER_SOCKET="https://cdn.jsdelivr.net/gh/docker/docker-ce@master/components/engine/contrib/init/systemd/docker.socket"
DEFAULT_SYSTEMD_CONTAINERD_SERVICE="https://cdn.jsdelivr.net/gh/containerd/containerd@master/containerd.service"
DEFAULT_SYSTEMD_PREFIX=/usr/lib/systemd/system
DEFAULT_SYSTEMD=1
DEFAULT_WRITE_DAEMON_JSON_FILE=1
DEFAULT_DAEMON_JSON_FILE_PREFIX="/etc/docker"
DEFAULT_DAEMON_JSON_VAR="{\"live-restore\":true,\"registry-mirrors\":[\"https://docker.mirrors.ustc.edu.cn\"],\"storage-driver\":\"overlay2\",\"storage-opts\":[\"overlay2.override_kernel_check=true\"],\"log-level\":\"info\",\"log-driver\":\"json-file\",\"log-opts\":{\"max-size\":\"100m\"}}"

OPENRC_DOCKER_CONFD="https://cdn.jsdelivr.net/gh/alpinelinux/aports@master/community/docker/docker.confd"
OPENRC_DOCKER_INITD="https://cdn.jsdelivr.net/gh/alpinelinux/aports@master/community/docker/docker.initd"

RUNIT_DOCKER_RUN="https://cdn.jsdelivr.net/gh/void-linux/void-packages@master/srcpkgs/moby/files/docker/run"

if [ -z "$CHANNEL" ]; then
	CHANNEL=$DEFAULT_CHANNEL_VALUE
fi

if [ -z "$DOWNLOAD_URL" ]; then
	DOWNLOAD_URL=$DEFAULT_DOWNLOAD_URL
fi

if [ -z "$PREFIX" ]; then
	PREFIX=$DEFAULT_PREFIX
fi

if [ -z "$VERSION" ]; then
	VERSION=$DEFAULT_VERSION
fi

if [ -z "$COMPOSE_VERSION" ]; then
	COMPOSE_VERSION=$DEFAULT_COMPOSE_VERSION
fi

if [ -z "$COMPOSE_PREFIX" ]; then
	COMPOSE_PREFIX=$DEFAULT_COMPOSE_PREFIX
fi

if [ -z "$COMPOSE_DOWNLOAD_URL" ]; then
	COMPOSE_DOWNLOAD_URL=$DEFAULT_COMPOSE_DOWNLOAD_URL
fi

if [ -z "$SYSTEMD_DOCKER_SERVICE" ]; then
	SYSTEMD_DOCKER_SERVICE=$DEFAULT_SYSTEMD_DOCKER_SERVICE
fi

if [ -z "$SYSTEMD_DOCKER_SOCKET" ]; then
	SYSTEMD_DOCKER_SOCKET=$DEFAULT_SYSTEMD_DOCKER_SOCKET
fi

if [ -z "$SYSTEMD_CONTAINERD_SERVICE" ]; then
	SYSTEMD_CONTAINERD_SERVICE=$DEFAULT_SYSTEMD_CONTAINERD_SERVICE
fi

if [ -z "$SYSTEMD_PREFIX" ]; then
	if [ -d "$DEFAULT_SYSTEMD_PREFIX" ]; then
		SYSTEMD_PREFIX=$DEFAULT_SYSTEMD_PREFIX
	elif [ -d "/etc/systemd/system" ]; then
		SYSTEMD_PREFIX="/etc/systemd/system"
	fi
fi
if [ -z "$DAEMON_JSON_FILE_PREFIX" ]; then
	DAEMON_JSON_FILE_PREFIX=$DEFAULT_DAEMON_JSON_FILE_PREFIX
fi



mirror=''
compose_mirror=''
systemd_mirror=''
openrc_mirror=''
runit_mirror=''
SYSTEMD=${DEFAULT_SYSTEMD:-}
DRY_RUN=${DRY_RUN:-}
OVERRIDE_EXISTING=${OVERRIDE_EXISTING:-}
WITH_COMPOSE=${WITH_COMPOSE:-}
WITH_OPENRC=${WITH_OPENRC:-}
WITH_RUNIT=${WITH_RUNIT:-}
WRITE_DAEMON_JSON_FILE=${DEFAULT_WRITE_DAEMON_JSON_FILE:-}
DAEMON_JSON_FILE=${DAEMON_JSON_FILE:-}
FLAG_PREFIX=${FLAG_PREFIX:-}
FLAG_COMPOSE_PREFIX=${FLAG_COMPOSE_PREFIX:-}
NO_MKDIR=${NO_MKDIR:-}
while [ $# -gt 0 ]; do
	case "$1" in
		--mirror)
			mirror_opt="$2"
			mirror="$(echo "$mirror_opt" | tr '[:upper:]' '[:lower:]')"
			shift
			;;
		--prefix)
			PREFIX="$2"
			FLAG_PREFIX=1
			shift
			;;
		--version)
			VERSION="$2"
			shift
			;;
		--compose-prefix)
			COMPOSE_PREFIX="$2"
			FLAG_COMPOSE_PREFIX=1
			shift
			;;
		--compose-version)
			COMPOSE_VERSION="$2"
			shift
			;;
		--compose-mirror)
			compose_mirror_opt="$2"
			compose_mirror="$(echo "$compose_mirror_opt" | tr '[:upper:]' '[:lower:]')"
			shift
			;;
		--dry-run)
			DRY_RUN=1
			;;
		--override-existing)
			OVERRIDE_EXISTING=1
			;;
		--no-systemd)
			SYSTEMD=''
			;;
		--daemon-json)
			WRITE_DAEMON_JSON_FILE=1
			DAEMON_JSON_FILE="$2"
			;;
		--daemon-json-prefix)
			DAEMON_JSON_FILE_PREFIX="$2"
			shift
			;;
		--no-daemon-json)
			WRITE_DAEMON_JSON_FILE=''
			;;
		--systemd-mirror)
			systemd_mirror_opt="$2"
			systemd_mirror="$(echo "$systemd_mirror_opt" | tr '[:upper:]' '[:lower:]')"
			shift
			;;
		--openrc-mirror)
			openrc_mirror_opt="$2"
			openrc_mirror="$(echo "$openrc_mirror_opt" | tr '[:upper:]' '[:lower:]')"
			shift
			;;
		--runit-mirror)
			runit_mirror_opt="$2"
			runit_mirror="$(echo "$runit_mirror_opt" | tr '[:upper:]' '[:lower:]')"
			shift
			;;			
		--systemd-prefix)
			SYSTEMD_PREFIX="$2"
			shift
			;;
		--with-compose)
			WITH_COMPOSE=1
			;;
		--with-openrc)
			WITH_OPENRC=1
			;;
		--with-runit)
			WITH_RUNIT=1
			;;
		--no-mkdir)
			NO_MKDIR=1
			;;
		--*)
			echo "Illegal option $1"
			;;
	esac
	shift $(( $# > 0 ? 1 : 0 ))
done

case "$mirror" in
	aliyun)
		DOWNLOAD_URL="https://mirrors.aliyun.com/docker-ce"
		;;
	huaweicloud)
		DOWNLOAD_URL="https://repo.huaweicloud.com/docker-ce"
		;;
	163)
		DOWNLOAD_URL="https://mirrors.163.com/docker-ce"
		;;
	tencent)
		DOWNLOAD_URL="https://mirrors.cloud.tencent.com/docker-ce"
		;;
	tsinghua|tuna)
		DOWNLOAD_URL="https://mirrors.tuna.tsinghua.edu.cn/docker-ce"
		;;
	opentuna)
		DOWNLOAD_URL="https://opentuna.cn/docker-ce"
		;;
	ustc)
		DOWNLOAD_URL="https://mirrors.ustc.edu.cn/docker-ce"
		;;
	sjtu)
		DOWNLOAD_URL="https://mirror.sjtu.edu.cn/docker-ce"
		;;
	zju)
		DOWNLOAD_URL="https://mirrors.zju.edu.cn/docker-ce"
		;;
	nju)
		DOWNLOAD_URL="https://mirrors.nju.edu.cn/docker-ce"
		;;
	njupt)
		DOWNLOAD_URL="https://mirrors.njupt.edu.cn/docker-ce"
		;;
	bfsu)
		DOWNLOAD_URL="https://mirrors.bfsu.edu.cn/docker-ce"
		;;
	nwafu)
		DOWNLOAD_URL="https://mirrors.nwafu.edu.cn/docker-ce"
		;;
	sustech)
		DOWNLOAD_URL="https://mirrors.sustech.edu.cn/docker-ce"
		;;
	hit)
		DOWNLOAD_URL="https://mirrors.hit.edu.cn/docker-ce"
		;;
	xtom)
		DOWNLOAD_URL="https://mirrors.xtom.com.hk/docker-ce"
		;;
	pku)
		DOWNLOAD_URL="https://mirrors.pku.edu.cn/docker-ce"
		;;
	ynu)
		DOWNLOAD_URL="https://mirrors.ynu.edu.cn/docker-ce"
		;;
	bupt)
		DOWNLOAD_URL="https://mirrors.bupt.edu.cn/docker-ce"
		;;
esac

case "$compose_mirror" in
	daocloud)
		COMPOSE_DOWNLOAD_URL="https://get.daocloud.io/docker/compose"
		;;
esac

case "$systemd_mirror" in
	github)
		SYSTEMD_DOCKER_SERVICE="https://raw.githubusercontent.com/docker/docker-ce/master/components/engine/contrib/init/systemd/docker.service"
		SYSTEMD_DOCKER_SOCKET="https://raw.githubusercontent.com/docker/docker-ce/master/components/engine/contrib/init/systemd/docker.socket"
		SYSTEMD_CONTAINERD_SERVICE="https://raw.githubusercontent.com/containerd/containerd/master/containerd.service"
		;;
	jsdelivr)
		SYSTEMD_DOCKER_SERVICE="https://cdn.jsdelivr.net/gh/docker/docker-ce@master/components/engine/contrib/init/systemd/docker.service"
		SYSTEMD_DOCKER_SOCKET="https://cdn.jsdelivr.net/gh/docker/docker-ce@master/components/engine/contrib/init/systemd/docker.socket"
		SYSTEMD_CONTAINERD_SERVICE="https://cdn.jsdelivr.net/gh/containerd/containerd@master/containerd.service"
		;;
	ghproxy)
		SYSTEMD_DOCKER_SERVICE="https://ghproxy.com/https://raw.githubusercontent.com/docker/docker-ce/master/components/engine/contrib/init/systemd/docker.service"
		SYSTEMD_DOCKER_SOCKET="https://ghproxy.com/https://raw.githubusercontent.com/docker/docker-ce/master/components/engine/contrib/init/systemd/docker.socket"
		SYSTEMD_CONTAINERD_SERVICE="https://ghproxy.com/https://raw.githubusercontent.com/containerd/containerd/master/containerd.service"
		;;
esac

case "$openrc_mirror" in
	github)
		OPENRC_DOCKER_CONFD="https://raw.githubusercontent.com/alpinelinux/aports/master/community/docker/docker.confd"
		OPENRC_DOCKER_INITD="https://raw.githubusercontent.com/alpinelinux/aports/master/community/docker/docker.initd"
		;;
	jsdelivr)
		OPENRC_DOCKER_CONFD="https://cdn.jsdelivr.net/gh/alpinelinux/aports@master/community/docker/docker.confd"
		OPENRC_DOCKER_INITD="https://cdn.jsdelivr.net/gh/alpinelinux/aports@master/community/docker/docker.initd"
		;;
	ghproxy)
		OPENRC_DOCKER_CONFD="https://ghproxy.com/https://raw.githubusercontent.com/alpinelinux/aports/master/community/docker/docker.confd"
		OPENRC_DOCKER_INITD="https://ghproxy.com/https://raw.githubusercontent.com/alpinelinux/aports/master/community/docker/docker.initd"
		;;
esac

case "$runit_mirror" in
	github)
		RUNIT_DOCKER_RUN="https://raw.githubusercontent.com/void-linux/void-packages/master/srcpkgs/moby/files/docker/run"
		;;
	jsdelivr)
		RUNIT_DOCKER_RUN="https://cdn.jsdelivr.net/gh/void-linux/void-packages@master/srcpkgs/moby/files/docker/run"
		;;
	ghproxy)
		RUNIT_DOCKER_RUN="https://ghproxy.com/https://raw.githubusercontent.com/void-linux/void-packages/master/srcpkgs/moby/files/docker/run"
		;;	
	artixlinux)
		RUNIT_DOCKER_RUN="https://gitea.artixlinux.org/packagesD/docker-runit/raw/branch/master/trunk/docker.run"
		;;
esac

command_exists() {
	command -v "$@" > /dev/null 2>&1
}

is_flag_prefix() {
	if [ -z "$FLAG_PREFIX" ]; then
		return 1
	else
		return 0
	fi
}

is_flag_compose_prefix() {
	if [ -z "$FLAG_COMPOSE_PREFIX" ]; then
		return 1
	else
		return 0
	fi
}
if is_flag_prefix && ! is_flag_compose_prefix; then
	COMPOSE_PREFIX="$PREFIX"
fi
is_dry_run() {
	if [ -z "$DRY_RUN" ]; then
		return 1
	else
		return 0
	fi
}
is_override_existing() {
	if [ -z "$OVERRIDE_EXISTING" ]; then
		return 1
	else
		return 0
	fi
}
is_no_mkdir() {
	if [ -z "$NO_MKDIR" ]; then
		return 1
	else
		return 0
	fi
}
is_write_daemon_json() {
	if [ -z "$WRITE_DAEMON_JSON_FILE" ]; then
		return 1
	else
		return 0
	fi
}

is_systemd() {
	if [ -z "$SYSTEMD" ]; then
		return 1
	else
		return 0
	fi
}

is_with_openrc() {
	if [ -z "$WITH_OPENRC" ]; then
		return 1
	else
		return 0
	fi
}

is_with_runit() {
	if [ -z "$WITH_RUNIT" ]; then
		return 1
	else
		return 0
	fi
}

is_with_compose() {
	if [ -z "$WITH_COMPOSE" ]; then
		return 1
	else
		return 0
	fi
}

is_wsl() {
	case "$(uname -r)" in
	*microsoft* ) true ;; # WSL 2
	*Microsoft* ) true ;; # WSL 1
	* ) false;;
	esac
}

is_darwin() {
	case "$(uname -s)" in
	*darwin* ) true ;;
	*Darwin* ) true ;;
	* ) false;;
	esac
}

deprecation_notice() {
	distro=$1
	date=$2
	echo
	echo "DEPRECATION WARNING:"
	echo "    The distribution, $distro, will no longer be supported in this script as of $date."
	echo "    If you feel this is a mistake please submit an issue at https://github.com/docker/docker-install/issues/new"
	echo
	sleep 10
}

get_distribution() {
	lsb_dist=""
	# Every system that we officially support has /etc/os-release
	if [ -r /etc/os-release ]; then
		lsb_dist="$(. /etc/os-release && echo "$ID")"
	fi
	# Returning an empty string here should be alright since the
	# case statements don't act unless you provide an actual value
	echo "$lsb_dist"
}

semverParse() {
	major="${1%%.*}"
	minor="${1#$major.}"
	minor="${minor%%.*}"
	patch="${1#$major.$minor.}"
	patch="${patch%%[-.]*}"
}

echo_docker_as_nonroot() {
	if is_dry_run; then
		return
	fi
	if command_exists docker && [ -e /var/run/docker.sock ]; then
		(
			set -x
			$sh_c 'docker version'
		) || true
	fi
	your_user=your-user
	[ "$user" != 'root' ] && your_user="$user"
	# intentionally mixed spaces and tabs here -- tabs are stripped by "<<-EOF", spaces are kept in the output
	echo "If you would like to use Docker as a non-root user, you should now consider"
	echo "adding your user to the \"docker\" group with something like:"
	echo
	echo "  sudo usermod -aG docker $your_user"
	echo
	echo "Remember that you will have to log out and back in for this to take effect!"
	echo
	echo "WARNING: Adding a user to the \"docker\" group will grant the ability to run"
	echo "         containers which can be used to obtain root privileges on the"
	echo "         docker host."
	echo "         Refer to https://docs.docker.com/engine/security/security/#docker-daemon-attack-surface"
	echo "         for more information."

}



do_install_static() {
	set +e
	if ! grep -e "^docker" /etc/group >& /dev/null; then
		$sh_c "groupadd docker 2>/dev/null || addgroup -S docker"
	fi
	set -e
	
	if ! is_no_mkdir; then
		$sh_c "mkdir -p /etc/docker/"
		$sh_c "mkdir -p /var/lib/docker/"
		$sh_c "mkdir -p /var/lib/containerd/"
		$sh_c "mkdir -p /etc/containerd/"
	fi

	platform=$(uname -s | awk '{print tolower($0)}')
	url=${DOWNLOAD_URL}/${platform}/static/${CHANNEL}/$(uname -m)/docker-${VERSION}.tgz
	
	$sh_c "curl -fsSL ${url} | tar -xvz --strip-components 1 --directory=${PREFIX}"
	if is_with_compose; then
		compose_url="${COMPOSE_DOWNLOAD_URL}/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)"
		$sh_c "curl -fsSL $compose_url -o $COMPOSE_PREFIX/docker-compose"
		$sh_c "chmod +x $COMPOSE_PREFIX/docker-compose"
	fi

daemonJsonPath="${DAEMON_JSON_FILE_PREFIX}/daemon.json"

if is_write_daemon_json; then

	if [ -n "$DAEMON_JSON_FILE" ]; then
		if [[ "$DAEMON_JSON_FILE" =~ ^http.* ]]; then
			$sh_c "curl --retry 3 -fsSL ${DAEMON_JSON_FILE} --output ${daemonJsonPath}";
		else
			$sh_c "cat ${DAEMON_JSON_FILE} > ${daemonJsonPath}";
		fi
	else

		if is_dry_run; then
		echo "cat > ${daemonJsonPath} << EOF"
cat << EOF
$DEFAULT_DAEMON_JSON_VAR
EOF
		echo "EOF"
 		else
		 		if command_exists python3; then
					$sh_c "echo '$DEFAULT_DAEMON_JSON_VAR' | python3 -m json.tool > ${daemonJsonPath}"
				else
					$sh_c "echo '$DEFAULT_DAEMON_JSON_VAR' > ${daemonJsonPath}"
				fi
		fi
	fi
fi
	if [[ "$(cat /proc/1/comm)" =~ systemd ]] && is_systemd; then
		$sh_c "mkdir -p /etc/systemd/system/docker.service.d"
		$sh_c "curl --retry 3 -fsSL -o ${SYSTEMD_PREFIX}/docker.service ${SYSTEMD_DOCKER_SERVICE}"
		$sh_c "curl --retry 3 -fsSL -o ${SYSTEMD_PREFIX}/docker.socket ${SYSTEMD_DOCKER_SOCKET}"
		$sh_c "curl --retry 3 -fsSL -o ${SYSTEMD_PREFIX}/containerd.service ${SYSTEMD_CONTAINERD_SERVICE}"
		if [ "$PREFIX" != "/usr/bin" ]; then
			$sh_c "sed -i \"s@/usr/bin/dockerd@""$PREFIX""/dockerd@g\" ${SYSTEMD_PREFIX}/docker.service"
		fi
		if [ "$PREFIX" != "/usr/local/bin" ]; then
			$sh_c "sed -i \"s@/usr/local/bin/containerd@""$PREFIX""/containerd@g\" ${SYSTEMD_PREFIX}/containerd.service"
		fi
		$sh_c "systemctl daemon-reload && systemctl enable docker"
		docker_state=$(systemctl show --property SubState docker | cut -d '=' -f 2)
		if [ "$docker_state" = "running" ]; then
			echo "docker is running"
		else
			$sh_c "systemctl start docker || journalctl -xe --no-pager -u docker"
		fi
	fi

	# openrc compatible
	if openrc --version > /dev/null 2>&1 && is_with_openrc; then
		$sh_c "curl --retry 3 -fsSL -o /etc/conf.d/docker ${OPENRC_DOCKER_CONFD}"
		$sh_c "curl --retry 3 -fsSL -o /etc/init.d/docker ${OPENRC_DOCKER_INITD}"
		$sh_c "chmod +x /etc/init.d/docker"
		if [ "$PREFIX" != "/usr/bin" ]; then
			$sh_c "sed -i \"s@^#DOCKERD_BINARY.*@DOCKERD_BINARY=""$PREFIX""/dockerd@g\" /etc/conf.d/docker"
		fi
		$sh_c "rc-update add docker > /dev/null 2>&1"
		$sh_c "rc-service docker start > /dev/null 2>&1"
	fi

	# runit compatible
	if [ "$(cat /proc/1/comm 2> /dev/null)" = "runit" ] && is_with_runit; then
		sv="/etc/sv"
		for sv_path in "/etc/sv" "/etc/runit/sv"; do
			if test -d "${sv_path}"; then
				sv="${sv_path}";
				break;
			fi
		done
		$sh_c "mkdir -p ${sv}/docker"
		$sh_c "curl --retry 3 -fsSL -o ${sv}/docker/run ${RUNIT_DOCKER_RUN}"
		$sh_c "chmod +x ${sv}/docker/run"
		$sh_c "ln -s -f ${sv}/docker /etc/runit/runsvdir/current/"
	fi
}


do_install() {
	if command_exists docker && ! is_dry_run && ! is_override_existing; then
		docker_version="$(docker -v | cut -d ' ' -f3 | cut -d ',' -f1)"
		MAJOR_W=1
		MINOR_W=10

		semverParse "$docker_version"

		shouldWarn=0
		if [ "$major" -lt "$MAJOR_W" ]; then
			shouldWarn=1
		fi

		if [ "$major" -le "$MAJOR_W" ] && [ "$minor" -lt "$MINOR_W" ]; then
			shouldWarn=1
		fi

		cat >&2 <<-'EOF'
			Warning: the "docker" command appears to already exist on this system.

			If you already have Docker installed, this script can cause trouble, which is
			why we're displaying this warning and provide the opportunity to cancel the
			installation.

			If you installed the current Docker package using this script and are using it
		EOF

		if [ $shouldWarn -eq 1 ]; then
			cat >&2 <<-'EOF'
			again to update Docker, we urge you to migrate your image store before upgrading
			to v1.10+.

			You can find instructions for this here:
			https://github.com/docker/docker/wiki/Engine-v1.10.0-content-addressability-migration
			EOF
		else
			cat >&2 <<-'EOF'
			again to update Docker, you can safely ignore this message.
			EOF
		fi

		cat >&2 <<-'EOF'

			You may press Ctrl+C now to abort this script.
		EOF
		( set -x; sleep 20 )
	fi

	user="$(id -un 2>/dev/null || true)"

	sh_c='sh -c'
	if [ "$user" != 'root' ]; then
		if command_exists sudo; then
			sh_c='sudo -E sh -c'
		elif command_exists su; then
			sh_c='su -c'
		else
			cat >&2 <<-'EOF'
			Error: this installer needs the ability to run commands as root.
			We are unable to find either "sudo" or "su" available to make this happen.
			EOF
			exit 1
		fi
	fi

	if is_dry_run; then
		sh_c="echo"
	fi

	# perform some very rudimentary platform detection
	lsb_dist=$( get_distribution )
	lsb_dist="$(echo "$lsb_dist" | tr '[:upper:]' '[:lower:]')"

	if is_wsl; then
		echo
		echo "WSL DETECTED: We recommend using Docker Desktop for Windows."
		echo "Please get Docker Desktop from https://www.docker.com/products/docker-desktop"
		echo
		cat >&2 <<-'EOF'

			You may press Ctrl+C now to abort this script.
		EOF
		( set -x; sleep 20 )
	fi

	# Run setup for each distro accordingly
	case "$lsb_dist" in
		opensuse-tumbleweed|opensuse-leap)
			if ! command_exists iptables; then
				echo
				echo "ERROR: iptables not found"
				echo "Please install iptables from https://software.opensuse.org/download.html?project=security%3Anetfilter&package=iptables"
				echo
				exit 1
			fi
			;;
		*)
			if [ -z "$lsb_dist" ]; then
				if is_darwin; then
					echo
					echo "ERROR: Unsupported operating system 'macOS'"
					echo "Please get Docker Desktop from https://www.docker.com/products/docker-desktop"
					echo
					exit 1
				fi
			fi
			;;
	esac

	local prefix_check=''
	if [ ! -d "$PREFIX" ]; then
		echo "ERROR: ${PREFIX} directory does not exist"
		prefix_check=1
	fi
	if [ ! "$PREFIX" = "$COMPOSE_PREFIX" ] && [ ! -d "$COMPOSE_PREFIX" ]; then
		echo "ERROR: ${COMPOSE_PREFIX} directory does not exist"
		prefix_check=1
	fi
	if [ -n "$prefix_check" ]; then
		exit 1
	fi

	do_install_static
	echo_docker_as_nonroot
	exit 0
}



# if [ "$(id -u 2>/dev/null || true)" -ne 0 ]
#   then echo "Please run as root"
#   exit 1
# fi



do_install