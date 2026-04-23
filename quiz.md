Aqui está o quiz formatado em **Markdown**, estruturado para que você possa utilizá-lo em materiais de estudo, apostilas ou plataformas de ensino. O feedback (justificativa) está incluído logo após as opções de cada questão.

---

# Quiz: Autenticação e Autorização em Sistemas Web
**Disciplina:** Desenvolvimento Web II  
**Público:** Graduação em Informática / Sistemas de Informação

---

## Questão 1
No contexto de segurança de sessões baseadas em cookies, qual é a finalidade principal da flag `httpOnly: true`?

* a) Impedir que o cookie seja enviado através de conexões HTTP não criptografadas.
* **b) Garantir que o cookie só seja acessível pelo servidor, impedindo o acesso via JavaScript no cliente.**
* c) Forçar o navegador a enviar o cookie apenas em requisições do mesmo domínio (Same-Origin).
* d) Definir que o cookie deve ser excluído assim que o navegador for fechado.

> **Feedback:** A flag `httpOnly` é uma medida de defesa em profundidade que mitiga ataques de XSS (Cross-Site Scripting). Mesmo que um invasor consiga injetar um script na página, ele não conseguirá ler o token de sessão via `document.cookie`.

---

## Questão 2
Ao configurar o fluxo de OAuth com provedores como GitHub ou X (Twitter), o que representa a **Callback URL**?

* a) A URL do provedor onde o usuário insere suas credenciais de login.
* **b) O endpoint da aplicação cliente que processa o código de autorização enviado pelo provedor.**
* c) A URL interna do banco de dados onde os tokens de acesso são armazenados.
* d) A URL de logout que limpa a sessão do provedor de identidade.

> **Feedback:** Após o usuário autorizar a aplicação no provedor de identidade, o provedor redireciona o navegador de volta para a **Callback URL** da sua aplicação, enviando um código temporário que será trocado pelo token de acesso.

---

## Questão 3
Sobre o ataque **CSRF (Cross-Site Request Forgery)**, como a propriedade `same_site: lax` nos cookies auxilia na proteção da aplicação?

* a) Criptografando o conteúdo do cookie para que sites terceiros não possam lê-lo.
* **b) Bloqueando o envio do cookie de sessão em requisições cross-site disparadas por métodos como POST vindos de outros domínios.**
* c) Exigindo que o usuário digite uma senha adicional para cada requisição feita.
* d) Impedindo que o site seja carregado dentro de um iframe.

> **Feedback:** O atributo `SameSite=Lax` permite que o cookie seja enviado em navegações seguras (como clicar em um link GET), mas impede que o navegador anexe o cookie automaticamente em requisições POST iniciadas por sites externos, que é a base do ataque CSRF.

---

## Questão 4
Qual é a principal diferença conceitual entre **Autenticação** e **Autorização**?

* **a) Autenticação verifica quem o usuário é; Autorização verifica o que o usuário pode fazer.**
* b) Autenticação é feita no banco de dados; Autorização é feita no servidor web.
* c) Autenticação ocorre apenas no login; Autorização ocorre apenas no logout.
* d) Não há diferença, ambos referem-se ao mesmo processo de login.

> **Feedback:** Autenticação é o ato de validar a identidade (ex: login social). Autorização é o controle de acesso que decide se aquela identidade confirmada tem permissão para acessar um recurso específico (ex: uma página de administração).

---

## Questão 5
Por que é uma prática comum utilizar ferramentas de tunelamento (como o **Ngrok**) ao testar integrações OAuth localmente?

* a) Para acelerar a velocidade de download das bibliotecas.
* **b) Para permitir que provedores externos acessem o ambiente local via uma URL pública válida e segura (HTTPS).**
* c) Para ocultar o código-fonte da aplicação dos provedores de identidade.
* d) Para evitar a necessidade de configurar um banco de dados.

> **Feedback:** Provedores de OAuth geralmente exigem que as URLs de callback sejam públicas e utilizem HTTPS. O Ngrok cria um túnel que expõe seu `localhost:3000` em um endereço público (ex: `https://xyz.ngrok.io`), permitindo o teste real do fluxo.

---

## Questão 6
Em uma arquitetura de múltiplos provedores (ex: GitHub e X), qual estratégia evita a criação de contas duplicadas para o mesmo usuário?

* a) Bloquear o login se o usuário tentar usar um provedor diferente do primeiro acesso.
* **b) Utilizar o endereço de e-mail como identificador único e vincular diferentes IDs de provedores ao mesmo registro no banco.**
* c) Exigir que o usuário digite o mesmo nome de usuário em todos os sites.
* d) Armazenar cada tentativa de login em tabelas separadas sem relação entre elas.

> **Feedback:** Ao identificar que um e-mail retornado pelo GitHub já existe na base de dados (mesmo que o usuário tenha se cadastrado via X anteriormente), a aplicação pode unificar os perfis, permitindo que o usuário acesse seus dados independentemente do método de login.

---

## Questão 7
Qual é a função do **Client Secret** (ou Secret Key) em uma configuração OAuth?

* a) Ser exibida no formulário de login para o usuário final conferir.
* **b) Autenticar a própria aplicação junto ao provedor de identidade durante a troca de tokens (server-to-server).**
* c) Servir como a senha de root do banco de dados.
* d) Criptografar as imagens de perfil dos usuários.

> **Feedback:** Enquanto o `Client ID` é público, o `Client Secret` deve ser guardado a sete chaves no servidor. Ele prova ao provedor que a requisição de troca de código por token é legítima e pertence à sua aplicação cadastrada.

---

## Questão 8
O que ocorre se um cookie de sessão for configurado com a flag `secure: true`?

* a) O cookie só pode ser acessado após um CAPTCHA.
* **b) O navegador só enviará o cookie em requisições feitas através de uma conexão HTTPS.**
* c) O cookie será apagado automaticamente após 10 minutos.
* d) O cookie será armazenado de forma criptografada no disco rígido.

> **Feedback:** Esta flag impede que o cookie de sessão seja enviado "em texto claro" por conexões HTTP, protegendo o token de ser interceptado por alguém que esteja monitorando o tráfego da rede (ataque de Man-in-the-Middle).

---

## Questão 9
No fluxo OAuth 2.0, qual é o papel do **Scope**?

* a) Definir o tempo de validade do token.
* **b) Especificar quais permissões e dados a aplicação está solicitando (ex: apenas e-mail ou acesso a repositórios).**
* c) Listar os endereços IP permitidos.
* d) Identificar a versão da linguagem de programação utilizada.

> **Feedback:** O Scope define o limite da autorização. Se a aplicação pede apenas o escopo `user:email`, ela não terá permissão para postar no perfil do usuário ou ler seus arquivos privados, garantindo o princípio do privilégio mínimo.

---

## Questão 10
Qual o benefício de utilizar um arquivo de variáveis de ambiente (`.env`) para gerenciar chaves de API e segredos de sessão?

* a) Aumentar a velocidade de processamento do banco de dados.
* **b) Impedir que segredos sensíveis sejam commitados acidentalmente no controle de versão (Git).**
* c) Permitir que o usuário final altere as configurações da aplicação.
* d) Substituir o uso de CSS no front-end.

> **Feedback:** Variáveis de ambiente mantêm as configurações específicas de cada ambiente (desenvolvimento, produção) fora do código-fonte. Isso evita que chaves secretas sejam expostas em repositórios públicos, o que comprometeria a segurança de todo o sistema.

---

### Gabarito Resumido
1. B | 2. B | 3. B | 4. A | 5. B | 6. B | 7. B | 8. B | 9. B | 10. B