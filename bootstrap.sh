#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# bootstrap.sh
# 在新项目中初始化 AI 协作方法论的文档结构和规则
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="$SCRIPT_DIR/templates"

# --- 参数解析 ---

usage() {
  cat <<EOF
用法: $(basename "$0") [选项] <项目目录>

在目标项目中初始化 AI 协作方法论的文档结构。

选项:
  --ide <cursor|windsurf|vscode|none>
      目标 IDE，决定 rules 文件的格式和存放位置（默认: cursor）
      - cursor:   .cursor/rules/*.mdc（带 frontmatter）
      - windsurf: .windsurf/rules/*.md
      - vscode:   .vscode/rules/*.md
      - none:     rules/*.md（纯 markdown，不带 IDE 特定格式）

  --git-flow <github-flow|env-branch>
      Git 分支策略（默认: github-flow）
      - github-flow:  main 为开发主线，适用于库/CLI/客户端应用
      - env-branch:   main 绑定生产、dev 绑定测试，适用于服务端项目

  --project-name <名称>
      项目名称，用于模板中的占位符替换（默认: 目录名）

  --lang <语言>
      复制语言特定的编码规范和 skills 示例模板（可多次指定）
      可用: rust, flutter（更多语言模板欢迎贡献）
      示例: --lang rust --lang flutter

  --dry-run
      只打印将要执行的操作，不实际创建文件

  -h, --help
      显示此帮助信息

示例:
  $(basename "$0") ~/projects/my-new-app
  $(basename "$0") --ide windsurf --project-name "MyApp" ~/projects/my-new-app
  $(basename "$0") --git-flow env-branch ~/projects/my-server-app
  $(basename "$0") --lang rust ~/projects/my-rust-app
EOF
  exit 0
}

IDE="cursor"
GIT_FLOW="github-flow"
PROJECT_NAME=""
DRY_RUN=false
TARGET_DIR=""
LANG_TEMPLATES=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --ide)       IDE="$2"; shift 2 ;;
    --git-flow)  GIT_FLOW="$2"; shift 2 ;;
    --project-name) PROJECT_NAME="$2"; shift 2 ;;
    --lang)      LANG_TEMPLATES+=("$2"); shift 2 ;;
    --dry-run)   DRY_RUN=true; shift ;;
    -h|--help)   usage ;;
    -*)          echo "未知选项: $1"; usage ;;
    *)           TARGET_DIR="$1"; shift ;;
  esac
done

# 验证 git-flow 参数
case "$GIT_FLOW" in
  github-flow|env-branch) ;;
  *)
    echo "错误: 不支持的 git-flow: $GIT_FLOW（可选: github-flow, env-branch）"
    exit 1
    ;;
esac

if [[ -z "$TARGET_DIR" ]]; then
  echo "错误: 请指定项目目录"
  usage
fi

TARGET_DIR="$(cd "$TARGET_DIR" 2>/dev/null && pwd || echo "$TARGET_DIR")"

if [[ -z "$PROJECT_NAME" ]]; then
  PROJECT_NAME="$(basename "$TARGET_DIR")"
fi

DATE="$(date +%Y-%m-%d)"

# --- IDE 配置 ---

case "$IDE" in
  cursor)
    RULES_DIR=".cursor/rules"
    RULES_EXT=".mdc"
    SKILLS_DIR=".agents/skills"
    ;;
  windsurf)
    RULES_DIR=".windsurf/rules"
    RULES_EXT=".md"
    SKILLS_DIR=".agents/skills"
    ;;
  vscode)
    RULES_DIR=".vscode/rules"
    RULES_EXT=".md"
    SKILLS_DIR=".agents/skills"
    ;;
  none)
    RULES_DIR="rules"
    RULES_EXT=".md"
    SKILLS_DIR=".agents/skills"
    ;;
  *)
    echo "错误: 不支持的 IDE: $IDE"
    exit 1
    ;;
esac

# --- 工具函数 ---

log() { echo "  $1"; }
create_dir() {
  if $DRY_RUN; then
    log "[dry-run] mkdir -p $1"
  else
    mkdir -p "$1"
    log "✅ $1/"
  fi
}
copy_template() {
  local src="$1" dst="$2"
  if [[ -f "$dst" ]]; then
    log "⏭️  $dst（已存在，跳过）"
    return
  fi
  if $DRY_RUN; then
    log "[dry-run] $dst"
  else
    # 替换占位符
    sed -e "s/{{PROJECT_NAME}}/$PROJECT_NAME/g" \
        -e "s/{{DATE}}/$DATE/g" \
        "$src" > "$dst"
    log "✅ $dst"
  fi
}

add_frontmatter() {
  local file="$1" desc="$2" always_apply="$3" globs="${4:-}"
  if [[ "$IDE" == "cursor" ]]; then
    local tmp
    tmp=$(mktemp)
    {
      echo "---"
      echo "description: $desc"
      if [[ -n "$globs" ]]; then
        echo "globs: $globs"
      fi
      echo "alwaysApply: $always_apply"
      echo "---"
      echo ""
      cat "$file"
    } > "$tmp"
    mv "$tmp" "$file"
  fi
}

# --- 执行 ---

echo ""
echo "🚀 初始化 AI 协作方法论"
echo "   项目: $PROJECT_NAME"
echo "   目录: $TARGET_DIR"
echo "   IDE:  $IDE"
echo "   Git:  $GIT_FLOW"
if [[ ${#LANG_TEMPLATES[@]} -gt 0 ]]; then
  echo "   语言: ${LANG_TEMPLATES[*]}"
fi
echo ""

# 1. 创建目录结构
echo "📁 创建目录结构..."
create_dir "$TARGET_DIR/docs/prds"
create_dir "$TARGET_DIR/docs/tech"
create_dir "$TARGET_DIR/docs/ai2ai/tasks"
create_dir "$TARGET_DIR/docs/ai2ai/iterations"
create_dir "$TARGET_DIR/$RULES_DIR"
create_dir "$TARGET_DIR/$SKILLS_DIR"

# 2. 复制 rules 模板
echo ""
echo "📋 复制 rules 模板..."

RULE_FILES=(
  "ai2ai-maintenance"
  "ai-boundary-framework"
  "ui-prototype"
)

RULE_DESCS=(
  "ai2ai 文档维护规则 — 定义 AI 在每次迭代中如何维护项目状态文档"
  "AI 决策边界框架 — 定义 AI 行为的三级决策体系和边界迭代机制"
  "UI HTML 原型生成规范 — 用静态 HTML 快速验证界面布局和交互"
)

RULE_ALWAYS_APPLY=(
  "true"
  "true"
  "false"
)

RULE_GLOBS=(
  ""
  ""
  "ui-preview/**/*.html"
)

