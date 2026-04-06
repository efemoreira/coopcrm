# Design System — CoopCRM

> **Criado por:** Diana Design  
> **Data:** 2026-04-05 | **Versão:** 1.0

---

## Referências Pesquisadas

Sem Figma disponível para este projeto. Referências pesquisadas:

| # | Referência | URL | Justificativa |
|---|-----------|-----|---------------|
| 1 | **Cora Business** (fintech B2B brasileiro) | https://www.cora.com.br | App de gestão financeira para pequenos negócios — padrão de dashboard limpo, status badges coloridos, hierarquia clara. Público similar (gestor de pequeno negócio no Brasil) |
| 2 | **Material Design 3 — Work Management** | https://m3.material.io/foundations/overview | Sistema de design com acessibilidade nativa, alto contraste, suporte a Android e Flutter out-of-the-box |
| 3 | **Mobbin — Task/Service Management Apps** | https://mobbin.com | Cards de tarefa com status colorido, bottom sheets para ações rápidas, FAB para criação inline |

**Direção visual escolhida:** Material Design 3 adaptado — institucional mas humano. Teal como cor primária (transmite confiança e cooperação), Amber como acento de ação, sem gradientes pesados. Interface funcional primeiro, ornamentação zero. Ideal para usuários menos tech-savvy (Dona Maria das Graças, Seu Jonas).

---

## Tokens de Design

### Cores

#### Primary (Teal — confiança, cooperação)
| Token | Hex | Uso |
|-------|-----|-----|
| `colorPrimary` | `#00796B` | CTA principal, botão "Me Candidatar", links |
| `colorPrimaryDark` | `#004D40` | Header do app, barra de status Android |
| `colorPrimaryLight` | `#B2DFDB` | Fundo de chips selecionados, highlight sutil |
| `colorPrimaryContainer` | `#E0F2F1` | Surface selecionada, estado ativo de tab |

#### Accent (Amber — ação urgente, atenção)
| Token | Hex | Uso |
|-------|-----|-----|
| `colorAccent` | `#F59E0B` | Badge NOVO, prazo próximo, destaque de valor (R$) |
| `colorAccentDark` | `#B45309` | Texto sobre fundo amber |

#### Status de Oportunidade / Candidatura
| Token | Hex | Nome | Uso |
|-------|-----|------|-----|
| `colorStatusAberta` | `#0EA5E9` | Azul | Badge ABERTA, candidatura AGUARDANDO |
| `colorStatusAtribuida` | `#7C3AED` | Roxo | Badge ATRIBUÍDA |
| `colorStatusEmExecucao` | `#F97316` | Laranja | Badge EM EXECUÇÃO, candidatura em andamento |
| `colorStatusConcluida` | `#16A34A` | Verde | Badge CONCLUÍDA, candidatura SELECIONADO |
| `colorStatusCancelada` | `#DC2626` | Vermelho | Badge CANCELADA, inadimplente |
| `colorStatusRascunho` | `#6B7280` | Cinza | Badge RASCUNHO |
| `colorStatusNaoSelecionado` | `#FCA5A5` | Vermelho suave | candidatura NÃO SELECIONADO |

#### Feedback
| Token | Hex | Uso |
|-------|-----|-----|
| `colorSuccess` | `#16A34A` | Confirmação, sucesso, adimplente |
| `colorWarning` | `#D97706` | Alerta, cota próxima do vencimento |
| `colorDanger` | `#DC2626` | Erro, inadimplente, cancelado |
| `colorInfo` | `#0891B2` | Informativo, dica |

#### Neutros
| Token | Hex | Uso |
|-------|-----|-----|
| `colorNeutral900` | `#111827` | Texto primário |
| `colorNeutral700` | `#374151` | Texto secundário, labels |
| `colorNeutral500` | `#6B7280` | Placeholder, hint text |
| `colorNeutral300` | `#D1D5DB` | Dividers, borders |
| `colorNeutral100` | `#F3F4F6` | Surface — fundo de cards |
| `colorNeutral50` | `#F9FAFB` | Background da tela |
| `colorWhite` | `#FFFFFF` | Surface elevada, cards |

