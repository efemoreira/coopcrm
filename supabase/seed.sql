-- Seed para desenvolvimento local
-- Insere uma cooperativa de teste e um admin

do $$
declare
  v_cooperative_id uuid := gen_random_uuid();
  v_user_id        uuid := gen_random_uuid();
begin
  -- Cooperativa teste
  insert into cooperativas (id, nome, cnpj, plano)
  values (v_cooperative_id, 'CoopTech Regional', '12.345.678/0001-99', 'growth');

  -- Usuário admin será criado via Supabase Auth no dashboard
  -- Após criar o user no dashboard, execute:
  -- insert into cooperados (cooperative_id, user_id, nome, cpf, email, is_admin, num_cota)
  -- values ('<cooperative_id>', '<auth_user_id>', 'Admin CoopTech', '000.000.000-00', 'admin@cooptech.com', true, 1);
  raise notice 'Seed cooperativa: %', v_cooperative_id;
end;
$$;
