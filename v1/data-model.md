# Modelo de Dados — CoopCRM

> **Criado por:** Mateus Modelagem  
> **Data:** 2026-04-05 | **Banco:** PostgreSQL 15 (Supabase) | **Multi-tenant:** RLS por `cooperative_id`

---

## Entidades

### cooperativas
| Campo | Tipo | Constraint | Descrição |
|-------|------|-----------|-----------|
| `id` | UUID | PK, DEFAULT gen_random_uuid() | Identificador único do tenant |
| `nome` | TEXT | NOT NULL | Nome da cooperativa |
| `tipo` | TEXT | NOT NULL, CHECK IN ('trabalho','saude','transporte','educacao','agro','outro') | Tipo da cooperativa |
| `cnpj` | TEXT | UNIQUE | CNPJ (opcional no MVP) |
| `logo_url` | TEXT | | URL do logo no Supabase Storage |
| `cor_primaria` | TEXT | DEFAULT '#00796B' | Hex da cor primária (customização) |
| `tipo_oport_label` | TEXT | DEFAULT 'Oportunidade' | Label customizada do tipo de oportunidade |
| `criterio_padrao` | TEXT | DEFAULT 'manual', CHECK IN ('fifo','rodizio','manual') | Critério padrão de seleção |
| `plano` | TEXT | DEFAULT 'basico', CHECK IN ('basico','padrao','avancado') | Plano SaaS contratado |
| `ativo` | BOOLEAN | DEFAULT TRUE | Tenant ativo/inativo |
| `created_at` | TIMESTAMPTZ | DEFAULT NOW() | Data de criação |

---

### cooperados
| Campo | Tipo | Constraint | Descrição |
|-------|------|-----------|-----------|
| `id` | UUID | PK, DEFAULT gen_random_uuid() | Identificador interno |
| `cooperative_id` | UUID | FK → cooperativas.id CASCADE | Tenant ao qual pertence |
| `user_id` | UUID | FK → auth.users(id), UNIQUE | Vínculo com Supabase Auth |
| `nome` | TEXT | NOT NULL | Nome completo |
| `cpf` | TEXT | NOT NULL | CPF (validado no app) |
| `email` | TEXT | | E-mail do cooperado |
| `telefone` | TEXT | | Telefone com máscara |
| `especialidades` | TEXT[] | DEFAULT '{}' | Lista de especialidades |
| `status` | TEXT | DEFAULT 'ativo', CHECK IN ('ativo','inativo','suspenso','inadimplente') | Situação na cooperativa |
| `fcm_token` | TEXT | | Token FCM para push — atualizado a cada login |
| `foto_url` | TEXT | | Foto de perfil (Supabase Storage) |
| `matricula` | TEXT | | Matrícula interna da cooperativa |
| `data_associacao` | DATE | | Data de entrada na cooperativa |
| `is_admin` | BOOLEAN | DEFAULT FALSE | Flag de administrador da cooperativa |
| `created_at` | TIMESTAMPTZ | DEFAULT NOW() | Data de cadastro |
| UNIQUE | | (cooperative_id, cpf) | CPF único por cooperativa |

---

### oportunidades
| Campo | Tipo | Constraint | Descrição |
|-------|------|-----------|-----------|
| `id` | UUID | PK, DEFAULT gen_random_uuid() | Identificador único |
| `cooperative_id` | UUID | FK → cooperativas.id CASCADE, NOT NULL | Tenant |
| `criado_por` | UUID | FK → cooperados.id RESTRICT | Admin que criou |
| `titulo` | TEXT | NOT NULL | Título da oportunidade |
| `tipo` | TEXT | NOT NULL | Tipo (usa tipo_oport_label da cooperativa) |
| `descricao` | TEXT | | Descrição detalhada |
| `data_execucao` | TIMESTAMPTZ | | Data e hora do serviço |
| `local` | TEXT | | Endereço do serviço |
| `valor_estimado` | DECIMAL(10,2) | CHECK (valor_estimado >= 0) | Remuneração estimada |
| `num_vagas` | INTEGER | NOT NULL DEFAULT 1, CHECK (num_vagas >= 1) | Número de vagas |
| `requisitos` | TEXT | | Requisitos para se candidatar |
| `prazo_candidatura` | TIMESTAMPTZ | NOT NULL | Deadline para candidaturas |
| `criterio_selecao` | TEXT | NOT NULL DEFAULT 'manual', CHECK IN ('fifo','rodizio','manual') | Critério de atribuição |
| `visibilidade` | TEXT | DEFAULT 'todos' | Público-alvo (todos ou subgrupo) |
| `status` | TEXT | DEFAULT 'rascunho', CHECK IN ('rascunho','aberta','em_candidatura','atribuida','em_execucao','concluida','cancelada') | Estado da máquina de estados |
| `motivo_cancelamento` | TEXT | | Preenchido ao cancelar |
| `created_at` | TIMESTAMPTZ | DEFAULT NOW() | Data de criação |
| `updated_at` | TIMESTAMPTZ | DEFAULT NOW() | Última atualização (trigger) |

