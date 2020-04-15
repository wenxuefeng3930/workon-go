set -l WORKON_TOOL TOOL_RESULT

function workon
    set WORKON_TOOL $HOME/.config/workon/workon.tool
    # 判断第一个参数是否是参数
    switch $argv[1]
        case '-*'
            # 如果是待参数的，直接调用二进制工具
            $WORKON_TOOL $argv
        case '*'
            if test (count $argv) -ne 1
                $WORKON_TOOL --help
                return
            end
            set TOOL_RESULT ($WORKON_TOOL --get $argv[1])
            if test $status -eq 0
                conda activate $argv[1]
                cd $TOOL_RESULT > /dev/null 2>&1
            end
    end
end

function deactivate
    conda deactivate
end