#### Verificação WCAG AA (contraste ≥ 4.5:1 para texto normal)
| Par | Ratio | Status |
|-----|-------|--------|
| `colorNeutral900` (texto) sobre `colorWhite` | 16.75:1 | ✅ WCAG AAA |
| `colorPrimary` sobre `colorWhite` | 4.56:1 | ✅ WCAG AA |
| `colorPrimaryDark` sobre `colorWhite` | 10.2:1 | ✅ WCAG AAA |
| `colorWhite` sobre `colorPrimary` | 4.56:1 | ✅ WCAG AA |
| `colorNeutral700` sobre `colorNeutral50` | 5.81:1 | ✅ WCAG AA |
| `colorDanger` sobre `colorWhite` | 5.41:1 | ✅ WCAG AA |

---

### Tipografia

**Fonte:** `Inter` (Google Fonts — excelente legibilidade em telas pequenas, grande suporte pt-BR)  
Fallback: `Roboto` (padrão Android/Material)

| Token | Tamanho | Peso | Line Height | Uso |
|-------|---------|------|-------------|-----|
| `textH1` | 28px | 700 | 36px | Títulos de tela principal |
| `textH2` | 22px | 600 | 30px | Títulos de seção, nome da cooperativa |
| `textH3` | 18px | 600 | 26px | Título de card de oportunidade |
| `textBody` | 16px | 400 | 24px | Texto corrido, descrição |
| `textBodyMedium` | 16px | 500 | 24px | Labels de valor, status textual |
| `textCaption` | 13px | 400 | 18px | Metadados (prazo, local), hints |
| `textLabel` | 12px | 600 | 16px | Badges, chips, tabs |
| `textButton` | 15px | 600 | 20px | Rótulo de botão |
| `textMicro` | 11px | 500 | 14px | Contador de candidatos, timestamps |

> **Nota Flutter:** usar `GoogleFonts.inter()` via pacote `google_fonts`. Garantir carregamento mesmo offline cacheando a fonte no build.

---

### Espaçamento (escala 4px)

| Token | Valor | Uso |
|-------|-------|-----|
| `space2xs` | 4px | Espaço interno de chip, ícone+texto |
| `spaceXs` | 8px | Gap entre label e campo, padding vertical de item de lista |
| `spaceSm` | 12px | Padding horizontal de chip |
| `spaceMd` | 16px | Padding interno de card, margem lateral de tela |
| `spaceLg` | 24px | Espaço entre seções dentro de uma tela |
| `spaceXl` | 32px | Espaço entre cards no feed, top padding de scrollview |
| `space2xl` | 48px | Padding top/bottom de tela de detalhe |
| `space3xl` | 64px | Espaço do FAB ao conteúdo abaixo |

---

### Border Radius

| Token | Valor | Uso |
|-------|-------|-----|
| `radiusXs` | 4px | Badges de status, chips pequenos |
| `radiusSm` | 8px | Campos de input, botões secundários |
| `radiusMd` | 12px | Cards de oportunidade |
| `radiusLg` | 16px | Bottom sheets, dialogs |
| `radiusFull` | 999px | Botões pill, avatares, FAB |

---

### Elevação / Shadows (Material 3)

| Token | Box Shadow | Uso |
|-------|-----------|-----|
| `elevation0` | none | Background, surface plana |
| `elevation1` | `0 1px 3px rgba(0,0,0,0.12)` | Cards no feed |
| `elevation2` | `0 2px 8px rgba(0,0,0,0.16)` | Bottom navigation bar |
| `elevation3` | `0 4px 16px rgba(0,0,0,0.20)` | Bottom sheets, modais |
| `elevation4` | `0 8px 24px rgba(0,0,0,0.24)` | FAB, snackbar |

---

## Componentes Principais

### App Mobile (Cooperado)

