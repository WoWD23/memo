# Git 设置说明

## 已完成的设置

1. ✅ 初始化 Git 仓库
2. ✅ 配置 `.gitignore` 文件
3. ✅ 添加所有项目文件到暂存区

## 需要完成的设置

### 设置 Git 用户信息

在创建提交之前，您需要设置 Git 用户信息。可以选择以下方式之一：

#### 方式 1: 为当前项目设置（推荐）

```powershell
git config user.name "Your Name"
git config user.email "your.email@example.com"
```

#### 方式 2: 全局设置（所有 Git 项目）

```powershell
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### 创建初始提交

设置完用户信息后，运行：

```powershell
git commit -m "feat: 初始化 Memo 项目

- 添加 Flutter 项目基础结构
- 实现 MVVM 架构
- 实现番茄钟功能（时间选择器和倒计时）
- 实现自定义底部导航栏
- 添加项目开发规范和里程碑文档
- 配置 Flutter 开发环境设置"
```

### 查看 Git 状态

```powershell
git status
```

### 查看提交历史

```powershell
git log
```

## 后续操作

### 连接远程仓库（可选）

如果需要将代码推送到 GitHub/GitLab 等远程仓库：

```powershell
# 添加远程仓库
git remote add origin <repository-url>

# 推送到远程仓库
git push -u origin master
```

### 常用 Git 命令

```powershell
# 查看状态
git status

# 添加文件
git add <file>

# 提交更改
git commit -m "commit message"

# 查看提交历史
git log

# 创建新分支
git checkout -b <branch-name>

# 切换分支
git checkout <branch-name>

# 合并分支
git merge <branch-name>
```

