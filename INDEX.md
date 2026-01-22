# VoxCPM Docs Index

本文件是 `docs/` 目录下文档站点的“总览大纲”，用于快速理解：

- 文档信息架构（Sphinx toctree 组织结构）
- `docs/` 的目录/文件结构
- 每个文档文件覆盖的大致内容

> 备注：本文档仓库是 **Sphinx 文档站**（而不是 VoxCPM 代码仓库）。部分页面会引用/假设主仓库中的脚本与配置路径。

## 信息架构（站点导航）

站点入口与导航主要由 `docs/index.rst` 中的多个隐藏 toctree 决定：

1. 首页主导航
   - `docs/index.rst`（self）
   - `docs/quickstart.rst`
   - `docs/chefsguide.rst`
   - `docs/models.rst`
2. Models
   - `docs/models/voxcpm1.rst`
   - `docs/models/voxcpm1.5.rst`
3. Fine Tuning
   - `docs/finetuning/finetune.rst`
4. Deployment
   - `docs/deployment/nanovllm.rst`

## 目录与文件结构（docs/）

```text
docs/
  conf.py
  index.rst
  quickstart.rst
  chefsguide.rst
  models.rst
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
    voxcpm1.rst
    voxcpm1.5.rst
  finetuning/
    finetune.rst
  deployment/
    nanovllm.rst
```

## 文件级内容概览

### `docs/index.rst`

- 站点首页：项目简介、Key Features（表达性/克隆/高效率合成）。
- Model Versions：使用 `sphinx-design` 的 card-carousel 展示 VoxCPM 2（开发中）、VoxCPM 1.5、VoxCPM 1.0。
- Community Projects：收录社区集成（ComfyUI、WebUI、ONNX、NanoVLLM 等）与声明。
- Risks and limitations：模型行为风险、克隆滥用风险、当前技术限制、双语限制、使用限制。
- License / Acknowledgments / Institutions / Star History / Citation。
- 隐藏 toctree：定义整站导航与分组（Models / Fine Tuning / Deployment）。

### `docs/quickstart.rst`

- Requirements：PyTorch/CUDA/Python 版本与磁盘空间。
- Installation：PyPI 安装与源码安装方式。
- Model Download（可选）：通过 Hugging Face / ModelScope 下载模型与可选组件。
- Basic Usage：
  - Code API：`VoxCPM.from_pretrained(...)` 初始化；非流式与流式生成示例。
  - CLI：直合成、克隆、批量、参数调节、模型加载、去噪器开关与帮助命令。
  - Web Demo：运行 `python app.py`（并说明额外 ASR 模型需求）。
- Next steps：引导到 chefsguide / models / finetuning / deployment。

### `docs/chefsguide.rst`

- “Voice Chef” 风格的进阶使用建议：
  - 文本输入：普通文本（开启 TN） vs 音素输入（关闭 TN）。
  - Prompt Speech：使用参考音频进行风格/音色复刻；可选“Prompt Speech Enhancement”。
  - 关键推理参数：CFG value 与 inference timesteps（质量/速度权衡）。
- Next steps：引导到 models / finetuning / deployment。

### `docs/models.rst`

- 模型列表页：表格列出 VoxCPM 1.0 与 VoxCPM 1.5 的参数规模与采样率。
- 链接到对应的模型详情页（`docs/models/voxcpm1.rst`、`docs/models/voxcpm1.5.rst`）。

### `docs/models/voxcpm1.rst`

- VoxCPM 1.0 信息：发布日期、参数规模、采样率。
- 徽章/链接：Hugging Face、ModelScope、Demo Page。
- 架构图：`docs/_static/voxcpm1/voxcpm_model.png`。
- Basic Usage：最小 Python 推理示例。
- Benchmark：Seed-TTS-eval、CV3-eval 相关表格（WER/CER/SIM/DNSMOS 等）。

### `docs/models/voxcpm1.5.rst`

- VoxCPM 1.5 信息：发布日期、参数规模、采样率。
- Overview：强调音质与效率升级，保留核心能力。
- 对比表：16kHz -> 44.1kHz、LM token rate 变化、patch size/token rate 变化。
- Basic Usage：最小 Python 推理示例（44.1kHz）。
- Model Updates：采样率提升、token rate 调整带来的影响。
- Migration Guide：从 0.5B/1.0 迁移到 1.5 的注意事项与兼容性说明。

### `docs/finetuning/finetune.rst`

- Fine-tuning 指南（标注 under construction）：
  - Data Preparation：JSONL manifest 结构（必选/可选字段、采样率要求）。
  - Full Fine-tuning：示例 YAML 配置、单卡/多卡训练命令、checkpoint 结构。
  - LoRA Fine-tuning：LoRA 配置与参数说明、训练命令、checkpoint 结构。
  - Inference：Full FT / LoRA 推理命令示例；含克隆场景。
  - LoRA Hot-swapping：API 级动态加载/禁用/重置/切换 LoRA 权重示例。
  - FAQ：OOM、效果差、不收敛、推理不生效、checkpoint 报错等排查建议。

### `docs/deployment/nanovllm.rst`

- Nano-vLLM 部署方案简介（标注 under construction）。
- 特性列表：高吞吐、流式、批量、多卡、支持 1.0/1.5。
- 安装：外链到 NanoVLLM-VoxCPM 项目文档。

### `docs/conf.py`

- Sphinx 配置：项目元信息（project/release/author）。
- 扩展：`myst_parser`、`sphinx_design`。
- 支持 `.rst` 与 `.md` 后缀；HTML theme 使用 `furo`；加载 `custom.css`。

### `docs/Makefile` / `docs/make.bat`

- Sphinx 官方模板 Makefile：通过 `sphinx-build -M <target>` 构建 `html/linkcheck/doctest` 等。
- Windows 下使用 `make.bat`。

### `docs/_static/custom.css` 与静态资源

- `docs/_static/custom.css`：
  - 全局字号与标题层级排版。
  - `sphinx-design` dropdown 组件的布局与样式。
  - 终端块（`pre.terminal`）的黑底白字与 `system/user` 颜色。
  - logo figure 宽度与少量布局细节。
- `docs/_static/` 图片：站点 logo、机构 logo、以及 VoxCPM 1.0 架构图。
