
# 📋 Análise Completa do Projeto Flask - Cake & Cia

**Projeto:** Sistema de Delivery de Cupcakes  
**Aluno:** Edson Galdino Silva  
**RGM:** 24972762  
**Data da Análise:** 11 de Outubro de 2025

---

## 🎯 Visão Geral do Projeto

Este é um **sistema de e-commerce para delivery de cupcakes** chamado **"Cake & Cia"**. O projeto foi desenvolvido como parte de um Projeto Integrador Transdisciplinar em Engenharia de Software I, utilizando Flask (Python) como backend e HTML/CSS/JavaScript para o frontend.

### Finalidade Principal
- Sistema de pedidos online de cupcakes
- Gestão de usuários (clientes e funcionários)
- Processamento de pagamentos (Dinheiro, Cartão de Crédito, PIX)
- Acompanhamento de pedidos

---

## 📁 Estrutura de Arquivos e Pastas

```
edson/
├── app.py                              # Aplicação Flask principal
├── index.html                          # Página inicial com catálogo de cupcakes
├── cadastro.html                       # Formulário de cadastro de usuários
├── login.html                          # Login de clientes
├── login-funcionario.html              # Login de funcionários
├── pagamento.html                      # Página de seleção de método de pagamento
├── pedido-concluido.html               # Confirmação de pedido
├── recebimento-pedido.html             # Visualização de pedido (funcionários)
├── der.jpg                             # Diagrama Entidade-Relacionamento (1290x775px)
├── PIC_atividade_engenharia_software_I.docx 2.docx  # Documentação do projeto
├── css/
│   ├── style.css                       # Estilos principais
│   ├── login.css                       # Estilos da página de login
│   ├── checkoutstyle.css               # Estilos do cadastro
│   ├── pagamento.css                   # Estilos da página de pagamento
│   └── finalizacao.css                 # Estilos da página de conclusão
├── js/
│   └── script.js                       # Lógica do carrinho de compras
└── images/
    ├── logo.png                        # Logo do Cake & Cia (668x197px)
    ├── qrcode.png                      # QR Code para pagamento PIX (110x110px)
    ├── 01.png até 21.jpg               # Imagens de cupcakes e produtos
    └── 14.png                          # Logo alternativo (286x63px)
```

**Total:** 39 arquivos  
**Tamanho das imagens:** ~13MB

---

## 🍰 Funcionalidades Implementadas

### 1. **Catálogo de Produtos (index.html)**
Exibição de 5 tipos de cupcakes:

| Produto | Preço | Imagem |
|---------|-------|--------|
| Cupcake de Morango | R$ 8,99 | 04.jpg |
| Cupcake de Chocolate | R$ 8,99 | 03.jpg |
| Cupcake de Baunilha | R$ 7,99 | 11.jpg |
| Cupcake de Caramelo | R$ 7,99 | 15.jpg |
| Cupcake de Doce de Leite | R$ 7,99 | 16.jpg |

**Funcionalidades:**
- Seleção de quantidade (1-24 unidades)
- Adição ao carrinho
- Resumo do pedido em tempo real
- Cálculo automático do total
- Botão "Finalizar Pedido" (redireciona para login)
- Botão "Remover Item"

### 2. **Sistema de Autenticação**

#### Login de Clientes (login.html)
- Campos: Usuário e Senha
- Login hardcoded: `admin/admin` → redireciona para `pagamento.html`
- Links: "Esqueceu a senha" e "Criar conta"

#### Login de Funcionários (login-funcionario.html)
- Campos: Username e Password
- Credenciais hardcoded: `user/password` → redireciona para `recebimento-pedido.html`
- Interface separada com estilos próprios

#### Cadastro de Usuários (cadastro.html)
Formulário completo com:
- Nome Completo
- E-mail
- Nome de Usuário
- Senha e Confirmação de Senha
- Data de Nascimento
- CPF
- Endereço completo (Rua, Número, Bairro, Complemento)
- Cidade
- Estado (dropdown com todos os estados brasileiros)
- CEP
- Celular com DDD

**Nota:** Atualmente usa cookies para armazenamento (inseguro)

### 3. **Processamento de Pagamento (pagamento.html)**

Três métodos de pagamento:
1. **Dinheiro** - Pagamento na entrega
2. **Cartão de Crédito** - Formulário com:
   - Número do Cartão
   - Nome do Titular
   - Data de Expiração
   - CVV
3. **PIX** - Exibe QR Code (qrcode.png)

