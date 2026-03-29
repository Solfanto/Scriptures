module ApplicationHelper

  def sidebar_link(label, icon, path, active: false)
    base = "w-full flex items-center gap-3 px-3 py-2.5 rounded-xl transition-all duration-200 group"
    active_class = "bg-stone-100 dark:bg-stone-900 text-stone-900 dark:text-stone-100"
    inactive_class = "text-stone-500 hover:bg-stone-50 dark:hover:bg-stone-900/50 hover:text-stone-900 dark:hover:text-stone-100"
    icon_active = "text-blue-500"
    icon_inactive = "group-hover:text-stone-900 dark:group-hover:text-stone-100"

    link_to path, class: "#{base} #{active ? active_class : inactive_class}", data: { turbo_action: "advance" } do
      content_tag(:span, icon.html_safe, class: "shrink-0 transition-colors #{active ? icon_active : icon_inactive}") +
        content_tag(:span, label, class: "text-sm font-medium whitespace-nowrap", data: { sidebar_target: "label" })
    end
  end

  # Lucide-style SVG icons (20x20, stroke-width 2)
  def reading_icon
    svg_icon('<path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"/><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"/>')
  end

  def browse_icon
    svg_icon('<path d="M4 19.5v-15A2.5 2.5 0 0 1 6.5 2H19a1 1 0 0 1 1 1v18a1 1 0 0 1-1 1H6.5a1 1 0 0 1 0-5H20"/>')
  end

  def search_icon
    svg_icon('<circle cx="11" cy="11" r="8"/><path d="m21 21-4.3-4.3"/>')
  end

  def search_icon_sm
    '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="shrink-0"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.3-4.3"/></svg>'.html_safe
  end

  def menu_icon
    svg_icon('<line x1="4" x2="20" y1="12" y2="12"/><line x1="4" x2="20" y1="6" y2="6"/><line x1="4" x2="20" y1="18" y2="18"/>')
  end

  def sun_icon
    svg_icon('<circle cx="12" cy="12" r="4"/><path d="M12 2v2"/><path d="M12 20v2"/><path d="m4.93 4.93 1.41 1.41"/><path d="m17.66 17.66 1.41 1.41"/><path d="M2 12h2"/><path d="M20 12h2"/><path d="m6.34 17.66-1.41 1.41"/><path d="m19.07 4.93-1.41 1.41"/>')
  end

  def moon_icon
    svg_icon('<path d="M12 3a6 6 0 0 0 9 9 9 9 0 1 1-9-9Z"/>')
  end

  def chevron_right_icon(size: 12)
    %(<svg xmlns="http://www.w3.org/2000/svg" width="#{size}" height="#{size}" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="shrink-0"><path d="m9 18 6-6-6-6"/></svg>).html_safe
  end

  def info_icon(size: 16)
    %(<svg xmlns="http://www.w3.org/2000/svg" width="#{size}" height="#{size}" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><path d="M12 16v-4"/><path d="M12 8h.01"/></svg>).html_safe
  end

  def bookmark_icon(size: 16)
    %(<svg xmlns="http://www.w3.org/2000/svg" width="#{size}" height="#{size}" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m19 21-7-4-7 4V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2v16z"/></svg>).html_safe
  end

  def annotation_icon(size: 20)
    %(<svg xmlns="http://www.w3.org/2000/svg" width="#{size}" height="#{size}" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>).html_safe
  end

  def discover_icon(size: 20)
    %(<svg xmlns="http://www.w3.org/2000/svg" width="#{size}" height="#{size}" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><polygon points="16.24 7.76 14.12 14.12 7.76 16.24 9.88 9.88 16.24 7.76"/></svg>).html_safe
  end

  def group_icon(size: 20)
    %(<svg xmlns="http://www.w3.org/2000/svg" width="#{size}" height="#{size}" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M22 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>).html_safe
  end

  def curriculum_icon(size: 20)
    %(<svg xmlns="http://www.w3.org/2000/svg" width="#{size}" height="#{size}" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 19.5v-15A2.5 2.5 0 0 1 6.5 2H19a1 1 0 0 1 1 1v18a1 1 0 0 1-1 1H6.5a1 1 0 0 1 0-5H20"/><path d="m9 9.5 2 2 4-4"/></svg>).html_safe
  end

  def collection_icon(size: 20)
    %(<svg xmlns="http://www.w3.org/2000/svg" width="#{size}" height="#{size}" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"/></svg>).html_safe
  end

  def arrow_right_icon(size: 10)
    %(<svg xmlns="http://www.w3.org/2000/svg" width="#{size}" height="#{size}" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12h14"/><path d="m12 5 7 7-7 7"/></svg>).html_safe
  end

  def speaker_icon(size: 14)
    %(<svg xmlns="http://www.w3.org/2000/svg" width="#{size}" height="#{size}" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polygon points="11 5 6 9 2 9 2 15 6 15 11 19 11 5"/><path d="M15.54 8.46a5 5 0 0 1 0 7.07"/><path d="M19.07 4.93a10 10 0 0 1 0 14.14"/></svg>).html_safe
  end

  def copy_icon(size: 14)
    %(<svg xmlns="http://www.w3.org/2000/svg" width="#{size}" height="#{size}" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect width="14" height="14" x="8" y="8" rx="2" ry="2"/><path d="M4 16c-1.1 0-2-.9-2-2V4c0-1.1.9-2 2-2h10c1.1 0 2 .9 2 2"/></svg>).html_safe
  end

  def x_icon(size: 14)
    %(<svg xmlns="http://www.w3.org/2000/svg" width="#{size}" height="#{size}" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="text-stone-400"><path d="M18 6 6 18"/><path d="m6 6 12 12"/></svg>).html_safe
  end

  # Map source document colors to Tailwind classes (avoids dynamic class interpolation)
  SOURCE_BG_CLASSES = {
    "blue" => "bg-blue-500",
    "amber" => "bg-amber-500",
    "emerald" => "bg-emerald-500",
    "red" => "bg-red-500",
    "purple" => "bg-purple-500"
  }.freeze

  SOURCE_TEXT_CLASSES = {
    "blue" => "text-blue-600/80 dark:text-blue-400/80",
    "amber" => "text-amber-600/80 dark:text-amber-400/80",
    "emerald" => "text-emerald-600/80 dark:text-emerald-400/80",
    "red" => "text-red-600/80 dark:text-red-400/80",
    "purple" => "text-purple-600/80 dark:text-purple-400/80"
  }.freeze

  def source_bg_class(color)
    SOURCE_BG_CLASSES[color] || "bg-stone-500"
  end

  def source_text_class(color)
    SOURCE_TEXT_CLASSES[color] || "text-stone-600/80 dark:text-stone-400/80"
  end

  def toggle_translation_params(translation)
    current = Array(params[:t])
    if current.include?(translation.abbreviation)
      remaining = current - [ translation.abbreviation ]
      remaining.empty? ? nil : remaining
    else
      current + [ translation.abbreviation ]
    end
  end

  EDITION_TYPE_BADGES = { "critical" => "C", "devotional" => "D", "original" => "O" }.freeze
  EDITION_TYPE_COLORS = {
    "critical" => "text-blue-500",
    "devotional" => "text-amber-500",
    "original" => "text-emerald-500"
  }.freeze

  def edition_type_badge(type)
    EDITION_TYPE_BADGES[type]
  end

  def edition_type_color(type)
    EDITION_TYPE_COLORS[type] || "text-stone-400"
  end

  def chevron_left_icon(size: 12)
    %(<svg xmlns="http://www.w3.org/2000/svg" width="#{size}" height="#{size}" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="shrink-0"><path d="m15 18-6-6 6-6"/></svg>).html_safe
  end

  def translation_diff(text_a, text_b)
    return [] if text_a.blank? || text_b.blank?

    words_a = text_a.split(/\s+/)
    words_b = text_b.split(/\s+/)
    sdiff = Diff::LCS.sdiff(words_a, words_b)

    sdiff.map do |change|
      case change.action
      when "=" then { type: :equal, text: change.old_element }
      when "-" then { type: :deletion, text: change.old_element }
      when "+" then { type: :addition, text: change.new_element }
      when "!" then { type: :change, old_text: change.old_element, new_text: change.new_element }
      end
    end
  end

  private

  def svg_icon(paths)
    %(<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">#{paths}</svg>).html_safe
  end
end
