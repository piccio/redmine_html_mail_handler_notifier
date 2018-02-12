require 'redmine_html_mail_handler_notifier/mail_handler_patch'
require 'redmine_html_mail_handler_notifier/html_mail_handler_notifier_logger'

Rails.configuration.to_prepare do
  unless MailHandler.included_modules.include? RedmineHtmlMailHandlerNotifier::MailHandlerPatch
    MailHandler.send(:include, RedmineHtmlMailHandlerNotifier::MailHandlerPatch)
  end
end

Redmine::Plugin.register :redmine_html_mail_handler_notifier do
  name 'Redmine Html Mail Handler Notifier plugin'
  author 'Roberto Piccini'
  description 'send a email to the user if he submitted invalid issue or invalid comment via email'
  version '0.0.1'
  url 'https://github.com/piccio/redmine_html_mail_handler_notifier'
  author_url 'https://github.com/piccio'
  requires_redmine version: '2.6.0'

  settings default: { enable_log: false }, partial: 'settings/html_mail_handler_notifier'
end
