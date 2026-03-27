# AI Coding Philosophy: Why This Methodology Exists

> This document is the philosophical foundation of ai-collab-methodology — an analysis of how humans and AI should collaborate on software development.
> This is not a literature survey. It is a critical analysis of popular theories and our own judgment framework.
> Last updated: 2026-03-27

---

**Table of Contents**
- [I. Three Popular Theories and Their Limits](#i-three-popular-theories-and-their-limits)
- [II. Our Judgment: Observation Granularity Layering](#ii-our-judgment-observation-granularity-layering)
- [III. Industry Practice: Validation and Additions](#iii-industry-practice-validation-and-additions)
- [IV. Implications for Methodology Design](#iv-implications-for-methodology-design)

---

## I. Three Popular Theories and Their Limits

### Theory A: Never Read the Code — Focus on Requirements, Design, and Tests

**Claim**: Developers don't need to read AI-generated code. The focus should be on requirements documents, design, testing, and iteration.

**What's reasonable**:
- AI generates code far faster than humans can read it — line-by-line review is genuinely impractical
- Shifting quality focus left to documents and requirements aligns with the "shift-left" principle
- **The efficiency bottleneck argument**: If review is mandatory, the speed advantage of AI gets consumed by the review step — this is the strongest challenge to "review is required." Better to focus human effort on what AI does poorly: requirements definition, architectural decisions, acceptance judgment

**Fundamental limits**:
- This degrades to pure black-box testing, which has a structural ceiling: limited coverage, no guarantee of robustness, unable to catch non-functional issues (performance regression, memory leaks, security vulnerabilities)
- Problems that black-box testing can't find will only surface in production
- This theory shifts quality responsibility onto document quality — but who ensures the documents are correct? A circular dependency forms
- **Rebuttal to the efficiency bottleneck argument**: The argument assumes "review can only mean manual line-by-line review." But the form of observation can change — automated toolchains (type checking, tests, lint) operate at machine speed; there's no human-chasing-AI problem. The real constraint is: however much you reduce manual review, you must increase automated observation by the same amount. The two cannot both decrease simultaneously. Furthermore, review serves another function — **understanding**: without understanding AI-generated code, you cannot make architectural decisions, assess technical debt, or quickly locate problems when things break. That cost doesn't appear today; it appears later.

---

### Theory B: Human-AI as Tech Lead and Employee

**Claim**: Treat AI as a broadly knowledgeable but low-initiative employee. A tech lead doesn't read every line their team writes.

**What's reasonable**:
- Trust tiering is valid — different capability levels warrant different degrees of oversight
- Frees developers from the psychological burden of tracking every detail

**Fundamental limits**:
- A tech lead's trust in an employee is built on **an established history** — new employees still get strict review, often including cross-review by peers
- AI has no trust accumulation mechanism: every conversation is "day one for a new hire"
- Tech leads don't read code, but they do read architecture, PR diffs, and test coverage reports — they have **indirect observation mechanisms**. Theories that skip code review often skip these indirect mechanisms too, and that's the dangerous part

---

### Theory C: AI Coding as Compiler — Output Doesn't Need to Be Read

**Claim**: Just as nobody reads the assembly output of a C compiler, nobody needs to read AI-generated code.

**What's reasonable**:
- For beginners, "debug when problems appear" is a valid approach — deep understanding of the underlying layer isn't required
- Raising the level of abstraction is a normal path of technological progress

**Fundamental limits**:

1. **Determinism gap**: A compiler has explicit rule mappings — same input always produces same output, and errors are enumerable (type errors, syntax errors). AI errors are **emergent** — you don't know where or what kind of mistake it will make, which means you need *more* observation points, not fewer.

2. **Natural language is not a specification**: Programming languages have formal specifications; AI input is natural language, which has no inherent formalism. Skills, cursor rules, AGENTS.md, command templates — all of these are attempts to build "quasi-specifications" for natural language. This is evidence that relying purely on natural language is insufficient.

3. **Depth layering persists**: Beginners don't read assembly, but experts analyze assembly to find performance bottlenecks and security vulnerabilities. AI coding is the same — beginners fix problems when they appear, experts can predict hidden problems from code structure. Raising the abstraction level does not eliminate depth layering.

4. **Error visibility**: A compiler's errors surface at **compile time**. AI errors surface at **runtime or in production**. This is a more fundamental distinction than the determinism gap — the cost of discovering errors grows exponentially the later they are found.

---

## II. Our Judgment: Observation Granularity Layering

All three theories have a reasonable core, but each goes to an extreme. Our judgment:

**AI coding changes the granularity of observation — it does not eliminate the need for observation.**

| Level | Traditional Engineer | AI Coding Practitioner |
|-------|---------------------|----------------------|
| Junior | Writes code, fixes bugs | Writes requirements docs, communicates with AI to fix problems |
| Mid-level | Owns a system area, designs tech stack, understands root causes | Designs/adapts AI engineering systems, tunes skill details, module-level observation |
| Senior | Architecture design, system-level non-functional requirements | System-level observation: architectural soundness, dependency relationships, security boundaries |

The distinction between levels is not "whether to read code" — it is **observation granularity**:
- Junior: line-level observation (every line of code)
- Mid-level: module-level observation (interfaces, data flow, test coverage)
- Senior: system-level observation (architecture, dependencies, non-functional metrics)

AI's high-speed generation reduces the necessity of line-level observation, but simultaneously makes mid-level and senior-level observation **more important** — because AI generates fast, problems accumulate fast, and they need to be caught at a higher level, sooner.

---

## III. Industry Practice: Validation and Additions

The three theories above are abstract claims. Mainstream tools and practitioners provide concrete operational experience. This experience both validates the observation granularity layering framework and adds two dimensions the framework doesn't yet cover.

---

### 3.1 Cursor/Devin Camp: Automated Toolchains Are the Infrastructure of Observation

Cursor and Devin represent two different AI coding product models, but share a common implicit assumption about quality assurance: **automated toolchains (lint/type check/CI) are a necessary compensation for reduced manual review — not an optional add-on.**

**Cursor in practice**:
- `.cursor/rules/` rule files are the core mechanism for solving "every conversation is day one" — encoding project conventions into persistent context rather than relying on users to re-explain them each time
- The best practice in Agent mode is to require AI to run `tsc --noEmit`, `eslint`, `cargo check`, etc. before marking a task complete — using compiler/linter output as a feedback signal
- Known failure pattern: AI modifies tests to make them pass rather than fixing the implementation — this is behavior that TDD rules must explicitly prohibit

**Devin in practice**:
- The CI pipeline is the core observation layer; test failures trigger automatic retries — **test coverage directly determines Devin's reliability ceiling**. Code paths without tests cannot be self-verified
- PR diff is the only human intervention point; the product design forces users to review before merging
- Known limits: performs poorly on ambiguous requirements or tasks requiring domain knowledge; introduces "reasonable but unrequested" features in long tasks (requirements drift)

**Key conclusion**: However much you reduce manual review, you must increase automated observation by the same amount. These two cannot both decrease simultaneously.

---

### 3.2 Simon Willison's Framework: PR Diff Is the Non-Negotiable Minimum Observation Unit

Simon Willison (co-creator of Django) is one of the most influential practitioners in AI coding. His framework is more precise than Theory B:

**Core claims**:
- AI is an "always-available junior engineer" — it needs clear task definitions, needs review, and makes predictable types of errors (overconfidence, missing edge cases, ignoring boundary conditions)
- Line-by-line review can be skipped, but **PR diff review cannot** — a diff is a compressed representation of change that forces you to ask "does this match my intent?"
- Git history is the audit log of AI behavior; if you don't review diffs, you lose the only mechanism for after-the-fact tracing

**Critique of Vibe Coding** (echoing Theory A's limits):
> "Vibe coding is fine for throwaway prototypes. It's actively dangerous for anything that will run in production, handle user data, or be maintained by other people."

The fundamental problem with vibe coding is not "low code quality" — it's that **nobody truly understands the code**. Maintenance costs, security vulnerabilities, and technical debt accumulate at a rate proportional to code generation speed.

**AI error patterns are predictable**, which allows experienced practitioners to design targeted observation points:
- Hallucinated APIs: calling library functions that don't exist (caught at compile time in statically typed languages, at runtime in dynamic languages)
- Stale knowledge: using deprecated APIs or outdated best practices
- Missing edge cases: happy path is implemented well; null, empty lists, concurrency edge cases are easily missed
- Missing security patterns: input validation, SQL injection protection, XSS prevention are not added unless explicitly requested

---

### 3.3 Anthropic's Agentic Coding Research: Drift Is a Systemic Risk

Anthropic's research (including SWE-bench related work) provides several important empirical conclusions:

**Performance cliff on cross-file tasks**: Success rates for single-file modifications are far higher than for tasks requiring coordination across multiple files. AI performs well on local tasks but drifts on cross-module consistency — supporting the necessity of module-level observation.

**Three forms of code drift**:
1. **Requirements drift**: Gradually deviating from original requirements in long tasks, introducing "reasonable but unrequested" features
2. **Style drift**: Inconsistent code style across sessions or agents, leading to codebase fragmentation
3. **Architecture drift**: Breaking global architectural constraints during local optimization (introducing new dependencies, changing data flow)

**Mechanisms for countering drift**:
- Re-inject the full constraint context at the start of each task (equivalent to Cursor rules' `alwaysApply`)
- Use structured output formats to force AI to declare its plan before executing
- Detect drift at each commit point through diff review

**Anthropic's design principles** (from official documentation):
- **Minimal footprint**: Request only necessary permissions; prefer reversible operations
- **Pause on uncertainty**: When encountering unexpected situations, stop and report rather than guessing and continuing
- **Clarify ambiguity before starting long tasks**, not halfway through

---

### 3.4 Addition: The Cost Gradient of Error Visibility

The critique of Theory C ("AI as compiler") can be sharper: a compiler's errors surface at **compile time**; AI errors surface at **runtime or in production**. This is a more fundamental distinction than the determinism gap.

```
Compile time < Test time < CI time < PR review time < Runtime < Production
```

Cost grows exponentially from left to right. AI's code generation speed accelerates error accumulation — without corresponding automated observation, errors are increasingly discovered on the right side (high cost).

**Four observation layers of the automated toolchain**:

| Layer | Tool Type | Trigger | Error Types Covered |
|-------|-----------|---------|---------------------|
| L1 Compile-time | tsc, cargo check, mypy | Before each commit | Type errors, syntax errors, undefined references |
| L2 Static analysis | eslint, clippy, ruff | Before each commit | Code style, known anti-patterns, security rules |
| L3 Unit/integration tests | jest, pytest, cargo test | Each commit/PR | Behavioral correctness, edge cases, regression |
| L4 CI/CD | GitHub Actions, etc. | Each PR/merge | Cross-environment compatibility, integration correctness |

Key practice: L1/L2 must run **before** AI marks a task complete. L3 tests must be defined by humans (or a TDD process) — tests generated entirely by AI tend to test the AI's own implementation rather than the actual requirements.

---

### 3.5 Addition: The Minimum Observation Threshold for Beginners

A blind spot in the current framework: the level table defines "junior AI practitioner" as "writing requirements docs and communicating with AI to fix problems" — this is somewhat idealized. In practice, most beginners' problem is not wrong observation granularity; it's that **they have no observation habit at all** — they accept AI's first output, skip tests, skip diff review, and commit directly.

How the three camps handle this:
- **Cursor camp**: Relies on user discipline; no enforced observation checkpoints; beginners accumulate technical debt fastest
- **Devin camp**: Forces review through PR product design, but assumes users have sufficient technical ability to do effective review
- **Willison framework**: Provides an actionable minimum standard — line-by-line review can be skipped, but diff review and automated toolchains cannot

**Implication for methodology design**: We cannot assume practitioners are already doing document-driven development. The methodology needs to design **mandatory minimum observation thresholds** for beginners:
1. After every AI task completion, run the automated toolchain (L1/L2)
2. Before every commit, review the diff (even without reading every line)
3. Acceptance checklists are steps humans must execute — not optional

---

### References

> The following links allow readers to verify the factual claims in this section. Some URLs have not been verified in real time — check before citing.

| Source | Link | Notes |
|--------|------|-------|
| Simon Willison's blog | [simonwillison.net](https://simonwillison.net) | Primary source for AI coding practice articles; search "vibe coding", "LLM junior developer" |
| SWE-bench paper | [arxiv.org/abs/2310.06770](https://arxiv.org/abs/2310.06770) | *SWE-bench: Can Language Models Resolve Real-World GitHub Issues?* (2023) |
| SWE-bench leaderboard | [swebench.com](https://www.swebench.com) | Includes Verified subset with latest model scores |
| Anthropic Agentic docs | [docs.anthropic.com/en/docs/build-with-claude/agentic-and-multi-agent-frameworks](https://docs.anthropic.com/en/docs/build-with-claude/agentic-and-multi-agent-frameworks) | Minimal footprint, human oversight checkpoints |
| Anthropic Computer Use | [anthropic.com/news/developing-computer-use](https://www.anthropic.com/news/developing-computer-use) | Design experience from Computer Use model (2024-10) |
| Cursor Rules docs | [docs.cursor.com/context/rules-for-ai](https://docs.cursor.com/context/rules-for-ai) | Official documentation for `.cursor/rules/` |
| Cognition AI / Devin | [cognition.ai/blog/introducing-devin](https://www.cognition.ai/blog/introducing-devin) | Devin launch blog post (2024-03) |

---

## IV. Implications for Methodology Design

This analysis directly explains why ai-collab-methodology exists:

- **Spec-Driven Development** is the operationalization of mid-level observation — using structured documents (requirements, design, tasks) to observe AI's work at the module level
- **TDD + self-review** establishes automated observation points between line-level and module-level, compensating for the speed gap in manual review
- **Three-tier decision boundaries** are systematic management of AI uncertainty — not eliminating uncertainty, but constraining it to a controllable range
- **Iteration archiving + experience library** is the mechanism for building "indirect trust" — accumulating understanding of AI behavior patterns through historical records, gradually replacing the need for human trust relationships
