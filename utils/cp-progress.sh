#!/bin/bash

# 脚本使用方法 $ ./cp_progress.sh dir1 dir2

# 获取当前终端宽度
TTY_WIDTH=$(stty size | cut -d" " -f2)

# 计算默认进度条宽度，基于终端宽度
BAR_WIDTH=$[ ${TTY_WIDTH} / 5 ]

# 定义默认最大文件名长度，用于显示
MAX_FILENAME_LENGTH=25

# 创建目录
# $1    源目录
# $2    目标目录
function create_dir() {
    local __source=$1
    local __target=$2

    # 统计源目录中的文件数
    file_count=$(find $1 -type f | wc -l)

    # 如果源目录中有文件，则在目标目录中创建必要的子目录
    if [ $file_count -gt 0 ]; then 
        # 列出并提取相对于源目录的唯一子目录路径
        # 其中 sed "s/${__source}//" 用于将父级目录替换为空，不可使用 /g 选项
        file_paths=$(find $__source/* -type d | sort | uniq | sed "s/${__source}//")

        # 如果目标目录中不存在，则创建每个目录路径
        for f_path in $file_paths
        do 
            if [ ! -d "$__target/$f_path" ]; then
                mkdir -p "$__target/$f_path"
            fi
        done
    fi
}

# 如果超过最大长度，则截取
# $1    带绝对路径的文件名：dir1/xx.txt
function cut_filename() {
    local __filename=$(basename $1)
    if [ ${#__filename} -gt $MAX_FILENAME_LENGTH ]; then
        __filename=${__filename:0:$MAX_FILENAME_LENGTH}
    fi
    echo $__filename
}

# 显示带有彩色进度条的复制进度
# $1    源目录
# $2    目标目录
function show_copy_progress() {
    local __path=$1

    # 统计总文件数
    file_count=$(find $__path -type f | wc -l)

    # 获取文件列表及其绝对路径
    file_list=$(find $__path -type f)

    # 初始化文件计数器
    count=0

    # 遍历文件列表中的每个文件
    for file in $file_list
    do
        ((count++))
        
        # 计算当前进度百分比
        percent=$(echo "scale=2;${count}/${file_count}*100" | bc)

        # 计算填充和空白部分的进度条
        used=$[ ${count} * ${BAR_WIDTH} / ${file_count} ]
        remains=$[ ${BAR_WIDTH} - ${used} ]

        # 截断文件名以便显示
        filename=$(cut_filename $file)

        # 生成目标文件路径
        target=$2$(echo ${file} | sed "s/${__path}//")

        # 从源目录复制文件到目标目录
        cp -rf ${file} $target

        # 检查复制操作是否成功
        if [ $? -eq 0 ]; then
            # 打印带有彩色指示符的进度条
            printf "\r\e[1;31m【 ○ 】\e[m[%8d/%-8d] : [%${MAX_FILENAME_LENGTH}s] %5s\e[42m%${used}s\e[47m%${remains}s\e[00m%5.0f%%\r" "$count" "$file_count" "$filename" "" "" "" "$percent"
        else 
            # 复制失败时打印换行并退出
            printf "\n"
            exit 1
        fi
    done
    # 完成后打印换行
    printf "\n"
}

# 主函数
# $1    源目录
# $2    目标目录
function main() {
    # 如果不存在，则创建目标目录中的子目录
    create_dir $1 $2

    # 显示文件复制进度条
    show_copy_progress $1 $2
}

# 脚本入口点，调用主函数并传入源目录和目标目录
main $1 $2
