# Rust 编码规范（示例模板）

> Rust 项目的编码约定示例。按需加载（globs: **/*.rs）。
> 这是一个起点模板，请根据项目实际情况调整。

## 模块组织（Rust 2018+ 风格）

使用 `模块名.rs` 作为模块根文件，子模块放在同名目录下。不使用 `mod.rs`。

```
✅ 正确
src/
├── lib.rs
├── model.rs            ← model 模块根
├── model/
│   ├── object.rs
│   └── term.rs
├── store.rs            ← store 模块根
└── store/
    ├── object.rs
    └── term.rs

❌ 错误
src/
├── lib.rs
├── model/
│   ├── mod.rs          ← 不要用 mod.rs
│   ├── object.rs
│   └── term.rs
```

注意：`model.rs` 和 `model/mod.rs` 不能同时存在，Rust 编译器会报 E0761 错误。

## 单元测试

测试写在同一个文件底部，用 `#[cfg(test)]` 隔离：

```rust
pub fn add(a: i32, b: i32) -> i32 {
    a + b
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_add() {
        assert_eq!(add(1, 2), 3);
    }
}
```

需要初始化环境的测试（如数据库），在测试模块中写 helper 函数：

```rust
#[cfg(test)]
mod tests {
    use super::*;

    fn setup() -> TestStore {
        TestStore::open_in_memory().unwrap()
    }

    #[test]
    fn test_create_object() {
        let store = setup();
        // ...
    }
}
```

## 错误处理

- 优先使用 `?` 传播，消除不必要的 `match` / `unwrap`
- 用 `thiserror` 定义类型化错误，避免裸 `String` 错误
- 应用层（`main`、API 入口）可用 `anyhow`，库代码不用

## 类型与泛型

- 消除不必要的类型标注（编译器能推断的不写）
- 消除不必要的 `.clone()`，优先用借用
- 避免过早泛型化——当前只有一个实现时，用具体类型

## 异步代码

- 不需要异步的函数不标 `async`
- 避免不必要的 `Arc`/`Mutex`，单线程上下文用简单引用
- `tokio::spawn` 仅在需要并发时使用，不要为顺序执行的代码 spawn
