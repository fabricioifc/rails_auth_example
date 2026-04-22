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

