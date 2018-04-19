module RedmineHtmlMailHandlerNotifier
  module MailHandlerPatch

    private

    # wrap original method to catch error catched by 'dispatch' method
    def receive_issue
      super
    rescue ActiveRecord::RecordInvalid, MailHandler::MissingInformation, MailHandler::UnauthorizedAction,
      RedmineHtmlMailHandler::Error, ActionView::Template::Error => e
      notify(email, e)
    end

    # wrap original method to catch error catched by 'dispatch' method
    def receive_issue_reply(issue_id, from_journal = nil)
      super
    rescue ActiveRecord::RecordInvalid, MailHandler::MissingInformation, MailHandler::UnauthorizedAction,
      RedmineHtmlMailHandler::Error, ActionView::Template::Error => e
      notify(email, e)
    end

    # wrap original method to catch error catched by 'dispatch' method
    def receive_message_reply(message_id)
      super
    rescue ActiveRecord::RecordInvalid, MailHandler::MissingInformation, MailHandler::UnauthorizedAction,
      RedmineHtmlMailHandler::Error, ActionView::Template::Error => e
      notify(email, e)
    end

    def notify(email, exc)
      RedmineHtmlMailHandlerNotifier::HtmlMailHandlerNotifierLogger.write(:info, 'invalid email')
      # send email
      InvalidMailer.notify_invalid_issue(email, exc).deliver
    rescue => e
      # log error
      RedmineHtmlMailHandlerNotifier::HtmlMailHandlerNotifierLogger.write(:error, "ERROR=#{e.message}")
      RedmineHtmlMailHandlerNotifier::HtmlMailHandlerNotifierLogger.write(:error, "BACKTRACE=#{e.backtrace.join("\n")}")
      # re-raise InvalidMailer.notify_invalid_issue deliver error
      raise e
    else
      RedmineHtmlMailHandlerNotifier::HtmlMailHandlerNotifierLogger.write(
        :debug, "notified #{email.from.first} about '#{email.subject}' error=#{exc.message}")
      # re-raise invalid mail handler exception to be catched by 'dispatch' method
      raise exc
    end
  end
end
