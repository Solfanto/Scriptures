# == Schema Information
#
# Table name: traditions
# Database name: primary
#
#  id          :bigint           not null, primary key
#  description :text
#  name        :string           not null
#  slug        :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_traditions_on_slug  (slug) UNIQUE
#
class Tradition < ApplicationRecord
  has_many :corpora, class_name: "Corpus", dependent: :destroy

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true

  def to_param = slug
end
