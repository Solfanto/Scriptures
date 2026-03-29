class CorporaController < ApplicationController
  def show
    @tradition = Tradition.find_by!(slug: params[:tradition_id])
    @corpus = @tradition.corpora.find_by!(slug: params[:slug])
    @sort = params[:sort]

    @scriptures = @corpus.scriptures.includes(:divisions, :composition_dates)

    if @sort == "date"
      @scriptures = @scriptures
        .left_joins(:composition_dates)
        .select("scriptures.*, MIN(composition_dates.earliest_year) AS min_year")
        .group("scriptures.id")
        .order(Arel.sql("min_year ASC NULLS LAST, scriptures.position ASC"))
    end
  end
end
