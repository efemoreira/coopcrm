// Edge Function: criar-cooperado
// Cria um usuário Supabase Auth + cooperado em uma única transação atômica.
// Requer JWT do admin logado (garante que apenas admins chamam).
//
// Body esperado:
//   { cooperativeId, nome, cpf, email, password?, telefone?, especialidades?, dataAdmissao? }
//
// Retorna: { cooperado: CooperadoRow } ou { error: string }
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // 1. Verifica que o chamador é admin usando o cliente com JWT do usuário
    const userClient = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_ANON_KEY")!,
      { global: { headers: { Authorization: req.headers.get("Authorization")! } } }
    );

    const { data: caller, error: callerErr } = await userClient
      .from("cooperados")
      .select("is_admin, cooperative_id")
      .maybeSingle();

    if (callerErr || !caller?.is_admin) {
      return new Response(
        JSON.stringify({ error: "Apenas administradores podem criar cooperados." }),
        { status: 403, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // 2. Parse do body
    const body = await req.json();
    const {
      cooperativeId,
      nome,
      cpf,
      email,
      password,
      telefone,
      especialidades,
      dataAdmissao,
    } = body as {
      cooperativeId: string;
      nome: string;
      cpf: string;
      email: string;
      password?: string;
      telefone?: string;
      especialidades?: string[];
      dataAdmissao?: string;
    };

    if (!cooperativeId || !nome || !cpf || !email) {
      return new Response(
        JSON.stringify({ error: "Campos obrigatórios: cooperativeId, nome, cpf, email." }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Garante que só cria cooperados na cooperativa do admin
    if (cooperativeId !== caller.cooperative_id) {
      return new Response(
        JSON.stringify({ error: "Não é possível criar cooperados em outra cooperativa." }),
        { status: 403, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // 3. Cria o usuário Auth via Admin API (service_role bypassa confirmação de email)
    const adminClient = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    const temporaryPassword = password ?? generateTempPassword();

    const { data: authData, error: authError } = await adminClient.auth.admin.createUser({
      email,
      password: temporaryPassword,
      email_confirm: true,
    });

    if (authError) {
      return new Response(
        JSON.stringify({ error: `Erro ao criar usuário: ${authError.message}` }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // 4. Cria o cooperado vinculado ao auth user
    const { data: cooperado, error: cooperadoErr } = await adminClient
      .from("cooperados")
      .insert({
        cooperative_id: cooperativeId,
        user_id: authData.user.id,
        nome,
        cpf: cpf.replace(/\D/g, ""),
        email,
        telefone: telefone ?? null,
        especialidades: especialidades ?? [],
        data_admissao: dataAdmissao ?? null,
        status: "ativo",
        num_cota: 1,
      })
      .select()
      .single();

    if (cooperadoErr) {
      // Rollback: remove o auth user criado
      await adminClient.auth.admin.deleteUser(authData.user.id);
      return new Response(
        JSON.stringify({ error: `Erro ao criar cooperado: ${cooperadoErr.message}` }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    return new Response(
      JSON.stringify({ cooperado, temporaryPassword }),
      { status: 201, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (e: unknown) {
    const message = e instanceof Error ? e.message : String(e);
    return new Response(
      JSON.stringify({ error: message }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});

function generateTempPassword(): string {
  const chars = "ABCDEFGHJKMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz23456789!@#$";
  let pwd = "";
  for (let i = 0; i < 12; i++) {
    pwd += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return pwd;
}