**Fluxo:** Após seleção e confirmação → redireciona para `pedido-concluido.html`

### 4. **Confirmação de Pedido (pedido-concluido.html)**
- Mensagem de sucesso: "PEDIDO FINALIZADO!"
- Informação: "Aguarde a entrega do seu produto."

### 5. **Gestão de Pedidos - Funcionários (recebimento-pedido.html)**
Exibe detalhes do pedido:
- Nome do Cliente (hardcoded: "João da Silva")
- Endereço de Entrega
- Lista de itens do pedido

---

## 🔧 Análise do Código Backend (Flask)

### app.py - Estrutura

```python
# Dependências
- Flask (framework web)
- sqlite3 (banco de dados)
- hashlib (criptografia de senhas)
- os (operações do sistema)

# Configurações
DATABASE = 'database.db'
SECRET_KEY = 'your_secret_key'  # ⚠️ Inseguro - precisa ser alterado
```

### Rotas API Implementadas

#### 1. POST /register
**Função:** Cadastro de novos usuários

**Payload Esperado:**
```json
{
  "username": "string",
  "email": "string",
  "password": "string"
}
```

**Segurança:**
- Hash de senha usando PBKDF2-HMAC-SHA512
- Salt aleatório de 60 bytes
- 100.000 iterações

**Resposta:**
- Sucesso: `201 - {"message": "Usuário registrado com sucesso!"}`
- Erro: `400 - {"error": "mensagem de erro"}`

#### 2. POST /login
**Função:** Autenticação de usuários

**Payload Esperado:**
```json
{
  "username": "string",
  "password": "string"
}
```

**Resposta:**
- Sucesso: `200 - {"message": "Login bem-sucedido!"}`
- Erro: `401 - {"error": "Credenciais inválidas"}`

### Funções de Banco de Dados

```python
connect_db()     # Conecta ao SQLite
get_db()         # Obtém conexão do contexto g
init_db()        # Inicializa DB a partir de schema.sql
close_db()       # Fecha conexão no teardown
```

### Segurança de Senhas

```python
hash_password(password)                        # Gera hash seguro
verify_password(stored_password, provided)     # Verifica senha
```

**Algoritmo:** PBKDF2-HMAC com SHA-512, 100.000 iterações

---

## 🗄️ Banco de Dados

### Status Atual
⚠️ **Banco de dados SQLite NÃO existe no projeto**

O código Python referencia:
- `database.db` (não encontrado)
- `schema.sql` (não encontrado)

### Estrutura Esperada (baseada no código)

#### Tabela: `users`
```sql
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT UNIQUE NOT NULL,
    email TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL  -- Hash PBKDF2
);
```

### Estrutura Necessária para Migração (baseada na análise)

Para o sistema completo, serão necessárias as seguintes tabelas:

#### 1. **users** (Usuários/Clientes)
```sql
id, username, email, password_hash, full_name, 
birth_date, cpf, phone, created_at
```

#### 2. **addresses** (Endereços)
```sql
id, user_id, street, number, neighborhood, 
complement, city, state, zipcode, is_default
```

#### 3. **products** (Produtos/Cupcakes)
```sql
id, name, description, price, image_url, 
category, is_available, created_at
```

#### 4. **orders** (Pedidos)
```sql
id, user_id, address_id, total_amount, 
payment_method, payment_status, order_status, 
created_at, delivered_at
```

#### 5. **order_items** (Itens do Pedido)
```sql
id, order_id, product_id, quantity, 
unit_price, subtotal
```

#### 6. **employees** (Funcionários)
```sql
id, username, password_hash, full_name, 
role, created_at
```

#### 7. **payments** (Pagamentos)
```sql
id, order_id, payment_method, amount, 
status, transaction_id, paid_at
```

---

## 🎨 Design e Interface

### Paleta de Cores Principal

| Cor | Código Hex | Uso |
|-----|------------|-----|
| Verde Menta | `#a1dbc7` | Background principal, botões |
| Verde Claro | `#b4eb99` | Botões, hover effects |
| Azul Pastel | `#b0c2eb` | Títulos, formulários |
| Rosa | `#d9a6ca` | Subtítulos |
| Rosa Escuro | `#eb6890` | Destaques |
| Roxo | `#bb6cf0` | Texto de botões |
| Rosa Bebê | `#ebbfde` | Background login |
| Azul Claro | `#93c5e6` | Resumo pedido, finalização |
| Bege | `#fef7ee` | Backgrounds de seções |
| Lilás | `#a4a0da` | Textos de confirmação |

