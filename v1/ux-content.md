# UX Content & i18n — CoopCRM

> **Criado por:** Diana Design  
> **Data:** 2026-04-05 | **Idiomas:** pt-BR, en-US, es-ES

---

## Estrutura de Namespaces

```
i18n/
├── common.json       — botões, ações globais, erros genéricos
├── auth.json         — login, logout, reset de senha
├── oportunidades.json — todo o módulo de Quadro de Oportunidades
├── candidaturas.json — módulo de candidaturas
├── cooperados.json   — módulo de cadastro e perfil
├── comunicados.json  — módulo de comunicados
├── cotas.json        — módulo de controle de cotas
├── relatorios.json   — módulo de relatórios
├── config.json       — configurações da cooperativa
└── notifications.json — textos de push notifications
```

---

## namespace: `common`

```json
{
  "pt-BR": {
    "actions": {
      "save": "Salvar",
      "saveAsDraft": "Salvar como Rascunho",
      "publish": "Publicar Agora",
      "cancel": "Cancelar",
      "confirm": "Confirmar",
      "edit": "Editar",
      "delete": "Excluir",
      "back": "Voltar",
      "next": "Próximo",
      "search": "Buscar",
      "filter": "Filtrar",
      "export": "Exportar CSV",
      "refresh": "Atualizar",
      "loading": "Carregando...",
      "tryAgain": "Tentar novamente",
      "close": "Fechar",
      "viewAll": "Ver todos"
    },
    "status": {
      "rascunho": "Rascunho",
      "aberta": "Aberta",
      "emCandidatura": "Em Avaliação",
      "atribuida": "Atribuída",
      "emExecucao": "Em Execução",
      "concluida": "Concluída",
      "cancelada": "Cancelada",
      "aguardando": "Aguardando",
      "selecionado": "Selecionado",
      "naoSelecionado": "Não Selecionado",
      "desistiu": "Desistiu"
    },
    "cooperado_status": {
      "ativo": "Ativo",
      "inativo": "Inativo",
      "suspenso": "Suspenso",
      "inadimplente": "Inadimplente"
    },
    "errors": {
      "networkError": "Sem conexão. Verifique sua internet e tente novamente.",
      "serverError": "Algo deu errado no servidor. Tente novamente em alguns instantes.",
      "unauthorized": "Sua sessão expirou. Faça login novamente.",
      "forbidden": "Você não tem permissão para esta ação.",
      "notFound": "Este item não foi encontrado ou foi removido.",
      "validationError": "Verifique os campos em destaque e tente novamente.",
      "conflictError": "Esta informação já existe no sistema."
    },
    "empty_states": {
      "title": "Nada por aqui",
      "subtitle": "Quando houver informações, elas aparecerão aqui."
    },
    "aria": {
      "closeButton": "Fechar",
      "backButton": "Voltar para a tela anterior",
      "menuButton": "Abrir menu de navegação",
      "notificationBell": "Ver notificações",
      "searchInput": "Campo de busca",
      "avatar": "Foto de perfil"
    }
  },
  "en-US": {
    "actions": {
      "save": "Save",
      "saveAsDraft": "Save as Draft",
      "publish": "Publish Now",
      "cancel": "Cancel",
      "confirm": "Confirm",
      "edit": "Edit",
      "delete": "Delete",
      "back": "Back",
      "next": "Next",
      "search": "Search",
      "filter": "Filter",
      "export": "Export CSV",
      "refresh": "Refresh",
      "loading": "Loading...",
      "tryAgain": "Try again",
      "close": "Close",
      "viewAll": "View all"
    },
    "status": {
      "rascunho": "Draft",
      "aberta": "Open",
      "emCandidatura": "Under Review",
      "atribuida": "Assigned",
      "emExecucao": "In Progress",
      "concluida": "Completed",
      "cancelada": "Cancelled",
      "aguardando": "Pending",
      "selecionado": "Selected",
      "naoSelecionado": "Not Selected",
      "desistiu": "Withdrawn"
    },
    "cooperado_status": {
      "ativo": "Active",
      "inativo": "Inactive",
      "suspenso": "Suspended",
      "inadimplente": "Overdue"
    },
    "errors": {
      "networkError": "No connection. Check your internet and try again.",
      "serverError": "Something went wrong. Please try again in a moment.",
      "unauthorized": "Your session has expired. Please sign in again.",
      "forbidden": "You don't have permission to perform this action.",
      "notFound": "This item was not found or has been removed.",
      "validationError": "Please review the highlighted fields and try again.",
      "conflictError": "This information already exists."
    },
    "empty_states": {
      "title": "Nothing here yet",
      "subtitle": "When there's information to show, it will appear here."
    },
    "aria": {
      "closeButton": "Close",
      "backButton": "Go back to previous screen",
      "menuButton": "Open navigation menu",
      "notificationBell": "View notifications",
      "searchInput": "Search field",
      "avatar": "Profile picture"
    }
  },
  "es-ES": {
    "actions": {
      "save": "Guardar",
      "saveAsDraft": "Guardar como Borrador",
      "publish": "Publicar Ahora",
      "cancel": "Cancelar",
      "confirm": "Confirmar",
      "edit": "Editar",
      "delete": "Eliminar",
      "back": "Volver",
      "next": "Siguiente",
      "search": "Buscar",
      "filter": "Filtrar",
      "export": "Exportar CSV",
      "refresh": "Actualizar",
      "loading": "Cargando...",
      "tryAgain": "Intentar de nuevo",
      "close": "Cerrar",
      "viewAll": "Ver todos"
    },
    "status": {
      "rascunho": "Borrador",
      "aberta": "Abierta",
      "emCandidatura": "En Evaluación",
      "atribuida": "Asignada",
      "emExecucao": "En Ejecución",
      "concluida": "Concluida",
      "cancelada": "Cancelada",
      "aguardando": "En Espera",
      "selecionado": "Seleccionado",
      "naoSelecionado": "No Seleccionado",
      "desistiu": "Retirado"
    },
    "cooperado_status": {
      "ativo": "Activo",
      "inativo": "Inactivo",
      "suspenso": "Suspendido",
      "inadimplente": "Con mora"
    },
    "errors": {
      "networkError": "Sin conexión. Verifica tu internet e inténtalo de nuevo.",
      "serverError": "Algo salió mal. Inténtalo de nuevo en unos instantes.",
      "unauthorized": "Tu sesión ha expirado. Inicia sesión de nuevo.",
      "forbidden": "No tienes permiso para esta acción.",
      "notFound": "Este elemento no fue encontrado o fue eliminado.",
      "validationError": "Revisa los campos resaltados e inténtalo de nuevo.",
      "conflictError": "Esta información ya existe en el sistema."
    },
    "empty_states": {
      "title": "Nada por aquí",
      "subtitle": "Cuando haya información, aparecerá aquí."
    },
    "aria": {
      "closeButton": "Cerrar",
      "backButton": "Volver a la pantalla anterior",
      "menuButton": "Abrir menú de navegación",
      "notificationBell": "Ver notificaciones",
      "searchInput": "Campo de búsqueda",
      "avatar": "Foto de perfil"
    }
  }
}
```

