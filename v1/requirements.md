# PRD — CoopCRM

> **Documento de Requisitos de Produto** produzido por Paula Produto  
> **Data:** 2026-04-05 | **Ciclo:** MVP v1.0 | **Modo:** Greenfield

---

## Objetivo

CoopCRM resolve o problema central de cooperativas brasileiras: **distribuir oportunidades de trabalho de forma justa e rastreável**, eliminando o caos do WhatsApp, favoritismos e a impossibilidade de prestar contas nas assembleias. O produto entrega um ciclo completo de 5 etapas (Criação → Candidatura → Atribuição → Execução → Conclusão) com notificações push em tempo real, multi-tenancy por cooperativa e módulos complementares de cotas, comunicados e relatórios.

**Valor central:** O admin posta a oportunidade, cooperados se candidatam, o sistema distribui com critério claro — do surgimento da demanda até o registro no balancete.

---

## Stakeholders e Personas

| Persona | Papel | Objetivo Principal |
|---------|-------|--------------------|
| **Admin / Gestor** | Dona Maria das Graças, Seu Raimundo | Distribuir oportunidades de forma justa, provar transparência na AGO, reduzir 10h → 2h de coordenação/semana |
| **Cooperado** | Seu Jonas, Dra. Ana, Marcos (motorista) | Receber notificação instantânea, se candidatar em 2 toques, ter histórico de produção auditável |
| **Felipe Moreira (operador)** | Dono do produto / dev solo | Onboarding rápido por cooperativa, zero suporte manual após setup, MRR recorrente |

---

## User Stories — Must Have

### US-01: Login cooperado
**Como cooperado**, quero fazer login com CPF ou e-mail e senha para acessar minha conta.
- **CA-01-1:** Login executado em ≤ 2s; cooperado redirecionado ao feed de oportunidades.
- **CA-01-2:** Senha nunca armazenada em plaintext; autenticação delegada ao BaaS (auth seguro).
- **CA-01-3:** Mensagem de erro clara ao digitar credenciais inválidas ("CPF/e-mail ou senha incorretos").
- **CA-01-4:** Botão "Esqueci minha senha" dispara reset via e-mail em ≤ 5 segundos.
- **Regra de negócio:** Cooperado que não possui conta não pode se cadastrar sozinho — admin cria o cadastro.

---

### US-02: Feed de oportunidades
**Como cooperado**, quero ver todas as oportunidades abertas da minha cooperativa ordenadas por data para não perder nenhuma.
- **CA-02-1:** Feed exibe apenas oportunidades com status `ABERTA` da cooperativa do cooperado logado.
- **CA-02-2:** Oportunidades ordenadas por `created_at DESC`.
- **CA-02-3:** Badge "NOVO" em oportunidades criadas há menos de 24h.
- **CA-02-4:** Card exibe: título, tipo, local, data/hora de execução, nº de vagas, valor estimado, prazo de candidatura.
- **CA-02-5:** Pull-to-refresh atualiza a lista em ≤ 3s.
- **CA-02-6:** Cooperado inadimplente visualiza o feed, mas botão de candidatura está desabilitado com mensagem "Regularize sua situação".
- **Regra de negócio:** Isolamento multi-tenant — cooperado jamais vê oportunidades de outra cooperativa.

---

### US-03: Candidatura a oportunidade
**Como cooperado**, quero me candidatar a uma oportunidade em ≤ 2 toques para não perder o prazo.
- **CA-03-1:** Botão "Tenho Interesse" disponível no card do feed e na tela de detalhe.
- **CA-03-2:** Ao tocar: candidatura registrada imediatamente e confirmação exibida ("Candidatura registrada! Aguarde o resultado.").
- **CA-03-3:** Se cooperado já se candidatou: botão exibe "Já candidatado" e fica desabilitado.
- **CA-03-4:** Após prazo encerrado: botão desabilitado + mensagem "Prazo encerrado".
- **CA-03-5:** Se inadimplente: botão desabilitado + mensagem "Regularize sua situação para se candidatar".
- **CA-03-6:** Campo opcional de mensagem para o admin (até 500 caracteres).
- **Regra de negócio:** `UNIQUE(oportunidade_id, cooperado_id)` — tentativas duplicadas retornam erro 409 sem crashar o app.

---

