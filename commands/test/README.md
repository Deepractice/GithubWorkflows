# /test 命令

> 在 PR 或 Issue 中运行各种类型的测试

## 概述

`/test` 命令用于在 GitHub Actions 环境中运行项目测试，支持多种测试类型和框架。

## 使用方法

### 基本语法

```bash
/test [type]
```

### 支持的测试类型

| 类型 | 说明 | 默认行为 |
|-----|------|---------|
| `all` | 运行所有测试（默认） | 执行完整测试套件 |
| `unit` | 单元测试 | 只运行单元测试 |
| `integration` | 集成测试 | 只运行集成测试 |
| `e2e` | 端到端测试 | 只运行 E2E 测试 |
| `coverage` | 测试覆盖率 | 运行测试并生成覆盖率报告 |

## 使用示例

### 在 PR 评论中使用

```bash
# 运行所有测试
/test

# 只运行单元测试
/test unit

# 运行集成测试
/test integration

# 运行 E2E 测试
/test e2e

# 生成测试覆盖率
/test coverage
```

## 框架自动检测

命令会自动检测项目使用的测试框架：

### Node.js 项目

检测标志：`package.json`

```json
{
  "scripts": {
    "test": "jest",
    "test:unit": "jest unit",
    "test:integration": "jest integration",
    "test:e2e": "cypress run",
    "test:coverage": "jest --coverage"
  }
}
```

支持的包管理器：
- npm (package-lock.json)
- yarn (yarn.lock)
- pnpm (pnpm-lock.yaml)

### Python 项目

检测标志：`setup.py`、`pyproject.toml` 或 `requirements.txt`

默认测试命令：
- `unit`: `python -m pytest tests/unit -v`
- `integration`: `python -m pytest tests/integration -v`
- `e2e`: `python -m pytest tests/e2e -v`
- `coverage`: `python -m pytest --cov=. --cov-report=term-missing`
- `all`: `python -m pytest`

### Go 项目

检测标志：`go.mod`

默认测试命令：
- `unit`: `go test -short ./...`
- `integration`: `go test -run Integration ./...`
- `e2e`: `go test -run E2E ./...`
- `coverage`: `go test -coverprofile=coverage.out ./...`
- `all`: `go test -v ./...`

### Makefile 项目

检测标志：`Makefile`

查找目标：
- `test-unit` 或 `test`
- `test-integration`
- `test-e2e`
- `test-coverage` 或 `coverage`

## 测试结果

测试完成后，机器人会回复测试结果：

### 成功示例

```markdown
### ✅ Test Results: PASSED

**Test Type:** unit
**Framework:** node
**Command:** `npm run test:unit`

<details>
<summary>Test Output (last 50 lines)</summary>

```
Test Suites: 12 passed, 12 total
Tests:       142 passed, 142 total
Snapshots:   0 total
Time:        15.234s
```

</details>

📝 [View full logs](link-to-github-actions)
```

### 失败示例

```markdown
### ❌ Test Results: FAILED

**Test Type:** integration
**Framework:** python
**Command:** `python -m pytest tests/integration -v`

<details>
<summary>Test Output (last 50 lines)</summary>

```
FAILED tests/integration/test_api.py::test_user_creation
AssertionError: Expected 201, got 500
```

</details>

📝 [View full logs](link-to-github-actions)
```

## 自定义配置

### 方法 1：使用 package.json scripts（Node.js）

```json
{
  "scripts": {
    "test": "jest",
    "test:unit": "jest --testMatch='**/*.unit.test.js'",
    "test:integration": "jest --testMatch='**/*.int.test.js'",
    "test:e2e": "playwright test",
    "test:coverage": "jest --coverage --coverageReporters=text-lcov"
  }
}
```

### 方法 2：使用 Makefile

```makefile
test:
	@echo "Running all tests..."
	@npm test

test-unit:
	@echo "Running unit tests..."
	@npm run test:unit

test-integration:
	@echo "Running integration tests..."
	@npm run test:integration

test-e2e:
	@echo "Running E2E tests..."
	@npm run test:e2e

test-coverage:
	@echo "Generating coverage report..."
	@npm run test:coverage
```

## 权限要求

- `contents: read` - 读取代码
- `issues: write` - 在 Issue 中评论
- `pull-requests: write` - 在 PR 中评论
- `checks: write` - 创建检查运行

## 最佳实践

1. **组织测试文件**
   ```
   tests/
   ├── unit/        # 单元测试
   ├── integration/ # 集成测试
   └── e2e/         # E2E 测试
   ```

2. **命名约定**
   - 单元测试：`*.unit.test.js` 或 `*_test.go`
   - 集成测试：`*.int.test.js` 或 `*_integration_test.go`
   - E2E 测试：`*.e2e.test.js` 或 `*_e2e_test.go`

3. **快速反馈**
   - 单元测试应该快速运行（< 30秒）
   - 集成测试可以稍慢（< 2分钟）
   - E2E 测试可能需要更长时间

## 故障排除

### 测试命令未找到

确保在 `package.json`、`Makefile` 或对应配置中定义了测试脚本。

### 依赖安装失败

检查：
- Node.js: `package-lock.json` 是否存在且最新
- Python: `requirements.txt` 包含所有测试依赖
- Go: `go.mod` 和 `go.sum` 是否完整

### 测试超时

GitHub Actions 有作业超时限制（默认 6 小时）。考虑：
- 拆分大型测试套件
- 并行运行测试
- 使用 `/test unit` 只运行必要的测试