---

## namespace: `auth`

```json
{
  "pt-BR": {
    "login": {
      "title": "Entrar na sua conta",
      "subtitle": "Acesse o CoopCRM",
      "cpfOrEmail": "CPF ou E-mail",
      "cpfOrEmailPlaceholder": "000.000.000-00 ou seu@email.com",
      "password": "Senha",
      "passwordPlaceholder": "Sua senha",
      "showPassword": "Mostrar senha",
      "hidePassword": "Ocultar senha",
      "forgotPassword": "Esqueci minha senha",
      "loginButton": "Entrar",
      "loginButtonLoading": "Entrando...",
      "noAccount": "Não tem conta? Fale com o administrador da sua cooperativa.",
      "errors": {
        "invalidCredentials": "CPF/e-mail ou senha incorretos. Tente novamente.",
        "accountBlocked": "Sua conta está bloqueada. Entre em contato com o administrador.",
        "requiredField": "Este campo é obrigatório."
      }
    },
    "forgotPassword": {
      "title": "Redefinir senha",
      "subtitle": "Informe seu e-mail cadastrado e enviaremos as instruções.",
      "email": "E-mail",
      "emailPlaceholder": "seu@email.com",
      "sendButton": "Enviar instruções",
      "success": "Pronto! Verifique seu e-mail — as instruções foram enviadas.",
      "backToLogin": "Voltar ao login"
    }
  },
  "en-US": {
    "login": {
      "title": "Sign in to your account",
      "subtitle": "Access CoopCRM",
      "cpfOrEmail": "CPF or Email",
      "cpfOrEmailPlaceholder": "000.000.000-00 or your@email.com",
      "password": "Password",
      "passwordPlaceholder": "Your password",
      "showPassword": "Show password",
      "hidePassword": "Hide password",
      "forgotPassword": "Forgot my password",
      "loginButton": "Sign In",
      "loginButtonLoading": "Signing in...",
      "noAccount": "No account? Contact your cooperative administrator.",
      "errors": {
        "invalidCredentials": "Incorrect CPF/email or password. Please try again.",
        "accountBlocked": "Your account is blocked. Contact the administrator.",
        "requiredField": "This field is required."
      }
    },
    "forgotPassword": {
      "title": "Reset password",
      "subtitle": "Enter your registered email and we'll send you instructions.",
      "email": "Email",
      "emailPlaceholder": "your@email.com",
      "sendButton": "Send instructions",
      "success": "Done! Check your email — instructions have been sent.",
      "backToLogin": "Back to login"
    }
  },
  "es-ES": {
    "login": {
      "title": "Iniciar sesión",
      "subtitle": "Accede a tu CoopCRM",
      "cpfOrEmail": "CPF o Correo",
      "cpfOrEmailPlaceholder": "000.000.000-00 o tu@correo.com",
      "password": "Contraseña",
      "passwordPlaceholder": "Tu contraseña",
      "showPassword": "Mostrar contraseña",
      "hidePassword": "Ocultar contraseña",
      "forgotPassword": "Olvidé mi contraseña",
      "loginButton": "Entrar",
      "loginButtonLoading": "Entrando...",
      "noAccount": "¿Sin cuenta? Contacta al administrador de tu cooperativa.",
      "errors": {
        "invalidCredentials": "CPF/correo o contraseña incorrectos. Inténtalo de nuevo.",
        "accountBlocked": "Tu cuenta está bloqueada. Contacta al administrador.",
        "requiredField": "Este campo es obligatorio."
      }
    }
  }
}
```

