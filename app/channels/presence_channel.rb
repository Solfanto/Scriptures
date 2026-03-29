class PresenceChannel < ApplicationCable::Channel
  def subscribed
    group = Group.find(params[:group_id])
    if group.member?(current_user)
      stream_for group
      self.class.broadcast_to(group, {
        type: "join",
        user_id: current_user.id,
        user: current_user.display_name || current_user.email_address
      })
    else
      reject
    end
  end

  def reading(data)
    group = Group.find(params[:group_id])
    self.class.broadcast_to(group, {
      type: "reading",
      user_id: current_user.id,
      user: current_user.display_name || current_user.email_address,
      passage_ref: data["passage_ref"]
    })
  end

  def unsubscribed
    group = Group.find_by(id: params[:group_id])
    return unless group

    self.class.broadcast_to(group, {
      type: "leave",
      user_id: current_user.id
    })
  end
end