### US-04: Criação de oportunidade (admin)
**Como admin**, quero criar uma nova oportunidade com todos os campos relevantes para que os cooperados possam se candidatar.
- **CA-04-1:** Formulário com campos obrigatórios: título, tipo, nº de vagas (≥ 1), prazo de candidatura.
- **CA-04-2:** Prazo de candidatura não pode ser no passado — validação em tempo real.
- **CA-04-3:** Ao salvar como "Publicar agora": status = `ABERTA`; push notification disparada para todos os cooperados ativos em ≤ 60s.
- **CA-04-4:** Ao salvar como "Rascunho": status = `RASCUNHO`; sem notificação.
- **CA-04-5:** Admin recebe confirmação visual com link para a oportunidade criada.
- **Regra de negócio:** Tipo de oportunidade pode ser customizado por cooperativa (ex: "Paciente" em vez de "Oportunidade").

---

### US-05: Atribuição de oportunidade (admin)
**Como admin**, quero selecionar o(s) cooperado(s) para executar uma oportunidade, usando critério claro, para garantir transparência.
- **CA-05-1:** Admin vê lista de candidatos com: nome, horário da candidatura, nº de serviços no período, avaliação média.
- **CA-05-2:** Modos disponíveis: FIFO (automático pelo sistema), Rodízio (prioriza quem tem menos produção), Manual (admin escolhe livremente).
- **CA-05-3:** Ao atribuir: selecionado recebe push "Parabéns! Você foi selecionado para: [título]".
- **CA-05-4:** Não selecionados recebem push "A oportunidade foi atribuída. Obrigado pela participação!".
- **CA-05-5:** Status da oportunidade muda de `EM_CANDIDATURA` → `ATRIBUÍDA` após atribuição.
- **Regra de negócio:** Para N vagas, N cooperados devem ser selecionados antes que o status avance.

---

### US-06: Ciclo completo de execução e conclusão
**Como cooperado selecionado**, quero confirmar ou declinar a oportunidade para que o sistema saiba se estou disponível.
- **CA-06-1:** Tela "Confirmar Aceitação" exibida ao cooperado selecionado, com botões "Confirmar" (verde) e "Declinar" (cinza).
- **CA-06-2:** Se declinar: status retorna para atribuição do próximo candidato na fila.
- **CA-06-3:** Se confirmar: status = `EM_EXECUÇÃO`.
- **CA-06-4:** Admin pode marcar como concluída → status = `CONCLUÍDA`.
- **CA-06-5:** Ao concluir: valor e data registrados no histórico do cooperado automaticamente.
- **CA-06-6:** Admin pode avaliar cooperado (1–5 estrelas) após conclusão opcional.

---

### US-07: Push notification (nova oportunidade)
**Como cooperado**, quero receber push notification ao surgir nova oportunidade para não perder o prazo mesmo com o app fechado.
- **CA-07-1:** Push chega em ≤ 60s após admin publicar a oportunidade.
- **CA-07-2:** Conteúdo: título da oportunidade, valor estimado, prazo de candidatura.
- **CA-07-3:** Ao tocar na notificação: app abre direto na tela de detalhe da oportunidade.
- **CA-07-4:** Funciona com app em foreground, background e fechado.
- **Regra de negócio:** Cooperados com status `ATIVO` recebem o push; inadimplentes também recebem (podem visualizar), só o botão de candidatura fica bloqueado.

---

### US-08: Notificações in-app (Minhas Candidaturas)
**Como cooperado**, quero acompanhar o status de todas as minhas candidaturas em uma tela para saber se fui selecionado.
- **CA-08-1:** Lista todas as candidaturas do cooperado em ordem cronológica decrescente.
- **CA-08-2:** Status visual por cor: AGUARDANDO (azul), SELECIONADO (verde, badge "ação necessária"), EM ANDAMENTO (laranja), CONCLUÍDO (cinza + check verde), NÃO SELECIONADO (vermelho suave).
- **CA-08-3:** Filtro por status e período (mês atual, últimos 3 meses, todos).
- **CA-08-4:** Ao tocar em candidatura SELECIONADO: abre tela de confirmação/declínio.

---

## User Stories — Should Have

### US-09: Cadastro de cooperados (admin)
**Como admin**, quero cadastrar/editar cooperados e controlar o status de cada um para manter o cadastro atualizado.
- **CA-09-1:** CRUD completo: criar, editar, ativar/desativar/suspender cooperado.
- **CA-09-2:** Campos obrigatórios: nome, CPF (único por cooperativa), status.
- **CA-09-3:** Busca em tempo real por nome ou CPF.
- **CA-09-4:** Filtro por status (ativo, inativo, suspenso, inadimplente).
- **CA-09-5:** Status `INADIMPLENTE` bloqueia automaticamente candidaturas (sem ação manual do admin).

