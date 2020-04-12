package main

import (
	"flag"
	"fmt"
	"io/ioutil"
	"os"
	"path"

	"gopkg.in/yaml.v2"
)

var (
	home        = os.Getenv("HOME")
	workDir     = path.Join(home, ".config/workon/")
	settingsDir = [...]string{path.Join(workDir, "workon.yml")}
)

var (
	configNotFound   = 2
	saveConfigError  = 3
	notFound         = 4
	parseConfigError = 5
)

var (
	arg      string
	settings workonConfigMap
	projects map[string]string
)

// 这样可以使用这种结构
// projects:
//   envName: "path_dir"
//   envName2: "path_dir2"
type workonConfigMap struct {
	Projects map[string]string `yaml:"projects,omitempty"`
}

// 定义选项
var (
	setArg     string
	removeArg  string
	getPathArg string
	showArg    bool
	cleanArg   bool
)

type argsmap struct {
	set     func()
	remove  func()
	clean   func()
	show    func()
	getPath func()
}

func newArgsMap() argsmap {
	return argsmap{
		set:     set,
		remove:  remove,
		show:    show,
		clean:   clean,
		getPath: getPath,
	}
}

func set() {
	if project := projects[setArg]; project == "" {
		projects[setArg], _ = os.Getwd()
	}
	saveConfig()
	fmt.Println("映射完成")
}

func remove() {
	if project := projects[removeArg]; project == "" {
		fmt.Println("映射不存在")
		os.Exit(configNotFound)
	}
	delete(projects, removeArg)
	saveConfig()
	fmt.Println("映射删除完成")
}
func clean() {
	if ioutil.WriteFile(settingsDir[0], []byte{}, 0644) != nil {
		os.Exit(saveConfigError)
	}
	fmt.Println("映射已清空")
}
func show() {
	content, err := yaml.Marshal(settings)
	if err != nil {
		os.Exit(saveConfigError)
	}
	fmt.Println(string(content))
}

//
func getPath() {
	project := projects[getPathArg]
	if project == "" {
		os.Exit(4)
	}
	fmt.Println(project)
}

// 保存配置
func saveConfig() {
	content, err := yaml.Marshal(settings)
	if err != nil {
		os.Exit(saveConfigError)
	}
	if ioutil.WriteFile(settingsDir[0], content, 0644) != nil {
		os.Exit(saveConfigError)
	}
}

func usage() {
	fmt.Fprintf(os.Stderr, `workon是自定义脚本，可以用来激活Python虚拟环境，设置路径和虚拟环境的映射，实现激活虚拟环境自动进入项目目录。

usage: workon [OPTION] [env]
`)
	flag.PrintDefaults()
}

func setFlagVar() {
	flag.StringVar(&setArg, "set", "", "`env`为当前目录设置虚拟环境，激活环境或进入当前目录自动激活环境")
	flag.StringVar(&removeArg, "remove", "", "`env`删除指定环境配置，可通过-show查看已经添加的全部配置信息")
	flag.StringVar(&getPathArg, "get", "", "获取虚拟环境对应的项目路径")
	flag.BoolVar(&cleanArg, "clean", false, "清除所有的配置信息")
	flag.BoolVar(&showArg, "show", false, "显示所有的配置信息")

	flag.Usage = usage
}

// 执行初始化任务
func init() {
	// flag相关初始化
	setFlagVar()
	flag.Parse()
	// 解析配置
	parseConfig()
}

// 配置文件自动管理
func parseConfig() {
	var configContent []byte
	// 读取配置文件
	for _, dir := range settingsDir {
		config, err := ioutil.ReadFile(dir)
		if err != nil {
			continue
		}
		configContent = config
		break
	}
	err := yaml.Unmarshal([]byte(configContent), &settings)
	if err != nil {
		os.Exit(notFound)
	}
	projects = settings.Projects
}

func main() {
	args := newArgsMap()
	if setArg != "" {
		args.set()
	} else if removeArg != "" {
		args.remove()
	} else if showArg != false {
		args.show()
	} else if cleanArg != false {
		args.clean()
	} else if getPathArg != "" {
		args.getPath()
	}
}
