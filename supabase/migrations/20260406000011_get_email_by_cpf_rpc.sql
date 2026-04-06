-- Migration: Função RPC para resolver CPF → email antes do login
-- Executada como SECURITY DEFINER para bypassar RLS
-- (necessário pois a query ocorre antes do usuário estar autenticado)

create or replace function get_email_by_cpf(p_cpf text)
returns text
language plpgsql
security definer
stable
as $$
declare
  v_email text;
  v_stripped text;
begin
  -- Remove máscara se houver (000.000.000-00 → 00000000000)
  v_stripped := regexp_replace(p_cpf, '\D', '', 'g');

  if length(v_stripped) != 11 then
    return null;
  end if;

  select email into v_email
  from cooperados
  where cpf = v_stripped
  limit 1;

  return v_email;
end;
$$;

-- Permite que usuários anônimos chamem a função (necessário para login por CPF)
grant execute on function get_email_by_cpf(text) to anon;
grant execute on function get_email_by_cpf(text) to authenticated;

comment on function get_email_by_cpf(text) is
  'Resolve CPF (com ou sem máscara) para o email do cooperado. SECURITY DEFINER para funcionar antes do login.';
