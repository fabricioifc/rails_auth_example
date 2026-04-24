# Rails Auth (GitHub + X)

Aplicação Ruby on Rails para autenticação social com múltiplos providers (GitHub e X/Twitter), usando sessão do Rails (cookie store).

## O que o projeto demonstra

- Login OAuth com GitHub e X
- Um único usuário por e-mail, mesmo autenticando por providers diferentes
- Sessão baseada em cookie com tempo de vida configurável
- Área protegida por sessão
- Painel didático de sessão (em desenvolvimento)
- Formulário de demonstração de CSRF

## Stack

- Ruby on Rails 8
- PostgreSQL 16
- Docker + Docker Compose
- OmniAuth (github e twitter2)

## Subindo a aplicação com Docker

### Primeira execução

1. Construir imagens e iniciar containers:

```bash
docker compose up -d --build
```

2. Criar e migrar banco:
```bash
docker compose run --rm web rails db:create db:migrate
```

3. Acessar no navegador: [http://127.0.0.1:3000](http://127.0.0.1:3000)

### Mais alguns comandos úteis

```bash
docker compose down # parar containers
docker compose down -v # parar containers e remover volumes (dados do banco)
docker compose logs -f web # acompanhar logs do container web
```

## Oauth: criando apps nos providers

- GitHub: https://github.com/settings/apps/
- X/Twitter: https://console.x.com/

Como callback URL, use o host onde a aplicação está rodando + `/auth/:provider/callback`.

 - Callback para GitHub: http://127.0.0.1:3000/auth/github/callback
 - Callback para X: http://127.0.0.1:3000/auth/twitter2/callback

## Rodando com Ngrok

1. Baixe e instale o Ngrok: https://ngrok.com/download
2. Inicie o Ngrok apontando para a porta da aplicação (3000):
```bash
ngrok http 3000
```
3. O Ngrok fornecerá uma URL pública (ex: https://wispy-citizen-oat.ngrok-free.dev). Use essa URL para configurar os callbacks nos providers e acessar a aplicação.

## Sessão

A sessão está configurada em [config/initializers/session_store.rb](config/initializers/session_store.rb).

Configuração atual:

- store: cookie_store
- key: _app_session
- expire_after: SESSION_TTL_MINUTES
- httponly: true
- same_site: lax
- secure: true apenas em produção

> same_site: Em casos de autenticação social, onde o fluxo envolve redirecionamentos entre domínios, `same_site: lax` permite que os cookies sejam enviados em requisições de navegação normal (GET) iniciadas pelo usuário, mas bloqueia em requisições cross-site feitas por scripts (como AJAX), aumentando a segurança contra ataques CSRF.
> http_only: true impede que os cookies sejam acessíveis via JavaScript, reduzindo o risco de ataques XSS.

## Criando a Aplicação do Zero

O passo a passo abaixo recria a aplicação final deste repositório.

### 1. Gerar um projeto Rails vazio

```bash
docker run --rm -v $(pwd):/app -w /app ruby:3.3 bash -lc "gem install rails --no-document && rails new rails_auth -d postgresql"
cd rails_auth
```

### 2. Adicionar as gems necessárias

Edite o `Gemfile` e adicione no final:

```ruby
gem "bcrypt", "~> 3.1.7"
gem "omniauth"
gem "omniauth-github"
gem "omniauth-twitter2"
gem "jwt"
```

### 3. Criar o arquivo `.env`

Crie o arquivo `.env` na raiz do projeto:

```env
DATABASE_HOST=db
DATABASE_USER=postgres
DATABASE_PASSWORD=postgres
DATABASE_NAME=rails_auth_development

GITHUB_CLIENT_ID=
GITHUB_CLIENT_SECRET=

X_CLIENT_ID=
X_CLIENT_SECRET=

SECRET_KEY_BASE=
SESSION_TTL_MINUTES=120
APP_HOST=http://127.0.0.1:3000
```

Para gerar `SECRET_KEY_BASE`:

```bash
openssl rand -hex 64
```

### 4. Criar o Dockerfile de desenvolvimento

Crie `Dockerfile.dev`:

```Dockerfile
FROM ruby:3.3

RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libpq-dev \
  nodejs

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
```

### 5. Criar o `docker-compose.yml`

```yaml
services:
  db:
    image: postgres:16
    volumes:
      - postgres_data:/var/lib/postgresql/data
    environment:
      POSTGRES_USER: ${DATABASE_USER:-postgres}
      POSTGRES_PASSWORD: ${DATABASE_PASSWORD:-postgres}
      POSTGRES_DB: ${DATABASE_NAME:-rails_auth_development}

  web:
    build:
      context: .
      dockerfile: Dockerfile.dev
    command: bash -c "rm -f tmp/pids/server.pid && rails s -b 0.0.0.0"
    volumes:
      - .:/app
    ports:
      - "3000:3000"
    environment:
      DATABASE_HOST: db
      DATABASE_USER: ${DATABASE_USER:-postgres}
      DATABASE_PASSWORD: ${DATABASE_PASSWORD:-postgres}
      DATABASE_NAME: ${DATABASE_NAME:-rails_auth_development}
      SESSION_TTL_MINUTES: ${SESSION_TTL_MINUTES:-120}
      APP_HOST: ${APP_HOST:-http://localhost:3000}
      GITHUB_CLIENT_ID: ${GITHUB_CLIENT_ID}
      GITHUB_CLIENT_SECRET: ${GITHUB_CLIENT_SECRET}
      X_CLIENT_ID: ${X_CLIENT_ID}
      X_CLIENT_SECRET: ${X_CLIENT_SECRET}
      SECRET_KEY_BASE: ${SECRET_KEY_BASE}
    depends_on:
      - db

volumes:
  postgres_data:
```

### 6. Ajustar o banco para usar variáveis de ambiente

No arquivo `config/database.yml`, ajuste o bloco `default`:

```yaml
default: &default
  adapter: postgresql
  encoding: unicode
  host: <%= ENV["DATABASE_HOST"] %>
  username: <%= ENV["DATABASE_USER"] %>
  password: <%= ENV["DATABASE_PASSWORD"] %>
  max_connections: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
```

### 7. Construir e instalar dependências

```bash
docker compose up -d --build
docker compose run --rm web bundle install
```

### 8. Gerar a estrutura base

```bash
docker compose exec web rails g model User name:string email:string provider:string uid:string github_uid:string twitter_uid:string
docker compose exec web rails g controller Home index
docker compose exec web rails g controller Protected index
docker compose exec web rails g controller Sessions create destroy
docker compose exec web rails g controller Users index
```

### 9. Ajustar a migration de usuários

Edite a migration criada para `users` e deixe assim:

```ruby
class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :provider
      t.string :uid
      t.string :github_uid
      t.string :twitter_uid

      t.timestamps
    end

    add_index :users, "lower(email)", unique: true, name: "index_users_on_lower_email"
    add_index :users, :github_uid, unique: true
    add_index :users, :twitter_uid, unique: true
  end
end
```

### 10. Rodar o banco

```bash
docker compose run --rm web rails db:create db:migrate
```

### 11. Configurar o OmniAuth

Crie `config/initializers/omniauth.rb`:

```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, ENV['GITHUB_CLIENT_ID'], ENV['GITHUB_CLIENT_SECRET'], scope: "user:email"
  provider :twitter2, ENV['X_CLIENT_ID'], ENV['X_CLIENT_SECRET'],
   scope: "tweet.read users.read users.email",
         callback_path: "/auth/twitter2/callback"
end

OmniAuth.config.allowed_request_methods = [:get, :post]
```

### 12. Configurar o session store

Crie `config/initializers/session_store.rb`:

```ruby
ttl_minutes = ENV.fetch("SESSION_TTL_MINUTES", "120").to_i
ttl_minutes = 120 if ttl_minutes <= 0

Rails.application.config.session_store :cookie_store,
  key: "_app_session",
  expire_after: ttl_minutes.minutes,
  secure: Rails.env.production?,
  httponly: true,
  same_site: :lax
```

### 13. Configurar as rotas

Substitua o conteúdo de `config/routes.rb` por:

```ruby
Rails.application.routes.draw do
  get "sessions/create"
  get "home/index"
  get "protected/index"

  get "up" => "rails/health#show", as: :rails_health_check

  root "home#index"
  get 'auth/:provider/callback', to: 'sessions#create'
  get 'auth/failure', to: redirect('/')
  delete '/logout', to: 'sessions#destroy'

  get '/protected', to: 'protected#index'
  post '/protected/csrf-demo', to: 'protected#csrf_demo', as: :protected_csrf_demo
  get '/users', to: 'users#index'
end
```

### 14. Implementar o `ApplicationController`

Substitua `app/controllers/application_controller.rb` por:

```ruby
class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  stale_when_importmap_changes

  helper_method :session_debug_data

  def authorize_request
    unless session[:user_id]
      redirect_to '/', alert: 'Faça login para continuar.'
      return
    end

    @current_user = User.find_by(id: session[:user_id])

    unless @current_user
      session.delete(:user_id)
      redirect_to '/', alert: 'Sessão inválida. Faça login novamente.'
    end
  end

  def session_debug_data
    user = User.find_by(id: session[:user_id]) if session[:user_id]
    expire_after_seconds = request.session_options[:expire_after]&.to_i

    {
      authenticated: session[:user_id].present? && user.present?,
      session_user_id: session[:user_id],
      user_name: user&.name,
      user_email: user&.email,
      session_cookie_key: Rails.application.config.session_options[:key],
      session_ttl_minutes: expire_after_seconds ? (expire_after_seconds / 60) : nil,
      session_keys: session.to_hash.keys.map(&:to_s).sort,
      request_host: request.host_with_port,
      request_scheme: request.protocol.delete_suffix('://')
    }
  end
end
```

### 15. Implementar o model `User`

Substitua `app/models/user.rb` por:

```ruby
class User < ApplicationRecord
  PROVIDER_UID_COLUMNS = {
    "github" => "github_uid",
    "twitter2" => "twitter_uid"
  }.freeze

  validates :email, uniqueness: { case_sensitive: false }, allow_nil: true

  def self.provider_uid_column(provider)
    PROVIDER_UID_COLUMNS[provider.to_s]
  end

  def linked_providers
    PROVIDER_UID_COLUMNS.each_with_object([]) do |(provider, column), providers|
      providers << provider if self[column].present?
    end
  end
end
```

### 16. Implementar os controllers

`app/controllers/home_controller.rb`:

```ruby
class HomeController < ApplicationController
  def index
  end
end
```

`app/controllers/sessions_controller.rb`:

```ruby
class SessionsController < ApplicationController
  def create
    auth = request.env['omniauth.auth']
    provider = auth.provider.to_s
    uid = auth.uid.to_s
    email = auth.info.email&.downcase
    provider_uid_column = User.provider_uid_column(provider)

    unless provider_uid_column
      redirect_to '/', alert: 'Provider não suportado.'
      return
    end

    user = User.find_by(provider_uid_column => uid)
    user ||= User.find_by(email: email) if email.present?

    if user.nil? && email.blank?
      redirect_to '/', alert: 'Não foi possível obter seu e-mail do provider.'
      return
    end

    user ||= User.new(email: email)

    user.name = auth.info.name if auth.info.name.present?
    user.email ||= email
    user.provider = provider
    user.uid = uid
    user[provider_uid_column] = uid
    user.save!

    session[:user_id] = user.id
    redirect_to '/protected'
  rescue ActiveRecord::RecordInvalid => e
    redirect_to '/', alert: "Erro ao autenticar: #{e.message}"
  end

  def destroy
    session.delete(:user_id)
    redirect_to '/'
  end
end
```

`app/controllers/protected_controller.rb`:

```ruby
class ProtectedController < ApplicationController
  before_action :authorize_request

  def index
  end

  def csrf_demo
    demo_text = params[:demo_text].to_s.strip
    csrf_token_valid = valid_authenticity_token?(session, params[:authenticity_token])

    if csrf_token_valid
      notice = demo_text.present? ? "POST recebido com CSRF token válido: #{demo_text}" : "POST recebido com CSRF token válido."
      redirect_to '/protected', notice: notice
    else
      alert = demo_text.present? ? "POST recebido com CSRF token inválido: #{demo_text}" : "POST recebido com CSRF token inválido."
      redirect_to '/protected', alert: alert
    end
  end
end
```

`app/controllers/users_controller.rb`:

```ruby
class UsersController < ApplicationController
  before_action :authorize_request

  def index
    @users = User.order(:name)
  end
end
```

### 17. Implementar o layout e os partials compartilhados

`app/views/layouts/application.html.erb`:

```erb
<!DOCTYPE html>
<html>
  <head>
    <title><%= content_for(:title) || "App" %></title>
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <meta name="apple-mobile-web-app-capable" content="yes">
    <meta name="application-name" content="App">
    <meta name="mobile-web-app-capable" content="yes">
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>
    <%= yield :head %>
    <link rel="icon" href="/icon.png" type="image/png">
    <link rel="icon" href="/icon.svg" type="image/svg+xml">
    <link rel="apple-touch-icon" href="/icon.png">
    <%= stylesheet_link_tag :app, "data-turbo-track": "reload" %>
    <%= javascript_importmap_tags %>
  </head>

  <body>
    <%= render 'shared/navbar' %>
    <main>
      <%= render 'shared/messages' %>
      <%= yield %>
      <% if Rails.env.development? %>
        <%= render 'shared/session_debug' %>
      <% end %>
    </main>
    <%= render 'shared/footer' %>
  </body>
</html>
```

`app/views/shared/_navbar.html.erb`:

```erb
<nav class="navbar">
  <a href="/" class="navbar__brand">Rails Auth</a>

  <div class="navbar__links">
    <% if session[:user_id] %>
      <a href="/users" class="navbar__link">Usuários</a>
      <%= button_to 'Sair', '/logout', method: :delete, class: 'navbar__logout-btn', form: { class: 'navbar__logout-form' } %>
    <% end %>
  </div>
</nav>
```

`app/views/shared/_messages.html.erb`:

```erb
<% flash.each do |key, message| %>
  <div class="flash flash--<%= key %>">
    <%= message %>
  </div>
<% end %>
```

`app/views/shared/_session_debug.html.erb`:

```erb
<% data = session_debug_data %>

<section class="session-debug" aria-label="Painel da sessão">
  <h2 class="session-debug__title">Painel da sessão</h2>

  <dl class="session-debug__grid">
    <dt>Autenticado</dt>
    <dd><%= data[:authenticated] ? 'Sim' : 'Não' %></dd>

    <dt>session[:user_id]</dt>
    <dd><%= data[:session_user_id].presence || 'nil' %></dd>

    <dt>Usuário</dt>
    <dd><%= data[:user_name].presence || 'nil' %></dd>

    <dt>E-mail</dt>
    <dd><%= data[:user_email].presence || 'nil' %></dd>

    <dt>Cookie key</dt>
    <dd><%= data[:session_cookie_key] %></dd>

    <dt>TTL configurado</dt>
    <dd><%= data[:session_ttl_minutes] ? "#{data[:session_ttl_minutes]} minutos" : 'sessão de navegador' %></dd>

    <dt>Chaves da sessão</dt>
    <dd><%= data[:session_keys].join(', ') %></dd>

    <dt>Host da requisição</dt>
    <dd><%= data[:request_host] %></dd>

    <dt>Protocolo</dt>
    <dd><%= data[:request_scheme] %></dd>
  </dl>
</section>
```

`app/views/shared/_footer.html.erb`:

```erb
<footer class="footer">
  &copy; <%= Time.current.year %> Rails Auth &mdash; Desenvolvido com Ruby on Rails
</footer>
```

### 18. Implementar as views

`app/views/home/index.html.erb`:

```erb
<%= content_for :title, "Home" %>

<div class="home-hero">
  <h1>Bem-vindo</h1>
  <% if session[:user_id] %>
    <p>Você já está logado. <a href="/protected">Acessar área protegida</a></p>
  <% else %>
    <p>Faça login para continuar.</p>
    <a href="/auth/github" class="btn btn--github">Login com GitHub</a>
    <a href="/auth/twitter2" class="btn btn--x">Login com X</a>
  <% end %>
</div>
```

`app/views/protected/index.html.erb`:

```erb
<div class="layout-2col">
  <div>
    <h1>Área Protegida</h1>
    <p>Bem-vindo, <%= @current_user.name %>!</p>
    <%= button_to 'Sair', '/logout', method: :delete, class: "btn btn--dark" %>
  </div>

  <div>
    <section class="csrf-demo">
      <h2>Demonstração de CSRF</h2>

      <%= form_with url: protected_csrf_demo_path, method: :post, local: true, class: "csrf-demo__form" do |f| %>
        <div class="csrf-demo__field">
          <%= f.label :demo_text, "Texto de exemplo" %>
          <%= f.text_field :demo_text, required: true %>
        </div>

        <%= f.submit "Enviar POST", class: "btn btn--dark" %>
      <% end %>
    </section>
  </div>
</div>
```

`app/views/users/index.html.erb`:

```erb
<h1 class="page-title">Usuários cadastrados</h1>

<% if @users.empty? %>
  <p class="users-table--empty">Nenhum usuário encontrado.</p>
<% else %>
  <table class="users-table">
    <thead>
      <tr>
        <th>#</th>
        <th>Nome</th>
        <th>E-mail</th>
        <th>Providers conectados</th>
        <th>Criado em</th>
      </tr>
    </thead>
    <tbody>
      <% @users.each do |user| %>
        <tr>
          <td><%= user.id %></td>
          <td><%= user.name %></td>
          <td><%= user.email %></td>
          <td><%= user.linked_providers.join(', ') %></td>
          <td><%= user.created_at.strftime('%d/%m/%Y %H:%M') %></td>
        </tr>
      <% end %>
    </tbody>
  </table>
<% end %>
```

### 19. Adicionar o CSS da aplicação

Substitua `app/assets/stylesheets/application.css` por:

```css
*, *::before, *::after {
  box-sizing: border-box;
}

body {
  font-family: Arial, sans-serif;
  margin: 0;
  color: #222;
}

main {
  padding: 40px 24px 80px;
}

.navbar {
  background: #24292e;
  padding: 0 24px;
  display: flex;
  justify-content: space-between;
  align-items: stretch;
  height: 52px;
}

.navbar__brand {
  color: white;
  text-decoration: none;
  font-weight: bold;
  font-size: 18px;
  display: flex;
  align-items: center;
}

.navbar__links {
  display: flex;
  align-items: center;
  gap: 4px;
}

.navbar__link {
  color: #ccc;
  text-decoration: none;
  font-size: 14px;
  padding: 6px 14px;
  border-radius: 4px;
  border: 1px solid transparent;
  display: inline-flex;
  align-items: center;
  transition: background 0.2s, color 0.2s;
}

.navbar__link:hover {
  background: #3a3f44;
  color: white;
}

.navbar__logout-form {
  display: inline-flex;
  align-items: center;
}

.navbar__logout-btn {
  background: transparent;
  color: #ccc;
  border: 1px solid #555;
  padding: 6px 14px;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
}

.footer {
  background: #f5f5f5;
  border-top: 1px solid #ddd;
  text-align: center;
  padding: 16px;
  font-size: 13px;
  color: #666;
  position: fixed;
  bottom: 0;
  width: 100%;
}

.flash {
  padding: 12px 20px;
  margin-bottom: 24px;
  border-radius: 6px;
  color: white;
}

.flash--notice {
  background: #2ecc71;
}

.flash--alert {
  background: #e74c3c;
}

.session-debug {
  margin-top: 24px;
  border: 1px solid #d8dde5;
  border-radius: 8px;
  background: #f7f9fc;
  padding: 16px;
}

.session-debug__title {
  margin: 0 0 12px;
  font-size: 16px;
}

.session-debug__grid {
  margin: 0;
  display: grid;
  grid-template-columns: 180px 1fr;
  gap: 8px 12px;
}

.session-debug__grid dt {
  margin: 0;
  font-weight: 600;
}

.session-debug__grid dd {
  margin: 0;
}

.home-hero {
  text-align: center;
  margin-top: 60px;
}

.home-hero p {
  color: #555;
  margin-bottom: 24px;
}

.btn {
  display: inline-block;
  padding: 12px 20px;
  border-radius: 6px;
  font-size: 16px;
  text-decoration: none;
  cursor: pointer;
  border: none;
}

.btn--dark,
.btn--github {
  background: #24292e;
  color: white;
}

.btn--x {
  background: #000;
  color: white;
}

.csrf-demo {
  margin: 24px 0;
  max-width: 640px;
  padding: 16px;
  border: 1px solid #ddd;
  border-radius: 8px;
  background: #fafafa;
}

.csrf-demo__form {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.csrf-demo__field {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.csrf-demo__field input {
  border: 1px solid #ccc;
  border-radius: 6px;
  padding: 10px;
  font-size: 15px;
}

.page-title {
  margin-bottom: 24px;
}

.users-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 15px;
}

.users-table thead tr {
  background: #24292e;
  color: white;
}

.users-table th,
.users-table td {
  padding: 10px 16px;
  text-align: left;
}

.users-table tbody tr {
  border-bottom: 1px solid #eee;
}

.users-table tbody tr:nth-child(even) {
  background: #f9f9f9;
}

.users-table--empty {
  color: #888;
}

.layout-2col {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 32px;
  align-items: start;
}

@media (max-width: 768px) {
  .layout-2col {
    grid-template-columns: 1fr;
  }
}
```

### 20. Subir a aplicação final

```bash
docker compose up -d --build
docker compose run --rm web rails db:create db:migrate
```

Abra no navegador:

- http://127.0.0.1:3000

### 21. Configurar os providers OAuth

Cadastre seus apps nos providers:

- GitHub: https://github.com/settings/apps/
- X/Twitter: https://console.x.com/accounts/2046938421357056000

Callbacks locais:

- GitHub: http://127.0.0.1:3000/auth/github/callback
- X: http://127.0.0.1:3000/auth/twitter2/callback

### 22. Comandos úteis durante o desenvolvimento

```bash
docker compose up -d
docker compose down
docker compose down -v
docker compose logs -f web
docker compose exec web rails c
docker compose run --rm web rails db:migrate
docker compose run --rm web rails db:migrate:status
docker compose up -d --force-recreate web
# seed
docker compose run --rm web rails db:seed
```