Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, ENV['GITHUB_CLIENT_ID'], ENV['GITHUB_CLIENT_SECRET'], scope: "user:email"
  provider :twitter2, ENV['X_CLIENT_ID'], ENV['X_CLIENT_SECRET'],
   scope: "tweet.read users.read users.email",
         callback_path: "/auth/twitter2/callback"
end

OmniAuth.config.full_host = lambda do |env|
  configured_host = ENV['APP_HOST'].to_s.strip
  use_configured_host = configured_host.present? && Rails.env.production?
  next configured_host if use_configured_host

  scheme = env['HTTP_X_FORWARDED_PROTO'] || env['rack.url_scheme'] || 'http'
  host = env['HTTP_X_FORWARDED_HOST'] || env['HTTP_HOST']
  "#{scheme}://#{host}"
end
OmniAuth.config.allowed_request_methods = [:get, :post]