### Tipografia
- **Fonte Principal:** Arial, sans-serif
- **Tamanhos:**
  - H1: Padrão (títulos)
  - H2: 30px-60px (dependendo da página)
  - H3: Padrão
  - Parágrafos: 35px (em confirmações)
  - Botões: 16px-18px

### Layout e Responsividade
- Design responsivo com media query: `max-width: 800px`
- Layout flexbox para catálogo de produtos
- Grid/Flexbox para formulários

### Imagens

#### Logo
- **Principal:** `logo.png` (668x197px, 18KB)
- **Alternativo:** `14.png` (286x63px, 11KB)

#### Fotos de Produtos (23 imagens, ~13MB total)
- Formatos: JPEG (maioria) e PNG
- Resoluções: 2000x3000 até 5142x7709 pixels
- Alta qualidade, apropriadas para e-commerce

#### Recursos
- **QR Code PIX:** `qrcode.png` (110x110px, 8KB)

---

## 💻 JavaScript (script.js)

### Funcionalidades Implementadas

#### 1. Array de Produtos
```javascript
const cupcakes = [
    { name: "Cupcake de Morango", price: 8.99 },
    { name: "Cupcake de Chocolate", price: 8.99 },
    { name: "Cupcake de Baunilha", price: 7.99 },
    { name: "Cupcake de Caramelo", price: 7.99 },
    { name: "Cupcake de Doce de Leite", price: 7.99 }
];
```

#### 2. Event Listeners
- **DOMContentLoaded:** Inicializa a aplicação
- **Botões "Pedir":** Adiciona item ao carrinho
- **Botão "Finalizar Pedido":** Limpa carrinho e redireciona para login

#### 3. Carrinho de Compras
- Adiciona itens dinamicamente na lista
- Calcula total automaticamente
- Atualiza em tempo real
- Limpa ao finalizar

#### 4. Limitações Atuais
- Não usa quantidade selecionada no input
- Não persiste carrinho (sem localStorage)
- Não remove itens individualmente
- Não há controle de estoque

---

## 📊 Análise de Requisitos (do Documento)

### História de Usuário Principal (DVC-001)
**Título:** Pedido de Delivery de Cupcake

### Critérios de Aceitação
1. ✅ Qualidade dos Cupcakes (imagens de alta qualidade)
2. ✅ Embalagem Adequada (mencionado na descrição)
3. ⚠️ Tempo de Entrega (não implementado rastreamento)
4. ⚠️ Atendimento ao Cliente (sem chat/suporte)
5. ✅ Precisão do Pedido (formulário completo)
6. ⚠️ Condição ao Chegar (não implementado)
7. ⚠️ Opções de Personalização (não implementado)
8. ❌ Política de Devolução (não implementado)

### Requisitos Não-Funcionais

| Requisito | Status | Prioridade |
|-----------|--------|------------|
| Desempenho do Site | ⚠️ Não testado | Alta |
| Segurança dos Dados | ❌ Crítico - Cookies inseguros | Alta |
| Disponibilidade 24/7 | ⚠️ Depende do deploy | Alta |
| Tempo de Entrega Máximo | ❌ Não especificado | Alta |
| Usabilidade | ✅ Interface simples | Média |
| Confiabilidade da Entrega | ❌ Não implementado | Alta |
| Compatibilidade | ⚠️ Básica, sem testes | Média |

### User Stories Documentadas

| ID | História | Pontos | Prioridade | Status |
|----|----------|--------|------------|--------|
| 1 | Login no sistema | 5 | Alta | ✅ Parcial |
| 2 | Adicionar produtos ao catálogo (admin) | 3 | Média | ❌ |
| 3 | Filtrar resultados por categoria | 2 | Alta | ❌ |
| 4 | Notificações por e-mail | 8 | Alta | ❌ |
| 5 | Carrinho e finalização de compra | 5 | Alta | ✅ |
| 7 | Lista de desejos | 4 | Baixa | ❌ |
| 8 | Múltiplos métodos de pagamento | 8 | Alta | ✅ Simulado |

---

## 🔍 Problemas Identificados

### 🔴 Críticos
1. **Banco de dados não existe** - Nenhum arquivo .db ou schema.sql
2. **Senhas hardcoded** - Login usa credenciais fixas em JavaScript
3. **Secret key exposta** - `'your_secret_key'` no código
4. **Dados em cookies** - Armazenamento inseguro
5. **Sem CSRF protection** - APIs REST sem tokens

