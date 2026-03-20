---
name: flutter-desktop-design
description: >-
  Create distinctive, production-grade Flutter desktop interfaces with high
  design quality. Use when building Flutter widgets, pages, layouts, or
  styling/beautifying any desktop UI. Generates creative, polished code that
  avoids generic AI aesthetics.
---

# Flutter Desktop Design（示例模板）

> Flutter 桌面端 UI 设计规范示例。与通用 `ui-design-conventions` skill 配合使用。
> 这是一个起点模板，请根据项目实际情况调整。

生成有辨识度、生产级的 Flutter 桌面界面，避免千篇一律的"AI味"设计。

## ThemeData 唯一真相源

`ThemeData` 是所有样式的唯一定义处，Widget 层只消费、不定义。

### 核心规则

- **`ColorScheme`** 是色彩的唯一来源 — 用 `Theme.of(context).colorScheme.primary` 而非 `Color(0xFFxxxxxx)`
- **`TextTheme`** 是文字样式的唯一来源 — 用 `Theme.of(context).textTheme.titleLarge` 而非手写 `TextStyle`
- **ComponentTheme** 统一定义组件默认样式 — `ElevatedButtonThemeData`、`CardTheme`、`AppBarTheme` 等全部在 `ThemeData` 中配置，组件处零配置直接使用
- **Widget 层只做覆盖** — 仅当个别组件确实需要偏离全局默认时，才用 `style` 参数局部覆盖
- **项目特有语义用 `ThemeExtension`** — 项目中 `ColorScheme` 不足以表达的自定义色彩/样式语义，通过 `ThemeExtension` 扩展，不用全局常量类

### 禁止

- `Color(0xFFxxxxxx)` / `Colors.xxx` 散落在 Widget 代码中
- 在 Widget 中手写 `TextStyle(fontSize: ..., fontWeight: ...)` 而不引用 `TextTheme`
- 每个按钮/卡片/输入框单独设置 `style`，重复定义相同样式
- 用全局静态常量类（`AppColors`、`AppStyles`）替代 `ThemeData` 体系

## 色彩与主题

- 在 `ThemeData` 中通过 `ColorScheme.fromSeed()` 或手动构建 `ColorScheme` 定义全局色彩
- 主色调搭配锐利强调色，优于均匀分布的多色方案
- 善用 opacity 和 surface tint 创造层次感
- 暗色/亮色主题都要精心设计，不是简单反转

**禁止**：Material 默认紫色主题直接上线、蓝紫渐变+白底的 AI 味配色。

## 字体与排版

- 选择有性格的字体对：标题字体 + 正文字体
- 在 `ThemeData.textTheme` 中建立清晰的字体层级（display → title → body → label），组件中通过 `Theme.of(context).textTheme` 引用
- 中文场景优先考虑：思源黑体/宋体、霞鹜文楷、鸿蒙字体等有辨识度的选择
- 西文场景避免 Roboto 默认值，选择 JetBrains Mono（代码）、Plus Jakarta Sans、DM Sans、Manrope 等有特色的字体
- 行高、字间距、段落间距需要精心调教

**禁止**：全盘使用 Material 默认 Roboto、不设字体层级的扁平排版。

## 空间与布局

- 桌面端要充分利用宽屏空间：多栏布局、侧边栏+内容区、Master-Detail
- 用 `EdgeInsets` 常量统一间距体系（4/8/12/16/24/32/48）
- 不对称布局、错落排列比死板网格更有生气
- 负空间（留白）是设计元素，不是浪费

**禁止**：手机式单栏布局直接搬到桌面、随意的 padding 数值。

## 动效与交互

- 桌面端核心交互：hover 状态、右键菜单、键盘快捷键、拖拽
- 用 `AnimatedContainer`/`AnimatedOpacity` 等隐式动画处理简单过渡
- 页面切换用 `Hero` 或自定义 `PageRouteBuilder`
- 列表项出现用 staggered animation（错位延迟）制造节奏感
- hover 效果要细腻：微妙的 elevation 变化、背景色过渡、缩放

**禁止**：无 hover 反馈的可点击元素、生硬的界面切换。

## 视觉细节与质感

- 用 `BoxDecoration` 的 gradient/shadow/border 组合创造质感
- 背景避免纯色：考虑微妙渐变、噪点纹理（`ShaderMask`）、模糊效果（`BackdropFilter`）
- 图标选择有性格的图标集（Phosphor、Lucide、Tabler），不局限于 Material Icons
- 圆角要统一且有意图：全圆角(柔和) vs 小圆角(锐利) vs 混合(层次)
- 分割线、边框用于结构化，但不要过度使用

**禁止**：纯白/纯灰背景不加任何质感处理、默认 Material 图标不加筛选。

## 桌面端特有考量

### 窗口与平台融合

- macOS：考虑 titlebar 融合、毛玻璃效果（`NSVisualEffectView` via platform channel）
- 合理使用 `window_manager` 控制窗口行为
- 支持窗口缩放时的响应式布局断点

### 信息密度

- 桌面用户期望更高的信息密度，不需要像移动端那样大留白大按钮
- 表格、树形结构、面板分割器是桌面端的核心 UI 模式
- 工具栏、状态栏要紧凑但清晰

### 键鼠优先

- 所有交互都有 hover/focus 状态
- 支持 Tab 键导航
- 右键菜单提供上下文操作
- 拖拽排序/移动是桌面端的自然交互

## 实现要求

- 所有代码必须可运行、无编译错误
- Widget 拆分合理，单个 build 方法不超过 80 行
- 颜色、间距、字体用 Theme/常量管理，不硬编码
- 动画 duration 控制在 150ms-400ms，贴合桌面端节奏
- 每次生成的设计应该有所不同 — 轮换明暗主题、字体、配色方案

## 反模式清单

生成 UI 时自检，以下任何一项出现即需修正：

- [ ] 使用了 Material 默认主题未做定制
- [ ] 全部使用 Roboto/系统默认字体
- [ ] 蓝紫渐变 + 白色背景
- [ ] 手机式单栏布局
- [ ] 可点击元素无 hover 反馈
- [ ] padding/margin 数值随意不统一
- [ ] 颜色硬编码散落在各 Widget 中
- [ ] 背景纯色无质感处理
- [ ] 动画生硬或缺失