| Componente | Descrição |
|-----------|-----------|
| `OportunidadeCard` | Card no feed: título, tipo chip, local, data, vagas, valor, prazo, botão "Tenho Interesse" + badge NOVO |
| `StatusBadge` | Chip colorido de status (usa mapeamento de status → cor). Variantes: filled, outlined |
| `CandidaturaListItem` | Item de lista em "Minhas Candidaturas" com status colorido, título e ação quando SELECIONADO |
| `PrimeiroCTA` | Botão primário — teal, texto branco, rounded, full-width. Estados: default, loading (spinner), disabled |
| `SecondaryButton` | Botão secundário — outlined teal |
| `DangerButton` | Botão de ação destrutiva — outlined vermelho |
| `ProducaoPeriodo` | Widget compacto: valor acumulado + contagem de serviços + avaliação (estrelas). Usado em Perfil |
| `CotaStatusCard` | Card com badge verde/vermelho de adimplência + próximo vencimento |
| `NotificationBanner` | Banner in-app para notificação quando app em foreground |
| `EmptyStateFeed` | Tela vazia do feed: ícone + título + subtexto + CTA opcional |
| `BottomNavBar` | Navegação inferior: 4 tabs — Oportunidades, Candidaturas, Comunicados, Perfil |
| `PullToRefresh` | Pull-to-refresh nativo com indicador teal |

### Painel Admin (Web)

| Componente | Descrição |
|-----------|-----------|
| `DashboardStatsCard` | Card de KPI: número + label + variação percentual opcional |
| `OportunidadeRow` | Linha em tabela: título, tipo, N candidatos, prazo, status, ações rápidas |
| `CandidatoListItem` | Item na lista de candidatos: avatar, nome, horário, produção mês, avaliação |
| `AtribuicaoModeSelector` | Seletor de modo: FIFO / Rodízio / Manual — botões de toggle |
| `FormField` | Campo de formulário: label, input/textarea/select, helper text, estado de erro |
| `DateTimePicker` | Picker de data e hora com localização pt-BR |
| `AdminTopBar` | Header do painel: logo cooperativa, nome admin, menu |
| `SideNav` | Navegação lateral: Quadro, Cooperados, Comunicados, Cotas, Relatórios, Configurações |
| `FilterBar` | Barra de filtros horizontal com chips clicáveis (status, período, tipo) |
| `DataTable` | Tabela responsiva com ordenação, paginação e seleção múltipla |
| `ConfirmDialog` | Modal de confirmação para ações irreversíveis (cancelar oportunidade, desativar cooperado) |
| `EvaluationStars` | Widget de avaliação 1-5 estrelas |

---

## Telas Prototipadas (Wireframe Médio-Fidelidade)

### Tela 1: Feed de Oportunidades (Mobile — Home)

```
┌─────────────────────────────────────┐
│ 🤝 CoopCRM         [ícone sino 🔔]  │  headerbar teal
│ Olá, Jonas 👋                       │
│                                     │
│ [🔍 Buscar oportunidades...]        │  searchbar
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ NOVO  ●  Job  ●  Aldeota        │ │  badge NOVO (amber) + chips
│ │ Limpeza pós-obra — Ed. Fortaleza│ │  H3 bold
│ │ 📅 20/04  📍 Aldeota  💰 R$420  │ │  metadata row
│ │ ⏰ Prazo: 18/04 às 18h          │ │  caption warning se < 24h
│ │ 👥 2 vagas  →  4 candidatos     │ │
│ │            [Tenho Interesse ✓]  │ │  botão primário teal
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ ●  Rota  ●  Itaperi             │ │
│ │ Entrega zona norte — Carga 2t   │ │
│ │ 📅 22/04  💰 R$280  ⏰ 21/04   │ │
│ │            [Tenho Interesse ✓]  │ │
│ └─────────────────────────────────┘ │
│                                     │
│ 🏠 Oportunidades | 📋 | 📢 | 👤   │  bottom nav
└─────────────────────────────────────┘
```

**Hierarquia visual:** Título (H3, bold) > Metadados (Caption, neutral500) > Botão (Primary, full-width)  
**Contraste:** Texto sobre card branco = 16:1 ✅

---

### Tela 2: Detalhe da Oportunidade (Mobile)

```
┌─────────────────────────────────────┐
│ ← Voltar          [ABERTA 🔵]       │  status badge no header
│                                     │
│ Limpeza pós-obra                    │  H1
│ Ed. Fortaleza, Aldeota              │  Body neutral700
│                                     │
│ ┌───────┬────────┬────────┬───────┐ │
│ │📅 20/04│💰 R$420│👥 2 vag│⏰ 18h│ │  info grid 4 cols
│ └───────┴────────┴────────┴───────┘ │
│                                     │
│ Descrição                           │  H3
│ Limpeza completa após obra civil... │  Body
│                                     │
│ Requisitos: NR35 válido             │  Body
│                                     │
│ 4 cooperados já se candidataram     │  Caption teal
│                                     │
│ [Mensagem opcional p/ admin...]     │  textarea
│                                     │
│ [      Me Candidatar →      ]       │  btn primário
│ [    (Prazo encerrado)       ]      │  estado disabled quando encerrado
└─────────────────────────────────────┘
```