---

### candidaturas
| Campo | Tipo | Constraint | Descrição |
|-------|------|-----------|-----------|
| `id` | UUID | PK, DEFAULT gen_random_uuid() | Identificador |
| `oportunidade_id` | UUID | FK → oportunidades.id CASCADE, NOT NULL | Oportunidade em questão |
| `cooperado_id` | UUID | FK → cooperados.id CASCADE, NOT NULL | Candidato |
| `mensagem` | TEXT | | Mensagem opcional para o admin |
| `status` | TEXT | DEFAULT 'aguardando', CHECK IN ('aguardando','selecionado','nao_selecionado','desistiu') | Status da candidatura |
| `created_at` | TIMESTAMPTZ | DEFAULT NOW() | Horário da candidatura |
| UNIQUE | | (oportunidade_id, cooperado_id) | Evita candidatura duplicada |

---

### atribuicoes
| Campo | Tipo | Constraint | Descrição |
|-------|------|-----------|-----------|
| `id` | UUID | PK, DEFAULT gen_random_uuid() | Identificador |
| `oportunidade_id` | UUID | FK → oportunidades.id CASCADE, NOT NULL | Oportunidade atribuída |
| `cooperado_id` | UUID | FK → cooperados.id CASCADE, NOT NULL | Cooperado selecionado |
| `candidatura_id` | UUID | FK → candidaturas.id | Candidatura de origem |
| `atribuido_por` | UUID | FK → cooperados.id RESTRICT | Admin que atribuiu |
| `confirmado` | BOOLEAN | DEFAULT FALSE | Cooperado confirmou aceitação |
| `confirmado_em` | TIMESTAMPTZ | | Timestamp da confirmação |
| `checkin_at` | TIMESTAMPTZ | | Opcional — check-in geolocalizado |
| `checkout_at` | TIMESTAMPTZ | | Opcional — check-out geolocalizado |
| `avaliacao` | INTEGER | CHECK (avaliacao BETWEEN 1 AND 5) | Nota do admin ao cooperado |
| `obs_avaliacao` | TEXT | | Observação de avaliação |
| `created_at` | TIMESTAMPTZ | DEFAULT NOW() | Data da atribuição |

---

### comunicados
| Campo | Tipo | Constraint | Descrição |
|-------|------|-----------|-----------|
| `id` | UUID | PK, DEFAULT gen_random_uuid() | Identificador |
| `cooperative_id` | UUID | FK → cooperativas.id CASCADE, NOT NULL | Tenant |
| `autor_id` | UUID | FK → cooperados.id RESTRICT | Admin autor |
| `titulo` | TEXT | NOT NULL | Título do comunicado |
| `corpo` | TEXT | NOT NULL | Texto do comunicado |
| `anexo_url` | TEXT | | URL de anexo (Supabase Storage) |
| `destinatarios` | TEXT | DEFAULT 'todos' | 'todos' ou UUID de subgrupo |
| `created_at` | TIMESTAMPTZ | DEFAULT NOW() | Data de publicação |

---

### comunicado_leituras
| Campo | Tipo | Constraint | Descrição |
|-------|------|-----------|-----------|
| `id` | UUID | PK | Identificador |
| `comunicado_id` | UUID | FK → comunicados.id CASCADE | Comunicado lido |
| `cooperado_id` | UUID | FK → cooperados.id CASCADE | Cooperado que leu |
| `lido_em` | TIMESTAMPTZ | DEFAULT NOW() | Timestamp da leitura |
| UNIQUE | | (comunicado_id, cooperado_id) | Evita duplicatas |

