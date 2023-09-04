#!/bin/sh

set -u

check_root() {
    if [ "$(id -ru)" -eq 0 ]; then
        return 0
    else
        return 1
    fi
}

error_fatal() {
    # shellcheck disable=SC2039
    local msg="$1"
    [ -z "${msg}" ] && msg="Unknown error"
    if which lava-test-raise;then
        lava-test-raise "${msg}"
    else
        printf "FATAL ERROR: %s\n" "${msg}" >&2
    fi
    exit 1
}

error_msg() {
    # shellcheck disable=SC2039
    local msg="$1"
    [ -z "${msg}" ] && msg="Unknown error"
    printf "ERROR: %s\n" "${msg}" >&2
    exit 1
}

info_msg() {
    # shellcheck disable=SC2039
    local msg="$1"
    [ -z "${msg}" ] && msg="Unknown info"
    printf "INFO: %s\n" "${msg}" >&1
}

report_pass() {
    [ "$#" -ne 1 ] && error_msg "Usage: report_pass test_case"
    # shellcheck disable=SC2039
    local test_case="$1"
    echo "${test_case} pass" | tee -a "${RESULT_FILE}"
}

dist_name() {
    if [ -f /etc/os-release ]; then
        # shellcheck disable=SC1091
        dist=$(. /etc/os-release && echo "${ID}")
    elif [ -x /usr/bin/lsb_release ]; then
        dist="$(lsb_release -si)"
    elif [ -f /etc/lsb-release ]; then
        # shellcheck disable=SC1091
        dist="$(. /etc/lsb-release && echo "${DISTRIB_ID}")"
    elif [ -f /etc/debian_version ]; then
        dist="debian"
    elif [ -f /etc/fedora-release ]; then
        dist="fedora"
    elif [ -f /etc/centos-release ]; then
        dist="centos"
    else
        dist="unknown"
        warn_msg "Unsupported distro: cannot determine distribution name"
    fi

    # convert dist to lower case
    dist=$(echo ${dist} | tr '[:upper:]' '[:lower:]')
    case "${dist}" in
        rpb*) dist="oe-rpb" ;;
    esac
}

install_deps() {
    # shellcheck disable=SC2039
    local pkgs="$1"
    [ -z "${pkgs}" ] && error_msg "Usage: install_deps pkgs"
    # skip_install parmater is optional.
    # shellcheck disable=SC2039
    local skip_install="${2:-false}"

    if [ "${skip_install}" = "True" ] || [ "${skip_install}" = "true" ]; then
        info_msg "install_deps skipped"
    else
        ! check_root && \
            error_msg "About to install packages, please run this script as root."
        info_msg "Installing ${pkgs}"
        dist_name
        case "${dist}" in
          debian|ubuntu)
            last_apt_time=/tmp/apt-get-updated.last
            apt_cache_time=21600 # 6 hours
            # Only run apt-get update if it hasn't been run in $apt_cache_time seconds
            if [ ! -e ${last_apt_time} ] || \
               [ "$(stat --format=%Y ${last_apt_time})" -lt $(( $(date +%s) - apt_cache_time )) ]; then
                DEBIAN_FRONTEND=noninteractive apt-get update -q -y && touch ${last_apt_time}
            fi
            # shellcheck disable=SC2086
            DEBIAN_FRONTEND=noninteractive apt-get install -q -y ${pkgs}
            ;;
          centos)
            # shellcheck disable=SC2086
            yum -e 0 -y install ${pkgs}
            ;;
          fedora)
            # shellcheck disable=SC2086
            dnf -e 0 -y install ${pkgs}
            ;;
          *)
            warn_msg "Unsupported distro: ${dist}! Package installation skipped."
            ;;
        esac
        # shellcheck disable=SC2181
        if [ $? -ne 0 ]; then
            error_msg "Failed to install dependencies, exiting..."
        fi
    fi
}

create_out_dir() {
    [ -z "$1" ] && error_msg "Usage: create_out_dir output_dir"
    # shellcheck disable=SC2039
    local OUTPUT=$1
    [ -d "${OUTPUT}" ] &&
        mv "${OUTPUT}" "${OUTPUT}_$(date -r "${OUTPUT}" +%Y%m%d%H%M%S)"
    mkdir -p "${OUTPUT}"
    [ -d "${OUTPUT}" ] || error_msg "Could not create output directory ${OUTPUT}"
}

