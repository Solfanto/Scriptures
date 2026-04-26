# == Schema Information
#
# Table name: import_runs
# Database name: primary
#
#  id              :bigint           not null, primary key
#  completed_at    :datetime
#  error_message   :text
#  key             :string           not null
#  processed_count :integer          default(0)
#  records_count   :integer          default(0)
#  started_at      :datetime
#  status          :string           default("pending"), not null
#  total_count     :integer          default(0)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_import_runs_on_key     (key)
#  index_import_runs_on_status  (status)
#
class ImportRun < ApplicationRecord
  STATUSES = %w[pending running completed failed cancelled].freeze

  validates :key, presence: true
  validates :status, inclusion: { in: STATUSES }

  scope :latest_by_key, -> { where(id: select("MAX(id)").group(:key)) }

  def running?
    status == "running"
  end

  def completed?
    status == "completed"
  end

  def failed?
    status == "failed"
  end

  def cancelled?
    status == "cancelled"
  end

  def cancel!
    update!(status: "cancelled", completed_at: Time.current)
  end

  def progress_percentage
    return 0 if total_count.nil? || total_count.zero?
    [ (processed_count.to_f / total_count * 100).round, 100 ].min
  end

  def duration
    return unless started_at
    (completed_at || Time.current) - started_at
  end
end
