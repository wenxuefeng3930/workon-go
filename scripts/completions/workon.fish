complete -c workon -l set --description "为当前目录设置虚拟环境，激活环境或进入当前目录自动激活环境"
complete -c workon -l remove --description "删除指定环境配置，可通过-show查看已经添加的全部配置信息"
complete -c workon -l clean --description "清除所有的配置信息"
complete -c workon -l show --description "显示所有的配置信息"
complete -c workon -l help --description "帮助信息"
complete -c workon -x -a '(ls /usr/local/Caskroom/miniconda/base/envs/ | cut -d : -f 1)'