### 🟡 Importantes
6. **Sem integração frontend-backend** - HTML não chama APIs Flask
7. **Sem validação de dados** - Formulários sem validação
8. **Sem tratamento de erros** - UX pobre em caso de falhas
9. **Imagens muito grandes** - 5MB+ algumas, impacta performance
10. **Sem responsividade completa** - CSS básico

### 🟢 Melhorias
11. **Sem controle de estoque** - Produtos sempre disponíveis
12. **Carrinho não persiste** - Perde ao recarregar
13. **Sem histórico de pedidos** - Cliente não vê pedidos antigos
14. **Sem painel administrativo** - Funcionários têm acesso limitado
15. **Sem testes** - Nenhum teste automatizado

---

## 🎯 Dados para Migração

### Produtos Existentes (5 cupcakes)

```json
[
  {
    "id": 1,
    "name": "Cupcake de Morango",
    "description": "Este cupcake é uma explosão de sabor refrescante de morangos maduros...",
    "price": 8.99,
    "image": "04.jpg",
    "category": "cupcakes"
  },
  {
    "id": 2,
    "name": "Cupcake de Chocolate",
    "description": "O cupcake de chocolate é uma escolha clássica...",
    "price": 8.99,
    "image": "03.jpg",
    "category": "cupcakes"
  },
  {
    "id": 3,
    "name": "Cupcake de Baunilha",
    "description": "Um cupcake de baunilha é uma opção elegante e simples...",
    "price": 7.99,
    "image": "11.jpg",
    "category": "cupcakes"
  },
  {
    "id": 4,
    "name": "Cupcake de Caramelo",
    "description": "O cupcake de caramelo é uma indulgência doce e reconfortante...",
    "price": 7.99,
    "image": "15.jpg",
    "category": "cupcakes"
  },
  {
    "id": 5,
    "name": "Cupcake de Doce de Leite",
    "description": "Este cupcake é uma celebração do doce de leite...",
    "price": 7.99,
    "image": "16.jpg",
    "category": "cupcakes"
  }
]
```

### Usuários de Teste

```json
[
  {
    "username": "admin",
    "password": "admin",
    "role": "customer",
    "full_name": "Administrador Teste"
  },
  {
    "username": "user",
    "password": "password",
    "role": "employee",
    "full_name": "Funcionário Teste"
  },
  {
    "username": "joao_silva",
    "full_name": "João da Silva",
    "address": "Rua da Amostra, 123, Cidade Exemplo",
    "role": "customer"
  }
]
```

### Métodos de Pagamento

```json
[
  { "id": 1, "name": "Dinheiro", "code": "money", "enabled": true },
  { "id": 2, "name": "Cartão de Crédito", "code": "credit-card", "enabled": true },
  { "id": 3, "name": "PIX", "code": "pix", "enabled": true }
]
```

---

## 📦 Recursos Estáticos para Migração

### Imagens a Migrar (23 arquivos)

#### Logos
- `logo.png` (principal)
- `14.png` (alternativo)

#### Produtos
- `03.jpg` - Chocolate
- `04.jpg` - Morango
- `11.jpg` - Baunilha
- `15.jpg` - Caramelo (4.8MB - OTIMIZAR)
- `16.jpg` - Doce de Leite

#### Imagens Extras (não usadas atualmente)
- `01.png`, `02.png`
- `05.jpg` até `10.jpg`
- `12.jpg`, `13.jpg`
- `17.jpg` até `21.jpg`

**Recomendação:** Otimizar todas as imagens para web (reduzir para ~200KB cada)

#### Recursos
- `qrcode.png` - QR Code PIX

#### Documentação
- `der.jpg` - Diagrama ER (guardar para referência)

---

## 🚀 Recomendações para Migração NextJS + PostgreSQL

### 1. Estrutura do Banco PostgreSQL

```sql
-- Criar schema completo baseado nas necessidades identificadas
-- Incluir relacionamentos, índices e constraints
-- Migrar dados dos produtos existentes
-- Criar usuários de teste
```

### 2. Arquitetura NextJS

