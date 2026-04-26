# == Schema Information
#
# Table name: passage_source_documents
# Database name: primary
#
#  id                 :bigint           not null, primary key
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  passage_id         :bigint           not null
#  source_document_id :bigint           not null
#
# Indexes
#
#  index_passage_source_documents_on_passage_id          (passage_id)
#  index_passage_source_documents_on_source_document_id  (source_document_id)
#
# Foreign Keys
#
#  fk_rails_...  (passage_id => passages.id)
#  fk_rails_...  (source_document_id => source_documents.id)
#
class PassageSourceDocument < ApplicationRecord
  belongs_to :passage
  belongs_to :source_document
end
