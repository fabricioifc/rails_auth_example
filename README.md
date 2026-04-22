# Rails Auth (GitHub + X)

Aplicação Ruby on Rails para autenticação social com múltiplos providers (GitHub e X/Twitter), usando sessão do Rails (cookie store) e demonstrações didáticas de sessão e CSRF.

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

## Requisitos

- Docker
- Docker Compose

## Configuração de ambiente

Crie ou ajuste o arquivo .env na raiz do projeto com as variáveis abaixo:

	DATABASE_HOST=db
	DATABASE_USER=postgres
	DATABASE_PASSWORD=postgres
	DATABASE_NAME=rails_auth_development

	GITHUB_CLIENT_ID=SEU_GITHUB_CLIENT_ID
	GITHUB_CLIENT_SECRET=SEU_GITHUB_CLIENT_SECRET

	X_CLIENT_ID=SEU_X_CLIENT_ID
	X_CLIENT_SECRET=SEU_X_CLIENT_SECRET

	SECRET_KEY_BASE=UMA_CHAVE_LONGA_E_ALEATORIA

	# Tempo de vida da sessão em minutos
	SESSION_TTL_MINUTES=120

	# Em desenvolvimento local
	APP_HOST=http://127.0.0.1:3000

## Subindo a aplicação com Docker

### Primeira execução

1. Construir imagens e iniciar containers:

	 docker compose up -d --build

2. Criar e migrar banco:

	 docker compose run --rm web rails db:create db:migrate

3. Acessar no navegador:

	 http://127.0.0.1:3000

### Execuções seguintes

Iniciar:

	docker compose up -d

Parar:

	docker compose down

Logs da aplicação:

	docker compose logs -f web

## Rotas principais

- / : tela inicial
- /protected : área protegida por sessão
- /users : lista de usuários
- /auth/github : inicia login com GitHub
- /auth/twitter2 : inicia login com X
- /logout : encerra sessão

## OAuth: callbacks esperados

No painel de cada provider, configure os callbacks de acordo com o host usado.

Ambiente local (exemplo):

- GitHub callback: http://127.0.0.1:3000/auth/github/callback
- X callback: http://127.0.0.1:3000/auth/twitter2/callback

Se usar túnel público (ngrok), ajuste APP_HOST e os callbacks para o mesmo domínio público.

## Sessão

A sessão está configurada em [config/initializers/session_store.rb](config/initializers/session_store.rb).

Configuração atual:

- store: cookie_store
- key: _app_session
- expire_after: SESSION_TTL_MINUTES
- httponly: true
- same_site: lax
- secure: true apenas em produção

Painel de sessão:

- Em desenvolvimento, o layout renderiza um painel com:
	- autenticado ou não
	- session[:user_id]
	- usuário atual
	- cookie key
	- TTL configurado
	- chaves da sessão

## Unificação de usuários por provider

Regra implementada:

- Login busca primeiro por UID do provider
- Se não encontrar, tenta por e-mail
- Mantém um único registro por e-mail
- Armazena vínculos por provider em github_uid e twitter_uid

Índices no banco:

- unique lower(email)
- unique github_uid
- unique twitter_uid

## Demonstração de CSRF

Na página protegida existe um formulário de demonstração.

- O formulário envia POST para /protected/csrf-demo
- O Rails valida authenticity_token
- Se token inválido, a requisição é bloqueada

Observação: para a demonstração didática, o formulário está com envio HTML clássico (sem Turbo), para ficar evidente a validação do token do próprio form.

## Comandos úteis

Abrir console Rails no container web:

	docker compose exec web rails c

Rodar migrations:

	docker compose run --rm web rails db:migrate

Ver status das migrations:

	docker compose run --rm web rails db:migrate:status

Recriar somente o container web (quando mudar .env):

	docker compose up -d --force-recreate web

## Estrutura relevante

- [config/routes.rb](config/routes.rb)
- [app/controllers/sessions_controller.rb](app/controllers/sessions_controller.rb)
- [app/controllers/application_controller.rb](app/controllers/application_controller.rb)
- [app/controllers/protected_controller.rb](app/controllers/protected_controller.rb)
- [app/models/user.rb](app/models/user.rb)
- [config/initializers/omniauth.rb](config/initializers/omniauth.rb)
- [config/initializers/session_store.rb](config/initializers/session_store.rb)

## Troubleshooting rápido

- Erro de callback OAuth: confira se APP_HOST e callback do provider estão exatamente iguais.
- Mudou .env e não refletiu no app: recrie o serviço web com --force-recreate.
- Falha de CSRF em teste: confirme que está enviando token válido da mesma sessão.
