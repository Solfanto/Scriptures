# == Schema Information
#
# Table name: highlights
#
#  id             :bigint           not null, primary key
#  color          :string           not null
#  end_offset     :integer          not null
#  label          :string
#  start_offset   :integer          not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  passage_id     :bigint           not null
#  translation_id :bigint           not null
#  user_id        :bigint           not null
#
# Indexes
#
#  index_highlights_on_passage_id      (passage_id)
#  index_highlights_on_translation_id  (translation_id)
#  index_highlights_on_user_id         (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (passage_id => passages.id)
#  fk_rails_...  (translation_id => translations.id)
#  fk_rails_...  (user_id => users.id)
#
class Highlight < ApplicationRecord
  COLORS = %w[yellow blue green pink purple orange].freeze

  belongs_to :user
  belongs_to :passage
  belongs_to :translation

  validates :color, presence: true, inclusion: { in: COLORS }
  validates :start_offset, presence: true
  validates :end_offset, presence: true
end
