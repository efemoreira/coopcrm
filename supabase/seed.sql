-- =============================================================
-- SEED — CoopCRM (desenvolvimento local)
-- Cooperativa completa com admin + 8 cooperados + oportunidades
-- comunicados, cotas e candidaturas para testar todos os fluxos.
--
-- COMO USAR:
--   supabase db reset          (recria tudo do zero + roda esta seed)
--   supabase db seed           (apenas roda a seed)
--
-- LOGINS DE TESTE (senha: CoopCRM@2026):
--   admin@cooptech.com   — admin
--   joao@cooptech.com    — cooperado comum
--   maria@cooptech.com   — cooperado comum
--   carlos@cooptech.com  — cooperado inadimplente
-- =============================================================

do $$
declare
  -- IDs fixos para facilitar referência cruzada
  v_coop_id   uuid := 'aaaaaaaa-0000-0000-0000-000000000001';

  -- Auth users (simulados — em produção são criados via Supabase Auth)
  v_uid_admin   uuid := 'bbbbbbbb-0000-0000-0000-000000000001';
  v_uid_joao    uuid := 'bbbbbbbb-0000-0000-0000-000000000002';
  v_uid_maria   uuid := 'bbbbbbbb-0000-0000-0000-000000000003';
  v_uid_carlos  uuid := 'bbbbbbbb-0000-0000-0000-000000000004';
  v_uid_ana     uuid := 'bbbbbbbb-0000-0000-0000-000000000005';
  v_uid_pedro   uuid := 'bbbbbbbb-0000-0000-0000-000000000006';
  v_uid_lucia   uuid := 'bbbbbbbb-0000-0000-0000-000000000007';
  v_uid_rafael  uuid := 'bbbbbbbb-0000-0000-0000-000000000008';
  v_uid_fernanda uuid := 'bbbbbbbb-0000-0000-0000-000000000009';

  -- Cooperados
  v_coop_admin   uuid := 'cccccccc-0000-0000-0000-000000000001';
  v_coop_joao    uuid := 'cccccccc-0000-0000-0000-000000000002';
  v_coop_maria   uuid := 'cccccccc-0000-0000-0000-000000000003';
  v_coop_carlos  uuid := 'cccccccc-0000-0000-0000-000000000004';
  v_coop_ana     uuid := 'cccccccc-0000-0000-0000-000000000005';
  v_coop_pedro   uuid := 'cccccccc-0000-0000-0000-000000000006';
  v_coop_lucia   uuid := 'cccccccc-0000-0000-0000-000000000007';
  v_coop_rafael  uuid := 'cccccccc-0000-0000-0000-000000000008';
  v_coop_fernanda uuid := 'cccccccc-0000-0000-0000-000000000009';

  -- Oportunidades
  v_op1 uuid := 'dddddddd-0000-0000-0000-000000000001';
  v_op2 uuid := 'dddddddd-0000-0000-0000-000000000002';
  v_op3 uuid := 'dddddddd-0000-0000-0000-000000000003';
  v_op4 uuid := 'dddddddd-0000-0000-0000-000000000004';
  v_op5 uuid := 'dddddddd-0000-0000-0000-000000000005';
  v_op6 uuid := 'dddddddd-0000-0000-0000-000000000006';

  -- Comunicados
  v_com1 uuid := 'eeeeeeee-0000-0000-0000-000000000001';
  v_com2 uuid := 'eeeeeeee-0000-0000-0000-000000000002';
  v_com3 uuid := 'eeeeeeee-0000-0000-0000-000000000003';
  v_com4 uuid := 'eeeeeeee-0000-0000-0000-000000000004';

