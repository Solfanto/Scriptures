class GroupChannel < ApplicationCable::Channel
  def subscribed
    group = Group.find(params[:id])
    if group.member?(current_user)
      stream_for group
    else
      reject
    end
  end
end
