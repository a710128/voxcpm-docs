Cookbook
========

Welcome back to the VoxCPM kitchen. With **VoxCPM 2**, the pantry now includes
more languages, richer control, and more expressive voice generation tools.
This page keeps the "voice chef" framing from the original cookbook while
presenting it in a format that fits the documentation site.

Think of it as a companion to :doc:`./usage_guide`: the Usage Guide explains
the API and parameters, while this page focuses on practical recipes for
getting the sound you want.

----

Step 1: Prepare Your Base Ingredients
*************************************

Global Ingredients: Multilingual Support
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

VoxCPM 2 brings a major upgrade to what you can put into the mixing bowl.
In most cases, you can simply write the target text directly in the language
you want to synthesize.

Representative languages include:

- **Asia:** Chinese, Japanese, Korean, Hindi, Thai, Vietnamese, Indonesian, Malay, Tagalog, Khmer, Lao, Burmese
- **Europe and the Americas:** English, French, German, Spanish, Italian, Russian, Portuguese, Dutch, Polish, Swedish, Danish, Finnish, Norwegian, Greek
- **Middle East and Africa:** Arabic, Turkish, Hebrew, Swahili

.. tip::

   You usually do not need to add an explicit language tag. Start with clean
   target text in the intended language first, then add extra control only
   when needed.


Local Specialties: Chinese Dialects
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Cook up authentic local flavors including Sichuan, Cantonese, Wu, Northeast,
Henan, Shaanxi, Shandong, Tianjin, and Minnan.

.. list-table::
   :widths: 18 42 40
   :header-rows: 1

   * - Dialect
     - Example in authentic dialect
     - Standard Mandarin equivalent
   * - Cantonese
     - ``伙計，唔該一個A餐，凍奶茶少甜！``
     - ``伙计，麻烦来一个A餐，冰奶茶少糖！``
   * - Sichuanese
     - ``幺儿，哈戳戳得你屋头来噶！``
     - ``孩子，你怎么跑到家里来了！``
   * - Northeast
     - ``你搁这整啥玩意儿呢？``
     - ``你在这儿干什么？``
   * - Henan
     - ``恁这是弄啥嘞？晌午吃啥饭？``
     - ``你这是在干什么呢？中午吃什么饭？``

Recommendations:

- **Use Authentic Vocabulary:** For the best flavor, your target text should use pure dialect expressions. See the examples above.
- Always write in the true local dialect for the best results.
- **Chef's Secret:** If you do not know how to write in a dialect, use an AI text assistant to translate your standard text into the authentic dialect first.
- **Keep Instructions Simple:** In the Control Instruction, simply type the dialect name (for example, ``Cantonese``). Adding too many complex voice instructions might spoil the broth.


Extra Spice: Non-verbal Tags
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

To make generated speech feel less mechanical, you can insert non-verbal tags
directly into the target text.

Use the **English** tag form with square brackets, for example:
``[laughing]`` or ``[sigh]``.

.. list-table::
   :widths: 28 72
   :header-rows: 1

   * - Category
     - Recommended tags
   * - Laughs and sighs
     - ``[laughing]``, ``[sigh]``
   * - Pauses and thinking
     - ``[Uhm]``, ``[Shh]``
   * - Questions
     - ``[Question-ah]``, ``[Question-ei]``, ``[Question-en]``, ``[Question-oh]``
   * - Emotions
     - ``[Surprise-wa]``, ``[Surprise-yo]``, ``[Dissatisfaction-hnn]``

.. warning::

   **Kitchen Warnings:** Stick to the recommended tags and use them sparingly.
   Lowercase tags such as ``[laughing]`` usually work better than variants like
   ``[Laughter]``. Avoid stacking too many tags into a single sentence.

----

Step 2: Choose Your Flavor Profile
**********************************

The "Build-Your-Own Combo" (Voice Design)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

No reference audio? No problem. You can now conjure a voice purely from a text
description. Think of it as building your own combo meal by mixing different
elements into one comprehensive **Control Instruction**. Both English and
Chinese instructions are supported.

.. list-table::
   :widths: 18 32 50
   :header-rows: 1

   * - Ingredient
     - Definition
     - Examples
   * - **Basic (The Base)**
     - Core identity such as gender, age, and role
     - ``middle-aged male broadcaster``, ``elderly woman``
   * - **Textured (The Marinade)**
     - Voice quality and pitch
     - ``low-pitched``, ``raspy``, ``magnetic``
   * - **Vivid (The Presentation)**
     - Emotion, pacing, and scenario
     - ``passionate``, ``shouting campaign slogans``, ``historical narration``

Chef's Signature Combos (Examples):

- *The Energetic Broadcaster Combo:* ``热情洋溢的中年男性播音员，声音较为低沉，富有磁性与感染力，带着逐渐密集的节奏感呼喊宣讲口号``
- *The Historical Narrator Combo:* ``A quiet raspy, elderly woman of a low-pitched voice with a distinct, grainy texture and subtle breathy tremors. Delivers a slow tone at a very low volume, perfect for historical narration.``

.. note::

   Because of the model's creative nature, every generation can still have
   subtle, unique variations, a bit like hiring a new voice actor each time.


Cloning a Masterpiece (Voice Cloning)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Want to replicate a specific voice? Upload or record an audio clip, and VoxCPM 2
will extract and clone the exact timbre.

Practical tips:

- **The 5-Second Rule:** Provide at least 5 seconds of reference audio. The more high-quality audio you provide, the better the clone.
- **Twist the Flavor (Style Control):** Cloning is not just copy-pasting. You can add a **Control Instruction** to change the emotion or speed of the cloned voice while preserving the timbre.

Example style instruction:

- ``speaking very fast, bright and full``

.. warning::

   **Physical Limits:** You cannot perform arbitrary identity transformations
   from cloning alone. The clone feature is best used for adjusting emotion,
   speed, and delivery style of the original voice.

----

Quick Recipe Summary
********************

- Use clean target text in the intended language first; add extra control only when needed.
- For dialects, rewrite the text in authentic dialect wording instead of standard Mandarin.
- Use non-verbal tags sparingly to add breaths, laughter, or hesitation.
- For Voice Design, combine identity, texture, and scenario into one prompt.
- For cloning, start with a clean 5-second-plus reference clip and then layer in style control.

For the exact ``generate()`` parameters and code-level examples, see
:doc:`./usage_guide`.

Happy creating. Mix, match, and experiment to find the sound that fits your use
case best.
