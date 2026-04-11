# VoxCPM Docs Index

本文件是 `docs/` 目录下文档站点的**当前总览大纲**，用于快速理解：

- 文档站的实际信息架构（以 `docs/index.rst` 的 hidden toctree 为准）
- `docs/` 的目录/文件结构
- 每个主要文档页面覆盖的大致内容
- 哪些页面参与构建，哪些页面只是补充/遗留页面

> 备注：本文档仓库是 **Sphinx 文档站**（而不是 VoxCPM 代码仓库）。部分页面会引用/假设主仓库中的脚本、模型目录与训练配置路径。

## 信息架构（站点导航）

站点入口与侧边栏导航由 `docs/index.rst` 中的多个 hidden toctree 决定。

### 1. 首页

- `docs/index.rst`（首页）

### 2. Getting Started

- `docs/quickstart.rst`
- `docs/installation.rst`

### 3. User Guide

- `docs/usage_guide.rst`
- `docs/cookbook.rst`
- `docs/faq.rst`

### 4. Models

- `docs/models/architecture.rst`
- `docs/models/version_history.rst`

### 5. Fine-tuning

- `docs/finetuning/finetune.rst`
- `docs/finetuning/walkthrough.rst`
- `docs/finetuning/faq.rst`

### 6. Reference

- `docs/reference/api.rst`
- `docs/reference/changelog.rst`

### 7. Ecosystem

Deployment:

- `docs/deployment/nanovllm_voxcpm.rst`
- `docs/deployment/voxcpm_cpp.rst`
- `docs/deployment/onnx.rst`
- `docs/deployment/ane.rst`
- `docs/deployment/mlx_audio.rst`
- `docs/deployment/rknn.rst`
- `docs/deployment/voxcpm_rs.rst`

Integrations:

- `docs/integrations/comfyui_voxcpm.rst`
- `docs/integrations/comfyui_rh_voxcpm.rst`
- `docs/integrations/comfyui_voxcpmtts.rst`
- `docs/integrations/tts_webui.rst`

## 参与构建但不在侧边栏主导航中的页面

以下页面会参与当前文档构建，但**不直接作为侧边栏主导航项**出现：

- `docs/models/voxcpm2.rst`：VoxCPM 2 详细介绍页
- `docs/models/voxcpm1.5.rst`：VoxCPM 1.5 详细介绍页
- `docs/models/voxcpm1.rst`：VoxCPM 1.0 详细介绍页
- `docs/models/earlier_releases.rst`：遗留版本说明页，和 `docs/models/version_history.rst` 有一定重叠，当前主导航未引用

这些页面通常通过首页卡片、版本历史页或正文内链接进入。

## 不参与当前构建的页面

- `docs/models.rst`：文件仍在，但 `docs/conf.py` 中已通过 `exclude_patterns` 排除，不参与当前站点构建

## 目录与文件结构（docs/）

```text
docs/
  conf.py
  index.rst
  quickstart.rst
  installation.rst
  usage_guide.rst
  cookbook.rst
  faq.rst
  models.rst                    # 存在，但不参与构建
  Makefile
  make.bat
  _static/
    custom.css
    voxcpm_logo.png
    voxcpm_logo_dark.png
    modelbest_logo.png
    thuhcsi_logo.png
    voxcpm1/
      voxcpm_model.png
  models/
    architecture.rst
    version_history.rst
    earlier_releases.rst        # 遗留页
    voxcpm2.rst
    voxcpm1.5.rst
    voxcpm1.rst
  finetuning/
    finetune.rst
    walkthrough.rst
    faq.rst
  reference/
    api.rst
    changelog.rst
  deployment/
    nanovllm_voxcpm.rst
    voxcpm_cpp.rst
    onnx.rst
    ane.rst
    mlx_audio.rst
    rknn.rst
    voxcpm_rs.rst
  integrations/
    comfyui_voxcpm.rst
    comfyui_voxcpmtts.rst
    tts_webui.rst
```

## 文件级内容概览

### `docs/index.rst`

- 站点首页：项目简介、Key Features、版本入口、社区项目、风险说明、License、Citation。
- 使用 `sphinx-design` 的卡片与按钮展示 VoxCPM 2 和 Earlier Releases。
- 末尾的 hidden toctree 定义整站导航，是当前信息架构的权威来源。

### `docs/quickstart.rst`

- 最快上手页：从安装到跑通 Python API、CLI、Web Demo。
- 主线围绕 `openbmb/VoxCPM2`。
- 提供“下一步阅读”入口，导向 Usage Guide / Models / Fine-tuning / Deployment。

### `docs/installation.rst`

- 安装总览页：requirements、`uv` / `pip` / source checkout。
- 说明何时需要源码安装（如运行本地 web demo、做开发或贡献）。
- 包含 Hugging Face mirror 和基础安装校验命令。

### `docs/usage_guide.rst`

- 核心使用指南：解释 `generate()` 关键参数与典型推荐值。
- 覆盖三种主要生成模式：Voice Design、Controllable Voice Cloning、Hi-Fi Cloning。
- 包括文本输入、参考音频、质量调优、长文本与流式生成建议。