check_return() {
    # shellcheck disable=SC2039
    local exit_code="$?"
    [ "$#" -ne 1 ] && error_msg "Usage: check_return test_case"
    # shellcheck disable=SC2039
    local test_case="$1"

    if [ "${exit_code}" -ne 0 ]; then
        echo "${test_case} fail" | tee -a "${RESULT_FILE}"
        return "${exit_code}"
    else
        echo "${test_case} pass" | tee -a "${RESULT_FILE}"
        return 0
    fi
}

OUTPUT="$(pwd)/output"
RESULT_FILE="${OUTPUT}/result.txt"
export RESULT_FILE

usage() {
    echo "$0 [-i <image>]" 1>&2
    exit 1
}

while getopts "i:h" o; do
    case "$o" in
        i) IMAGE="${OPTARG}" ;;
        h|*) usage ;;
    esac
done

! check_root && error_msg "You need to be root to run this script."
create_out_dir "${OUTPUT}"

install() {
    dist_name
    # shellcheck disable=SC2154
    case "${dist}" in
        debian|ubuntu)
            install_deps tftpd-hpa expect bc coreutils
            ;;
        *)
            warn_msg "No package installation support on ${dist}"
            ;;
    esac
}

if [ ! -f "${IMAGE}" ]; then
	error_fatal "${IMAGE} doesn't exist"
fi

TTY=$(find /dev/ -xdev -name "ttyUSB*" -type c -print -quit)

# prepare image
mkdir tftp
split --verbose -b 10M -a 4 --numeric-suffixes=1 "${IMAGE}" tftp/x
PARTS_NO=$(ls -1 tftp/ | wc -l)

# generate expect script
SERVER_IP=$(ip route get 8.8.8.8 | head -1 | cut -d' ' -f7)

cat << EOF > u-boot-load.expect 
#!/usr/bin/expect
set timeout 1800
set serverip "${SERVER_IP}"
set send_slow {1 .001}
send_user "interact with u-boot, ctrl-C to exit\n"
spawn -open [open "${TTY}" w+]
send "\r"
sleep 0.1
expect "U-Boot>"
sleep 0.1
send -s "setenv serverip \$serverip\r"
sleep 0.1
expect "U-Boot>"
send "dhcp\r"
sleep 0.1
expect "U-Boot>"
sleep 0.1
EOF

OFFSET="0"
for i in $(seq --format "%04g" 1 "${PARTS_NO}");
do
	PART_SIZE_DEC=$(ls -nl tftp/x"${i}" | awk '{print $5}')
	PART_SIZE=$(echo "obase=16; ${PART_SIZE_DEC}" | bc)
	PART_BLOCK_COUNT=$(echo "ibase=16; obase=10; ${PART_SIZE}/200" | bc)
	echo "send -s \"tftp x${i}\\r\"" >> u-boot-load.expect
	echo "expect {" >> u-boot-load.expect
	echo " \"Retry count exceeded\" {exit 1}" >> u-boot-load.expect
 	echo " \"Bytes transferred\" {sleep 0.1}" >> u-boot-load.expect
	echo " \"U-Boot>\" {sleep 0.1}" >> u-boot-load.expect
	echo "}" >> u-boot-load.expect
	echo "send -s \"mmc write 0x200000 0x${OFFSET} 0x${PART_BLOCK_COUNT}\\r\"" >> u-boot-load.expect
	echo "sleep 0.1" >> u-boot-load.expect
	echo "expect \"MMC write\"" >> u-boot-load.expect
	echo "expect {" >> u-boot-load.expect
	echo " \"ERROR\" {exit 1}" >> u-boot-load.expect
	echo " \"U-Boot>\" {sleep 0.1}" >> u-boot-load.expect
	echo "}" >> u-boot-load.expect
	echo "sleep 0.1" >> u-boot-load.expect
	echo "send \"mmc part\\r\"" >> u-boot-load.expect
	echo "sleep 0.1" >> u-boot-load.expect
	echo "expect \"U-Boot>\"" >> u-boot-load.expect
	OFFSET=$(echo "ibase=16; obase=10; ${OFFSET}+${PART_BLOCK_COUNT}" | bc)
done
report_pass "prepare_files"

# start tftpd
mv ./tftp/* /var/lib/tftpboot/
systemctl enable tftpd-hpa
systemctl restart tftpd-hpa

# run expect script
stty -F "${TTY}" 115200 cs8 -parenb -cstopb
chmod a+x ./u-boot-load.expect
./u-boot-load.expect
check_return "copy_image"