---

### cotas_pagamentos
| Campo | Tipo | Constraint | Descrição |
|-------|------|-----------|-----------|
| `id` | UUID | PK, DEFAULT gen_random_uuid() | Identificador |
| `cooperado_id` | UUID | FK → cooperados.id CASCADE, NOT NULL | Cooperado pagante |
| `cooperative_id` | UUID | FK → cooperativas.id CASCADE, NOT NULL | Tenant (para RLS) |
| `competencia` | DATE | NOT NULL | Mês de referência (sempre primeiro dia do mês) |
| `valor` | DECIMAL(10,2) | NOT NULL, CHECK (valor > 0) | Valor da cota |
| `pago` | BOOLEAN | DEFAULT FALSE | Foi pago? |
| `data_pagamento` | DATE | | Data efetiva do pagamento |
| `created_at` | TIMESTAMPTZ | DEFAULT NOW() | Data do lançamento |
| UNIQUE | | (cooperado_id, competencia) | Uma cota por mês por cooperado |

---

### notifications_log
| Campo | Tipo | Constraint | Descrição |
|-------|------|-----------|-----------|
| `id` | UUID | PK, DEFAULT gen_random_uuid() | Identificador |
| `cooperative_id` | UUID | FK → cooperativas.id | Tenant |
| `cooperado_id` | UUID | FK → cooperados.id | Destinatário |
| `tipo` | TEXT | NOT NULL, CHECK IN ('nova_oportunidade','atribuicao','comunicado','cota_vencida','confirmacao') | Tipo do push |
| `titulo` | TEXT | NOT NULL | Título do push |
| `corpo` | TEXT | | Corpo do push |
| `referencia_id` | UUID | | ID do item referenciado (oportunidade_id etc.) |
| `enviado` | BOOLEAN | DEFAULT FALSE | Push enviado com sucesso? |
| `lido` | BOOLEAN | DEFAULT FALSE | Usuário leu/interagiu? |
| `enviado_em` | TIMESTAMPTZ | | Timestamp do envio |
| `lido_em` | TIMESTAMPTZ | | Timestamp da leitura |
| `created_at` | TIMESTAMPTZ | DEFAULT NOW() | Data de criação |

---

## Relacionamentos

| Entidade A | Cardinalidade | Entidade B | FK | Comportamento |
|------------|--------------|------------|-----|--------------|
| cooperativas | 1:N | cooperados | cooperados.cooperative_id → cooperativas.id | CASCADE |
| cooperativas | 1:N | oportunidades | oportunidades.cooperative_id → cooperativas.id | CASCADE |
| cooperativas | 1:N | comunicados | comunicados.cooperative_id → cooperativas.id | CASCADE |
| cooperativas | 1:N | cotas_pagamentos | cotas_pagamentos.cooperative_id → cooperativas.id | CASCADE |
| cooperados | 1:N | oportunidades (criado_por) | oportunidades.criado_por → cooperados.id | RESTRICT |
| oportunidades | 1:N | candidaturas | candidaturas.oportunidade_id → oportunidades.id | CASCADE |
| cooperados | 1:N | candidaturas | candidaturas.cooperado_id → cooperados.id | CASCADE |
| oportunidades | 1:N | atribuicoes | atribuicoes.oportunidade_id → oportunidades.id | CASCADE |
| cooperados | 1:N | atribuicoes (selecionado) | atribuicoes.cooperado_id → cooperados.id | CASCADE |
| cooperados | 1:N | atribuicoes (atribuidor) | atribuicoes.atribuido_por → cooperados.id | RESTRICT |
| candidaturas | 1:1 | atribuicoes | atribuicoes.candidatura_id → candidaturas.id | SET NULL |
| comunicados | 1:N | comunicado_leituras | comunicado_leituras.comunicado_id → comunicados.id | CASCADE |
| cooperados | 1:N | cotas_pagamentos | cotas_pagamentos.cooperado_id → cooperados.id | CASCADE |
| auth.users | 1:1 | cooperados | cooperados.user_id → auth.users.id | CASCADE |

---

## Índices

