class ParallelPassagesController < ApplicationController
  require_authentication only: :create

  def create
    parallel = current_user.parallel_passages.new(parallel_passage_params)

    if parallel.save
      redirect_back fallback_location: root_path, notice: "Parallel link added."
    else
      redirect_back fallback_location: root_path, alert: parallel.errors.full_messages.join(", ")
    end
  end

  private

  def parallel_passage_params
    params.require(:parallel_passage).permit(:passage_id, :parallel_passage_id, :relationship_type, :description, :citation)
  end
end
