ttl_minutes = ENV.fetch("SESSION_TTL_MINUTES", "120").to_i
ttl_minutes = 120 if ttl_minutes <= 0

Rails.application.config.session_store :cookie_store,
  key: "_app_session",
  expire_after: ttl_minutes.minutes,
  secure: Rails.env.production?,
  httponly: true,
  same_site: :lax