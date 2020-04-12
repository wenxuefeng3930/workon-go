.PHONY: install uninstall test clear
install: clear
	@/bin/bash ./script/setup.sh

uninstall: clear
	@rm -rf ~/.config/workon/workon.yml
	@echo "卸载完成!"
	@echo ""
	@echo "你可能需要手动删除shell环境变量，查看.zshrc或者.bash_profile中是否有以下语句:"
	@echo 'alias setWorkon="source $HOME/.config/workon/workon.sh"'
	@echo 'setWorkon'
	@echo ""
	@echo "找到并删除这两行语句，然后执行:"
	@echo "source ~/.zshrc"
	@echo "或者"
	@echo "source ~/.bash_profile"
	@echo ""

test: clear
	go build -o workon.tool && mv workon.tool ~/.config/workon/
	@echo "Ok"

clear:
	@rm -rf ~/.config/workon/workon.tool
	@rm -rf ~/.config/workon/workon.sh

clearAll: clear
	@rm -rf ~/.config/workon/*
