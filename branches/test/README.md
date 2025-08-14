# 分支策略测试

> 测试分支保护规则和工作流

## 测试内容

### 1. 分支保护规则（不能用 act 测试）

分支保护规则是 GitHub 的设置，需要通过 API 配置：
- ❌ 不能用 act 测试
- ✅ 可以用 `validate.sh` 验证配置
- ✅ 可以用 `check-protection.js` 检查 API

### 2. 分支工作流（可以用 act 测试）

可以测试的工作流：
- ✅ 分支命名检查
- ✅ 合并方向验证
- ✅ 自动标签
- ✅ 分支清理

## 测试方法

### 方法 1：验证配置文件

```bash
# 验证 YAML 语法
./test/validate.sh

# 检查配置完整性
./test/check-config.js
```

### 方法 2：测试工作流

```bash
# 测试分支命名检查
make test-branch-naming

# 测试合并规则
make test-merge-rules

# 测试所有
make test
```

### 方法 3：模拟 GitHub API

```bash
# 模拟应用保护规则
./test/mock-protection.js --branch=main --dry-run

# 验证保护规则是否正确
./test/verify-protection.js --branch=main
```

## 测试用例

### 分支命名测试

```yaml
测试用例:
  合法分支名:
    - feature/user-auth ✅
    - fix/memory-leak ✅
    - docs/readme ✅
    
  非法分支名:
    - feat/test ❌ (应该是 feature)
    - bug/fix ❌ (应该是 fix)
    - Feature/Test ❌ (应该小写)
```

### 合并方向测试

```yaml
测试用例:
  允许的合并:
    - feature/* → develop ✅
    - develop → main ✅
    - hotfix/* → main ✅
    
  禁止的合并:
    - feature/* → main ❌
    - main → develop ❌
    - feature/* → feature/* ❌
```

## 文件结构

```
test/
├── fixtures/               # 测试数据
│   ├── valid-branch.json
│   ├── invalid-branch.json
│   └── merge-scenarios.json
│
├── workflows/             # 可测试的工作流
│   ├── branch-check.yml
│   └── merge-check.yml
│
├── scripts/              # 测试脚本
│   ├── validate.sh      # 验证配置
│   ├── check-config.js  # 检查完整性
│   └── mock-api.js      # 模拟 API
│
└── Makefile             # 测试命令
```