begin

  -- ===========================================================
  -- 1. AUTH USERS (bypass RLS para seed local)
  -- ===========================================================
  insert into auth.users (id, email, encrypted_password, email_confirmed_at, role)
  values
    (v_uid_admin,   'admin@cooptech.com',   crypt('CoopCRM@2026', gen_salt('bf')), now(), 'authenticated'),
    (v_uid_joao,    'joao@cooptech.com',    crypt('CoopCRM@2026', gen_salt('bf')), now(), 'authenticated'),
    (v_uid_maria,   'maria@cooptech.com',   crypt('CoopCRM@2026', gen_salt('bf')), now(), 'authenticated'),
    (v_uid_carlos,  'carlos@cooptech.com',  crypt('CoopCRM@2026', gen_salt('bf')), now(), 'authenticated'),
    (v_uid_ana,     'ana@cooptech.com',     crypt('CoopCRM@2026', gen_salt('bf')), now(), 'authenticated'),
    (v_uid_pedro,   'pedro@cooptech.com',   crypt('CoopCRM@2026', gen_salt('bf')), now(), 'authenticated'),
    (v_uid_lucia,   'lucia@cooptech.com',   crypt('CoopCRM@2026', gen_salt('bf')), now(), 'authenticated'),
    (v_uid_rafael,  'rafael@cooptech.com',  crypt('CoopCRM@2026', gen_salt('bf')), now(), 'authenticated'),
    (v_uid_fernanda,'fernanda@cooptech.com',crypt('CoopCRM@2026', gen_salt('bf')), now(), 'authenticated')
  on conflict (id) do nothing;

  -- ===========================================================
  -- 2. COOPERATIVA
  -- ===========================================================
  insert into cooperativas (id, nome, cnpj, plano, status, settings)
  values (
    v_coop_id,
    'CoopTech Regional',
    '12.345.678/0001-99',
    'growth',
    'ativo',
    '{"valor_cota_padrao": 150.00, "dias_vencimento_cota": 10, "criterio_selecao_padrao": "rodizio"}'
  )
  on conflict (id) do nothing;

  -- ===========================================================
  -- 3. COOPERADOS
  -- ===========================================================
  insert into cooperados (id, cooperative_id, user_id, nome, cpf, email, telefone,
                          status, num_cota, especialidades, data_admissao, is_admin)
  values
    (v_coop_admin,   v_coop_id, v_uid_admin,   'Ana Paula Souza',    '111.111.111-11', 'admin@cooptech.com',    '(11) 91111-1111', 'ativo',        1,  '{"gestão","RH"}',                          '2023-01-15', true),
    (v_coop_joao,    v_coop_id, v_uid_joao,    'João Carlos Lima',   '222.222.222-22', 'joao@cooptech.com',     '(11) 92222-2222', 'ativo',        2,  '{"desenvolvimento","backend","Python"}',    '2023-03-10', false),
    (v_coop_maria,   v_coop_id, v_uid_maria,   'Maria Oliveira',     '333.333.333-33', 'maria@cooptech.com',    '(11) 93333-3333', 'ativo',        3,  '{"design","UI/UX","Figma"}',               '2023-04-01', false),
    (v_coop_carlos,  v_coop_id, v_uid_carlos,  'Carlos Eduardo',     '444.444.444-44', 'carlos@cooptech.com',   '(11) 94444-4444', 'inadimplente', 4,  '{"infraestrutura","DevOps","Docker"}',      '2023-05-20', false),
    (v_coop_ana,     v_coop_id, v_uid_ana,     'Ana Beatriz Costa',  '555.555.555-55', 'ana@cooptech.com',      '(11) 95555-5555', 'ativo',        5,  '{"frontend","React","Flutter"}',           '2023-06-12', false),
    (v_coop_pedro,   v_coop_id, v_uid_pedro,   'Pedro Henrique',     '666.666.666-66', 'pedro@cooptech.com',    '(11) 96666-6666', 'ativo',        6,  '{"dados","Power BI","SQL"}',               '2023-07-08', false),
    (v_coop_lucia,   v_coop_id, v_uid_lucia,   'Lúcia Ferreira',     '777.777.777-77', 'lucia@cooptech.com',    '(11) 97777-7777', 'suspenso',     7,  '{"comercial","vendas"}',                   '2023-08-30', false),
    (v_coop_rafael,  v_coop_id, v_uid_rafael,  'Rafael Mendes',      '888.888.888-88', 'rafael@cooptech.com',   '(11) 98888-8888', 'ativo',        8,  '{"mobile","Android","Flutter","iOS"}',     '2023-09-15', false),
    (v_coop_fernanda,v_coop_id, v_uid_fernanda,'Fernanda Torres',    '999.999.999-99', 'fernanda@cooptech.com', '(11) 99999-9999', 'ativo',        9,  '{"QA","testes","automação","Cypress"}',    '2024-01-10', false)
  on conflict (id) do nothing;

  -- ===========================================================
  -- 4. OPORTUNIDADES (vários status para testar todos os fluxos)
  -- ===========================================================
  insert into oportunidades (id, cooperative_id, criado_por, titulo, tipo, descricao,
                              status, prazo_candidatura, data_execucao, local,
                              valor_estimado, num_vagas, requisitos, criterio_selecao)
  values
    -- Aberta: prazo no futuro, aguardando candidaturas
    (v_op1, v_coop_id, v_coop_admin,
     'Desenvolvimento de API REST — Sistema de Relatórios',
     'desenvolvimento',
     'Criar endpoints REST em Python/FastAPI para exportação de relatórios financeiros em PDF e Excel. Integração com banco PostgreSQL.',
     'aberta',
     now() + interval '7 days',
     now() + interval '14 days',
     'Remoto',
     2800.00, 2,
     'Python + FastAPI, PostgreSQL, experiência com geração de PDF (ReportLab)',
     'manual'),

    -- Aberta com rodízio
    (v_op2, v_coop_id, v_coop_admin,
     'App Mobile Flutter — Módulo de Agendamento',
     'mobile',
     'Implementar módulo de agendamento de visitas técnicas no aplicativo Flutter existente. Inclui integração com Google Calendar API.',
     'aberta',
     now() + interval '5 days',
     now() + interval '12 days',
     'Remoto',
     3500.00, 1,
     'Flutter 3.x, Dart, Google Calendar API, familiaridade com BLoC/Cubit',
     'rodizio'),

    -- Em candidatura: prazo próximo
    (v_op3, v_coop_id, v_coop_admin,
     'Consultoria DevOps — Pipeline CI/CD para Cliente Industrial',
     'infraestrutura',
     'Estruturar pipeline de CI/CD com GitHub Actions e deploy automatizado para cliente do setor industrial. Docker + AWS EC2.',
     'em_candidatura',
     now() + interval '2 days',
     now() + interval '10 days',
     'Híbrido — São Paulo/SP',
     4200.00, 1,
     'GitHub Actions, Docker, AWS EC2/S3, conhecimento de redes e segurança',
     'fifo'),

    -- Atribuída: já foi selecionado alguém
    (v_op4, v_coop_id, v_coop_admin,
     'Design de Interface — Redesign de Portal do Cliente',
     'design',
     'Redesign completo do portal web de um cliente do setor financeiro. Entrega: protótipo Figma + style guide + assets exportados.',
     'atribuida',
     now() - interval '3 days',
     now() + interval '5 days',
     'Remoto',
     1800.00, 1,
     'Figma, design system, UX research, experiência com fintech',
     'manual'),

    -- Concluída: para testar histórico
    (v_op5, v_coop_id, v_coop_admin,
     'Análise de Dados — Dashboard Power BI para Cooperativa',
     'dados',
     'Criar dashboard executivo em Power BI com KPIs de produção, faturamento e inadimplência para diretoria da cooperativa.',
     'concluida',
     now() - interval '30 days',
     now() - interval '15 days',
     'Remoto',
     2200.00, 1,
     'Power BI, DAX, modelagem dimensional, SQL Server ou PostgreSQL',
     'manual'),

    -- Cancelada: para testar filtros
    (v_op6, v_coop_id, v_coop_admin,
     'Suporte Técnico — Migração de Servidor On-Premise',
     'infraestrutura',
     'Auxiliar cliente na migração de servidor físico para nuvem Azure. Projeto cancelado por mudança de escopo do cliente.',
     'cancelada',
     now() - interval '10 days',
     null,
     'Presencial — Campinas/SP',
     5000.00, 2,
     'Azure, Windows Server, Active Directory',
     'manual')
  on conflict (id) do nothing;

  -- ===========================================================
  -- 5. CANDIDATURAS
  -- ===========================================================
  insert into candidaturas (oportunidade_id, cooperado_id, status, mensagem)
  values
    -- op1: 3 candidatos
    (v_op1, v_coop_joao,  'pendente',    'Tenho experiência sólida com FastAPI e PostgreSQL. Disponível para iniciar imediatamente.'),
    (v_op1, v_coop_pedro, 'pendente',    'Trabalho com Python há 4 anos, incluindo APIs REST e geração de relatórios PDF.'),
    (v_op1, v_coop_ana,   'pendente',    'Conheço o stack e tenho interesse no projeto. Posso dedicar 40h/semana.'),

    -- op2: 2 candidatos
    (v_op2, v_coop_rafael,  'pendente',  'Flutter é minha principal tecnologia. Já integrei Google Calendar em outros projetos.'),
    (v_op2, v_coop_ana,     'pendente',  'Desenvolvido 3 apps Flutter em produção, incluindo um com agendamentos.'),

    -- op3: candidaturas (1 selecionada para a atribuição)
    (v_op3, v_coop_carlos, 'selecionada','DevOps full-time há 3 anos. GitHub Actions e AWS são meu dia a dia.'),
    (v_op3, v_coop_joao,   'rejeitada',  'Tenho conhecimento básico de Docker, mas prefiro projetos backend.'),

    -- op4: selecionada (já atribuída)
    (v_op4, v_coop_maria,  'selecionada','Design é minha especialidade. Já fiz 2 redesigns para fintechs.'),
    (v_op4, v_coop_ana,    'rejeitada',  'Tenho Figma básico mas foco em desenvolvimento frontend.'),

    -- op5: concluída
    (v_op5, v_coop_pedro,  'selecionada','Power BI é minha ferramenta principal. Entrego dashboards executivos há 2 anos.')
  on conflict (oportunidade_id, cooperado_id) do nothing;

  -- ===========================================================
  -- 6. ATRIBUIÇÕES (op4 e op5)
  -- ===========================================================
  insert into atribuicoes (oportunidade_id, cooperado_id, atribuido_por)
  values
    (v_op4, v_coop_maria, v_coop_admin),
    (v_op5, v_coop_pedro, v_coop_admin)
  on conflict (oportunidade_id, cooperado_id) do nothing;

  -- ===========================================================
  -- 7. COMUNICADOS
  -- ===========================================================
  insert into comunicados (id, cooperative_id, criado_por, titulo, conteudo, tipo, pinned, created_at)
  values
    (v_com1, v_coop_id, v_coop_admin,
     '⚠️ Manutenção programada — Sistema fora do ar domingo',
     'Informamos que o sistema CoopCRM ficará indisponível no domingo, dia 13/04, das 02h às 06h para manutenção preventiva. Planejem suas atividades com antecedência.',
     'urgente', true, now() - interval '1 day'),

    (v_com2, v_coop_id, v_coop_admin,
     'Resultado das candidaturas — Projeto Portal Financeiro',
     'A seleção para o projeto "Redesign de Portal do Cliente" foi concluída. Maria Oliveira foi selecionada para a oportunidade. Parabenizamos todos que se candidataram.',
     'informativo', false, now() - interval '2 days'),

    (v_com3, v_coop_id, v_coop_admin,
     'Novo critério de distribuição de oportunidades',
     'A partir de maio/2026 passaremos a utilizar o critério de rodízio para distribuição de oportunidades técnicas, garantindo equidade entre os cooperados ativos. Mais detalhes na próxima assembleia.',
     'geral', false, now() - interval '5 days'),

    (v_com4, v_coop_id, v_coop_admin,
     'Cotas em atraso — Regularize sua situação',
     'Cooperados com cotas em atraso por mais de 30 dias serão marcados como inadimplentes e não poderão se candidatar a novas oportunidades. Verifique seu status na seção Cotas.',
     'financeiro', false, now() - interval '10 days')
  on conflict (id) do nothing;

  -- Marcar alguns comunicados como lidos
  insert into comunicado_leituras (comunicado_id, cooperado_id)
  values
    (v_com1, v_coop_joao),
    (v_com1, v_coop_maria),
    (v_com2, v_coop_joao),
    (v_com2, v_coop_maria),
    (v_com2, v_coop_pedro),
    (v_com3, v_coop_admin),
    (v_com4, v_coop_admin)
  on conflict do nothing;

  -- ===========================================================
  -- 8. COTAS (últimos 3 meses para todos os cooperados)
  -- ===========================================================
  insert into cotas_pagamentos (cooperative_id, cooperado_id, competencia, valor_devido,
                                 valor_pago, status, data_vencimento, data_pagamento)
  values
    -- Janeiro/2026
    (v_coop_id, v_coop_joao,     '2026-01', 150.00, 150.00, 'pago',      '2026-01-10', '2026-01-08'),
    (v_coop_id, v_coop_maria,    '2026-01', 150.00, 150.00, 'pago',      '2026-01-10', '2026-01-09'),
    (v_coop_id, v_coop_carlos,   '2026-01', 150.00, null,   'em_atraso', '2026-01-10', null),
    (v_coop_id, v_coop_ana,      '2026-01', 150.00, 150.00, 'pago',      '2026-01-10', '2026-01-07'),
    (v_coop_id, v_coop_pedro,    '2026-01', 150.00, 150.00, 'pago',      '2026-01-10', '2026-01-10'),
    (v_coop_id, v_coop_lucia,    '2026-01', 150.00, null,   'em_atraso', '2026-01-10', null),
    (v_coop_id, v_coop_rafael,   '2026-01', 150.00, 150.00, 'pago',      '2026-01-10', '2026-01-06'),
    (v_coop_id, v_coop_fernanda, '2026-01', 150.00, 150.00, 'pago',      '2026-01-10', '2026-01-09'),

    -- Fevereiro/2026
    (v_coop_id, v_coop_joao,     '2026-02', 150.00, 150.00, 'pago',      '2026-02-10', '2026-02-08'),
    (v_coop_id, v_coop_maria,    '2026-02', 150.00, 150.00, 'pago',      '2026-02-10', '2026-02-07'),
    (v_coop_id, v_coop_carlos,   '2026-02', 150.00, null,   'em_atraso', '2026-02-10', null),
    (v_coop_id, v_coop_ana,      '2026-02', 150.00, 150.00, 'pago',      '2026-02-10', '2026-02-10'),
    (v_coop_id, v_coop_pedro,    '2026-02', 150.00, 150.00, 'pago',      '2026-02-10', '2026-02-09'),
    (v_coop_id, v_coop_lucia,    '2026-02', 150.00, null,   'em_atraso', '2026-02-10', null),
    (v_coop_id, v_coop_rafael,   '2026-02', 150.00, 150.00, 'pago',      '2026-02-10', '2026-02-05'),
    (v_coop_id, v_coop_fernanda, '2026-02', 150.00, 80.00,  'pendente',  '2026-02-10', null),

    -- Março/2026
    (v_coop_id, v_coop_joao,     '2026-03', 150.00, 150.00, 'pago',      '2026-03-10', '2026-03-09'),
    (v_coop_id, v_coop_maria,    '2026-03', 150.00, 150.00, 'pago',      '2026-03-10', '2026-03-08'),
    (v_coop_id, v_coop_carlos,   '2026-03', 150.00, null,   'em_atraso', '2026-03-10', null),
    (v_coop_id, v_coop_ana,      '2026-03', 150.00, 150.00, 'pago',      '2026-03-10', '2026-03-07'),
    (v_coop_id, v_coop_pedro,    '2026-03', 150.00, 150.00, 'pago',      '2026-03-10', '2026-03-10'),
    (v_coop_id, v_coop_lucia,    '2026-03', 150.00, null,   'em_atraso', '2026-03-10', null),
    (v_coop_id, v_coop_rafael,   '2026-03', 150.00, 150.00, 'pago',      '2026-03-10', '2026-03-06'),
    (v_coop_id, v_coop_fernanda, '2026-03', 150.00, null,   'pendente',  '2026-03-10', null),

    -- Abril/2026 — mês atual, maioria pendente
    (v_coop_id, v_coop_joao,     '2026-04', 150.00, 150.00, 'pago',      '2026-04-10', '2026-04-05'),
    (v_coop_id, v_coop_maria,    '2026-04', 150.00, null,   'pendente',  '2026-04-10', null),
    (v_coop_id, v_coop_carlos,   '2026-04', 150.00, null,   'em_atraso', '2026-04-10', null),
    (v_coop_id, v_coop_ana,      '2026-04', 150.00, null,   'pendente',  '2026-04-10', null),
    (v_coop_id, v_coop_pedro,    '2026-04', 150.00, null,   'pendente',  '2026-04-10', null),
    (v_coop_id, v_coop_lucia,    '2026-04', 150.00, null,   'em_atraso', '2026-04-10', null),
    (v_coop_id, v_coop_rafael,   '2026-04', 150.00, null,   'pendente',  '2026-04-10', null),
    (v_coop_id, v_coop_fernanda, '2026-04', 150.00, null,   'pendente',  '2026-04-10', null)
  on conflict (cooperative_id, cooperado_id, competencia) do nothing;

  raise notice '✅ Seed CoopCRM concluída.';
  raise notice '   Cooperativa: % (%)', 'CoopTech Regional', v_coop_id;
  raise notice '   Logins disponíveis (senha: CoopCRM@2026):';
  raise notice '     admin@cooptech.com (admin)';
  raise notice '     joao@cooptech.com, maria@cooptech.com, ana@cooptech.com (ativos)';
  raise notice '     carlos@cooptech.com (inadimplente), lucia@cooptech.com (suspenso)';

end;
$$;