---

## namespace: `oportunidades`

```json
{
  "pt-BR": {
    "feed": {
      "title": "Oportunidades",
      "greeting": "Olá, {{name}} 👋",
      "searchPlaceholder": "Buscar por título ou tipo...",
      "badgeNew": "NOVO",
      "vagas": "{{n}} vaga",
      "vagas_plural": "{{n}} vagas",
      "candidatos": "1 cooperado se candidatou",
      "candidatos_plural": "{{n}} cooperados se candidataram",
      "prazo": "Prazo: {{date}} às {{time}}",
      "prazoUrgente": "⚠️ Encerra hoje às {{time}}",
      "empty": {
        "title": "Nenhuma oportunidade por aqui",
        "subtitle": "Quando o administrador publicar uma oportunidade, ela aparecerá aqui.",
        "pullToRefresh": "Deslize para atualizar"
      }
    },
    "detail": {
      "candidatar": "Me Candidatar",
      "interesse": "Tenho Interesse",
      "jaCandidatado": "Você já está candidato",
      "prazoEncerrado": "Prazo encerrado",
      "inadimplenteBlocked": "Regularize sua situação para se candidatar",
      "messagePlaceholder": "Mensagem opcional para o administrador...",
      "messageLabel": "Mensagem (opcional)",
      "candidaturaRegistrada": "Candidatura registrada! Aguarde o resultado.",
      "confirmarAceitacao": "Confirmar Aceitação",
      "declinar": "Declinar",
      "confirmDialog": {
        "title": "Confirmar participação?",
        "body": "Ao confirmar, você está se comprometendo com esta oportunidade. Desistir depois pode afetar sua avaliação.",
        "confirm": "Sim, confirmar",
        "cancel": "Cancelar"
      },
      "declinarDialog": {
        "title": "Declinar oportunidade?",
        "body": "A oportunidade será oferecida ao próximo candidato da fila.",
        "confirm": "Sim, declinar",
        "cancel": "Cancelar"
      }
    },
    "form": {
      "title": "Nova Oportunidade",
      "titleField": "Título *",
      "titlePlaceholder": "Ex: Limpeza pós-obra — Ed. Fortaleza",
      "tipoField": "Tipo *",
      "descricaoField": "Descrição",
      "descricaoPlaceholder": "Detalhe o serviço, endereço, cliente, requisitos especiais...",
      "dataField": "Data / Horário",
      "localField": "Local",
      "localPlaceholder": "Rua das Flores, 123 — Aldeota",
      "valorField": "Valor Estimado (R$)",
      "vagasField": "Nº de Vagas *",
      "requisitosField": "Requisitos",
      "requisitosPlaceholder": "Ex: NR35 válido, experiência em obra",
      "prazoField": "Prazo para Candidatura *",
      "criterioField": "Critério de Seleção *",
      "criterioFifo": "FIFO — Primeiro a chegar",
      "criterioRodizio": "Rodízio — Menor produção no período",
      "criterioManual": "Manual — Escolho manualmente",
      "visibilidadeField": "Visibilidade",
      "visibilidadeTodos": "Todos os cooperados ativos",
      "publishButton": "Publicar Agora",
      "draftButton": "Salvar Rascunho",
      "publishSuccess": "Oportunidade publicada! Cooperados sendo notificados...",
      "draftSuccess": "Rascunho salvo com sucesso.",
      "validation": {
        "titleRequired": "O título é obrigatório.",
        "tipoRequired": "Selecione o tipo da oportunidade.",
        "vagasMin": "O número de vagas deve ser pelo menos 1.",
        "prazoRequired": "Informe o prazo de candidatura.",
        "prazoPast": "O prazo não pode ser no passado.",
        "criterioRequired": "Selecione o critério de seleção."
      }
    },
    "atribuicao": {
      "title": "Candidatos — {{n}} inscrito",
      "title_plural": "Candidatos — {{n}} inscritos",
      "modo": "Modo de atribuição:",
      "modoFifo": "FIFO automático",
      "modoRodizio": "Rodízio",
      "modoManual": "Manual",
      "vagas_restantes": "{{n}} vaga a preencher",
      "vagas_restantes_plural": "{{n}} vagas a preencher",
      "atribuirButton": "Confirmar Atribuição",
      "atribuicaoSuccess": "Atribuição realizada. Notificações enviadas aos candidatos.",
      "conflictWarning": "⚠️ {{name}} já tem um serviço no dia {{date}}. Deseja continuar assim mesmo?",
      "columns": {
        "cooperado": "Cooperado",
        "hora": "Candidatura",
        "producao": "Produção/mês",
        "avaliacao": "Avaliação",
        "acao": "Ação"
      },
      "selectButton": "Selecionar",
      "deselectButton": "Remover"
    }
  },
  "en-US": {
    "feed": {
      "title": "Opportunities",
      "greeting": "Hello, {{name}} 👋",
      "searchPlaceholder": "Search by title or type...",
      "badgeNew": "NEW",
      "vagas": "{{n}} spot",
      "vagas_plural": "{{n}} spots",
      "candidatos": "1 member applied",
      "candidatos_plural": "{{n}} members applied",
      "prazo": "Deadline: {{date}} at {{time}}",
      "prazoUrgente": "⚠️ Closes today at {{time}}",
      "empty": {
        "title": "No opportunities yet",
        "subtitle": "When the admin publishes an opportunity, it will show here.",
        "pullToRefresh": "Pull to refresh"
      }
    },
    "detail": {
      "candidatar": "Apply",
      "interesse": "I'm Interested",
      "jaCandidatado": "Already applied",
      "prazoEncerrado": "Deadline passed",
      "inadimplenteBlocked": "Regularize your account to apply",
      "candidaturaRegistrada": "Application submitted! We'll let you know the result.",
      "confirmarAceitacao": "Confirm Acceptance",
      "declinar": "Decline"
    }
  },
  "es-ES": {
    "feed": {
      "title": "Oportunidades",
      "greeting": "Hola, {{name}} 👋",
      "searchPlaceholder": "Buscar por título o tipo...",
      "badgeNew": "NUEVO",
      "vagas": "{{n}} plaza",
      "vagas_plural": "{{n}} plazas",
      "candidatos": "1 cooperativista se postuló",
      "candidatos_plural": "{{n}} cooperativistas se postularon",
      "prazo": "Plazo: {{date}} a las {{time}}",
      "prazoUrgente": "⚠️ Cierra hoy a las {{time}}",
      "empty": {
        "title": "Sin oportunidades por aquí",
        "subtitle": "Cuando el administrador publique una oportunidad, aparecerá aquí.",
        "pullToRefresh": "Desliza para actualizar"
      }
    },
    "detail": {
      "candidatar": "Postularme",
      "interesse": "Me Interesa",
      "jaCandidatado": "Ya estás postulado",
      "prazoEncerrado": "Plazo cerrado",
      "inadimplenteBlocked": "Regulariza tu situación para postularte",
      "candidaturaRegistrada": "¡Postulación registrada! Espera el resultado.",
      "confirmarAceitacao": "Confirmar Participación",
      "declinar": "Declinar"
    }
  }
}
```

