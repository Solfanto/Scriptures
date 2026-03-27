namespace :llm do
  desc "Generate LLM translations for a passage range"
  task :translate, [ :corpus_slug, :scripture_slug, :style, :from_chapter, :to_chapter ] => :environment do |_t, args|
    corpus = Corpus.find_by!(slug: args[:corpus_slug])
    scripture = corpus.scriptures.find_by!(slug: args[:scripture_slug])
    style = args[:style] || "word_for_word"
    from_ch = (args[:from_chapter] || 1).to_i
    to_ch = (args[:to_chapter] || from_ch).to_i

    unless LlmTranslationJob::STYLES.key?(style)
      abort "Invalid style: #{style}. Choose from: #{LlmTranslationJob::STYLES.keys.join(', ')}"
    end

    divisions = scripture.divisions.where(number: from_ch..to_ch)
    passages = Passage.where(division: divisions)

    puts "Enqueuing #{passages.count} LLM translations (#{style}) for #{scripture.name} chapters #{from_ch}-#{to_ch}"

    passages.find_each do |passage|
      LlmTranslationJob.perform_later(passage_id: passage.id, style: style)
    end

    puts "Done. Jobs enqueued for background processing."
  end
end
