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
DEFAULT_SYSTEMD_DOCKER_SERVICE="https://cdn.jsdelivr.net/gh/docker/docker-ce@master/components/packaging/systemd/docker.service"
DEFAULT_SYSTEMD_DOCKER_SOCKET="https://cdn.jsdelivr.net/gh/docker/docker-ce@master/components/packaging/systemd/docker.socket"
DEFAULT_SYSTEMD_CONTAINERD_SERVICE="https://cdn.jsdelivr.net/gh/containerd/containerd@master/containerd.service"
DEFAULT_SYSTEMD_PREFIX=/usr/lib/systemd/system
DEFAULT_SYSTEMD=1
DEFAULT_WRITE_DAEMON_JSON_FILE=1
DEFAULT_DAEMON_JSON_FILE_PREFIX="/etc/docker"

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
SYSTEMD=${DEFAULT_SYSTEMD:-}
DRY_RUN=${DRY_RUN:-}
WITH_COMPOSE=${WITH_COMPOSE:-}
WRITE_DAEMON_JSON_FILE=${DEFAULT_WRITE_DAEMON_JSON_FILE:-}
DAEMON_JSON_FILE=${DAEMON_JSON_FILE:-}
while [ $# -gt 0 ]; do
	case "$1" in
		--mirror)
			mirror_opt="$2"
			mirror="$(echo "$mirror_opt" | tr '[:upper:]' '[:lower:]')"
			shift
			;;
		--prefix)
			PREFIX="$2"
			shift
			;;
		--version)
			VERSION="$2"
			shift
			;;
		--compose-prefix)
			COMPOSE_PREFIX="$2"
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
		--systemd-prefix)
			SYSTEMD_PREFIX="$2"
			shift
			;;
		--with-compose)
			WITH_COMPOSE=1
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
	tsinghua)
		DOWNLOAD_URL="https://mirrors.tuna.tsinghua.edu.cn/docker-ce"
		;;
	tuna)
		DOWNLOAD_URL="https://mirrors.tuna.tsinghua.edu.cn/docker-ce"
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
esac

case "$compose_mirror" in
	daocloud)
		COMPOSE_DOWNLOAD_URL="https://get.daocloud.io/docker/compose"
		;;
esac

case "$systemd_mirror" in
	github)
		SYSTEMD_DOCKER_SERVICE="https://raw.githubusercontent.com/docker/docker-ce/master/components/packaging/systemd/docker.service"
		SYSTEMD_DOCKER_SOCKET="https://raw.githubusercontent.com/docker/docker-ce/master/components/packaging/systemd/docker.socket"
		SYSTEMD_CONTAINERD_SERVICE="https://raw.githubusercontent.com/containerd/containerd/master/containerd.service"
		;;
	jsdelivr)
		SYSTEMD_DOCKER_SERVICE="https://cdn.jsdelivr.net/gh/docker/docker-ce@master/components/packaging/systemd/docker.service"
		SYSTEMD_DOCKER_SOCKET="https://cdn.jsdelivr.net/gh/docker/docker-ce@master/components/packaging/systemd/docker.socket"
		SYSTEMD_CONTAINERD_SERVICE="https://cdn.jsdelivr.net/gh/containerd/containerd@master/containerd.service"
		;;
	ghproxy)
		SYSTEMD_DOCKER_SERVICE="https://ghproxy.com/https://raw.githubusercontent.com/docker/docker-ce/master/components/packaging/systemd/docker.service"
		SYSTEMD_DOCKER_SOCKET="https://ghproxy.com/https://raw.githubusercontent.com/docker/docker-ce/master/components/packaging/systemd/docker.socket"
		SYSTEMD_CONTAINERD_SERVICE="https://ghproxy.com/https://raw.githubusercontent.com/containerd/containerd/master/containerd.service"
		;;
esac


command_exists() {
	command -v "$@" > /dev/null 2>&1
}

is_dry_run() {
	if [ -z "$DRY_RUN" ]; then
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

# Check if this is a forked Linux distro
check_forked() {

	# Check for lsb_release command existence, it usually exists in forked distros
	if command_exists lsb_release; then
		# Check if the `-u` option is supported
		set +e
		lsb_release -a -u > /dev/null 2>&1
		lsb_release_exit_code=$?
		set -e

		# Check if the command has exited successfully, it means we're in a forked distro
		if [ "$lsb_release_exit_code" = "0" ]; then
			# Print info about current distro
			cat <<-EOF
			You're using '$lsb_dist' version '$dist_version'.
			EOF

			# Get the upstream release info
			lsb_dist=$(lsb_release -a -u 2>&1 | tr '[:upper:]' '[:lower:]' | grep -E 'id' | cut -d ':' -f 2 | tr -d '[:space:]')
			dist_version=$(lsb_release -a -u 2>&1 | tr '[:upper:]' '[:lower:]' | grep -E 'codename' | cut -d ':' -f 2 | tr -d '[:space:]')

			# Print info about upstream distro
			cat <<-EOF
			Upstream release is '$lsb_dist' version '$dist_version'.
			EOF
		else
			if [ -r /etc/debian_version ] && [ "$lsb_dist" != "ubuntu" ] && [ "$lsb_dist" != "raspbian" ]; then
				if [ "$lsb_dist" = "osmc" ]; then
					# OSMC runs Raspbian
					lsb_dist=raspbian
				else
					# We're Debian and don't even know it!
					lsb_dist=debian
				fi
				dist_version="$(sed 's/\/.*//' /etc/debian_version | sed 's/\..*//')"
				case "$dist_version" in
					10)
						dist_version="buster"
					;;
					9)
						dist_version="stretch"
					;;
					8|'Kali Linux 2')
						dist_version="jessie"
					;;
				esac
			fi
		fi
	fi
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
		$sh_c "groupadd docker"
	fi
	set -e

	$sh_c "mkdir -p /etc/systemd/system/docker.service.d"
	$sh_c "mkdir -p /etc/docker/"
	$sh_c "mkdir -p /var/lib/docker/"
	$sh_c "mkdir -p /var/lib/containerd/"
	$sh_c "mkdir -p /etc/containerd/"

	platform=$(uname -s | awk '{print tolower($0)}')
	url=${DOWNLOAD_URL}/${platform}/static/${CHANNEL}/$(uname -m)/docker-${VERSION}.tgz
	
	$sh_c "curl -fsSL ${url} | tar --extract --gunzip --verbose --strip-components 1 --directory=${PREFIX}"
	if is_with_compose; then
		compose_url="${COMPOSE_DOWNLOAD_URL}/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)"
		$sh_c "curl -L $compose_url -o $COMPOSE_PREFIX/docker-compose"
		$sh_c "chmod +x $COMPOSE_PREFIX/docker-compose"
	fi




