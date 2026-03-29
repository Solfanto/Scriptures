class AnnotationCommentsController < ApplicationController
  require_authentication

  def create
    annotation = Annotation.find(params[:annotation_id])
    unless annotation.group && annotation.group.member?(current_user)
      redirect_to root_path, alert: "Not authorized."
      return
    end

    comment = annotation.annotation_comments.new(user: current_user, body: params[:body])
    if comment.save
      annotation.group.record_activity!(user: current_user, action: "commented", trackable: annotation)
      AnnotationChannel.broadcast_comment(annotation, comment)
      redirect_back fallback_location: root_path
    else
      redirect_back fallback_location: root_path, alert: comment.errors.full_messages.join(", ")
    end
  end

  def destroy
    comment = current_user.annotation_comments.find(params[:id])
    comment.destroy
    redirect_back fallback_location: root_path
  end
end
