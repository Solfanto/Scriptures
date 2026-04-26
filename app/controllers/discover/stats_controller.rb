module Discover
  class StatsController < ApplicationController
    require_authentication

    def show
      @passages_read = current_user.reading_progresses.count
      @total_time = current_user.reading_progresses.sum(:time_spent_seconds)
      @words_encountered = current_user.reading_progresses
        .joins("JOIN passages ON passages.id = reading_progresses.passage_id")
        .joins("JOIN divisions ON divisions.id = passages.division_id")
        .joins("JOIN translation_segments ON translation_segments.scripture_id = divisions.scripture_id " \
               "AND translation_segments.start_position <= passages.position_in_scripture " \
               "AND translation_segments.end_position >= passages.position_in_scripture")
        .sum("array_length(string_to_array(translation_segments.text, ' '), 1)")

      @recent_reads = current_user.reading_progresses
        .includes(passage: { division: { scripture: :corpus } })
        .order(read_at: :desc)
        .limit(20)

      @daily_counts = current_user.reading_progresses
        .where("read_at >= ?", 30.days.ago)
        .group("DATE(read_at)")
        .count
        .transform_keys { |k| k.to_date }
    end
  end
end
