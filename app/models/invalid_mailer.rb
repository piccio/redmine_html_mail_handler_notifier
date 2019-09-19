class InvalidMailer < Mailer

  # Builds a mail to user about an invalid issue
  # Note:
  #   can't use keywords arguments due to an error:
  #     First argument has to be a user, was {:user=>#<User ... >, :subject=>"...", ...}
  def invalid_issue(user, subject, msg, error)
    @error = error
    @msg = msg

    mail to: user, subject: subject
  end

  # Notifies users about an invalid issue
  def self.deliver_invalid_issue(user:, subject:, msg:, error:)
    invalid_issue(user, subject, msg, error).deliver_later
  end

end
