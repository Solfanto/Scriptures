class PagesController < ApplicationController
  def home
    @traditions = Tradition.includes(:corpora).order(:name)
    @stats = {
      traditions: Tradition.count,
      scriptures: Scripture.count,
      passages: Passage.count,
      translations: Translation.count
    }
  end
end
