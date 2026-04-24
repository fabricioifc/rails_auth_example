Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, ENV['GITHUB_CLIENT_ID'], ENV['GITHUB_CLIENT_SECRET'], scope: "user:email"
  provider :google_oauth2, 
    ENV['GOOGLE_CLIENT_ID'], 
    ENV['GOOGLE_CLIENT_SECRET'], 
    scope: "userinfo.email, userinfo.profile"
  provider :twitter2, ENV['X_CLIENT_ID'], ENV['X_CLIENT_SECRET'],
   scope: "tweet.read users.read users.email",
         callback_path: "/auth/twitter2/callback"
end

OmniAuth.config.allowed_request_methods = [:get, :post]