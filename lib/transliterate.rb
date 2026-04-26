module Transliterate
  # Romanise Greek, Hebrew, and Arabic text into Latin script using simple
  # SBL-style schemes. Combining marks (Greek accents/breathing, Hebrew niqud,
  # Arabic harakat) are dropped before mapping the base characters.
  #
  # The output is intended for keyword search and accessibility, not for
  # philological precision: vowel pointing and length distinctions are lost.

  GREEK = {
    "α" => "a", "β" => "b", "γ" => "g", "δ" => "d", "ε" => "e",
    "ζ" => "z", "η" => "ē", "θ" => "th", "ι" => "i", "κ" => "k",
    "λ" => "l", "μ" => "m", "ν" => "n", "ξ" => "x", "ο" => "o",
    "π" => "p", "ρ" => "r", "σ" => "s", "ς" => "s", "τ" => "t",
    "υ" => "u", "φ" => "ph", "χ" => "ch", "ψ" => "ps", "ω" => "ō",
    "Α" => "A", "Β" => "B", "Γ" => "G", "Δ" => "D", "Ε" => "E",
    "Ζ" => "Z", "Η" => "Ē", "Θ" => "Th", "Ι" => "I", "Κ" => "K",
    "Λ" => "L", "Μ" => "M", "Ν" => "N", "Ξ" => "X", "Ο" => "O",
    "Π" => "P", "Ρ" => "R", "Σ" => "S", "Τ" => "T", "Υ" => "U",
    "Φ" => "Ph", "Χ" => "Ch", "Ψ" => "Ps", "Ω" => "Ō"
  }.freeze

  HEBREW = {
    "א" => "ʾ", "ב" => "b", "ג" => "g", "ד" => "d", "ה" => "h",
    "ו" => "w", "ז" => "z", "ח" => "ḥ", "ט" => "ṭ", "י" => "y",
    "כ" => "k", "ך" => "k", "ל" => "l", "מ" => "m", "ם" => "m",
    "נ" => "n", "ן" => "n", "ס" => "s", "ע" => "ʿ", "פ" => "p",
    "ף" => "p", "צ" => "ṣ", "ץ" => "ṣ", "ק" => "q", "ר" => "r",
    "ש" => "š", "ת" => "t"
  }.freeze

  ARABIC = {
    "ا" => "ā", "ب" => "b", "ت" => "t", "ث" => "ṯ", "ج" => "j",
    "ح" => "ḥ", "خ" => "ḫ", "د" => "d", "ذ" => "ḏ", "ر" => "r",
    "ز" => "z", "س" => "s", "ش" => "š", "ص" => "ṣ", "ض" => "ḍ",
    "ط" => "ṭ", "ظ" => "ẓ", "ع" => "ʿ", "غ" => "ġ", "ف" => "f",
    "ق" => "q", "ك" => "k", "ل" => "l", "م" => "m", "ن" => "n",
    "ه" => "h", "و" => "w", "ي" => "y", "ى" => "ā", "ة" => "h",
    "ء" => "ʾ", "أ" => "a", "إ" => "i", "آ" => "ā", "ؤ" => "ʾ",
    "ئ" => "ʾ", "ـ" => ""
  }.freeze

  # Combining-mark ranges: Greek/Latin diacritics, Hebrew niqud + cantillation,
  # Arabic harakat + Quranic annotation marks.
  COMBINING_MARKS = /[̀-֑ͯ-ׇؐ-ًؚ-ٰٟۖ-ۭ࣓-ࣿ︠-︯]+/

  module_function

  def greek(text)
    map(text, GREEK)
  end

  def hebrew(text)
    map(text, HEBREW)
  end

  def arabic(text)
    map(text, ARABIC)
  end

  def map(text, table)
    return "" if text.nil?
    text.to_s
      .unicode_normalize(:nfd)
      .gsub(COMBINING_MARKS, "")
      .each_char
      .map { |c| table.fetch(c, c) }
      .join
  end
end
