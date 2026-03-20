# AI Collab Methodology

A spec-driven methodology and bootstrap toolkit for human-AI collaborative software development.

## What is this

A practical framework for working with AI coding assistants (Cursor, Windsurf, VS Code Copilot, etc.), covering the full lifecycle from requirements to implementation to testing.

### Core concepts

**me2ai / ai2ai document system** — Clear separation of responsibilities:
- **me2ai** (human-maintained): requirements, architecture, coding standards — "what it should be"
- **ai2ai** (AI-maintained, human-reviewed): project status, iteration records, lessons learned — "what it actually is"

**Iterative workflow** — Structured development cycle:
```
Clarify (optional) → Task (plan) → Branch → TDD + Self-review → Checklist (acceptance test) → Merge → Iteration (archive)
```

**Requirements clarification** — Before jumping to code:
- AI proactively asks questions about ambiguous requirements
- Explores boundaries of "what to do" vs "what not to do"
- Confirms understanding in digestible sections before creating task files

**Test-Driven Development (TDD)** — RED-GREEN-REFACTOR cycle:
- Write a failing test first → minimal implementation to pass → refactor → commit
- YAGNI: only implement what the test demands, nothing more
- Enforced for service/store/infra layers; UI covered by acceptance checklist

**AI self-review** — After each task completion:
- Spec compliance, code quality, test coverage, regression impact
- Issues fixed before marking task as done

**Branch isolation** — Each iteration works on a feature branch:
- Create `iter/NNN-xxx` from main; merge back via PR after tests pass
- Failed iterations can be safely discarded

**Git workflow (Agent-Driven GitHub Flow)** — Supports parallel multi-agent development:
- `main` is the only long-lived branch; iteration branches merge via PR
- Multiple AI agents work on different branches simultaneously
- `release/X.Y` branches for versioned releases (when needed)
- PR serves as permanent record of each iteration (goals, changes, test results)
- Alternative: Environment Branch Flow (`--git-flow env-branch`) for server projects where `main` = production, `dev` = staging

**Subagent-driven development** (optional) — For parallel independent tasks:
- Each subagent handles one task with full context
- Main agent dispatches and reviews (spec compliance + code quality)

**Testing checklist** — AI generates, human reviews and executes:
- Acceptance tests derived from task acceptance criteria
- Regression tests inherited from previous iterations
- Defect feedback loop with in-iteration fixes
- Global test suite for long-term regression

**Boundary framework** — Three-level AI decision system:
- **Always do**: safe operations, execute without asking
- **Ask first**: operations with side effects, explain intent and wait
- **Never do**: hard stops, forbidden even if requested

**Safety guardrails**:
- Error loop detection (stop after 3 failed attempts)
- Change scope awareness (pause if modifying 10+ files)

**Experience library** — Persistent cross-session memory:
- Technical micro-decisions (D)
- Lessons learned / pitfalls (L)
- Boundary changes (B)

## Quick start

```bash
# Clone this repo
git clone https://github.com/xkos/ai-collab-methodology.git

# Initialize a new project (default: Cursor IDE)
./ai-collab-methodology/bootstrap.sh ~/projects/my-new-app

# Specify IDE
./ai-collab-methodology/bootstrap.sh --ide windsurf ~/projects/my-new-app
./ai-collab-methodology/bootstrap.sh --ide vscode ~/projects/my-new-app
./ai-collab-methodology/bootstrap.sh --ide none ~/projects/my-new-app  # plain markdown

# Specify project name
./ai-collab-methodology/bootstrap.sh --project-name "MyApp" ~/projects/my-new-app

# Use environment branch flow (for server projects: main=production, dev=staging)
./ai-collab-methodology/bootstrap.sh --git-flow env-branch ~/projects/my-server-app

# Include language-specific coding conventions
./ai-collab-methodology/bootstrap.sh --lang rust ~/projects/my-rust-app

# Include language-specific conventions + skills
./ai-collab-methodology/bootstrap.sh --lang flutter ~/projects/my-flutter-app

# Dry run (preview without creating files)
./ai-collab-methodology/bootstrap.sh --dry-run ~/projects/my-new-app
```

## What the bootstrap creates

