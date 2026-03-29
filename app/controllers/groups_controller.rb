class GroupsController < ApplicationController
  require_authentication except: %i[show]

  def index
    @owned = current_user.owned_groups
    @member_of = current_user.groups.where.not(id: @owned.select(:id))
  end

  def show
    @group = Group.find(params[:id])
    unless @group.public? || (authenticated? && @group.member?(current_user))
      redirect_to root_path, alert: "Group not found."
      return
    end

    @memberships = @group.group_memberships.includes(:user)
    @pending_invitations = @group.group_invitations.pending if authenticated? && @group.editor?(current_user)
    @activities = @group.group_activities.includes(:user).limit(20)
    @collections = @group.collections.includes(:passages)
    @curricula = @group.curricula.includes(:curriculum_items)
    @annotations = @group.annotations.includes(passage: { division: { scripture: :corpus } }, tags: []).limit(10)
  end

  def new
    @group = Group.new
  end

  def create
    @group = Group.new(group_params)
    @group.owner = current_user
    if @group.save
      @group.group_memberships.create!(user: current_user, role: "owner")
      redirect_to group_path(@group), notice: "Group created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @group = find_owned_group
  end

  def update
    @group = find_owned_group
    if @group.update(group_params)
      redirect_to group_path(@group), notice: "Group updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    find_owned_group.destroy
    redirect_to groups_path
  end

  def invite
    @group = find_editor_group
    invitation = @group.group_invitations.new(
      email: params[:email],
      role: params[:role].presence || "viewer",
      invited_by: current_user
    )
    if invitation.save
      GroupMailer.invitation(invitation).deliver_later
      redirect_to group_path(@group), notice: "Invitation sent to #{invitation.email}."
    else
      redirect_to group_path(@group), alert: invitation.errors.full_messages.join(", ")
    end
  end

  def accept_invitation
    invitation = GroupInvitation.pending.find_by!(token: params[:token])
    invitation.accept!(current_user)
    redirect_to group_path(invitation.group), notice: "You joined #{invitation.group.name}."
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "Invalid or expired invitation."
  end

  def remove_member
    @group = find_owned_group
    membership = @group.group_memberships.find_by!(user_id: params[:user_id])
    membership.destroy unless membership.user == @group.owner
    redirect_to group_path(@group)
  end

  def leave
    @group = Group.find(params[:id])
    if @group.owner == current_user
      redirect_to group_path(@group), alert: "Owners cannot leave. Transfer ownership or delete the group."
    else
      @group.group_memberships.find_by(user: current_user)&.destroy
      redirect_to groups_path, notice: "You left #{@group.name}."
    end
  end

  private

  def group_params
    params.require(:group).permit(:name, :description, :public)
  end

  def find_owned_group
    current_user.owned_groups.find(params[:id])
  end

  def find_editor_group
    group = Group.find(params[:id])
    raise ActiveRecord::RecordNotFound unless group.editor?(current_user)
    group
  end
end
