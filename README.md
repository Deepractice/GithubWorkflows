# GitHub Workflows

> 🎯 **可复用的 GitHub 工作流集合** - 通过 git submodule 为任何项目提供生产级的 CI/CD 能力

## 设计理念

### 核心原则

1. **通用优先** - 优先实现所有项目都需要的功能（如版本管理），而非特定语言功能
2. **零侵入** - 通过 submodule + 软链接使用，不污染项目代码
3. **评论驱动** - 使用 PR 评论作为命令接口，直观且有历史记录
4. **Shell 实现** - 核心逻辑用 Shell 实现，确保跨语言通用性

### 架构设计

```yaml
GithubWorkflows/
├── common/                    # 通用功能（所有项目可用）
│   ├── commands/             # 斜杠命令
│   │   └── changeset/        # 版本管理
│   └── workflows/            # 通用工作流
├── node/                     # Node.js 生态
│   ├── workflows/            # Node 特定工作流
│   └── actions/              # Node 特定 actions
├── python/                   # Python 生态（规划中）
└── java/                     # Java 生态（规划中）
```

### 设计决策

- **为什么不放在 `.github`**：本仓库就是工作流集合，不是使用者
- **为什么用斜杠命令**：符合业界标准（Kubernetes、GitHub），学习成本低
- **为什么分 common 和生态目录**：通用功能复用，特定功能隔离

## 快速开始

### 1. 添加到你的项目

```bash
# 在你的项目根目录
git submodule add https://github.com/Deepractice/GithubWorkflows .github-workflows

# 初始化（如果 clone 了包含 submodule 的项目）
git submodule update --init --recursive
```

### 2. 使用通用功能

```bash
# 创建 .github/workflows 目录
mkdir -p .github/workflows

# 链接需要的工作流
ln -s ../../.github-workflows/common/commands/changeset/changeset.yml .github/workflows/changeset.yml
```

### 3. 使用生态特定功能

```bash
# Node.js 项目额外链接
ln -s ../../.github-workflows/node/workflows/npm-publish.yml .github/workflows/npm-publish.yml

# Python 项目（未来）
ln -s ../../.github-workflows/python/workflows/pypi-publish.yml .github/workflows/pypi-publish.yml
```

## 功能列表

### 🌍 通用功能 (common/)

#### `/changeset` - 版本管理命令
在 PR 评论中管理版本变更：
```bash
/changeset patch              # Bug 修复
/changeset minor              # 新功能
/changeset major              # 破坏性变更
```
[详细文档](./common/commands/changeset/README.md)

### 📦 Node.js 生态 (node/)

- **npm-publish.yml** - NPM 包发布流程（开发中）
- **pnpm-setup** - pnpm 环境配置（开发中）

### 🐍 Python 生态 (python/)

规划中...

## 使用示例

### 基础项目配置

```yaml
# 你的项目结构
my-project/
├── .github/
│   └── workflows/
│       ├── changeset.yml -> ../../.github-workflows/common/commands/changeset/changeset.yml
│       └── ci.yml         # 你自己的 CI
├── .github-workflows/     # submodule
├── src/
└── package.json
```

### 在 PR 中使用

1. 创建 Pull Request
2. 在评论中输入命令：
   ```
   /changeset minor 添加了深色模式支持
   ```
3. 机器人自动创建 changeset 文件并提交到 PR

## 最佳实践

### ✅ 推荐做法

1. **选择性链接** - 只链接需要的工作流，不要全部复制
2. **保持更新** - 定期更新 submodule 获取最新功能
   ```bash
   git submodule update --remote --merge
   ```
3. **自定义配置** - 通过环境变量和 secrets 配置，不要修改工作流文件

### ❌ 避免做法

1. **不要直接复制文件** - 使用 submodule + 软链接，便于更新
2. **不要修改工作流** - 通过 PR 向本仓库贡献改进
3. **不要混用版本** - 保持 submodule 在一个稳定版本

## 测试方法

我们使用 `act` 在本地测试 GitHub Actions 工作流，无需推送代码。

### 测试结构

每个工作流都包含测试：
```yaml
command-name/
├── workflow.yml      # 工作流文件
├── README.md        # 文档
└── test/           # 测试目录
    ├── Makefile    # 测试命令
    └── fixtures/   # 测试数据（模拟的 GitHub 事件）
```

### 运行测试

```bash
# 安装 act (首次运行)
brew install act

# 进入测试目录
cd common/commands/changeset/test

# 运行所有测试
make test

# 运行单个测试
make test-patch

# 查看可用命令
make help
```

### 测试原则

- **使用 act 模拟** - 在本地模拟 GitHub Actions 环境
- **测试真实工作流** - 测试实际的 yml 文件，而非逻辑片段
- **覆盖主要场景** - 正常路径、错误处理、边界情况
- **快速反馈** - 本地运行，无需推送到 GitHub

## 贡献指南

欢迎贡献新的工作流或改进现有功能！

1. Fork 本仓库
2. 创建功能分支
3. 遵循现有目录结构
4. 提供清晰的文档
5. **编写测试** - 使用 act 测试你的工作流
6. 提交 PR

### 开发原则

- **通用性** - 新功能应该对多数项目有用
- **简单性** - 遵循奥卡姆剃刀原则，不过度设计
- **文档完整** - 每个工作流都需要 README
- **可测试** - 必须提供 act 测试

## 路线图

- [x] Changeset 版本管理命令
- [ ] NPM 发布工作流
- [ ] 通用 CI 模板
- [ ] PR 自动检查
- [ ] Python 生态支持
- [ ] Java 生态支持
- [ ] 性能测试工作流
- [ ] 安全扫描工作流

## 许可证

MIT

## 相关项目

- [Changesets](https://github.com/changesets/changesets) - 版本管理工具
- [GitHub Actions](https://docs.github.com/actions) - GitHub 官方文档

---

> 💡 **设计哲学**：工作流应该像乐高积木，按需组合，而非一体化方案。