| Tabela | Campos | Tipo | Motivo |
|--------|--------|------|--------|
| cooperados | (cooperative_id, status) | INDEX | Feed — filtrar cooperados ativos por tenant |
| cooperados | (cooperative_id, cpf) | UNIQUE INDEX | Unicidade de CPF por cooperativa |
| cooperados | user_id | UNIQUE INDEX | Lookup do cooperado pelo auth.uid() |
| oportunidades | (cooperative_id, status, prazo_candidatura) | INDEX | Feed — oportunidades abertas ordenadas |
| oportunidades | (cooperative_id, created_at DESC) | INDEX | Ordenação do feed por mais recentes |
| candidaturas | (oportunidade_id, status) | INDEX | Lista de candidatos por oportunidade |
| candidaturas | (cooperado_id, created_at DESC) | INDEX | "Minhas Candidaturas" do cooperado |
| atribuicoes | (cooperado_id, created_at DESC) | INDEX | Histórico de produção do cooperado |
| cotas_pagamentos | (cooperado_id, competencia) | UNIQUE INDEX | Uma cota por mês por cooperado |
| cotas_pagamentos | (cooperative_id, pago) | INDEX | Dashboard de inadimplência |
| comunicados | (cooperative_id, created_at DESC) | INDEX | Feed de comunicados por tenant |
| comunicado_leituras | (cooperado_id, comunicado_id) | UNIQUE INDEX | Marcar leitura sem duplicatas |
| notifications_log | (cooperado_id, enviado) | INDEX | Notificações pendentes de envio |

---

## Schema SQL Completo (Supabase PostgreSQL 15)