---

## namespace: `notifications`

```json
{
  "pt-BR": {
    "novaOportunidade": {
      "title": "Nova {{tipo}}: {{titulo}}",
      "body": "Prazo: {{prazo}} | Valor: R$ {{valor}}"
    },
    "selecionado": {
      "title": "Parabéns! Você foi selecionado 🎉",
      "body": "{{titulo}} — Confirme sua participação no app."
    },
    "naoSelecionado": {
      "title": "Resultado disponível",
      "body": "A oportunidade '{{titulo}}' foi atribuída. Obrigado por participar!"
    },
    "comunicado": {
      "title": "📢 Aviso da cooperativa",
      "body": "{{titulo}}"
    },
    "cotaVencida": {
      "title": "⚠️ Cota em atraso",
      "body": "Sua cota de {{competencia}} está em atraso. Regularize para se candidatar a oportunidades."
    },
    "confirmacaoNecessaria": {
      "title": "Ação necessária — {{titulo}}",
      "body": "Você foi selecionado! Toque aqui para confirmar ou declinar."
    }
  },
  "en-US": {
    "novaOportunidade": {
      "title": "New {{tipo}}: {{titulo}}",
      "body": "Deadline: {{prazo}} | Rate: R$ {{valor}}"
    },
    "selecionado": {
      "title": "Congratulations! You were selected 🎉",
      "body": "{{titulo}} — Confirm your participation in the app."
    },
    "naoSelecionado": {
      "title": "Result available",
      "body": "The opportunity '{{titulo}}' has been assigned. Thanks for applying!"
    }
  },
  "es-ES": {
    "novaOportunidade": {
      "title": "Nueva {{tipo}}: {{titulo}}",
      "body": "Plazo: {{prazo}} | Valor: R$ {{valor}}"
    },
    "selecionado": {
      "title": "¡Felicitaciones! Fuiste seleccionado 🎉",
      "body": "{{titulo}} — Confirma tu participación en la app."
    },
    "naoSelecionado": {
      "title": "Resultado disponible",
      "body": "La oportunidad '{{titulo}}' fue asignada. ¡Gracias por participar!"
    }
  }
}
```

