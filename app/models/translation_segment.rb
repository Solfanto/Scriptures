class TranslationSegment < ApplicationRecord
  belongs_to :translation
  belongs_to :scripture
  belongs_to :start_passage, class_name: "Passage"
  belongs_to :end_passage, class_name: "Passage"
  has_many :ratings, dependent: :destroy

  validates :text, presence: true
  validates :start_position, presence: true
  validates :end_position, presence: true
  validate :end_position_not_before_start
  validate :passages_in_same_scripture

  scope :covering, ->(passage) {
    where(scripture_id: passage.scripture.id)
      .where("start_position <= :p AND end_position >= :p", p: passage.position_in_scripture)
      .order(Arel.sql("(end_position - start_position) ASC"))
  }

  scope :for_translation, ->(translation) { where(translation_id: translation.id) }

  def single_passage?
    start_passage_id == end_passage_id
  end

  def passages
    Passage.where(division: scripture.divisions)
      .where("position_in_scripture BETWEEN ? AND ?", start_position, end_position)
      .order(:position_in_scripture)
  end

  def self.upsert_for_range(translation:, start_passage:, end_passage:, text:)
    segment = build_for_range(translation: translation, start_passage: start_passage, end_passage: end_passage)
    segment.text = text
    segment.save!
    segment
  end

  def self.find_or_create_for_range(translation:, start_passage:, end_passage:, text:)
    validate_range!(start_passage, end_passage)
    find_or_create_by!(
      translation: translation,
      start_passage: start_passage,
      end_passage: end_passage
    ) do |s|
      s.scripture = start_passage.scripture
      s.start_position = start_passage.position_in_scripture
      s.end_position = end_passage.position_in_scripture
      s.text = text
    end
  end

  def self.build_for_range(translation:, start_passage:, end_passage:)
    validate_range!(start_passage, end_passage)
    segment = find_or_initialize_by(
      translation: translation,
      start_passage: start_passage,
      end_passage: end_passage
    )
    segment.scripture = start_passage.scripture
    segment.start_position = start_passage.position_in_scripture
    segment.end_position = end_passage.position_in_scripture
    segment
  end

  def self.validate_range!(start_passage, end_passage)
    raise ArgumentError, "passages must share a scripture" unless start_passage.scripture == end_passage.scripture
    raise ArgumentError, "start must precede end" if start_passage.position_in_scripture > end_passage.position_in_scripture
  end

  private

  def end_position_not_before_start
    return if start_position.blank? || end_position.blank?
    errors.add(:end_position, "must not precede start_position") if end_position < start_position
  end

  def passages_in_same_scripture
    return if start_passage.blank? || end_passage.blank? || scripture.blank?
    sid = scripture_id
    return if start_passage.division.scripture_id == sid && end_passage.division.scripture_id == sid
    errors.add(:base, "start_passage, end_passage, and scripture must match")
  end
end
