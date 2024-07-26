#!/bin/bash

# 功能描述：
# 该脚本展示一个选择菜单，允许用户使用上下箭头键在选项之间移动，并通过回车键选择一个选项。
# 脚本支持循环浏览选项，用户可以从最后一个选项跳回第一个选项，或从第一个选项跳到最后一个选项。
# 选中的选项会用红色突出显示，用户选择的选项将在退出菜单后显示出来。

# 显示选择列表并返回用户选择的选项
select_option() {
  local options=("$@")    # 将传入的选项数组保存在本地变量中
  local selected=0        # 初始化当前选中的选项索引为0

  while true; do
    clear  # 清除屏幕以重新绘制菜单

    # 遍历所有选项
    for i in "${!options[@]}"; do
      # 如果当前索引是选中的索引，则用红色高亮显示
      [[ $i -eq $selected ]] && printf "\033[31m> %s\033[0m\n" "${options[$i]}" || echo "  ${options[$i]}"
    done

    read -n1 -s key  # 读取用户输入的一个字符（不显示输入）

    case "$key" in
      A)  # 上箭头键，选择上一个选项
        ((selected = (selected - 1 + ${#options[@]}) % ${#options[@]})) ;;
      B)  # 下箭头键，选择下一个选项
        ((selected = (selected + 1) % ${#options[@]})) ;;
      "")  # 回车键，确认选择
        break ;;
    esac
  done

  # 输出最终选择的选项
  echo "Selected: ${options[$selected]}"
}

# 调用函数，并传入选项列表
select_option "Option 1" "Option 2" "Option 3" "Option 4"