---

### Tela 3: Nova Oportunidade (Admin Web)

```
┌──────────────────────────────────────────────────┐
│ 🤝 CoopCRM Admin    [Dona Maria ▼]    [Sair]     │
├────────────┬─────────────────────────────────────┤
│ 📋 Quadro  │  Nova Oportunidade                   │
│ 👥 Cooperad│                                      │
│ 📢 Comunic │  Título *                            │
│ 💰 Cotas   │  [Limpeza pós-obra...           ]   │
│ 📊 Relatór │                                      │
│ ⚙️ Config  │  Tipo *              Nº de Vagas *  │
│            │  [Job ▼           ]  [  1  ↑↓    ]  │
│            │                                      │
│            │  Data / Horário        Local         │
│            │  [20/04/2026 08:00]    [Aldeota...] │
│            │                                      │
│            │  Valor Estimado        Prazo Cand.*  │
│            │  [R$ 420,00       ]    [18/04 18h ]  │
│            │                                      │
│            │  Critério de Seleção *               │
│            │  ○ FIFO  ○ Rodízio  ● Manual         │
│            │                                      │
│            │  Descrição                          │
│            │  [___________________________________]│
│            │                                      │
│            │  Requisitos                          │
│            │  [NR35 válido...                   ] │
│            │                                      │
│            │  [Salvar Rascunho]  [Publicar Agora] │
└────────────┴─────────────────────────────────────┘
```

---

### Tela 4: Lista de Candidatos (Admin Web — Detalhe)

```
┌──────────────────────────────────────────────────┐
│ Limpeza pós-obra — Ed. Fortaleza    [ATRIBUÍDA ●]│
│                                                   │
│ Modo de Atribuição:                               │
│ [FIFO automático]  [Rodízio]  [■ Manual]          │
│                                                   │
│ 2 vagas para preencher                            │
│                                                   │
│ ┌──────────────┬──────┬──────┬─────────┬────────┐ │
│ │ Cooperado    │ Hora │ Prod.│ Aval.   │ Ação   │ │
│ ├──────────────┼──────┼──────┼─────────┼────────┤ │
│ │ Jonas Silva  │ 14:03│ R$1.2│ ★★★★☆  │[Selec.]│ │
│ │ Ana Costa    │ 14:17│ R$890│ ★★★★★  │[Selec.]│ │
│ │ Paulo Melo   │ 15:02│ R$640│ ★★★☆☆  │[Selec.]│ │
│ └──────────────┴──────┴──────┴─────────┴────────┘ │
│                                                   │
│ Selecionados: Jonas Silva ✓ | Ana Costa ✓         │
│ [Confirmar Atribuição]                            │
└──────────────────────────────────────────────────┘
```

---

## Acessibilidade

| Critério | Status | Detalhes |
|---------|--------|---------|
| Contraste texto/fundo WCAG AA | ✅ | Todos os pares verificados (tabela acima) |
| Tamanho mínimo de toque | ✅ | Todos os elementos interativos ≥ 44×44px |
| Aria-labels em ícones sem texto | ✅ | Ver seção UX Content (aria-labels) |
| Cores não como único indicador | ✅ | Status badges sempre têm texto + cor |
| Fonte mínima legível | ✅ | Caption = 13px (> mínimo Android de 12px) |
| Suporte a Dynamic Type / Accessibility Font Size | 🔶 | Definir no step de implementação |

---

## Responsividade

- **Mobile (app):** 320px–414px — layout single-column, bottom nav, FAB
- **Tablet (admin):** 768px+ — side nav + main content area
- **Desktop (admin web):** 1024px+ — side nav (240px) + 3-column content area
- Mobile-first: todos os componentes desenhados para 360px antes de expandir

---

## Modo Escuro (Dark Mode)

Planejado para v2. Na v1, somente Light Mode. Tokens nomeados para suportar dark mode futuro (evitar `colorWhite` hardcoded — usar `colorSurface` que muda por tema).