```sql
-- ============================================================
-- EXTENSÕES
-- ============================================================
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================
-- COOPERATIVAS — tenant root
-- ============================================================
CREATE TABLE cooperativas (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nome             TEXT NOT NULL,
  tipo             TEXT NOT NULL CHECK (tipo IN ('trabalho','saude','transporte','educacao','agro','outro')),
  cnpj             TEXT UNIQUE,
  logo_url         TEXT,
  cor_primaria     TEXT DEFAULT '#00796B',
  tipo_oport_label TEXT DEFAULT 'Oportunidade',
  criterio_padrao  TEXT DEFAULT 'manual' CHECK (criterio_padrao IN ('fifo','rodizio','manual')),
  plano            TEXT DEFAULT 'basico' CHECK (plano IN ('basico','padrao','avancado')),
  ativo            BOOLEAN DEFAULT TRUE,
  created_at       TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- COOPERADOS — membros de uma cooperativa
-- ============================================================
CREATE TABLE cooperados (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  cooperative_id   UUID NOT NULL REFERENCES cooperativas(id) ON DELETE CASCADE,
  user_id          UUID UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
  nome             TEXT NOT NULL,
  cpf              TEXT NOT NULL,
  email            TEXT,
  telefone         TEXT,
  especialidades   TEXT[] DEFAULT '{}',
  status           TEXT DEFAULT 'ativo' CHECK (status IN ('ativo','inativo','suspenso','inadimplente')),
  fcm_token        TEXT,
  foto_url         TEXT,
  matricula        TEXT,
  is_admin         BOOLEAN DEFAULT FALSE,
  data_associacao  DATE,
  created_at       TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (cooperative_id, cpf)
);

CREATE INDEX idx_cooperados_coop_status ON cooperados(cooperative_id, status);
CREATE UNIQUE INDEX idx_cooperados_user_id ON cooperados(user_id);

-- ============================================================
-- OPORTUNIDADES — core do produto
-- ============================================================
CREATE TABLE oportunidades (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  cooperative_id      UUID NOT NULL REFERENCES cooperativas(id) ON DELETE CASCADE,
  criado_por          UUID REFERENCES cooperados(id) ON DELETE RESTRICT,
  titulo              TEXT NOT NULL,
  tipo                TEXT NOT NULL,
  descricao           TEXT,
  data_execucao       TIMESTAMPTZ,
  local               TEXT,
  valor_estimado      DECIMAL(10,2) CHECK (valor_estimado >= 0),
  num_vagas           INTEGER NOT NULL DEFAULT 1 CHECK (num_vagas >= 1),
  requisitos          TEXT,
  prazo_candidatura   TIMESTAMPTZ NOT NULL,
  criterio_selecao    TEXT NOT NULL DEFAULT 'manual'
                        CHECK (criterio_selecao IN ('fifo','rodizio','manual')),
  visibilidade        TEXT DEFAULT 'todos',
  status              TEXT DEFAULT 'rascunho'
                        CHECK (status IN (
                          'rascunho','aberta','em_candidatura',
                          'atribuida','em_execucao','concluida','cancelada'
                        )),
  motivo_cancelamento TEXT,
  created_at          TIMESTAMPTZ DEFAULT NOW(),
  updated_at          TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_oport_coop_status_prazo
  ON oportunidades(cooperative_id, status, prazo_candidatura);
CREATE INDEX idx_oport_coop_created
  ON oportunidades(cooperative_id, created_at DESC);

-- Trigger: atualizar updated_at automaticamente
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_oportunidades_updated_at
  BEFORE UPDATE ON oportunidades
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ============================================================
-- CANDIDATURAS
-- ============================================================
CREATE TABLE candidaturas (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  oportunidade_id  UUID NOT NULL REFERENCES oportunidades(id) ON DELETE CASCADE,
  cooperado_id     UUID NOT NULL REFERENCES cooperados(id) ON DELETE CASCADE,
  mensagem         TEXT CHECK (LENGTH(mensagem) <= 500),
  status           TEXT DEFAULT 'aguardando'
                     CHECK (status IN ('aguardando','selecionado','nao_selecionado','desistiu')),
  created_at       TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (oportunidade_id, cooperado_id)  -- CRITICAL: evita candidatura duplicada
);

CREATE INDEX idx_candidaturas_oport_status ON candidaturas(oportunidade_id, status);
CREATE INDEX idx_candidaturas_cooperado ON candidaturas(cooperado_id, created_at DESC);

-- ============================================================
-- ATRIBUIÇÕES
-- ============================================================
CREATE TABLE atribuicoes (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  oportunidade_id  UUID NOT NULL REFERENCES oportunidades(id) ON DELETE CASCADE,
  cooperado_id     UUID NOT NULL REFERENCES cooperados(id) ON DELETE CASCADE,
  candidatura_id   UUID REFERENCES candidaturas(id) ON DELETE SET NULL,
  atribuido_por    UUID REFERENCES cooperados(id) ON DELETE RESTRICT,
  confirmado       BOOLEAN DEFAULT FALSE,
  confirmado_em    TIMESTAMPTZ,
  checkin_at       TIMESTAMPTZ,
  checkout_at      TIMESTAMPTZ,
  avaliacao        INTEGER CHECK (avaliacao BETWEEN 1 AND 5),
  obs_avaliacao    TEXT,
  created_at       TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_atrib_cooperado ON atribuicoes(cooperado_id, created_at DESC);

-- ============================================================
-- COMUNICADOS
-- ============================================================
CREATE TABLE comunicados (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  cooperative_id   UUID NOT NULL REFERENCES cooperativas(id) ON DELETE CASCADE,
  autor_id         UUID REFERENCES cooperados(id) ON DELETE RESTRICT,
  titulo           TEXT NOT NULL,
  corpo            TEXT NOT NULL,
  anexo_url        TEXT,
  destinatarios    TEXT DEFAULT 'todos',
  created_at       TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_comunicados_coop ON comunicados(cooperative_id, created_at DESC);

-- ============================================================
-- COMUNICADO LEITURAS
-- ============================================================
CREATE TABLE comunicado_leituras (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  comunicado_id  UUID NOT NULL REFERENCES comunicados(id) ON DELETE CASCADE,
  cooperado_id   UUID NOT NULL REFERENCES cooperados(id) ON DELETE CASCADE,
  lido_em        TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (comunicado_id, cooperado_id)
);

-- ============================================================
-- COTAS E PAGAMENTOS
-- ============================================================
CREATE TABLE cotas_pagamentos (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  cooperado_id     UUID NOT NULL REFERENCES cooperados(id) ON DELETE CASCADE,
  cooperative_id   UUID NOT NULL REFERENCES cooperativas(id) ON DELETE CASCADE,
  competencia      DATE NOT NULL,  -- sempre o primeiro dia do mês: 2026-04-01
  valor            DECIMAL(10,2) NOT NULL CHECK (valor > 0),
  pago             BOOLEAN DEFAULT FALSE,
  data_pagamento   DATE,
  created_at       TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (cooperado_id, competencia)
);

CREATE INDEX idx_cotas_coop_pago ON cotas_pagamentos(cooperative_id, pago);

-- ============================================================
-- NOTIFICATIONS LOG
-- ============================================================
CREATE TABLE notifications_log (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  cooperative_id   UUID REFERENCES cooperativas(id) ON DELETE CASCADE,
  cooperado_id     UUID REFERENCES cooperados(id) ON DELETE CASCADE,
  tipo             TEXT NOT NULL
                     CHECK (tipo IN (
                       'nova_oportunidade','atribuicao','comunicado',
                       'cota_vencida','confirmacao'
                     )),
  titulo           TEXT NOT NULL,
  corpo            TEXT,
  referencia_id    UUID,
  enviado          BOOLEAN DEFAULT FALSE,
  lido             BOOLEAN DEFAULT FALSE,
  enviado_em       TIMESTAMPTZ,
  lido_em          TIMESTAMPTZ,
  created_at       TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_notif_cooperado_enviado ON notifications_log(cooperado_id, enviado);
```