---

### US-10: Controle de cotas (admin)
**Como admin**, quero registrar pagamentos de cotas e saber quem está inadimplente para bloquear candidaturas automaticamente.
- **CA-10-1:** Lançamento de pagamento: cooperado + competência (mês) + valor + data.
- **CA-10-2:** Dashboard: totais de adimplentes / inadimplentes / a vencer.
- **CA-10-3:** Cooperado inadimplente (cota vencida há > 30 dias) bloqueado automaticamente de novas candidaturas.
- **CA-10-4:** Histórico de pagamentos por cooperado (mês a mês com status).

---

### US-11: Comunicados e avisos (admin → cooperados)
**Como admin**, quero enviar comunicados para os cooperados com push notification para garantir que a mensagem chegue.
- **CA-11-1:** Admin cria comunicado: título + corpo de texto + anexo opcional (imagem ou PDF).
- **CA-11-2:** Envio para todos os cooperados ativos ou para subgrupo.
- **CA-11-3:** Push notification disparada para todos os destinatários em ≤ 60s.
- **CA-11-4:** Feed de comunicados no app do cooperado com indicador de não-lido (ponto azul).

---

### US-12: Meu Perfil e Produção (cooperado)
**Como cooperado**, quero ver minha produção e situação de cotas para acompanhar meus ganhos.
- **CA-12-1:** Produção do mês atual: valor total + número de serviços + avaliação média.
- **CA-12-2:** Status de adimplência em badge visível (verde = em dia, vermelho = inadimplente).
- **CA-12-3:** Histórico de cotas pagas mês a mês.

---

### US-13: Relatórios (admin)
**Como admin**, quero visualizar relatórios de produção e distribuição para prestar contas na AGO.
- **CA-13-1:** Seletor de período (mês, trimestre, ano).
- **CA-13-2:** Tabela: cooperado | nº serviços | valor total | avaliação média.
- **CA-13-3:** Gráfico de barras mostrando distribuição de oportunidades entre cooperados (identifica desigualdade).
- **CA-13-4:** Relatório de inadimplência: cooperados com cotas em atraso + dias de atraso.
- **CA-13-5:** Exportação CSV para sistemas externos (Excel, planilhas).
- **Sem PDF** (fora do escopo v1 — ver seção abaixo).

---

### US-14: Configuração da cooperativa (admin/onboarding)
**Como admin**, quero configurar o nome, tipo e preferências da minha cooperativa para personalizar o produto.
- **CA-14-1:** Nome, tipo (trabalho/saúde/transporte/educação/agro) e logo da cooperativa configuráveis.
- **CA-14-2:** Label do tipo de oportunidade configurável (ex: "Paciente", "Rota", "Turma").
- **CA-14-3:** Critério de seleção padrão (FIFO / Rodízio / Manual).
- **CA-14-4:** Período de apuração configurável (mensal / trimestral / anual).

---

## User Stories — Could Have

### US-15: Check-in / Check-out geolocalizado
**Como admin**, quero que o cooperado faça check-in e check-out com geolocalização para confirmar presença no local.
- **CA-15-1:** Cooperado faz check-in ao chegar no local; geolocalização registrada.
- **CA-15-2:** Cooperado faz check-out ao finalizar; horário registrado.
- Útil para coops de limpeza, manutenção, transporte. Ativável/desativável por cooperativa.

### US-16: Convite por e-mail para cooperados
**Como admin**, quero enviar convite por e-mail ao novo cooperado para que ele configure a própria senha.
- **CA-16-1:** Admin clica "Enviar convite" → e-mail enviado com link de primeiro acesso.

---

## User Stories — Won't Have (v1)

- Portal do cliente externo (contratante solicita serviço diretamente)
- Pagamento integrado (Pix, cartão)
- Rodízio automático por algoritmo (apenas manual e FIFO na v1)
- App watchOS / Android Wear
- Integração com sistemas contábeis via API
- Relatório em PDF

---

## Requisitos Não-Funcionais