```
your-project/
├── AGENTS.md                          ← Project skeleton (needs filling)
├── .agents/skills/                    ← Agent Skills (on-demand, not always loaded)
│   ├── git-workflow/SKILL.md          ← Branch management, PR, release workflow
│   ├── git-commit-summary/SKILL.md   ← Change analysis, grouping, commit message generation
│   └── <lang>-*/SKILL.md             ← Language-specific skills (optional, via --lang)
├── docs/
│   ├── prds/                          ← Product requirements
│   ├── tech/                          ← Technical docs
│   ├── session-context.md             ← New session context template (user reference)
│   ├── project-methodology.md         ← Zero-to-one methodology (user reference)
│   └── ai2ai/
│       ├── status.md                  ← Project status snapshot
│       ├── checklist.md               ← Acceptance test checklist
│       ├── test-suite.md              ← Global test suite
│       ├── decisions.md               ← Experience library
│       ├── tasks/                     ← Iteration task breakdowns
│       └── iterations/                ← Iteration archives
└── <rules-dir>/                       ← IDE-specific location (3 rules)
    ├── ai2ai-maintenance.*            ← Iteration workflow rules (alwaysApply)
    ├── ai-boundary-framework.*        ← Three-level decision framework (alwaysApply)
    ├── ui-prototype.*                 ← HTML prototype spec (on-demand, globs: ui-preview/**)
    └── <lang>-conventions.*           ← Language conventions (optional, via --lang)
```

## After bootstrap

The script creates structure and universal rules. Project-specific content is generated by AI using the bootstrap prompt:

1. Open `bootstrap-prompt.md` in this repo
2. Copy the prompt, replace `{{...}}` placeholders with your project info
3. Send to your AI assistant
4. AI fills in AGENTS.md, status.md, and generates the first task file
5. Review, confirm, and start your first iteration

## Supported IDEs

| IDE | Rules directory | File format |
|-----|----------------|-------------|
| Cursor | `.cursor/rules/` | `.mdc` (with frontmatter) |
| Windsurf | `.windsurf/rules/` | `.md` |
| VS Code | `.vscode/rules/` | `.md` |
| none | `rules/` | `.md` (plain markdown) |

## Repository structure

```
ai-collab-methodology/
├── bootstrap.sh               ← Bootstrap script
├── bootstrap-prompt.md        ← Prompt template for AI to fill project-specific content
├── docs/
│   └── methodology.md         ← Research background and design decisions
└── templates/
    ├── rules/                 ← Universal rule templates (IDE-agnostic)
    │   ├── ai2ai-maintenance.md
    │   ├── ai-boundary-framework.md
    │   ├── ui-prototype.md
    │   └── lang-examples/     ← Language-specific convention examples (optional, via --lang)
    │       └── rust-conventions.md
    ├── skills/                ← Agent Skills templates (on-demand capabilities)
    │   ├── git-workflow/      ← Branch management, PR, release workflow
    │   ├── git-commit-summary/ ← Change analysis, grouping, commit messages
    │   ├── ui-design-conventions/ ← UI design conventions template (framework-agnostic)
    │   └── lang-examples/     ← Language-specific skill examples (optional, via --lang)
    │       └── flutter/       ← Flutter desktop design skill
    ├── session-context.md     ← New session context template (user reference, not a rule)
    ├── project-methodology.md ← Zero-to-one methodology (user reference, not a rule)
    ├── ai2ai/                 ← ai2ai document templates
    └── docs/                  ← AGENTS.md skeleton template
```

## Methodology sources