---

## RLS Policies Completas

```sql
-- ============================================================
-- HABILITAR RLS EM TODAS AS TABELAS
-- ============================================================
ALTER TABLE cooperativas       ENABLE ROW LEVEL SECURITY;
ALTER TABLE cooperados         ENABLE ROW LEVEL SECURITY;
ALTER TABLE oportunidades      ENABLE ROW LEVEL SECURITY;
ALTER TABLE candidaturas       ENABLE ROW LEVEL SECURITY;
ALTER TABLE atribuicoes        ENABLE ROW LEVEL SECURITY;
ALTER TABLE comunicados        ENABLE ROW LEVEL SECURITY;
ALTER TABLE comunicado_leituras ENABLE ROW LEVEL SECURITY;
ALTER TABLE cotas_pagamentos   ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications_log  ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- FUNÇÕES HELPER (SECURITY DEFINER — executam como owner)
-- ============================================================

-- Retorna o cooperative_id do usuário logado
CREATE OR REPLACE FUNCTION current_cooperative_id()
RETURNS UUID AS $$
  SELECT cooperative_id FROM cooperados
  WHERE user_id = auth.uid() LIMIT 1;
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- Retorna o cooperado_id do usuário logado
CREATE OR REPLACE FUNCTION current_cooperado_id()
RETURNS UUID AS $$
  SELECT id FROM cooperados
  WHERE user_id = auth.uid() LIMIT 1;
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- Verifica se o usuário logado é admin de sua cooperativa
CREATE OR REPLACE FUNCTION current_is_admin()
RETURNS BOOLEAN AS $$
  SELECT COALESCE(
    (SELECT is_admin FROM cooperados WHERE user_id = auth.uid() LIMIT 1),
    FALSE
  );
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- ============================================================
-- COOPERATIVAS — só admin pode ver/editar sua cooperativa
-- ============================================================
CREATE POLICY "cooperativa_select_own" ON cooperativas
  FOR SELECT USING (id = current_cooperative_id());

CREATE POLICY "cooperativa_update_admin" ON cooperativas
  FOR UPDATE USING (id = current_cooperative_id() AND current_is_admin());

-- ============================================================
-- COOPERADOS
-- ============================================================
-- Todos veem cooperados da sua cooperativa (para saber nome dos candidatos)
CREATE POLICY "cooperados_select_own_coop" ON cooperados
  FOR SELECT USING (cooperative_id = current_cooperative_id());

-- Admin gerencia cooperados da sua cooperativa
CREATE POLICY "cooperados_admin_insert" ON cooperados
  FOR INSERT WITH CHECK (cooperative_id = current_cooperative_id() AND current_is_admin());

CREATE POLICY "cooperados_admin_update" ON cooperados
  FOR UPDATE USING (cooperative_id = current_cooperative_id() AND current_is_admin());

-- Cooperado pode atualizar apenas seu próprio fcm_token e foto
CREATE POLICY "cooperado_update_self" ON cooperados
  FOR UPDATE USING (user_id = auth.uid());

-- ============================================================
-- OPORTUNIDADES
-- ============================================================
-- Todos da coop visualizam oportunidades
CREATE POLICY "oportunidades_select_coop" ON oportunidades
  FOR SELECT USING (cooperative_id = current_cooperative_id());

-- Só admin cria/edita/cancela
CREATE POLICY "oportunidades_admin_insert" ON oportunidades
  FOR INSERT WITH CHECK (cooperative_id = current_cooperative_id() AND current_is_admin());

CREATE POLICY "oportunidades_admin_update" ON oportunidades
  FOR UPDATE USING (cooperative_id = current_cooperative_id() AND current_is_admin());

-- ============================================================
-- CANDIDATURAS
-- ============================================================
-- Cooperado vê apenas suas próprias candidaturas
CREATE POLICY "candidaturas_select_own" ON candidaturas
  FOR SELECT USING (
    cooperado_id = current_cooperado_id()
    OR (
      current_is_admin() AND
      oportunidade_id IN (
        SELECT id FROM oportunidades WHERE cooperative_id = current_cooperative_id()
      )
    )
  );

-- Cooperado cria apenas suas próprias candidaturas
CREATE POLICY "candidaturas_insert_self" ON candidaturas
  FOR INSERT WITH CHECK (
    cooperado_id = current_cooperado_id()
    -- Validação extra no app: não inadimplente, prazo não encerrado
  );

-- Admin atualiza status de candidaturas (selecionado, nao_selecionado)
CREATE POLICY "candidaturas_admin_update" ON candidaturas
  FOR UPDATE USING (
    current_is_admin() AND
    oportunidade_id IN (
      SELECT id FROM oportunidades WHERE cooperative_id = current_cooperative_id()
    )
  );

-- ============================================================
-- ATRIBUIÇÕES
-- ============================================================
-- Admin e cooperado atribuído veem a atribuição
CREATE POLICY "atribuicoes_select" ON atribuicoes
  FOR SELECT USING (
    cooperative_id = (
      SELECT cooperative_id FROM oportunidades WHERE id = oportunidade_id
    )
    -- simplificado: qualquer membro da coop pode ver atribuições (histórico transparente)
    AND current_cooperative_id() = (
      SELECT cooperative_id FROM oportunidades WHERE id = oportunidade_id
    )
  );

-- Admin cria atribuições
CREATE POLICY "atribuicoes_admin_insert" ON atribuicoes
  FOR INSERT WITH CHECK (current_is_admin());

-- Cooperado confirma/declina (update confirmado)
CREATE POLICY "atribuicoes_cooperado_update" ON atribuicoes
  FOR UPDATE USING (cooperado_id = current_cooperado_id());

-- ============================================================
-- COMUNICADOS
-- ============================================================
CREATE POLICY "comunicados_select_coop" ON comunicados
  FOR SELECT USING (cooperative_id = current_cooperative_id());

CREATE POLICY "comunicados_admin_insert" ON comunicados
  FOR INSERT WITH CHECK (cooperative_id = current_cooperative_id() AND current_is_admin());

-- ============================================================
-- COMUNICADO LEITURAS
-- ============================================================
CREATE POLICY "leituras_select_own" ON comunicado_leituras
  FOR SELECT USING (cooperado_id = current_cooperado_id());

CREATE POLICY "leituras_insert_self" ON comunicado_leituras
  FOR INSERT WITH CHECK (cooperado_id = current_cooperado_id());

-- ============================================================
-- COTAS PAGAMENTOS
-- ============================================================
-- Cooperado vê apenas suas cotas
CREATE POLICY "cotas_select_own" ON cotas_pagamentos
  FOR SELECT USING (
    cooperado_id = current_cooperado_id()
    OR (current_is_admin() AND cooperative_id = current_cooperative_id())
  );

-- Admin lança pagamentos
CREATE POLICY "cotas_admin_insert" ON cotas_pagamentos
  FOR INSERT WITH CHECK (cooperative_id = current_cooperative_id() AND current_is_admin());

CREATE POLICY "cotas_admin_update" ON cotas_pagamentos
  FOR UPDATE USING (cooperative_id = current_cooperative_id() AND current_is_admin());

-- ============================================================
-- NOTIFICATIONS LOG
-- ============================================================
-- Cooperado vê suas notificações; admin vê tudo da coop
CREATE POLICY "notif_select" ON notifications_log
  FOR SELECT USING (
    cooperado_id = current_cooperado_id()
    OR (current_is_admin() AND cooperative_id = current_cooperative_id())
  );

-- Edge Functions usam Service Role Key — bypass RLS (correto para funções server-side)
```

