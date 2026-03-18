# AI 协作方法论调研

> 调研 AI 辅助开发的业内最佳实践，结合本项目现状分析优化方向。
> 调研日期：2026-03-11

---

## 一、调研来源

| 来源 | 核心贡献 |
|------|---------|
| Addy Osmani — "How to write a good spec for AI agents"（O'Reilly） | Boundary 三级决策框架、spec 六领域模型 |
| GitHub Spec Kit + AWS SDD | Specify → Plan → Tasks → Implement 四阶段流水线 |
| David Lapsley — Spec-Driven LLM Development（SDLD） | 三文件结构（requirements.md / design.md / tasks.md） |
| Stanford IT — Practical Workflow for AI Coding Assistants（2025） | 时间戳 session notes + commit ID 绑定 + docs-as-code |
| GUARDRAILS.md 协议 | Sign 格式安全护栏、上下文容量管理、错误循环检测 |
| PROGRESS.md / MEMORIES.md 模式 | 持久记忆的两类文件：进度 + 经验教训 |
| Agent RuleZ（2026.02） | 确定性策略引擎、YAML 规则、<10ms 执行 |

---

## 二、业内共识：Spec-Driven Development（SDD）

### 核心流程

```
Specify（需求）→ Plan（设计）→ Tasks（任务分解）→ Implement（实现）
```

每个阶段门控下一个阶段，spec 而非代码是 source of truth。

### 解决的问题

- AI drift：指令模糊时 AI 实现偏离需求
- Vibe coding：无结构地 prompt → 接受生成代码，导致架构不一致、需求幻觉、返工
- 跨 session 失忆：新 session 不知道之前做了什么、踩过什么坑

### 三文件结构（AWS SDD 原型）

| 文件 | 内容 | 维护者 |
|------|------|--------|
| requirements.md | 用户故事、验收标准、边界条件 | 人 |
| design.md | 技术架构、数据模型、API 契约 | AI 生成，人审核 |
| tasks.md | 有序的原子任务列表，每个任务有验证标准 | AI 生成，人审核 |

---

## 三、Boundary 三级决策框架

Addy Osmani 基于 GitHub 对 2500+ agent 配置文件的分析，提出用三级决策替代冗长的指令列表：

| 级别 | 含义 | 示例 |
|------|------|------|
| Always do | AI 不需要问直接做 | 遵循编码规范、运行测试、更新文档 |
| Ask first | 需要人确认才做 | 新增依赖、修改 schema、改 API 签名 |
| Never do | 硬性禁止 | 删除生产数据、修改生成代码 |

核心洞察：更多指令反而降低 AI 表现（"curse of instructions"），三级框架比长列表更有效。

---

## 四、安全护栏（GUARDRAILS.md）

### Sign 格式

每条护栏由四部分组成：触发条件、指令、原因、来源。

### 关键护栏模式

| 模式 | 说明 |
|------|------|
| 错误循环检测 | 连续 N 次相同错误后停止，报告而非继续尝试 |
| 上下文容量管理 | 上下文超 80% 或连续 10+ 错误时重置 |
| 破坏性操作审批 | 删除、schema 变更前输出影响分析，等待确认 |
| 路径权限边界 | 明确禁止修改的目录（如 node_modules、生成代码） |
| 变更范围限制 | 单次迭代修改文件数上限 |

---

## 五、持久记忆模式

### 两类记忆文件

| 文件 | 性质 | 更新策略 |
|------|------|---------|
| PROGRESS.md | 当前状态快照 | 覆盖更新，保持最新 |
| MEMORIES.md / lessons.md | 累积经验库 | 只追加，压缩而非删除 |

### 最佳实践

- 记忆文件是压缩状态，不是日志 — 过时条目替换而非追加
- 不在记忆中存放代码片段或聊天记录
- session 开始时读取，compaction 前更新
- 大项目拆分为模块级记忆文件，主文件做索引

---

## 六、本项目现状对照

| 实践领域 | 业内标准 | 本项目现状 | 差距 |
|----------|---------|-----------|------|
| Specify（需求） | requirements.md | docs/prds/*.md | ✅ 超出标准 |
| Plan（设计） | design.md | docs/tech/*.md | ✅ 超出标准 |
| Tasks（任务分解） | tasks.md | ❌ 无 | 从 Plan 直接跳到 Implement |
| Boundary 决策 | 三级框架 | AGENTS.md 部分覆盖 | ⚠️ 缺 Ask first 层 |
| 安全护栏 | GUARDRAILS.md | .cursor/rules/ 部分覆盖 | ⚠️ 缺错误循环、变更范围限制 |
| 进度追踪 | PROGRESS.md | docs/ai2ai/status.md | ✅ 已覆盖 |
| 经验教训 | MEMORIES.md | docs/ai2ai/decisions.md | ⚠️ 范围偏窄，仅记录选型决策 |
| 迭代记录 | session notes + commit ID | docs/ai2ai/iterations/ | ✅ 已覆盖 |

---

## 七、优化建议（按优先级）

### P0: 加入 Tasks 层

在每次迭代前生成 `docs/ai2ai/tasks/NNN-xxx.md`，将迭代目标分解为有序的原子任务，每个任务有独立的验证标准。AI 生成，人审核后执行。tasks/ 和 iterations/ 共享编号、一一配对：task 定义"要做什么"（事前计划，过程中更新），iteration 记录"做完了什么"（事后归档）。

已落地：
- `docs/ai2ai/tasks/` 目录已创建
- `.cursor/rules/ai2ai-maintenance.mdc` 已包含完整的迭代工作流规则
- `AGENTS.md` 已更新文档结构说明

### P1: 定义 Boundary 三级决策

分两层落地：
- 抽象层：`.cursor/rules/ai-boundary-framework.mdc` — 三级决策体系的判断标准和迭代机制（跨项目可复用）
- 具体层：`AGENTS.md` 的"AI 决策边界"章节 — 本项目的 Always do / Ask first / Never do 规则（随实践持续补充）

已落地。

### P2: 扩展 decisions.md 为经验库

将 decisions.md 从纯"技术微决策"扩展为三类记录的统一经验库：
- D（技术微决策）：实现选型
- L（踩坑记录）：技术限制和绕过方案
- B（Boundary 变更）：决策边界规则的新增/调整

已落地。

### P3: 补充安全护栏规则

大部分护栏已被 P1 的 Boundary 覆盖（破坏性操作审批 = Ask first）。额外补充了两条：
- 错误循环检测：连续 3 次相同修复未成功时停止
- 变更范围感知：单次迭代修改超过 10 个文件时暂停确认

已落地到 `.cursor/rules/ai2ai-maintenance.mdc`。
