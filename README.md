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

## 一键安装

同时安装到 Codex 和 Claude Code 的个人级目录：

```bash
curl -fsSL https://raw.githubusercontent.com/hon94csl/grok-skill/main/install.sh | bash
```

仅安装到当前 Git 项目：

```bash
curl -fsSL https://raw.githubusercontent.com/hon94csl/grok-skill/main/install.sh \
  | bash -s -- --project .
```

脚本可以重复运行：已有正确安装会被保留，技能源会通过 `git pull --ff-only` 更新；遇到未知文件、目录或指向其他位置的符号链接时会停止，不会强制覆盖。

项目模式会安装到 `.agents/skills` 和 `.claude/skills`，并把生成的本机符号链接加入 `.git/info/exclude`，不会修改项目的 `.gitignore`。

## 手动安装

克隆仓库：

```bash
mkdir -p "${XDG_DATA_HOME:-$HOME/.local/share}"

git clone https://github.com/hon94csl/grok-skill.git \
  "${XDG_DATA_HOME:-$HOME/.local/share}/grok-skill"
```

同时安装到 Codex 和 Claude Code：

```bash
mkdir -p "$HOME/.agents/skills" "$HOME/.claude/skills"

ln -s "${XDG_DATA_HOME:-$HOME/.local/share}/grok-skill/delegate-to-grok" \
  "$HOME/.agents/skills/delegate-to-grok"

ln -s "${XDG_DATA_HOME:-$HOME/.local/share}/grok-skill/delegate-to-grok" \
  "$HOME/.claude/skills/delegate-to-grok"
```

也可以只执行其中一条 `ln -s`，仅安装到对应工具。安装后重新启动 Codex 或 Claude Code 会话。

如果目标路径已经存在，`ln` 会安全失败而不会覆盖。请先检查现有安装：

```bash
ls -ld \
  "$HOME/.agents/skills/delegate-to-grok" \
  "$HOME/.claude/skills/delegate-to-grok"
```

确认旧路径是需要替换的符号链接后，再使用 `unlink <路径>` 删除它并重新执行安装命令。不要使用 `ln -sf` 覆盖未知文件或目录。

## 仅安装到当前项目

如果只希望当前项目使用该 Skill，先进入目标 Git 仓库，然后将同一份技能源链接到项目级目录：

```bash
cd /path/to/your/project

PROJECT_ROOT="$(git rev-parse --show-toplevel)"
SKILL_SOURCE="${XDG_DATA_HOME:-$HOME/.local/share}/grok-skill/delegate-to-grok"

mkdir -p "$PROJECT_ROOT/.agents/skills" "$PROJECT_ROOT/.claude/skills"

ln -s "$SKILL_SOURCE" \
  "$PROJECT_ROOT/.agents/skills/delegate-to-grok"

ln -s "$SKILL_SOURCE" \
  "$PROJECT_ROOT/.claude/skills/delegate-to-grok"
```

- [Codex](https://developers.openai.com/codex/skills) 从项目内 `.agents/skills` 加载 Skill。
- [Claude Code](https://code.claude.com/docs/en/skills) 从项目内 `.claude/skills` 加载 Skill。
- 这种方式只影响当前项目，不会让其他项目自动使用该 Skill。

这些符号链接包含当前机器的绝对路径，不适合提交给团队。若项目使用 Git，请将下面两条路径加入项目的 `.gitignore` 或 `.git/info/exclude`：

```gitignore
/.agents/skills/delegate-to-grok
/.claude/skills/delegate-to-grok
```

如果对应项目级技能目录是在当前会话启动后首次创建，请重新启动 Codex 或 Claude Code。

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
unlink "$HOME/.agents/skills/delegate-to-grok"
unlink "$HOME/.claude/skills/delegate-to-grok"
```