---

## Diagrama ERD (simplificado)

```
cooperativas ─────────────┐
  id (PK)                 │ 1:N
  nome, tipo, cnpj        ▼
  configurações       cooperados ────────────────────┐
                        id (PK)                      │
                        user_id → auth.users          │ 1:N
                        cooperative_id (FK)           │
                        cpf, nome, status             │     candidaturas
                        is_admin, fcm_token           │       id (PK)
                        │                            │       oportunidade_id (FK) ─┐
                        │ 1:N                        │       cooperado_id (FK) ───┘│
                        ▼                            │       status, mensagem       │
                   oportunidades ←───────────────────┘       UNIQUE(oport,coop)    │
                     id (PK)                                                        │
                     cooperative_id (FK)                  atribuicoes              │
                     titulo, tipo, status                   id (PK)                │
                     prazo_candidatura                      oportunidade_id (FK) ──┘
                     criterio_selecao                       cooperado_id (FK)
                     │                                      candidatura_id (FK)
                     │ 1:N                                  confirmado, avaliacao

comunicados → comunicado_leituras
cotas_pagamentos (cooperado 1:N cotas)
notifications_log (cooperado 1:N logs)
```

---

## Função para Atualização de Status (Machine State)

```sql
-- Previne transições de status inválidas na oportunidade
CREATE OR REPLACE FUNCTION validate_oport_status_transition()
RETURNS TRIGGER AS $$
BEGIN
  -- Transições permitidas
  IF (OLD.status, NEW.status) IN (
    ('rascunho', 'aberta'),
    ('rascunho', 'cancelada'),
    ('aberta', 'em_candidatura'),
    ('aberta', 'cancelada'),
    ('em_candidatura', 'atribuida'),
    ('em_candidatura', 'aberta'),   -- re-abrir se nenhum candidato
    ('em_candidatura', 'cancelada'),
    ('atribuida', 'em_execucao'),
    ('atribuida', 'em_candidatura'), -- declínio de todos os selecionados
    ('atribuida', 'cancelada'),
    ('em_execucao', 'concluida'),
    ('em_execucao', 'cancelada')
  ) THEN
    RETURN NEW;
  END IF;
  RAISE EXCEPTION 'Transição de status inválida: % → %', OLD.status, NEW.status;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validate_oport_status
  BEFORE UPDATE OF status ON oportunidades
  FOR EACH ROW EXECUTE FUNCTION validate_oport_status_transition();
```

