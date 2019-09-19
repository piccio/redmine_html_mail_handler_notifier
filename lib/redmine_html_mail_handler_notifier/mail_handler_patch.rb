module RedmineHtmlMailHandlerNotifier
  module MailHandlerPatch

    private

    # wrap original method to catch error catched by 'dispatch' method
    def receive_issue
      super
    rescue ActiveRecord::RecordInvalid, MailHandler::MissingInformation, MailHandler::UnauthorizedAction,
      RedmineHtmlMailHandler::Error, ActionView::Template::Error => e
      notify(user: user, email: email, receiver: :invalid_new_issue, exc: e)
    end

    # wrap original method to catch error catched by 'dispatch' method
    def receive_issue_reply(issue_id, from_journal = nil)
      super
    rescue ActiveRecord::RecordInvalid, MailHandler::MissingInformation, MailHandler::UnauthorizedAction,
      RedmineHtmlMailHandler::Error, ActionView::Template::Error => e
      notify(user: user, email: email, receiver: :invalid_issue_reply, exc: e)
    end

    # wrap original method to catch error catched by 'dispatch' method
    def receive_message_reply(message_id)
      super
    rescue ActiveRecord::RecordInvalid, MailHandler::MissingInformation, MailHandler::UnauthorizedAction,
      RedmineHtmlMailHandler::Error, ActionView::Template::Error => e
      notify(user: user, email: email, receiver: :invalid_issue_reply, exc: e)
    end

    def notify(user:, email:, receiver:, exc:)
      RedmineHtmlMailHandlerNotifier::HtmlMailHandlerNotifierLogger.write(:info, 'invalid email')

      error_msg = l(receiver, scope: :html_mail_handler_notifier)
      subject = l("#{receiver}_subject".to_sym, subject: email.subject, project: email.to.first,
                  scope: :html_mail_handler_notifier)

      # send email
      InvalidMailer.deliver_invalid_issue(user: user, subject: subject, msg: error_msg, error: exc.message)
    rescue => e
      # log error
      RedmineHtmlMailHandlerNotifier::HtmlMailHandlerNotifierLogger.write(:error, "ERROR=#{e.message}")
      RedmineHtmlMailHandlerNotifier::HtmlMailHandlerNotifierLogger.write(:error, "BACKTRACE=#{e.backtrace.join("\n")}")
      # re-raise InvalidMailer.notify_invalid_issue deliver error
      raise e
    else
      RedmineHtmlMailHandlerNotifier::HtmlMailHandlerNotifierLogger.write(
        :debug, "notified #{user} about '#{email.subject}' error=#{exc.message}")
      # re-raise invalid mail handler exception to be catched by 'dispatch' method
      raise exc
    end
  end
end
