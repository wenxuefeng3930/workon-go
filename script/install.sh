#!/bin/bash
APP_NAME=workon # 应用名称
BIN_DIR=$WORKON_CONFIG_DIR # 二进制脚本工作目录
CUR_PATH=$(pwd) # 当前目录
TMP_DIR=/tmp/$APP_NAME # 临时目录
WORKON_CONFIG_DIR=$HOME/.config/$APP_NAME # 配置所在目录
SHELL_FILES=($HOME/.zshrc $HOME/.bashrc) # shell的配置文件

RELATIVE_PATH=.config/workon

__colorPrint() {
    printf "\033[1;32m$1\033[0m\n"
}

__colorPrintError() {
    printf "\033[1;31m$1\033[0m\n"
}

# 检测是否安装go和git
go version > /dev/null 2>&1
if [[ $? -ne 0 ]];then
    __colorPrintError "缺少Go工具，请先安装Go工具"
    exit 1
fi
git --version > /dev/null 2>&1
if [[ $? -ne 0 ]];then
    echo "缺少Git工具，请先安装Git工具"
    exit 1
fi

# 检测是否存在workon配置目录
if [[ ! -d $WORKON_CONFIG_DIR ]];then
    mkdir -p $WORKON_CONFIG_DIR > /dev/null 2>&1
fi
rm -rf $TMP_DIR > /dev/null 2>&1
# 执行编译和安装的命令
$(git clone -q https://github.com/zzhaolei/workon.git $TMP_DIR 1> /dev/null \
    && cd $TMP_DIR \
    && go build -o $APP_NAME.tool main.go > /dev/null 2>&1 \
    && cp -f $APP_NAME.* $BIN_DIR/)
# 记录执行状态
exit_code=$?
# 清理现场
cd $CUR_PATH
rm -rf $TMP_DIR > /dev/null 2>&1

# 写入文件
for shellFile in ${$SHELL_FILES[@]};do
    # 检查shell rc文件中是否有相应的配置
    shellConfig=$(cat $shellFile | grep -v "grep" | grep "$WORKON_CONFIG_DIR")
    if [[ $shellConfig == "" || $(echo $shellConfig | wc -l) -eq 0 ]];then
        __colorPrint "$shellFile 中配置不存在，开始写入..."
        shellComplete=$(cat $shellFile | grep -v "grep" | grep "^autoload bashcompinit" | wc -l)
        if [[ shellComplete -eq 0 ]];then
            echo "autoload bashcompinit" >> $shellFile
            echo "bashcompinit" >> $shellFile
        fi
        # 如果之前没有配置的话，则会先执行让其生效
        alias setWorkon="source $HOME/.config/workon/workon.sh"
        setWorkon
        # 写入文件中
        echo 'alias setWorkon="source $HOME/.config/workon/workon.sh"' >> $shellFile
        echo 'setWorkon' >> $shellFile
        __colorPrint "配置写入 $shellFile 成功"
    fi
done


# 输出结果
if [[ $exit_code -ne 0 ]];then
    __colorPrintError "安装失败"
else
    __colorPrint "安装成功"
fi

unset -f __colorPrint > /dev/null 2>&1
unset -f __colorPrintError > /dev/null 2>&1