---

## namespace: `cooperados` (Admin)

```json
{
  "pt-BR": {
    "list": {
      "title": "Cooperados",
      "addButton": "Novo Cooperado",
      "searchPlaceholder": "Buscar por nome ou CPF...",
      "empty": {
        "title": "Nenhum cooperado cadastrado",
        "subtitle": "Clique em 'Novo Cooperado' para começar.",
        "action": "Novo Cooperado"
      },
      "columns": {
        "nome": "Nome",
        "cpf": "CPF",
        "status": "Situação",
        "associacao": "Associado em",
        "producao": "Produção/mês",
        "acoes": "Ações"
      }
    },
    "form": {
      "title": "Novo Cooperado",
      "editTitle": "Editar Cooperado",
      "nome": "Nome completo *",
      "cpf": "CPF *",
      "cpfPlaceholder": "000.000.000-00",
      "email": "E-mail",
      "telefone": "Telefone",
      "telefonePlaceholder": "(85) 99999-9999",
      "especialidades": "Especialidades",
      "especialidadesPlaceholder": "Ex: limpeza, pintura, NR35...",
      "status": "Status",
      "matricula": "Matrícula",
      "dataAssociacao": "Data de Associação",
      "saveButton": "Salvar Cooperado",
      "inviteButton": "Salvar e enviar convite por e-mail",
      "success": "Cooperado cadastrado com sucesso.",
      "editSuccess": "Dados atualizados com sucesso.",
      "validation": {
        "nomeRequired": "O nome é obrigatório.",
        "cpfRequired": "O CPF é obrigatório.",
        "cpfInvalid": "CPF inválido. Informe no formato 000.000.000-00.",
        "cpfDuplicate": "Este CPF já está cadastrado nesta cooperativa."
      }
    },
    "statusActions": {
      "activate": "Ativar cooperado",
      "deactivate": "Desativar cooperado",
      "suspend": "Suspender cooperado",
      "confirmDeactivate": "Desativar {{name}}?",
      "confirmDeactivateBody": "O cooperado perderá acesso ao sistema. Esta ação pode ser revertida.",
      "deactivateSuccess": "Cooperado desativado.",
      "activateSuccess": "Cooperado reativado com sucesso."
    }
  },
  "en-US": {
    "list": {
      "title": "Members",
      "addButton": "New Member",
      "searchPlaceholder": "Search by name or CPF...",
      "empty": {
        "title": "No members registered",
        "subtitle": "Click 'New Member' to get started.",
        "action": "New Member"
      }
    }
  },
  "es-ES": {
    "list": {
      "title": "Cooperativistas",
      "addButton": "Nuevo Cooperativista",
      "searchPlaceholder": "Buscar por nombre o CPF...",
      "empty": {
        "title": "Sin cooperativistas registrados",
        "subtitle": "Haz clic en 'Nuevo Cooperativista' para empezar.",
        "action": "Nuevo Cooperativista"
      }
    }
  }
}
```

