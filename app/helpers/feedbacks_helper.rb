module FeedbacksHelper
  include Rails.application.routes.url_helpers
  include ActionDispatch::Routing::UrlFor

  def default_url_options
    Rails.application.config.action_mailer.default_url_options || {}
  end

  def feedback_form_link(outfit)
    Rails.application.routes.url_helpers.new_outfit_feedback_path(outfit)
  end
end