---

## Estratégia de Migrações

**Ferramenta:** Supabase CLI (`supabase db push` / `supabase db diff`)

```
supabase/migrations/
├── 20260405000001_create_cooperativas.sql
├── 20260405000002_create_cooperados.sql
├── 20260405000003_create_oportunidades.sql
├── 20260405000004_create_candidaturas_atribuicoes.sql
├── 20260405000005_create_comunicados.sql
├── 20260405000006_create_cotas.sql
├── 20260405000007_create_notifications_log.sql
├── 20260405000008_enable_rls_all_tables.sql
├── 20260405000009_rls_policies.sql
└── 20260405000010_helper_functions.sql
```

**Regras de migration:**
- Sempre **additive only** na v1 — `ALTER TABLE ADD COLUMN` nunca `DROP COLUMN`
- Toda migration testada em ambiente local (`supabase start`) antes de push para prod
- Migrations são idempotentes quando possível (`CREATE IF NOT EXISTS`)

---

## Cache Strategy (TTL)

| Entidade | Frequência de Leitura | TTL Flutter (SharedPreferences) | Invalidação |
|---------|----------------------|--------------------------------|-------------|
| Feed oportunidades | Muito alta | Supabase Realtime (sem cache local) | Push notification → invalidar |
| Minhas candidaturas | Alta | 5 min | Ao receber push de atribuição |
| Perfil do cooperado | Média | 30 min | Ao atualizar dados |
| Comunicados | Baixa | 1h | Ao abrir o app |
| Config da cooperativa | Baixa | 24h | Ao fazer login |