---

## namespace: `cotas`

```json
{
  "pt-BR": {
    "dashboard": {
      "title": "Controle de Cotas",
      "adimplentes": "Adimplentes",
      "inadimplentes": "Inadimplentes",
      "aVencer": "A vencer (30 dias)",
      "lancamentoButton": "Registrar Pagamento"
    },
    "lancamento": {
      "title": "Registrar Pagamento de Cota",
      "cooperado": "Cooperado *",
      "competencia": "Competência (mês/ano) *",
      "valor": "Valor (R$) *",
      "dataPagamento": "Data do Pagamento",
      "saveButton": "Registrar",
      "success": "Pagamento registrado. Situação do cooperado atualizada."
    },
    "status": {
      "emDia": "Em dia ✓",
      "atrasada": "Atrasada {{days}} dias",
      "aVencer": "Vence em {{days}} dias"
    },
    "alerts": {
      "bloqueado": "Você está com cota em atraso e não pode se candidatar a oportunidades. Fale com o administrador.",
      "aVencer7dias": "Sua cota vence em 7 dias. Regularize para não perder oportunidades.",
      "aVencer15dias": "Sua cota vence em 15 dias."
    }
  },
  "en-US": {
    "dashboard": {
      "title": "Dues Control",
      "adimplentes": "Up to date",
      "inadimplentes": "Overdue",
      "aVencer": "Due in 30 days"
    }
  },
  "es-ES": {
    "dashboard": {
      "title": "Control de Cuotas",
      "adimplentes": "Al día",
      "inadimplentes": "Con mora",
      "aVencer": "Por vencer (30 días)"
    }
  }
}
```

---

## namespace: `comunicados`

```json
{
  "pt-BR": {
    "feed": {
      "title": "Comunicados",
      "empty": {
        "title": "Nenhum comunicado por aqui",
        "subtitle": "Avisos da cooperativa aparecerão aqui."
      }
    },
    "form": {
      "title": "Novo Comunicado",
      "tituloField": "Título *",
      "tituloPlaceholder": "Ex: Assembleia Geral Ordinária — Aviso",
      "corpoField": "Mensagem *",
      "corpoPlaceholder": "Digite o comunicado aqui...",
      "anexoField": "Anexo (imagem ou PDF, max 5MB)",
      "destinatariosField": "Destinatários",
      "destinatariosTodos": "Todos os cooperados ativos",
      "sendButton": "Enviar Comunicado",
      "success": "Comunicado enviado. Cooperados sendo notificados."
    },
    "badge": {
      "naoLido": "Novo",
      "lido": "Lido"
    }
  },
  "en-US": {
    "feed": {
      "title": "Announcements",
      "empty": {
        "title": "No announcements yet",
        "subtitle": "Cooperative notices will appear here."
      }
    }
  },
  "es-ES": {
    "feed": {
      "title": "Comunicados",
      "empty": {
        "title": "Sin comunicados por aquí",
        "subtitle": "Los avisos de la cooperativa aparecerán aquí."
      }
    }
  }
}
```

