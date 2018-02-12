class InvalidMailer < Mailer

  # Notifies users about an invalid issue
  def notify_invalid_issue(email, exc)
    @error = exc.message
    mail to: email.from.first,
         subject: l(:notify_invalid_issue_subject, subject: email.subject, project: email.to.first,
                    scope: :html_mail_handler_notifier)
  end

  # Notifies users about an invalid issue reply
  def notify_invalid_issue_reply(email, exc)
    @error = exc.message
    mail to: email.from.first,
         subject: l(:notify_invalid_issue_reply_subject, subject: email.subject, project: email.to.first,
                    scope: :html_mail_handler_notifier)
  end

end
