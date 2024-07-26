#!/bin/bash

# 常用Linux系统版本版本信息文件列表
# lsb-release区别于系统
# 如:
#   Red Hat/CentOS: /etc/lsb-release:LSB_VERSION，而 LSB_VERSION 基本不使用
#           Ubuntu: /etc/lsb-release:DISTRIB_ID:DISTRIB_RELEASE
VERSION_FILES=(
    "/etc/os-release:NAME:VERSION"
    "/etc/redhat-release:Red Hat"
    "/etc/debian_version:Debian"
    "/etc/centos-release:CentOS"
    "/etc/fedora-release:Fedora"
    "/etc/SuSE-release:SUSE"
    "/etc/lsb-release:DISTRIB_ID:DISTRIB_RELEASE"
)

# 输出操作系统版本号
print_os_ver() {
    if [ -z "$2" ]; then 
        echo "当前操作系统: $1"
    else
        echo "当前操作系统: $1 $2"
    fi

    exit 0
}

# 获取操作系统版本信息
#
# 一个系统可能会有多个 *-release 文件
# 如:
#   Red Hat/CentOS: /etc/redhat-release、/etc/lsb-release
#           Ubuntu: /etc/os-release、/etc/debian_version、/etc/lsb-release
#
# 个人觉得匹配顺序为 os-release > *-release > lsb-release
get_os_ver() {
    # 遍历各版本号文件，只要匹配其中一种
    for entry in "${VERSION_FILES[@]}"; do
        # 将数组内容通过 : 符号进行分割，并存入到 file、name_key、version_key三个变量中
        IFS=':' read -r file name_key version_key <<< "$entry"

        if [ -f "$file" ]; then 
            case "$file" in 
                "/etc/os-release" | "/etc/lsb-release")
                    # 通过 source 命令（或其别名 .）加载文件内容
                    # . "${file}"
                    source "${file}"

                    # 必须使用!符号 引用变量
                    print_os_ver "${!name_key}" "${!version_key}"
                    ;;
                "/etc/redhat-release")
                    # 如 Redhat, CentOS等可直接获取结果
                    print_os_ver "$(cat /etc/redhat-release)"
                    ;;
                "/etc/fedora-release" | "/etc/SuSE-release" | "/etc/centos-release")
                    print_os_ver "${!name_key}" "$(cat $file)"
                    ;;
                *)
                    print_os_ver "未知系统"
                    ;;
            esac
        fi
    done

    print_os_ver "Linux" "$(uname -r)"
}


main() {
    # 获取操作系统版本信息
    get_os_ver
}

main