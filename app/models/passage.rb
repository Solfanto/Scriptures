# == Schema Information
#
# Table name: passages
# Database name: primary
#
#  id                    :bigint           not null, primary key
#  number                :integer
#  position              :integer
#  position_in_scripture :integer          not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  division_id           :bigint           not null
#
# Indexes
#
#  index_passages_on_division_id                            (division_id)
#  index_passages_on_division_id_and_number                 (division_id,number)
#  index_passages_on_division_id_and_position_in_scripture  (division_id,position_in_scripture)
#
# Foreign Keys
#
#  fk_rails_...  (division_id => divisions.id)
#
class Passage < ApplicationRecord
  belongs_to :division
  has_many :passage_source_documents, dependent: :destroy
  has_many :source_documents, through: :passage_source_documents
  has_many :original_language_tokens, dependent: :destroy
  has_many :textual_variants, dependent: :destroy
  has_many :parallel_passages, dependent: :destroy
  has_many :commentaries, dependent: :destroy
  has_many :curriculum_items, dependent: :destroy
  has_many :reading_progresses, dependent: :destroy

  default_scope { order(:position) }

  delegate :scripture, to: :division

  def covering_segment(translation)
    if @segment_cache
      @segment_cache[translation.id]
    else
      TranslationSegment.for_translation(translation).covering(self).first
    end
  end

  def covering_segments
    TranslationSegment.covering(self)
  end

  def text_for(translation)
    covering_segment(translation)&.text
  end

  def translations
    Translation.joins(:translation_segments)
      .where(translation_segments: { scripture_id: scripture.id })
      .where("translation_segments.start_position <= :p AND translation_segments.end_position >= :p",
             p: position_in_scripture)
      .distinct
  end

  # Bulk-load covering segments for a set of passages × translations into each
  # passage's per-instance cache, so subsequent covering_segment / text_for
  # calls hit memory. Narrowest segment wins when multiple cover the same passage.
  def self.preload_texts!(passages, translations)
    return if passages.empty? || translations.empty?

    positions = passages.map(&:position_in_scripture)
    scripture_ids = passages.map { |p| p.division.scripture_id }.uniq

    segments = TranslationSegment
      .where(translation_id: translations.map(&:id), scripture_id: scripture_ids)
      .where("start_position <= ? AND end_position >= ?", positions.max, positions.min)
      .order(Arel.sql("(end_position - start_position) ASC"))
      .to_a

    passages.each do |p|
      cache = {}
      sid = p.division.scripture_id
      pos = p.position_in_scripture
      translations.each do |t|
        cache[t.id] = segments.find do |s|
          s.translation_id == t.id && s.scripture_id == sid &&
            s.start_position <= pos && s.end_position >= pos
        end
      end
      p.instance_variable_set(:@segment_cache, cache)
    end
  end
end
