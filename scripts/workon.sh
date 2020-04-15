#!/bin/bash

# 激活方式
if [[ $ACTIVATE_TOOL == "" ]];then
    ACTIVATE_TOOL="conda activate"
fi
if [[ $DEACTIVATE_TOOL == "" ]];then
    DEACTIVATE_TOOL="conda deactivate"
fi

# 存放路径和虚拟环境名称
FULLPATH=
ENVNAME=

# 是否开启切换目录
CHANGE_DIR_SWITCH=1

# WORKON Tools
WORKON_TOOL=$HOME/.config/workon/workon.tool

function __output_color() {
    if [[ $# -eq 1 ]];then
        printf "\033[1;32m$1\033[0m"
    else
        if [[ $2 -eq 0 ]];then
            printf "$1"
            return
        fi
        printf "\033[1;31m$1\033[0m"
    fi
}

function __activate_env() {
    if [[ $ENVNAME != "" ]];then
        eval "$DEACTIVATE_TOOL"
        eval "$ACTIVATE_TOOL $ENVNAME 2>& /dev/null"
    fi
}

function __deactivate_env(){
    if [[ ${CONDA_SHLVL} -eq 0 ]];then
        __output_color "虚拟环境已经退出\n" 1
    else
        eval $DEACTIVATE_TOOL
    fi
}

function __change_dir() {
    if [[ $FULLPATH != "" ]];then
        cd $FULLPATH
    fi
}

function __call_workon_tool() {
    local TOOL_RESULT
    # 自检
    if [[ $# -eq 0 ]];then
        $WORKON_TOOL
    elif [[ $1 != -* && $# -eq 1 ]];then
        # 通过退出码进行通信
        TOOL_RESULT=$($WORKON_TOOL -get $@)
        if [[ $? -eq 0 ]];then
            # 设置虚拟环境名称和路径
            ENVNAME=$1
            FULLPATH=$TOOL_RESULT
            # 激活虚拟环境
            __activate_env
            CHANGE_DIR_SWITCH=0
            __change_dir
            CHANGE_DIR_SWITCH=1
        fi
    else
        result=$($WORKON_TOOL $@)
        if [[ $? -eq 0 ]];then
            echo $result
        fi
    fi
}

function __completeWorkon(){
    if [[ $@ == "" ]];then
        __output_color "私有函数\n" 1
        return 3
    fi
    local compCWORD pre opts compPath options
    COMPREPLY=()
    compCWORD="${COMP_WORDS[COMP_CWORD]}"
    pre="${COMP_WORDS[COMP_CWORD-1]}"
    if [[ ! -z ${WORKON_HOME} ]];then
        opts="$(ls ${WORKON_HOME})"
    fi
    if [[ $compCWORD == -* && $compCWORD != "" ]];then
        options=(
            -clean
            -remove
            -h
            -set
            -show
        )
       opts="$(printf "%s\n" ${options[@]})"
    fi
    case "${compCWORD}" in
    * )
        COMPREPLY=( $(compgen -W "${opts}" -- ${compCWORD}) )
    ;;
    esac
}

# 取消所有的设置
function unWorkon() {
    unset -f unWorkon 2>& /dev/null
    unset -f workon 2>& /dev/null
    unset -f deactivate 2>& /dev/null
    unset -f __output_color 2>& /dev/null
    unset -f __activate_env 2>& /dev/null
    unset -f __deactivate_env 2>& /dev/null
    unset -f __completeWorkon 2>& /dev/null
    unset -f __call_workon_tool 2>& /dev/null
    unset -f __change_dir 2>& /dev/null
}

function deactivate() {
    __deactivate_env
}

function workon(){
    __call_workon_tool $@
}

complete -F __completeWorkon workon
complete deactivate
