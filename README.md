# LocaTudo 🔑

> Sistema multiplataforma de locação de itens e serviços, com backend em Supabase (PostgreSQL) e autenticação nativa via Google Sign-In.

---

## 📖 Sobre o Projeto

O **LocaTudo** é um aplicativo Flutter que conecta proprietários de equipamentos e serviços a pessoas que precisam alugá-los de forma rápida, segura e sem burocracia.

### Principais Funcionalidades

| Funcionalidade | Status |
|---|---|
| Autenticação por e-mail e senha | ✅ |
| Login com Google (Android/iOS) | ✅ |
| Recuperação de senha | ✅ |
| Listagem e busca de produtos | ✅ |
| Cadastro de produtos para locação | ✅ |
| Gerenciamento de aluguéis (locador/locatário) | ✅ |
| Perfil de usuário | ✅ |

---

## 🛠️ Stack Tecnológica

| Camada | Tecnologia |
|---|---|
| **Frontend** | Flutter 3.x (Android, iOS, Web) |
| **Backend / BaaS** | [Supabase](https://supabase.com) (PostgreSQL + Auth + Storage) |
| **Autenticação** | Supabase Auth + Google Sign-In (`google_sign_in` 7.x) |
| **Estado** | Stateful Widgets + Streams |
| **Variáveis de ambiente** | `flutter_dotenv` |

---

## 🚀 Como Rodar

### Pré-requisitos

- Flutter SDK `>=3.0.0`
- Conta no [Supabase](https://supabase.com)
- Credenciais do Google Cloud Console configuradas (SHA-1 registrado)

### 1. Clone o repositório

```bash
git clone https://github.com/seu-usuario/locatudo.git
cd locatudo
```

### 2. Configure as variáveis de ambiente

Crie um arquivo `.env` na raiz do projeto (nunca commite este arquivo):

```env
SUPABASE_URL=https://seu-projeto.supabase.co
SUPABASE_ANON_KEY=sua_anon_key_aqui
```

> Consulte `.env.example` para ver todas as variáveis necessárias.

### 3. Instale as dependências

```bash
flutter pub get
```

### 4. Configure o Google Sign-In

- Baixe o `google-services.json` do [Firebase Console](https://console.firebase.google.com) e coloque em `android/app/`
- Registre o SHA-1 do seu keystore no Google Cloud Console

### 5. Execute o app

```bash
# Android
flutter run

# Web
flutter run -d chrome
```

---

## 🗄️ Estrutura do Banco de Dados (Supabase)

```
users          → Perfis de usuário (id, name, email, avatar_url, ...)
products       → Anúncios de locação (id, owner_id, title, price, category, ...)
rentings       → Contratos de aluguel (id, product_id, tenant_id, start_date, ...)
```

> O schema completo está em [`supabase_schema.sql`](./supabase_schema.sql).

---

## 📁 Estrutura do Projeto

```
locatudo/
├── lib/
│   ├── main.dart               # Entry point + rotas
│   ├── app_theme.dart          # Design system / tema global
│   ├── screens/                # Telas do app
│   ├── services/               # AuthService, SupabaseService
│   └── repositories/           # Camada de acesso a dados
├── android/
│   └── app/
│       └── google-services.json  ← NÃO commitar
├── .env                          ← NÃO commitar
└── supabase_schema.sql
```

---

## 🔒 Segurança

- As credenciais do Supabase são carregadas via `flutter_dotenv` e **nunca expostas no código-fonte**.
- O acesso ao banco de dados é controlado por **Row Level Security (RLS)** no Supabase.
- O `google-services.json` e arquivos `.keystore` estão listados no `.gitignore`.

---

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.
