Fine-Tuning FAQ
===============

Can I fine-tune for a new language?
***********************************

Yes. Community reports suggest starting with LoRA before full fine-tuning, mixing some Chinese/English data to reduce forgetting, and using conservative learning rates. For the full workflow, see :doc:`./finetune`.


Common training issues
**********************

**Model ignores input text after fine-tuning:**
(`#169 <https://github.com/OpenBMB/VoxCPM/issues/169>`_)

This typically means the model has overfit to reproducing training audio without text conditioning.

- Reduce learning rate to ``1e-5`` (full FT) or ``1e-4`` (LoRA).
- Keep ``training_cfg_rate=0.1`` (do NOT set it to 0).
- Keep ``weight_decay=0.01``.
- Test checkpoints every ~2000 steps to catch the issue early.

**Generation doesn't stop (runaway):**
(`#195 <https://github.com/OpenBMB/VoxCPM/issues/195>`_, `#124 <https://github.com/OpenBMB/VoxCPM/issues/124>`_)

- Check your data for clips with long trailing silence (>0.5s) and trim them.
- Enable ``retry_badcase=True`` at inference time.
- If fine-tuning a new language, the stop loss and diffusion loss may converge at different rates — try increasing the stop loss weight.

**Resume training shows wrong step count:**
(`#187 <https://github.com/OpenBMB/VoxCPM/issues/187>`_)

This is a known bug in multi-GPU training. Ensure you're using the latest version of the training scripts.


Out of Memory (OOM)
*******************

- Increase ``grad_accum_steps`` (gradient accumulation) to reduce per-step memory.
- Decrease ``batch_size``.
- Use LoRA fine-tuning instead of full fine-tuning.
- Decrease ``max_batch_tokens`` to filter out long samples.


Poor LoRA performance
*********************

- Increase ``r`` (LoRA rank) — try 32 or 64 for harder tasks.
- Adjust ``alpha`` (try ``alpha = r/2`` or ``alpha = r``).
- Ensure ``enable_dit: true`` — this is essential for voice quality.
- Increase training steps.
- Add more target modules (e.g. include ``gate_proj``, ``up_proj``, ``down_proj``).


Training not converging
***********************

- Decrease ``learning_rate``.
- Increase ``warmup_steps``.
- Check data quality — noisy audio or mismatched transcripts are common culprits.


LoRA not taking effect at inference
***********************************

- Ensure the inference LoRA config (``r``, ``alpha``, ``target_modules``) matches the training config.
- Check the return value of ``load_lora_weights`` — ``skipped_keys`` should be empty.
- Verify ``set_lora_enabled(True)`` is called if you previously disabled it.


Checkpoint loading errors
*************************

- **Full fine-tuning:** the checkpoint directory must contain ``model.safetensors`` (or ``pytorch_model.bin``), ``config.json``, and ``audiovae.pth``.
- **LoRA:** the checkpoint directory must contain ``lora_weights.safetensors`` (or ``lora_weights.ckpt``) and ``lora_config.json``.