Built on top of established practices:
- [Addy Osmani — How to write a good spec for AI agents](https://addyosmani.com/blog/good-spec/) — Boundary framework
- [GitHub Spec Kit](https://github.com/github/spec-kit) / AWS SDD — Specify → Plan → Tasks → Implement
- [GUARDRAILS.md](https://guardrails.md/) — Safety guardrail protocol
- PROGRESS.md / MEMORIES.md — Persistent memory patterns
- Stanford IT — docs-as-code workflow
- [obra/superpowers](https://github.com/obra/superpowers) — TDD, requirements clarification, self-review, subagent-driven development

## License

[Apache License 2.0](LICENSE)

---

# 中文文档

## 这是什么

一套面向人-AI 协作开发的规范驱动方法论和引导工具包，适用于 Cursor、Windsurf、VS Code Copilot 等 AI 编码助手，覆盖从需求到实现到测试的完整生命周期。

### 核心概念

**me2ai / ai2ai 文档体系** — 清晰的职责分离：
- **me2ai**（人维护）：需求、架构、编码规范 — "应该是什么样"
- **ai2ai**（AI 维护，人审核）：项目状态、迭代记录、经验教训 — "现在实际是什么样"

**迭代工作流** — 结构化的开发循环：
```
澄清（按需）→ Task（事前计划）→ 分支 → TDD + 自审 → Checklist（验收测试）→ 合并 → Iteration（事后归档）
```

**需求澄清** — 写代码之前先厘清需求：
- AI 主动对模糊需求提问
- 探明"做什么"和"不做什么"的边界
- 分段确认理解后再建 task 文件

**测试驱动开发（TDD）** — 红-绿-重构循环：
- 先写失败测试 → 最小实现让测试通过 → 重构 → 提交
- YAGNI：只实现测试要求的行为，不提前预设未来需求
- service/store/infra 层强制，UI 层由验收 checklist 覆盖

**AI 自审** — 每个 task 完成后检查：
- 规格合规、代码质量、测试覆盖、回归影响
- 发现问题立即修复，修复后再标记完成

**分支隔离** — 每个迭代在独立分支上工作：
- 从主分支创建 `iter/NNN-xxx`，测试通过后通过 PR 合并回主分支
- 失败的迭代可以安全丢弃

**Git 工作流（Agent-Driven GitHub Flow）** — 支持多 Agent 并行开发：
- `main` 是唯一长期分支，迭代分支通过 PR 合并
- 多个 AI Agent 可同时在不同分支上工作，各自提 PR
- `release/X.Y` 分支用于版本发布（按需启用）
- PR 作为每个迭代的永久记录（目标、变更、测试结果）
- 可选：环境分支流（`--git-flow env-branch`），适用于 `main` 绑定生产、`dev` 绑定测试的服务端项目

**子代理驱动开发**（可选）— 独立任务并行执行：
- 每个子代理处理一个独立任务，携带完整上下文
- 主代理负责分发和双轮 review（规格合规 + 代码质量）

**测试 Checklist** — AI 生成，人审核和执行：
- 从 task 验收标准展开的功能验收测试
- 从上一迭代自动继承的回归测试
- 缺陷反馈环：失败项区分当轮修复 / 下轮修复
- 全局用例库：沉淀长期回归用例

**三级决策边界** — AI 行为的决策框架：
- **Always do**：安全操作，直接执行
- **Ask first**：有副作用的操作，说明意图后等确认
- **Never do**：硬性禁止，即使用户要求也应提醒风险

**安全护栏**：
- 错误循环检测（连续 3 次相同修复失败后停止）
- 变更范围感知（修改超过 10 个文件时暂停确认）

**经验库** — 跨 session 持久化记忆：
- 技术微决策（D）
- 踩坑记录（L）
- Boundary 变更（B）

## 快速开始

```bash
# 克隆本仓库
git clone https://github.com/xkos/ai-collab-methodology.git

# 初始化新项目（默认 Cursor IDE）
./ai-collab-methodology/bootstrap.sh ~/projects/my-new-app

# 指定 IDE
./ai-collab-methodology/bootstrap.sh --ide windsurf ~/projects/my-new-app
./ai-collab-methodology/bootstrap.sh --ide vscode ~/projects/my-new-app
./ai-collab-methodology/bootstrap.sh --ide none ~/projects/my-new-app  # 纯 markdown

# 指定项目名称
./ai-collab-methodology/bootstrap.sh --project-name "MyApp" ~/projects/my-new-app

# 使用环境分支流（服务端项目：main=生产，dev=测试）
./ai-collab-methodology/bootstrap.sh --git-flow env-branch ~/projects/my-server-app

# 包含语言特定的编码规范
./ai-collab-methodology/bootstrap.sh --lang rust ~/projects/my-rust-app

# 包含语言特定的编码规范 + skills
./ai-collab-methodology/bootstrap.sh --lang flutter ~/projects/my-flutter-app

# 预览（不实际创建文件）
./ai-collab-methodology/bootstrap.sh --dry-run ~/projects/my-new-app
```

## 脚本创建的结构

```
你的项目/
├── AGENTS.md                          ← 项目骨架（需要填充）
├── .agents/skills/                    ← Agent Skills（按需加载，不常驻上下文）
│   ├── git-workflow/SKILL.md          ← 分支管理、PR、发布工作流
│   ├── git-commit-summary/SKILL.md   ← 变更分析、分组、提交信息生成
│   └── <lang>-*/SKILL.md             ← 语言特定 skills（可选，通过 --lang 指定）
├── docs/
│   ├── prds/                          ← 产品需求文档
│   ├── tech/                          ← 技术文档
│   ├── session-context.md             ← 新 session 上下文模板（用户参考）
│   ├── project-methodology.md         ← 从零到一方法论（用户参考）
│   └── ai2ai/
│       ├── status.md                  ← 项目状态快照
│       ├── checklist.md               ← 验收测试清单
│       ├── test-suite.md              ← 全局用例库
│       ├── decisions.md               ← 经验库
│       ├── tasks/                     ← 迭代任务分解
│       └── iterations/                ← 迭代归档
└── <rules-dir>/                       ← 根据 IDE 不同（3 条规则）
    ├── ai2ai-maintenance.*            ← 迭代工作流规则（alwaysApply）
    ├── ai-boundary-framework.*        ← 三级决策框架（alwaysApply）
    ├── ui-prototype.*                 ← HTML 原型规范（按需加载，globs: ui-preview/**）
    └── <lang>-conventions.*           ← 语言编码规范（可选，通过 --lang 指定）
```

## 脚本之后做什么

脚本只创建结构和通用规则。项目相关的内容需要用 bootstrap prompt 引导 AI 生成：

1. 打开本仓库中的 `bootstrap-prompt.md`
2. 复制 prompt，替换 `{{...}}` 占位符为你的项目信息
3. 发送给 AI 助手
4. AI 会填充 AGENTS.md、status.md，并生成第一个 task 文件
5. 审核确认后，开始第一个迭代

## 支持的 IDE

| IDE | rules 目录 | 文件格式 |
|-----|-----------|---------|
| Cursor | `.cursor/rules/` | `.mdc`（带 frontmatter） |
| Windsurf | `.windsurf/rules/` | `.md` |
| VS Code | `.vscode/rules/` | `.md` |
| none | `rules/` | `.md`（纯 markdown） |

## 仓库结构

```
ai-collab-methodology/
├── bootstrap.sh               ← 初始化脚本
├── bootstrap-prompt.md        ← AI 填充项目内容的 prompt 模板
├── docs/
│   └── methodology.md         ← 调研背景和设计决策
└── templates/
    ├── rules/                 ← 通用规则模板（IDE 无关）
    │   ├── ai2ai-maintenance.md
    │   ├── ai-boundary-framework.md
    │   ├── ui-prototype.md
    │   └── lang-examples/     ← 语言编码规范示例（可选，通过 --lang 指定）
    │       └── rust-conventions.md
    ├── skills/                ← Agent Skills 模板（按需加载的能力）
    │   ├── git-workflow/      ← 分支管理、PR、发布工作流
    │   ├── git-commit-summary/ ← 变更分析、分组、提交信息生成
    │   ├── ui-design-conventions/ ← UI 设计规范模板（框架无关）
    │   └── lang-examples/     ← 语言特定 skill 示例（可选，通过 --lang 指定）
    │       └── flutter/       ← Flutter 桌面端设计规范
    ├── session-context.md     ← 新 session 上下文模板（用户参考，非规则）
    ├── project-methodology.md ← 从零到一方法论（用户参考，非规则）
    ├── ai2ai/                 ← ai2ai 文档模板
    └── docs/                  ← AGENTS.md 骨架模板
```

## 方法论来源

基于以下业内实践整合：
- [Addy Osmani — How to write a good spec for AI agents](https://addyosmani.com/blog/good-spec/) — 三级决策边界框架
- [GitHub Spec Kit](https://github.com/github/spec-kit) / AWS SDD — Specify → Plan → Tasks → Implement
- [GUARDRAILS.md](https://guardrails.md/) — 安全护栏协议
- PROGRESS.md / MEMORIES.md — 持久记忆模式
- Stanford IT — docs-as-code 工作流
- [obra/superpowers](https://github.com/obra/superpowers) — TDD、需求澄清、自审、子代理驱动开发

## 许可证

[Apache License 2.0](LICENSE)