| Requisito | Critério Mensurável |
|-----------|---------------------|
| **Performance — App** | Tela de feed carrega em ≤ 2s em rede 4G; lista renderiza ≤ 50 itens sem paginação |
| **Performance — Push** | Push notification entregue em ≤ 60s após evento no servidor |
| **Disponibilidade** | Uptime ≥ 99.5% (infraestrutura BaaS gerenciada) |
| **Segurança — Multi-tenancy** | Nenhuma query retorna dados de outra cooperativa; testável ao logar como `cooperado_A` e tentar acessar `cooperative_B` → resposta deve ser array vazio |
| **Segurança — Auth** | Senhas nunca em plaintext; autenticação via BaaS (OAuth/JWT) |
| **Segurança — RLS** | Row Level Security habilitada em 100% das tabelas com dado sensível |
| **Segurança — LGPD** | Política de privacidade publicada; dados de CPF e localização coletados com consentimento explícito |
| **Escalabilidade** | 1 instância de BaaS suporta 50+ cooperativas × 150 cooperados sem custo adicional por cooperativa |
| **Localização** | Todas as datas em pt-BR; moeda em R$; validação de CPF (11 dígitos); máscara de telefone (XX) XXXXX-XXXX |
| **Acessibilidade** | Contraste WCAG AA nos componentes; textos de botão legíveis (sem branco em fundo branco) |
| **Offline** | App exibe último feed carregado ao perder conexão; candidatura bloqueada offline com mensagem clara |
| **Paginação** | Feeds com > 20 itens paginados automaticamente (lazy load) |

---

## Requisitos de Segurança (OWASP Top 10)

| Risco OWASP | Mitigação no CoopCRM |
|-------------|----------------------|
| A01 — Broken Access Control | RLS em todas as tabelas; políticas de admin vs cooperado separadas |
| A02 — Cryptographic Failures | Senhas via BaaS; dados em trânsito sempre HTTPS; tokens JWT com expiração |
| A03 — Injection | Queries parametrizadas via SDK do BaaS (sem SQL dinâmico) |
| A04 — Insecure Design | Multi-tenant por design; `cooperative_id` obrigatório em toda query |
| A07 — ID & Auth Failures | Autenticação delegada ao BaaS; reset de senha via e-mail verificado |
| A09 — Security Logging | `notifications_log` registra todos os pushes; auditoria de status em `atribuicoes` |

---

## Fora do Escopo (v1)

1. **Relatório PDF** — exportação CSV é suficiente para v1; PDF adiciona complexidade de geração
2. **Portal do cliente externo** — contratante não acessa o sistema v1; demanda chega ao admin por qualquer canal
3. **Algoritmo de rodízio automático** — admin seleciona manualmente ou por FIFO; algoritmo de equilíbrio de renda vai para v2
4. **Pagamento integrado** — cotas lançadas manualmente; Pix/cartão são Módulo v2
5. **Integração com OCB / sistemas contábeis** — exportação CSV cobre o caso de uso v1
6. **App native desktop** — painel admin como Flutter Web cobre o caso de uso
7. **Multi-cooperativa por usuário** — um cooperado pertence a uma cooperativa por conta no v1
8. **Marketplace de cooperativas** — descoberta pública de cooperativas fora do escopo
9. **Chat interno** — comunicados são unidirecionais (admin → cooperado) no v1
10. **Agendamento de oportunidades recorrentes** — cada oportunidade é criada manualmente no v1

---

## Suposições e Riscos

| Tipo | Descrição | Mitigação |
|------|-----------|-----------|
| **Suposição** | Gestores de cooperativa têm smartphone e acesso a computador com internet | Validar nas entrevistas da Fase 0 |
| **Suposição** | Cooperados têm smartphone Android ou iOS com WhatsApp (cobertura > 90% no NE do Brasil) | Fallback: notificação via e-mail se sem app |
| **Suposição** | Free tier do BaaS suporta os primeiros 3–5 clientes sem custo | Monitorar uso; migrar para plano Pro ao atingir 80% dos limites |
| **Risco** | Concorrência simultânea em candidaturas (dois cooperados tocando ao mesmo tempo) | Constraint `UNIQUE(oportunidade_id, cooperado_id)` no banco + erro 409 tratado no app |
| **Risco** | Push notification não chega (token FCM expirado ou iOS DND) | Fallback: feed do app sempre mostra oportunidades abertas; token expirado removido ao receber `InvalidRegistration` |
| **Risco** | Apple rejeita app na App Store por login obrigatório sem Guest | Criar conta de demo para revisores; seguir Apple HIG; publicar política de privacidade |
| **Risco** | Admin sobrecarregado durante onboarding (migração de planilha) | Setup inclui migração assistida de até 80 cooperados; template CSV fornecido |
| **Risco** | LGPD — CPF e geolocalização são dados sensíveis | Política de privacidade publicada antes do lançamento; consentimento no onboarding |
| **Risco** | Stack a ser definida pode não ter ecossistema maduro para todos os módulos | Arquiteto avalia ecossistema antes de comprometer a stack |
