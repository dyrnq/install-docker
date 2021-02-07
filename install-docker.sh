#!/usr/bin/env bash
set -Eeo pipefail


DEFAULT_DOWNLOAD_URL="https://download.docker.com"
DEFAULT_PREFIX=/usr/local/bin
DEFAULT_VERSION="20.10.2"

if [ -z "$DOWNLOAD_URL" ]; then
	DOWNLOAD_URL=$DEFAULT_DOWNLOAD_URL
fi

if [ -z "$PREFIX" ]; then
	PREFIX=$DEFAULT_PREFIX
fi

if [ -z "$VERSION" ]; then
	VERSION=$DEFAULT_VERSION
fi

mirror=''
while [ $# -gt 0 ]; do
	case "$1" in
		--mirror)
			mirror="$2"
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
		# --dry-run)
		# 	DRY_RUN=1
		# 	;;
		--*)
			echo "Illegal option $1"
			;;
	esac
	shift $(( $# > 0 ? 1 : 0 ))
done

case "$mirror" in
	Aliyun)
		DOWNLOAD_URL="https://mirrors.aliyun.com/docker-ce"
		;;
	Huaweicloud)
		DOWNLOAD_URL="https://repo.huaweicloud.com/docker-ce"
		;;
	163)
		DOWNLOAD_URL="https://mirrors.163.com/docker-ce"
		;;
	Tencent)
		DOWNLOAD_URL="https://mirrors.cloud.tencent.com/docker-ce"
		;;
	Tsinghua)
		DOWNLOAD_URL="https://mirrors.tuna.tsinghua.edu.cn/docker-ce"
		;;
	Tuna)
		DOWNLOAD_URL="https://mirrors.tuna.tsinghua.edu.cn/docker-ce"
		;;		
	Ustc)
		DOWNLOAD_URL="https://mirrors.ustc.edu.cn/docker-ce"
		;;
	Sjtu)
		DOWNLOAD_URL="https://mirror.sjtu.edu.cn/docker-ce"
		;;
	Zju)
		DOWNLOAD_URL="https://mirrors.zju.edu.cn/docker-ce"
		;;
	Nju)
		DOWNLOAD_URL="https://mirrors.nju.edu.cn/docker-ce"
		;;
esac





command_exists() {
	command -v "$@" > /dev/null 2>&1
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
	# if is_dry_run; then
	# 	return
	# fi
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

do_goupadd_docker() {
	set +e
	grep -e "^docker" /etc/group >& /dev/null
	if [ $? -ne 0 ]; then
		groupadd docker
	#else
	#	echo "docker group installed"	
	fi
	set -e
}

do_install_static() {
	mkdir -p /etc/systemd/system/docker.service.d
	mkdir -p /etc/docker/
	mkdir -p /var/lib/docker/
	mkdir -p /var/lib/containerd/
	mkdir -p /etc/containerd/

	platform=`uname -s | awk '{print tolower($0)}'`
	url=${DOWNLOAD_URL}/${platform}/static/stable/$(uname -m)/docker-${VERSION}.tgz
	echo $url;
	curl -fksSL $url | tar --extract --gunzip --verbose --strip-components 1 --directory=$PREFIX

if [ ! -f /etc/docker/daemon.json ]; then
cat > /etc/docker/daemon.json << EOF
{
	"dns": [
		"223.5.5.5",
		"223.6.6.6",
		"8.8.8.8"
	],
	"log-level": "info",
	"oom-score-adjust": -1000,
	"debug": false,
	"metrics-addr": "0.0.0.0:1337",
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
fi

	curl -fksSL -o /usr/lib/systemd/system/docker.service https://ghproxy.com/https://raw.githubusercontent.com/docker/docker-ce/master/components/packaging/systemd/docker.service
	curl -fksSL -o /usr/lib/systemd/system/docker.socket https://ghproxy.com/https://raw.githubusercontent.com/docker/docker-ce/master/components/packaging/systemd/docker.socket
	curl -fksSL -o /usr/lib/systemd/system/containerd.service https://ghproxy.com/https://raw.githubusercontent.com/containerd/containerd/master/containerd.service
	sed -i "s@/usr/bin/dockerd@$PREFIX/dockerd@g" /usr/lib/systemd/system/docker.service
	
	systemctl enable docker && systemctl daemon-reload && systemctl start docker;
	systemctl --full --no-pager status docker
	journalctl -xe --no-pager -u docker
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

	# if is_dry_run; then
	# 	sh_c="echo"
	# fi

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



if [ `id -u ` -ne 0 ]
  then echo "Please run as root"
  exit 1
fi


do_goupadd_docker
do_install