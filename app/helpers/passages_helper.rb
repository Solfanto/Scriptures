module PassagesHelper
  # Returns one of:
  #   :anchor       — render the segment text on this passage (segment starts here)
  #   :continuation — segment covers this passage but already rendered earlier
  #   nil           — no covering segment
  def segment_render_role(passage, translation)
    segment = passage.covering_segment(translation)
    return nil unless segment
    segment.start_passage_id == passage.id ? :anchor : :continuation
  end

  # "v. 3", "v. 1–5", or "1:1–2:3" if the range crosses a chapter
  def segment_range_label(segment)
    start_p = segment.start_passage
    end_p = segment.end_passage
    return "v. #{start_p.number}" if segment.single_passage?

    if start_p.division_id == end_p.division_id
      "v. #{start_p.number}–#{end_p.number}"
    else
      "#{start_p.division.number}:#{start_p.number}–#{end_p.division.number}:#{end_p.number}"
    end
  end
end
