module RedmineHtmlMailHandlerNotifier
  module MailHandlerPatch
    def self.included(base) # :nodoc:
      base.send(:include, InstanceMethods)

      base.class_eval do
        alias_method_chain :receive_issue, :invalid_mail_catcher
        alias_method_chain :receive_issue_reply, :invalid_mail_catcher
        alias_method_chain :receive_message_reply, :invalid_mail_catcher
      end
    end

    module InstanceMethods
      private

      # wrap original method to catch error catched by 'dispatch' method
      def receive_issue_with_invalid_mail_catcher
        receive_issue_without_invalid_mail_catcher
      rescue ActiveRecord::RecordInvalid, MailHandler::MissingInformation, MailHandler::UnauthorizedAction,
        RedmineHtmlMailHandler::Error, ActionView::Template::Error => e
        notify(email, e)
      end

      # wrap original method to catch error catched by 'dispatch' method
      def receive_issue_reply_with_invalid_mail_catcher(issue_id, from_journal = nil)
        receive_issue_reply_without_invalid_mail_catcher(issue_id, from_journal)
      rescue ActiveRecord::RecordInvalid, MailHandler::MissingInformation, MailHandler::UnauthorizedAction,
        RedmineHtmlMailHandler::Error, ActionView::Template::Error => e
        notify(email, e)
      end

      # wrap original method to catch error catched by 'dispatch' method
      def receive_message_reply_with_invalid_mail_catcher(message_id)
        receive_message_reply_without_invalid_mail_catcher(message_id)
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
end