```
nextjs-cake-cia/
├── app/
│   ├── (auth)/
│   │   ├── login/
│   │   ├── register/
│   │   └── employee-login/
│   ├── (shop)/
│   │   ├── page.tsx              # Catálogo
│   │   ├── cart/
│   │   ├── checkout/
│   │   └── order-confirmation/
│   ├── (dashboard)/
│   │   ├── orders/
│   │   └── products/
│   └── api/
│       ├── auth/
│       ├── products/
│       ├── orders/
│       └── payments/
├── components/
│   ├── ProductCard.tsx
│   ├── Cart.tsx
│   ├── CheckoutForm.tsx
│   └── PaymentSelector.tsx
├── lib/
│   ├── db.ts                     # Prisma/PostgreSQL
│   ├── auth.ts                   # NextAuth.js
│   └── utils.ts
├── public/
│   └── images/                   # Imagens otimizadas
└── prisma/
    └── schema.prisma
```

### 3. Tecnologias Recomendadas

- **Framework:** Next.js 14+ (App Router)
- **Banco de Dados:** PostgreSQL 15+
- **ORM:** Prisma
- **Autenticação:** NextAuth.js v5
- **UI:** Tailwind CSS + shadcn/ui
- **Validação:** Zod
- **Pagamentos:** Stripe (cartão) + PIX API
- **Upload de Imagens:** Cloudinary ou AWS S3
- **Deploy:** Vercel (frontend) + Supabase/Neon (DB)

### 4. Melhorias Essenciais

#### Segurança
- ✅ Implementar JWT ou Sessions seguras
- ✅ HTTPS obrigatório
- ✅ CSRF tokens
- ✅ Rate limiting
- ✅ Sanitização de inputs
- ✅ Bcrypt para senhas (mínimo 12 rounds)

#### Funcionalidades
- ✅ Carrinho persistente (localStorage + DB)
- ✅ Histórico de pedidos
- ✅ Rastreamento de entregas
- ✅ Notificações por email (Resend/SendGrid)
- ✅ Painel administrativo completo
- ✅ Gestão de estoque
- ✅ Sistema de avaliações
- ✅ Lista de desejos

#### Performance
- ✅ Otimizar imagens (Next.js Image)
- ✅ Lazy loading
- ✅ Cache de produtos
- ✅ CDN para assets
- ✅ SSR/ISR para SEO

#### UX/UI
- ✅ Design system consistente
- ✅ Responsividade completa
- ✅ Loading states
- ✅ Error boundaries
- ✅ Validação em tempo real
- ✅ Feedback visual

### 5. Fases de Migração

#### Fase 1: Setup e Infraestrutura
- Criar projeto Next.js
- Configurar PostgreSQL
- Setup Prisma
- Migrar imagens otimizadas

#### Fase 2: Autenticação
- Implementar NextAuth.js
- Criar telas de login/registro
- Separar roles (customer/employee)

#### Fase 3: Catálogo e Produtos
- Criar listagem de produtos
- Migrar dados dos 5 cupcakes
- Implementar carrinho

#### Fase 4: Checkout e Pagamentos
- Formulário de checkout
- Integração de pagamentos
- Confirmação de pedido

#### Fase 5: Dashboard
- Painel de pedidos (clientes)
- Painel de gestão (funcionários)
- Relatórios básicos

#### Fase 6: Polimento
- Testes automatizados
- Otimizações de performance
- Deploy em produção

---

## 📝 Notas Finais

### Pontos Fortes do Projeto Atual
- ✅ Interface limpa e intuitiva
- ✅ Paleta de cores agradável
- ✅ Imagens de produto de alta qualidade
- ✅ Fluxo de compra bem definido
- ✅ Documentação acadêmica completa

### Oportunidades de Melhoria
- ⚠️ Backend Flask está incompleto (sem DB)
- ⚠️ Frontend e backend não se comunicam
- ⚠️ Segurança precisa ser completamente refeita
- ⚠️ Faltam features essenciais de e-commerce
- ⚠️ Sem testes ou CI/CD

### Complexidade da Migração
**Estimativa:** Média-Alta

- **Baixa:** Design já existe, poucas funcionalidades
- **Alta:** Precisa criar backend completo do zero
- **Tempo Estimado:** 40-80 horas (1-2 semanas full-time)

---

## 📚 Arquivos Anexos

1. `RESUMO_PROJETO_FLASK.json` - Dados estruturados em JSON
2. `/home/ubuntu/flask_project_analysis/edson/` - Código fonte completo
3. `der.jpg` - Diagrama Entidade-Relacionamento
4. `PIC_atividade_engenharia_software_I.docx 2.docx` - Documentação original

---

**Análise Realizada por:** DeepAgent (Abacus.AI)  
**Data:** 11 de Outubro de 2025  
**Versão:** 1.0