for i in "${!RULE_FILES[@]}"; do
  src="$TEMPLATES_DIR/rules/${RULE_FILES[$i]}.md"
  dst="$TARGET_DIR/$RULES_DIR/${RULE_FILES[$i]}${RULES_EXT}"

  if [[ ! -f "$src" ]]; then
    log "⚠️  模板不存在: $src"
    continue
  fi

  copy_template "$src" "$dst"

  if ! $DRY_RUN && [[ -f "$dst" ]]; then
    add_frontmatter "$dst" "${RULE_DESCS[$i]}" "${RULE_ALWAYS_APPLY[$i]}" "${RULE_GLOBS[$i]}"
  fi
done

# 3. 复制 skills 模板
echo ""
echo "🛠️  复制 skills 模板..."

SKILL_DIRS=(
  "git-workflow"
  "git-commit-summary"
)

for skill_name in "${SKILL_DIRS[@]}"; do
  # git-workflow 根据 --git-flow 参数选择模板
  if [[ "$skill_name" == "git-workflow" && "$GIT_FLOW" == "env-branch" ]]; then
    src="$TEMPLATES_DIR/skills/$skill_name/SKILL.env-branch.md"
  else
    src="$TEMPLATES_DIR/skills/$skill_name/SKILL.md"
  fi
  dst_dir="$TARGET_DIR/$SKILLS_DIR/$skill_name"
  dst="$dst_dir/SKILL.md"

  if [[ ! -f "$src" ]]; then
    log "⚠️  模板不存在: $src"
    continue
  fi

  create_dir "$dst_dir"
  copy_template "$src" "$dst"
