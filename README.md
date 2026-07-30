# Delegate to Grok

一个可同时用于 Codex 和 Claude Code 的 Agent Skill。它把范围明确、机械且可验证的编码执行任务交给本机 Grok Build，当前 Agent 保留需求判断、代码审查和最终验证。

## 前置条件

支持 macOS、Linux 或 WSL，并需要：

- Git
- Bash
- 已安装并登录的 Grok Build CLI

按照 [Grok Build 官方文档](https://docs.x.ai/build/overview) 安装，或运行：

```bash
curl -fsSL https://x.ai/cli/install.sh | bash
grok login
grok --version
```

## 安装 Skill

克隆仓库：

```bash
mkdir -p "${XDG_DATA_HOME:-$HOME/.local/share}"

git clone https://github.com/hon94csl/grok-skill.git \
  "${XDG_DATA_HOME:-$HOME/.local/share}/grok-skill"
```

同时安装到 Codex 和 Claude Code：

```bash
mkdir -p "$HOME/.codex/skills" "$HOME/.claude/skills"

ln -s "${XDG_DATA_HOME:-$HOME/.local/share}/grok-skill/delegate-to-grok" \
  "$HOME/.codex/skills/delegate-to-grok"

ln -s "${XDG_DATA_HOME:-$HOME/.local/share}/grok-skill/delegate-to-grok" \
  "$HOME/.claude/skills/delegate-to-grok"
```

也可以只执行其中一条 `ln -s`，仅安装到对应工具。安装后重新启动 Codex 或 Claude Code 会话。

如果目标路径已经存在，`ln` 会安全失败而不会覆盖。请先检查现有安装：

```bash
ls -ld \
  "$HOME/.codex/skills/delegate-to-grok" \
  "$HOME/.claude/skills/delegate-to-grok"
```

确认旧路径是需要替换的符号链接后，再使用 `unlink <路径>` 删除它并重新执行安装命令。不要使用 `ln -sf` 覆盖未知文件或目录。

## 使用

Codex 中显式调用：

```text
$delegate-to-grok 按照现有 service 模式补齐用户状态更新和测试
```

Claude Code 中显式调用：

```text
/delegate-to-grok 按照现有 service 模式补齐用户状态更新和测试
```

当任务满足以下条件时，Agent 也可以自动加载该 Skill：

- 行为已经确定，不再需要产品或架构决策；
- 修改范围可以明确限定；
- 任务具有重复性、涉及多个文件，或预计直接执行超过一分钟；
- 可以通过测试、构建、lint 或代码检查客观验证。

安全、权限、支付、生产操作、破坏性操作、需求含糊或极小的修改不会被委派。

## 配置

脚本默认使用低推理强度、最多 8 turns，并关闭 Grok 的联网、记忆和子代理。可以在调用环境中覆盖：

```bash
export GROK_MODEL="<model-id>"
export GROK_MAX_TURNS=12
export GROK_REASONING_EFFORT=medium
```

支持的推理强度为 `none`、`low`、`medium`、`high`、`xhigh` 和 `max`。

## 更新

```bash
git -C "${XDG_DATA_HOME:-$HOME/.local/share}/grok-skill" pull --ff-only
```

符号链接会继续指向更新后的 Skill，无需重新安装。

## 卸载

仅移除 Skill 链接并保留克隆的仓库：

```bash
unlink "$HOME/.codex/skills/delegate-to-grok"
unlink "$HOME/.claude/skills/delegate-to-grok"
```