DAEMON_JSON_VAR=$(cat << EOF
{
	"dns": [
		"223.5.5.5",
		"223.6.6.6",
		"8.8.8.8"
	],
	"log-level": "info",
	"debug": false,
	"experimental": true,
	"insecure-registries": [],
	"live-restore": true,
	"registry-mirrors": [
		"https://docker.mirrors.ustc.edu.cn"
	],
	"max-concurrent-downloads": 20,
	"exec-opts": [
		""
	],
	"storage-driver": "overlay2",
	"storage-opts": [
		"overlay2.override_kernel_check=true"
	],
	"log-driver": "json-file",
	"log-opts": {
		"max-size": "100m",
		"max-file": "10"
	}
}
EOF
)

daemonJsonPath="${DAEMON_JSON_FILE_PREFIX}/daemon.json"

if is_write_daemon_json; then

	if [ -n "$DAEMON_JSON_FILE" ]; then
		if [[ "$DAEMON_JSON_FILE" =~ ^http.* ]]; then
			$sh_c "curl -fsSL ${DAEMON_JSON_FILE} --output ${daemonJsonPath}";
		else
			$sh_c "cat ${DAEMON_JSON_FILE} > ${daemonJsonPath}";
		fi
	else

		if is_dry_run; then
		echo "cat > ${daemonJsonPath} << EOF"
cat << EOF
$DAEMON_JSON_VAR
EOF
		echo "EOF"
		else
cat > "${daemonJsonPath}" << EOF
$DAEMON_JSON_VAR
EOF
		fi
	fi
fi


	if is_systemd; then
		$sh_c "curl -fsSL -o ${SYSTEMD_PREFIX}/docker.service ${SYSTEMD_DOCKER_SERVICE}"
		$sh_c "curl -fsSL -o ${SYSTEMD_PREFIX}/docker.socket ${SYSTEMD_DOCKER_SOCKET}"
		$sh_c "curl -fsSL -o ${SYSTEMD_PREFIX}/containerd.service ${SYSTEMD_CONTAINERD_SERVICE}"
		$sh_c "sed -i \"s@/usr/bin/dockerd@""$PREFIX""/dockerd@g\" ${SYSTEMD_PREFIX}/docker.service"
		$sh_c "systemctl enable docker && systemctl daemon-reload && systemctl start docker"
		$sh_c "systemctl --full --no-pager status docker"
		$sh_c "journalctl -xe --no-pager -u docker"
	fi
}


do_install() {
	if command_exists docker; then
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

	case "$lsb_dist" in

		ubuntu)
			if command_exists lsb_release; then
				dist_version="$(lsb_release --codename | cut -f2)"
			fi
			if [ -z "$dist_version" ] && [ -r /etc/lsb-release ]; then
				dist_version="$(. /etc/lsb-release && echo "$DISTRIB_CODENAME")"
			fi
		;;

		debian|raspbian)
			dist_version="$(sed 's/\/.*//' /etc/debian_version | sed 's/\..*//')"
			case "$dist_version" in
				10)
					dist_version="buster"
				;;
				9)
					dist_version="stretch"
				;;
				8)
					dist_version="jessie"
				;;
			esac
		;;

		centos|rhel)
			if [ -z "$dist_version" ] && [ -r /etc/os-release ]; then
				dist_version="$(. /etc/os-release && echo "$VERSION_ID")"
			fi
		;;

		*)
			if command_exists lsb_release; then
				dist_version="$(lsb_release --release | cut -f2)"
			fi
			if [ -z "$dist_version" ] && [ -r /etc/os-release ]; then
				dist_version="$(. /etc/os-release && echo "$VERSION_ID")"
			fi
		;;

	esac

	# Check if this is a forked Linux distro
	check_forked


	# Run setup for each distro accordingly
	case "$lsb_dist" in
		ubuntu|debian|raspbian)
			do_install_static
			echo_docker_as_nonroot
			exit 0
			;;
		centos|fedora|rhel)
			do_install_static
			echo_docker_as_nonroot
			exit 0
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
			echo
			echo "ERROR: Unsupported distribution '$lsb_dist'"
			echo
			exit 1
			;;
	esac
	exit 1
}



if [ "$(id -u 2>/dev/null || true)" -ne 0 ]
  then echo "Please run as root"
  exit 1
fi



do_install