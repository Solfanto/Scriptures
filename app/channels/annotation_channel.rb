class AnnotationChannel < ApplicationCable::Channel
  def subscribed
    group = Group.find(params[:group_id])
    if group.member?(current_user)
      stream_for group
    else
      reject
    end
  end

  def self.broadcast_annotation(group, annotation)
    broadcast_to(group, {
      type: "annotation",
      id: annotation.id,
      passage_id: annotation.passage_id,
      body: annotation.body,
      user: annotation.user.display_name || annotation.user.email,
      created_at: annotation.created_at.iso8601
    })
  end

  def self.broadcast_comment(annotation, comment)
    return unless annotation.group

    broadcast_to(annotation.group, {
      type: "comment",
      annotation_id: annotation.id,
      body: comment.body,
      user: comment.user.display_name || comment.user.email,
      created_at: comment.created_at.iso8601
    })
  end
end