done

# 4. 复制 ai2ai 模板
echo ""
echo "📊 复制 ai2ai 模板..."
copy_template "$TEMPLATES_DIR/ai2ai/status.md" "$TARGET_DIR/docs/ai2ai/status.md"
copy_template "$TEMPLATES_DIR/ai2ai/checklist.md" "$TARGET_DIR/docs/ai2ai/checklist.md"
copy_template "$TEMPLATES_DIR/ai2ai/test-suite.md" "$TARGET_DIR/docs/ai2ai/test-suite.md"
copy_template "$TEMPLATES_DIR/ai2ai/decisions.md" "$TARGET_DIR/docs/ai2ai/decisions.md"

# 5. 复制参考文档模板（非 IDE 规则）
echo ""
echo "📄 复制参考文档模板..."
copy_template "$TEMPLATES_DIR/session-context.md" "$TARGET_DIR/docs/session-context.md"
copy_template "$TEMPLATES_DIR/project-methodology.md" "$TARGET_DIR/docs/project-methodology.md"

# 6. 复制语言规则和 skills 示例（可选，通过 --lang 指定）
if [[ ${#LANG_TEMPLATES[@]} -gt 0 ]]; then
  echo ""
  echo "🌐 复制语言规则和 skills 示例..."

  for lang in "${LANG_TEMPLATES[@]}"; do
    # 语言配置：rules 文件名、描述、globs
    case "$lang" in
      rust)
        lang_file="rust-conventions"
        lang_desc="Rust 编码规范 — 模块组织、测试、命名等约定"
        lang_globs="**/*.rs"
        ;;
      flutter)
        lang_file=""
        lang_desc=""
        lang_globs=""
        ;;
      *)
        log "⚠️  不支持的语言: ${lang}（可用: rust, flutter）"
        continue
        ;;
    esac

    # 6a. 复制 rules/lang-examples（如果该语言有 rules 模板）
    if [[ -n "$lang_file" ]]; then
      src="$TEMPLATES_DIR/rules/lang-examples/${lang_file}.md"
      dst="$TARGET_DIR/$RULES_DIR/${lang_file}${RULES_EXT}"

      if [[ ! -f "$src" ]]; then
        log "⚠️  规则模板不存在: $src"
      else
        copy_template "$src" "$dst"

        if ! $DRY_RUN && [[ -f "$dst" ]]; then
          add_frontmatter "$dst" "$lang_desc" "false" "$lang_globs"
        fi
      fi
    fi

    # 6b. 复制 skills/lang-examples（如果该语言有 skills 模板）
    lang_skills_dir="$TEMPLATES_DIR/skills/lang-examples/$lang"
    if [[ -d "$lang_skills_dir" ]]; then
      for skill_src_dir in "$lang_skills_dir"/*/; do
        [[ -d "$skill_src_dir" ]] || continue
        skill_name="$(basename "$skill_src_dir")"
        skill_src="$skill_src_dir/SKILL.md"

        if [[ ! -f "$skill_src" ]]; then
          log "⚠️  skill 模板不存在: $skill_src"
          continue
        fi

        dst_dir="$TARGET_DIR/$SKILLS_DIR/$skill_name"
        dst="$dst_dir/SKILL.md"
        create_dir "$dst_dir"
        copy_template "$skill_src" "$dst"
      done
    fi
  done
fi

# 7. 复制 AGENTS.md 模板
echo ""
echo "📝 复制 AGENTS.md 模板..."
copy_template "$TEMPLATES_DIR/docs/AGENTS.md.template" "$TARGET_DIR/AGENTS.md"

# 8. 完成
echo ""
echo "✅ 初始化完成！"
echo ""
echo "下一步："
echo "  1. 编辑 AGENTS.md — 填充项目结构、全局规范、具体 Boundary 规则"
echo "  2. 或者使用 bootstrap prompt 让 AI 帮你生成："
echo "     cat $SCRIPT_DIR/bootstrap-prompt.md"
echo ""
