# == Schema Information
#
# Table name: translations
# Database name: primary
#
#  id           :bigint           not null, primary key
#  abbreviation :string
#  description  :text
#  edition_type :string
#  language     :string
#  name         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  corpus_id    :bigint           not null
#
# Indexes
#
#  index_translations_on_abbreviation  (abbreviation)
#  index_translations_on_corpus_id     (corpus_id)
#
# Foreign Keys
#
#  fk_rails_...  (corpus_id => corpora.id)
#
class Translation < ApplicationRecord
  EDITION_TYPES = %w[critical devotional original].freeze

  belongs_to :corpus
  has_many :translation_segments, dependent: :destroy

  validates :name, presence: true
  validates :abbreviation, presence: true
  validates :edition_type, inclusion: { in: EDITION_TYPES }, allow_nil: true

  scope :critical, -> { where(edition_type: "critical") }
  scope :devotional, -> { where(edition_type: "devotional") }
  scope :original, -> { where(edition_type: "original") }

  def critical? = edition_type == "critical"
  def devotional? = edition_type == "devotional"
  def original? = edition_type == "original"
end
