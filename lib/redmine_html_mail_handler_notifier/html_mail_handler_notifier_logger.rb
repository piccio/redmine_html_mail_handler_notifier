module RedmineHtmlMailHandlerNotifier
class HtmlMailHandlerNotifierLogger < Logger
    def self.write(level, message)
      if Setting.plugin_redmine_html_mail_handler_notifier[:enable_log] == 'true'
        logger ||= new("#{Rails.root}/log/html_mail_handler_notifier.log")
        logger.send(level, message)
      end
    end
  end
end
