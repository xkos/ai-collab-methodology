---
name: git-workflow
description: Agent-Driven Environment Branch Flow for iteration branch management, PR submission, release workflow, and cross-session handoff. Use when creating branches, submitting PRs, releasing versions, switching branches, or starting a new session.
---

# Git Workflow（环境分支流）

Agent-Driven Environment Branch Flow：main 绑定生产环境，dev 为开发主线，迭代在独立分支上进行，通过 PR 合并到 dev。发布 = 将 dev 合并到 main。

适用于服务端项目，分支绑定了部署环境（CI/CD 自动部署）的场景。

## 分支策略

| 分支 | 用途 | 绑定环境 | 来源 | 合并目标 | 生命周期 |
|---|---|---|---|---|---|
| `main` | 生产代码 | 生产环境 | — | — | 永久 |
| `dev` | 开发主线，最新代码 | 测试环境 | — | main（发布时） | 永久 |
| `iter/NNN-xxx` | 迭代开发分支 | — | dev | dev（PR） | 合并后删除 |
| `hotfix/xxx` | 生产热修复 | — | main | main + dev | 合并后删除 |

## 迭代分支生命周期

### 1. 创建分支

**始终从 dev 创建**，不从其他迭代分支创建：

```bash
git checkout dev
git pull origin dev
git checkout -b iter/NNN-xxx
```

前提：上一迭代的 PR 已合并。如果未合并，先完成上一迭代的 PR 流程。

### 2. 开发过程

- 每完成一个子任务（T1、T2...），做一次提交
- 不要把整个迭代积攒成一个大提交
- 定期同步 dev（当其他迭代的 PR 合并后）：

```bash
git merge dev
```

### 3. 提交 PR

迭代结束、测试门禁通过后，提交 PR（合并目标为 dev）：

```bash
git push -u origin iter/NNN-xxx
gh pr create --base dev --title "iter/NNN: 标题" --body "$(cat <<'EOF'
## 迭代目标
（一句话描述）

## 完成内容
- T1: ...
- T2: ...

## 测试结果
- 全量测试: ✅ 通过

## Checklist
（链接到 docs/ai2ai/checklist.md 或内联）

EOF
)"
```

### 4. Review + 合并

- 人审核 PR diff + checklist 验收
- 通过后合并到 dev（Merge commit，保留迭代历史）
- 合并后删除远程分支
- dev 分支的更新会自动部署到测试环境

### 5. 其他进行中的分支同步

PR 合并后，其他正在开发的迭代分支需要同步 dev：

```bash
git checkout iter/其他迭代
git merge dev
```

冲突在自己分支上解决，不影响 dev。

## 并行开发规则

多个 AI Agent 可以同时在不同迭代分支上工作：

```
你（人）
 ├── Session A (Agent) → iter/013-feature-a
 ├── Session B (Agent) → iter/014-feature-b
 └── Session C (Agent) → iter/015-feature-c
```

关键约束：
- 每个 Agent 只在自己的分支上工作
- dev 是唯一合并目标，不允许分支间直接合并
- PR 按完成顺序合并，后合并的分支负责解决与先合并分支的冲突
- 合并顺序由人决定

## 发布工作流（dev → main）

### 发布流程

dev 上功能就绪、测试环境验证通过后，发布到生产：

```bash
# 确保 dev 是最新的
git checkout dev
git pull origin dev

# 提交 dev → main 的 PR
gh pr create --base main --head dev --title "Release: 版本描述" --body "$(cat <<'EOF'
## 发布内容
- iter/NNN: ...
- iter/NNN: ...

## 测试环境验证
- 全量测试: ✅ 通过
- 集成测试: ✅ 通过

EOF
)"
```

### 合并后打 tag

```bash
git checkout main
git pull origin main
git tag vX.Y.Z
git push origin vX.Y.Z
```

### 热修复

生产环境发现严重 bug：

1. 从 main 创建修复分支：

```bash
git checkout main
git pull origin main
git checkout -b hotfix/xxx
```

2. 修复并验证后，提交两个 PR：

```bash
# PR 1: 修复生产
gh pr create --base main --head hotfix/xxx --title "hotfix: 修复描述"

# PR 2: 同步开发主线
gh pr create --base dev --head hotfix/xxx --title "hotfix: 修复描述（同步 dev）"
```

3. 合并顺序由人决定：
   - 紧急程度高：先合 main（立即修复生产），再合 dev
   - 需要测试环境验证：先合 dev（测试环境验证通过后），再合 main

## 切换分支安全检查

切换分支前必须确保工作区干净：

```bash
git status
```

如果有未提交的改动：
- 属于当前迭代的改动 → 先提交
- 临时性的改动 → `git stash`
- 不需要的改动 → `git checkout -- <file>`

**禁止在有未提交改动时切换分支。**

## 跨 Session 衔接

新 session 开始时，必须：

1. `git branch -a` — 确认当前分支和所有分支
2. `git status` — 确认工作区状态
3. `git log --oneline -5` — 确认最近提交
4. 读 `docs/ai2ai/status.md` — 确认迭代状态

基于以上信息判断应该在哪个分支上工作，而不是假设应该从 dev 开始。
