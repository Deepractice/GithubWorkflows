- mermaid 注意事项
  1. 将 @ 符号替换为引号，避免被识别为链接
  2. 将路径字符串用引号包裹，如 "~/.promptx/user/"
  3. 确保所有特殊字符都正确转义

- promptx 的日志打印需要使用utils中的 logger 而不是 console
- promptx 项目的运行日志在 ~/.promptx/logs

- 使用 pnpm 管理项目

- Claude Code 的项目日志在 ~/.claude/projects/ 目录

- 如果要测试 promptx-local 的功能，改了代码需要停下来等待用户重启才能继续测试

- 在修改工作流的代码时， 不是修改.github, .github 是 使用 make.js组装生成的

- 每次执行命令的时候，需要根据上下文判断当前所在目录，如果无法判断，就执行一下 pwd 确认

- 不要盲目的执行，执行前尽量的获得用户的肯定