class GroupMailer < ApplicationMailer
  def invitation(invitation)
    @invitation = invitation
    @group = invitation.group
    @url = accept_invitation_groups_url(token: invitation.token)
    mail subject: "You're invited to join #{@group.name} on Scriptures", to: invitation.email
  end
end