### `docs/cookbook.rst`

- 计划中的“配方/案例”页。
- 当前仍偏占位，属于后续可补强区域。

### `docs/faq.rst`

- 面向安装、运行与部署问题的 FAQ。
- 涵盖 Triton、torchcodec、`torch.compile`、Mac/MPS、Python 版本兼容性、显存与 RTF 等。

### `docs/models/architecture.rst`

- 模型架构总览页。
- 当前仍偏占位，后续可补充 VoxCPM 2 / 1.x 架构关系与组件说明。

### `docs/models/version_history.rst`

- 旧版本总览页：说明为什么/何时使用 VoxCPM 1.5 或 1.0。
- 提供 1.x 与 2.0 的迁移建议，并链接到详细版本页。

### `docs/models/voxcpm2.rst`

- 当前主推模型页。
- 介绍 30 语言、多风格控制、48kHz 输出、V2 架构变化与使用示例。

### `docs/models/voxcpm1.5.rst`

- 1.x 的成熟升级版本页。
- 强调 44.1kHz 输出、更轻量部署与从 1.0 迁移的说明。

### `docs/models/voxcpm1.rst`

- 最初版本的详细说明页。
- 包含架构图、基准结果和最小使用示例。

### `docs/finetuning/finetune.rst`

- 微调总指南：数据格式、环境要求、LoRA 与 Full Fine-tuning 两条路径。
- 给出 YAML 配置、训练命令、checkpoint 与推理方式说明。

### `docs/finetuning/walkthrough.rst`

- 端到端实操示例页。
- 用具体数据集和训练流程串起 manifest 准备、训练与验证过程。

### `docs/finetuning/faq.rst`

- 微调问题排查页。
- 重点覆盖 OOM、不收敛、过拟合、LoRA 加载/推理异常等问题。

### `docs/reference/api.rst`

- Python API 与 CLI 参考页。
- 包含 `VoxCPM`、`from_pretrained()`、`generate()`、`generate_streaming()` 以及 LoRA 相关方法。
- 同时记录新的 CLI 子命令形态：`design` / `clone` / `batch`。

### `docs/reference/changelog.rst`

- 面向开发者的版本变更页。
- 重点记录 2.0 相对 1.x 的 breaking changes、架构变更、API 默认值变化、CLI 迁移提示。

### `docs/deployment/nanovllm_voxcpm.rst`

- NanoVLLM-VoxCPM 高吞吐 GPU 部署页。
- 覆盖服务模式、流式能力与 FastAPI demo 方向。

### `docs/deployment/voxcpm_cpp.rst`

- C++ / GGUF 推理与服务化方案。
- 面向 CPU、CUDA、Vulkan 等多后端部署场景。

### `docs/deployment/onnx.rst`

- ONNX Runtime 方案说明。
- 偏归档/历史兼容路线，主要用于旧版本或特定部署约束。

### `docs/deployment/ane.rst`

- Apple Neural Engine / CoreML 部署方案。
- 面向 Apple Silicon 设备上的本地推理。

### `docs/deployment/mlx_audio.rst`

- MLX-Audio 集成说明。
- 面向 Apple Silicon 的 CLI / API / UI 推理生态。

### `docs/deployment/rknn.rst`

- RK3588 / RKNN / RKLLM 边缘部署说明。
- 面向嵌入式或端侧设备推理场景。

### `docs/deployment/voxcpm_rs.rst`

- Rust 生态下的实验性实现说明。
- 偏探索性质，适合关注跨语言推理实现的读者。

### `docs/integrations/comfyui_voxcpm.rst`

- ComfyUI-VoxCPM 集成页。
- 节点式工作流、推理与 LoRA 训练是重点。

### `docs/integrations/comfyui_rh_voxcpm.rst`

- RunningHub 的 ComfyUI 集成页。
- 重点覆盖 VoxCPM 2、多说话人工作流、自动 ASR、ZipEnhancer 去噪与可选 LoRA 加载。

### `docs/integrations/comfyui_voxcpmtts.rst`

- 另一套 ComfyUI 集成方案说明。
- 更偏轻量接入、预设工作流和自动转写辅助。

### `docs/integrations/tts_webui.rst`

- TTS WebUI 扩展说明页。
- 当前内容相对较薄，更像一个入口与外链说明。

## 构建与组织说明

- 站点使用 Sphinx，配置文件为 `docs/conf.py`
- 当前启用的扩展包括：`myst_parser`、`sphinx_copybutton`、`sphinx_design`
- 同时支持 `.rst` 与 `.md`，但主要内容以 `.rst` 为主
- 主题为 `furo`，自定义样式在 `docs/_static/custom.css`
- `docs/models.rst` 虽然保留在仓库中，但当前不参与构建；如果以后恢复使用，需要同时调整 `docs/conf.py` 与首页导航

## 维护备注（简要，带主观判断）

- **最完整**：Quick Start、Installation、Usage Guide、Fine-tuning、API Reference、Changelog
- **可继续补强**：Cookbook、Models / Architecture
- **生态页特点**：覆盖面广，但部分页面更偏“项目入口与集成说明”，深度不完全一致