---

## namespace: `relatorios`

```json
{
  "pt-BR": {
    "title": "Relatórios para AGO",
    "periodo": "Período",
    "periodoMes": "Mês atual",
    "periodoTrimestre": "Trimestre",
    "periodoAno": "Ano",
    "periodoCustom": "Personalizado",
    "exportCsv": "Exportar CSV",
    "tabs": {
      "producao": "Produção",
      "distribuicao": "Distribuição",
      "inadimplencia": "Inadimplência"
    },
    "producao": {
      "title": "Produção por Cooperado",
      "columns": {
        "nome": "Cooperado",
        "servicos": "Serviços",
        "valorTotal": "Valor Total",
        "avaliacao": "Avaliação"
      },
      "empty": "Nenhum serviço concluído neste período."
    },
    "distribuicao": {
      "title": "Distribuição de Oportunidades",
      "subtitle": "Gráfico de barras — quanto cada cooperado recebeu no período",
      "equilibrioLabel": "Equilíbrio de distribuição: {{pct}}%"
    },
    "inadimplencia": {
      "title": "Cooperados com Cotas em Atraso",
      "columns": {
        "nome": "Cooperado",
        "diasAtraso": "Dias em atraso",
        "valorPendente": "Valor pendente"
      },
      "empty": "Todos os cooperados estão em dia. 🎉"
    }
  },
  "en-US": {
    "title": "Assembly Reports",
    "exportCsv": "Export CSV"
  },
  "es-ES": {
    "title": "Informes para Asamblea",
    "exportCsv": "Exportar CSV"
  }
}
```

---

## namespace: `config`

```json
{
  "pt-BR": {
    "title": "Configurações da Cooperativa",
    "tabs": {
      "geral": "Geral",
      "oportunidades": "Oportunidades",
      "cotas": "Cotas",
      "plano": "Plano"
    },
    "geral": {
      "nome": "Nome da cooperativa *",
      "tipo": "Tipo de cooperativa *",
      "tipos": {
        "trabalho": "Trabalho / TPBS",
        "saude": "Saúde",
        "transporte": "Transporte",
        "educacao": "Educação",
        "agro": "Agropecuária",
        "outro": "Outro"
      },
      "logo": "Logo",
      "logoUpload": "Enviar imagem (PNG, JPG, SVG — max 1MB)"
    },
    "oportunidades": {
      "labelTipo": "Nome do tipo de oportunidade",
      "labelTipoHelper": "Este nome aparecerá em toda a interface. Ex: 'Paciente', 'Rota', 'Turma'.",
      "labelTipoPlaceholder": "Oportunidade",
      "criterioPadrao": "Critério de seleção padrão",
      "periodoApuracao": "Período de apuração"
    },
    "cotas": {
      "valorMensal": "Valor da cota mensal (R$)",
      "diaVencimento": "Dia de vencimento",
      "blockeioApos": "Bloquear candidaturas após quantos dias de atraso"
    },
    "saveButton": "Salvar configurações",
    "saveSuccess": "Configurações salvas com sucesso."
  }
}
```

---

## Notas de Implementação

1. **Interpolação de variáveis:** usar sintaxe `{{variavel}}` (compatível com i18next, ARB Flutter e outros)
2. **Pluralização:** usar chaves `key` e `key_plural` (padrão i18next) — em Flutter usar `intl` package com mensagens pluralizadas
3. **Formato de data/hora:** sempre via `intl` com `DateFormat` localizado — nunca hardcoded em inglês
4. **Formato de moeda:** `NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$ ')` via `intl`
5. **Máscara de CPF:** implementar via `flutter_masked_text2` ou regex `\d{3}\.\d{3}\.\d{3}-\d{2}`
6. **Fontes:** carregar `Inter` offline para funcionamento sem internet (bundle no app)
7. **Direção de texto:** todos os três idiomas são LTR — nenhuma adaptação RTL necessária na v1
