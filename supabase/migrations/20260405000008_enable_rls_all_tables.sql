-- Migration: Habilitar RLS em todas as tabelas de dados
alter table cooperativas       enable row level security;
alter table cooperados         enable row level security;
alter table oportunidades      enable row level security;
alter table candidaturas        enable row level security;
alter table atribuicoes         enable row level security;
alter table comunicados         enable row level security;
alter table comunicado_leituras enable row level security;
alter table cotas_pagamentos    enable row level security;
alter table notifications_log   enable row level security;

comment on table cooperativas is 'RLS habilitado — acesso via políticas abaixo.';
