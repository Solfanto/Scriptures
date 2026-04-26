class Admin::LlmTranslationsController < Admin::ApplicationController
  def index
    if params[:scripture_id].present?
      @scripture = Scripture.find(params[:scripture_id])
      @corpus = @scripture.corpus
      @style = valid_style(params[:style])
      @divisions = @scripture.divisions.where(parent_id: nil).order(:position)
      @completion = compute_completion(@scripture, @style)
    elsif params[:corpus_id].present?
      @corpus = Corpus.find(params[:corpus_id])
      @scriptures = @corpus.scriptures.order(:position)
    else
      @corpora = Corpus.order(:name)
    end
  end

  def show
    @division = Division.find(params[:id])
    @scripture = @division.scripture
    @corpus = @scripture.corpus
    @style = valid_style(params[:style])
    @style_config = LlmTranslationJob::STYLES[@style]
    @provider = valid_provider(params[:provider])

    @passages = @division.passages.order(:position).to_a

    @source_translation = @corpus.translations.find_by(edition_type: "original") ||
                          @corpus.translations.first
    @originals = single_passage_text_index(@passages, @source_translation)

    abbr = "LLM-#{@style_config[:abbreviation_suffix]}"
    @llm_translation = Translation.find_by(abbreviation: abbr, corpus: @corpus)

    @single_passage_translations = single_passage_text_index(@passages, @llm_translation)
    @range_segments = load_range_segments(@passages, @llm_translation)
  end

  def translate
    style = valid_style(params[:style])
    provider = valid_provider(params[:provider])
    division = Division.find(params[:division_id])

    if params[:passage_ids].present?
      ids = Array(params[:passage_ids]).map(&:to_i)
      passages = Passage.where(id: ids).order(:position_in_scripture).to_a
      return redirect_back fallback_location: admin_llm_translation_path(division, style: style, provider: provider),
        alert: "No passages selected." if passages.empty?

      LlmTranslationJob.perform_later(
        start_passage_id: passages.first.id,
        end_passage_id: passages.last.id,
        style: style,
        provider: provider
      )
      redirect_to admin_llm_translation_path(division, style: style, provider: provider),
        notice: "Range translation enqueued for #{passages.size} passage(s) (#{LlmTranslationJob::PROVIDERS[provider][:name]})."
    elsif params[:passage_id].present?
      LlmTranslationJob.perform_later(
        start_passage_id: params[:passage_id].to_i,
        end_passage_id: params[:passage_id].to_i,
        style: style,
        provider: provider
      )
      redirect_to admin_llm_translation_path(division, style: style, provider: provider),
        notice: "Translation enqueued (#{LlmTranslationJob::PROVIDERS[provider][:name]})."
    else
      count = 0
      division.passages.find_each do |passage|
        LlmTranslationJob.perform_later(
          start_passage_id: passage.id,
          end_passage_id: passage.id,
          style: style,
          provider: provider
        )
        count += 1
      end
      redirect_to admin_llm_translation_path(division, style: style, provider: provider),
        notice: "#{count} translations enqueued (#{LlmTranslationJob::PROVIDERS[provider][:name]})."
    end
  end

  def save_segment
    start_passage = Passage.find(params[:start_passage_id])
    end_passage = Passage.find(params[:end_passage_id])
    style = valid_style(params[:style])
    style_config = LlmTranslationJob::STYLES[style]
    corpus = start_passage.scripture.corpus

    abbr = "LLM-#{style_config[:abbreviation_suffix]}"
    translation = Translation.find_or_create_by!(abbreviation: abbr, corpus: corpus) do |t|
      t.name = "AI #{style_config[:name_suffix]}"
      t.language = "English"
      t.edition_type = "critical"
    end

    TranslationSegment.upsert_for_range(
      translation: translation,
      start_passage: start_passage,
      end_passage: end_passage,
      text: params[:text]
    )

    redirect_to admin_llm_translation_path(start_passage.division, style: style),
      notice: "Saved (#{start_passage.number}–#{end_passage.number})."
  end

  private

  def valid_style(style)
    LlmTranslationJob::STYLES.key?(style) ? style : "word_for_word"
  end

  def valid_provider(provider)
    LlmTranslationJob::PROVIDERS.key?(provider) ? provider : LlmTranslationJob::DEFAULT_PROVIDER
  end

  # Loads single-passage segments only (start = end), keyed by passage_id.
  def single_passage_text_index(passages, translation)
    return {} unless translation && passages.any?

    TranslationSegment
      .where(translation: translation, start_passage_id: passages.map(&:id))
      .where("start_passage_id = end_passage_id")
      .pluck(:start_passage_id, :text).to_h
  end

  # Loads range segments (start != end) overlapping the division's passages.
  def load_range_segments(passages, translation)
    return [] unless translation && passages.any?

    positions = passages.map(&:position_in_scripture)
    TranslationSegment
      .where(translation: translation, scripture_id: passages.first.scripture.id)
      .where("start_passage_id != end_passage_id")
      .where("start_position <= ? AND end_position >= ?", positions.max, positions.min)
      .includes(:start_passage, :end_passage)
      .order(:start_position)
  end

  def compute_completion(scripture, style)
    style_config = LlmTranslationJob::STYLES[style]
    abbr = "LLM-#{style_config[:abbreviation_suffix]}"
    translation = Translation.find_by(abbreviation: abbr, corpus: scripture.corpus)

    total = Passage.unscoped.where(division: scripture.divisions).group(:division_id).count

    translated = {}
    if translation
      translated = TranslationSegment
        .where(translation: translation, scripture_id: scripture.id)
        .where("start_passage_id = end_passage_id")
        .joins("JOIN passages ON passages.id = translation_segments.start_passage_id")
        .group("passages.division_id")
        .count
    end

    { total: total, translated: translated }
  end
end
