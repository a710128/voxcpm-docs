Fine-Tuning FAQ
===============


General
*******

**Can I fine-tune for a new language?**

Yes. For languages not yet supported by VoxCPM, we recommend full fine-tuning with 500+ hours of target-language data, mixed with some Chinese/English data to reduce forgetting. Use conservative learning rates (``1e-5``). For the full workflow, see :doc:`./finetune`.


Training Issues
***************

**Out of memory (OOM):**

- Reduce ``batch_size`` or ``max_batch_tokens`` to filter out long samples.
- Increase ``grad_accum_steps`` to maintain effective batch size with less per-step memory.
- Switch to LoRA fine-tuning — it uses roughly half the VRAM of full fine-tuning.
- For multi-GPU (DDP), expect ~10 GB additional VRAM per card from gradient buckets and NCCL buffers.

**Training loss not converging:**

- Decrease ``learning_rate``.
- Increase ``warmup_steps``.
- Check data quality — noisy audio or mismatched transcripts are common culprits.

**Resume training shows wrong step count:**
(`#187 <https://github.com/OpenBMB/VoxCPM/issues/187>`_)

This is a known bug in multi-GPU training. Ensure you are using the latest version of the training scripts.


Output Quality Issues
*********************

**Model ignores input text after fine-tuning (overfitting):**
(`#169 <https://github.com/OpenBMB/VoxCPM/issues/169>`_)

The model has overfit to reproducing training audio without text conditioning. This is the most common fine-tuning failure mode and can emerge surprisingly early (within a few hundred steps for small datasets).

- Keep ``training_cfg_rate=0.1`` (do NOT set it to 0).
- Keep ``weight_decay=0.01``.
- Reduce learning rate to ``1e-5`` (full FT) or ``1e-4`` (LoRA).
- Monitor checkpoints at each ``save_interval``. For most single-speaker tasks, 1–3 epochs is sufficient — training beyond that often hurts.

**Generation doesn't stop (runaway output):**
(`#195 <https://github.com/OpenBMB/VoxCPM/issues/195>`_, `#124 <https://github.com/OpenBMB/VoxCPM/issues/124>`_)

- Check your training data for clips with long trailing silence (>0.5 s) and trim them — this is the most common cause.
- Enable ``retry_badcase=True`` at inference time as a safety net.
- If fine-tuning a new language, the stop loss and diffusion loss may converge at different rates — try increasing the stop loss weight (``lambdas > loss/stop``).


LoRA Issues
***********

**Poor LoRA quality:**

- Increase ``r`` (LoRA rank) — try 32 or 64 for harder tasks like style or language adaptation.
- Adjust ``alpha`` — try ``alpha = r`` or ``alpha = 2*r``.
- Ensure ``enable_dit: true`` — this is essential for voice quality.
- Increase training steps if the model has not converged yet.

**LoRA not taking effect at inference:**

- Ensure the inference LoRA config (``r``, ``alpha``, ``enable_lm``, ``enable_dit``) matches the training config exactly.
- Check the return value of ``load_lora`` — ``skipped_keys`` should be empty.
- Verify ``set_lora_enabled(True)`` is called if you previously disabled it.


Checkpoint Issues
*****************

**Checkpoint loading errors:**

- **Full fine-tuning:** the checkpoint directory must contain ``model.safetensors`` (or ``pytorch_model.bin``), ``config.json``, and ``audiovae.pth``.
- **LoRA:** the checkpoint directory must contain ``lora_weights.safetensors`` (or ``lora_weights.ckpt``) and ``lora_config.json``.
