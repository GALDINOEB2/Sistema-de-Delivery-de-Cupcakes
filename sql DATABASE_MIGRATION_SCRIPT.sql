
-- ============================================================================
-- SCRIPT DE MIGRAÇÃO: Flask SQLite → PostgreSQL
-- Projeto: Cake & Cia - Sistema de Delivery de Cupcakes
-- Target: PostgreSQL 15+
-- Data: 2025-10-11
-- ============================================================================

-- Criar extensões necessárias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- 1. TABELA: users (Clientes)
-- ============================================================================
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    uuid UUID DEFAULT uuid_generate_v4() UNIQUE NOT NULL,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    birth_date DATE,
    cpf VARCHAR(14) UNIQUE,
    phone VARCHAR(20),
    email_verified BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP
);

CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_cpf ON users(cpf);
CREATE INDEX idx_users_created_at ON users(created_at);

-- ============================================================================
-- 2. TABELA: addresses (Endereços de Entrega)
-- ============================================================================
CREATE TABLE addresses (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    street VARCHAR(200) NOT NULL,
    number VARCHAR(10) NOT NULL,
    neighborhood VARCHAR(100) NOT NULL,
    complement VARCHAR(100),
    city VARCHAR(100) NOT NULL,
    state VARCHAR(2) NOT NULL,
    zipcode VARCHAR(9) NOT NULL,
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_addresses_user_id ON addresses(user_id);
CREATE INDEX idx_addresses_default ON addresses(user_id, is_default) WHERE is_default = TRUE;

-- ============================================================================
-- 3. TABELA: products (Catálogo de Produtos)
-- ============================================================================
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    slug VARCHAR(100) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    image_url VARCHAR(255),
    category VARCHAR(50),
    stock_quantity INTEGER DEFAULT 0 CHECK (stock_quantity >= 0),
    is_available BOOLEAN DEFAULT TRUE,
    is_featured BOOLEAN DEFAULT FALSE,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_products_category ON products(category);
CREATE INDEX idx_products_available ON products(is_available);
CREATE INDEX idx_products_featured ON products(is_featured);
CREATE INDEX idx_products_slug ON products(slug);

-- ============================================================================
-- 4. TABELA: orders (Pedidos)
-- ============================================================================
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    order_number VARCHAR(20) UNIQUE NOT NULL,
    user_id INTEGER NOT NULL REFERENCES users(id),
    address_id INTEGER NOT NULL REFERENCES addresses(id),
    subtotal DECIMAL(10,2) NOT NULL,
    delivery_fee DECIMAL(10,2) DEFAULT 0.00,
    discount DECIMAL(10,2) DEFAULT 0.00,
    total_amount DECIMAL(10,2) NOT NULL,
    payment_method VARCHAR(20) NOT NULL CHECK (payment_method IN ('money', 'credit-card', 'pix')),
    payment_status VARCHAR(20) DEFAULT 'pending' CHECK (payment_status IN ('pending', 'processing', 'paid', 'failed', 'refunded')),
    order_status VARCHAR(20) DEFAULT 'pending' CHECK (order_status IN ('pending', 'confirmed', 'preparing', 'ready', 'delivering', 'delivered', 'cancelled')),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    confirmed_at TIMESTAMP,
    delivered_at TIMESTAMP,
    cancelled_at TIMESTAMP
);

CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_orders_status ON orders(order_status);
CREATE INDEX idx_orders_payment_status ON orders(payment_status);
CREATE INDEX idx_orders_created_at ON orders(created_at DESC);
CREATE INDEX idx_orders_number ON orders(order_number);

-- ============================================================================
-- 5. TABELA: order_items (Itens dos Pedidos)
-- ============================================================================
CREATE TABLE order_items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES products(id),
    product_name VARCHAR(100) NOT NULL, -- Snapshot do nome
    product_price DECIMAL(10,2) NOT NULL, -- Snapshot do preço
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);

-- ============================================================================
-- 6. TABELA: employees (Funcionários)
-- ============================================================================
CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    uuid UUID DEFAULT uuid_generate_v4() UNIQUE NOT NULL,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    role VARCHAR(50) NOT NULL DEFAULT 'staff' CHECK (role IN ('admin', 'manager', 'staff')),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP
);

CREATE INDEX idx_employees_username ON employees(username);
CREATE INDEX idx_employees_role ON employees(role);
CREATE INDEX idx_employees_active ON employees(is_active);

-- ============================================================================
-- 7. TABELA: payments (Transações de Pagamento)
-- ============================================================================
CREATE TABLE payments (
    id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES orders(id),
    payment_method VARCHAR(20) NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'completed', 'failed', 'refunded')),
    transaction_id VARCHAR(100),
    gateway_response JSONB,
    paid_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_payments_order_id ON payments(order_id);
CREATE INDEX idx_payments_status ON payments(status);
CREATE INDEX idx_payments_transaction_id ON payments(transaction_id);

-- ============================================================================
-- 8. TABELA: order_history (Histórico de Mudanças de Status)
-- ============================================================================
CREATE TABLE order_history (
    id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    old_status VARCHAR(20),
    new_status VARCHAR(20) NOT NULL,
    changed_by_employee_id INTEGER REFERENCES employees(id),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_order_history_order_id ON orders(id);
CREATE INDEX idx_order_history_created_at ON order_history(created_at DESC);

-- ============================================================================
-- 9. TABELA: product_reviews (Avaliações de Produtos)
-- ============================================================================
CREATE TABLE product_reviews (
    id SERIAL PRIMARY KEY,
    product_id INTEGER NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    user_id INTEGER NOT NULL REFERENCES users(id),
    order_id INTEGER REFERENCES orders(id),
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    title VARCHAR(100),
    comment TEXT,
    is_verified_purchase BOOLEAN DEFAULT FALSE,
    is_published BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_reviews_product_id ON product_reviews(product_id);
CREATE INDEX idx_reviews_user_id ON product_reviews(user_id);
CREATE INDEX idx_reviews_rating ON product_reviews(rating);

-- ============================================================================
-- 10. TABELA: wishlists (Lista de Desejos)
-- ============================================================================
CREATE TABLE wishlists (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, product_id)
);

CREATE INDEX idx_wishlists_user_id ON wishlists(user_id);
CREATE INDEX idx_wishlists_product_id ON wishlists(product_id);

-- ============================================================================
-- 11. TABELA: sessions (Sessões de Usuário - para NextAuth)
-- ============================================================================
CREATE TABLE sessions (
    id SERIAL PRIMARY KEY,
    session_token VARCHAR(255) UNIQUE NOT NULL,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    employee_id INTEGER REFERENCES employees(id) ON DELETE CASCADE,
    expires TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_sessions_token ON sessions(session_token);
CREATE INDEX idx_sessions_user_id ON sessions(user_id);
CREATE INDEX idx_sessions_employee_id ON sessions(employee_id);

-- ============================================================================
-- TRIGGERS: updated_at automático
-- ============================================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_addresses_updated_at BEFORE UPDATE ON addresses
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON products
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON orders
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_employees_updated_at BEFORE UPDATE ON employees
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_payments_updated_at BEFORE UPDATE ON payments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_reviews_updated_at BEFORE UPDATE ON product_reviews
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- SEED DATA: Inserir os 5 produtos existentes
-- ============================================================================
INSERT INTO products (slug, name, description, price, image_url, category, stock_quantity, is_available, is_featured, sort_order) VALUES
(
    'cupcake-morango',
    'Cupcake de Morango',
    'Este cupcake é uma explosão de sabor refrescante de morangos maduros. A base do bolo é macia e úmida, e o recheio é feito com um delicioso purê de morango, que adiciona um toque doce e frutado. A cobertura é decorada com um delicado glacê de morango e é coroada com um morango fresco, proporcionando um contraste agridoce que vai fazer sua boca se encher de água.',
    8.99,
    '/images/04.jpg',
    'cupcakes',
    50,
    true,
    true,
    1
),
(
    'cupcake-chocolate',
    'Cupcake de Chocolate',
    'O cupcake de chocolate é uma escolha clássica para os amantes de chocolate. A base do bolo é rica e intensa, com um sabor profundo de cacau. No topo, você encontrará uma generosa camada de ganache de chocolate que derrete na boca, e para finalizar, lascas de chocolate ou confeitos podem ser adicionados para dar um toque extra de textura e sabor.',
    8.99,
    '/images/03.jpg',
    'cupcakes',
    50,
    true,
    true,
    2
),
(
    'cupcake-baunilha',
    'Cupcake de Baunilha',
    'Um cupcake de baunilha é uma opção elegante e simples. A base do bolo é leve e macia, com uma nota suave de baunilha. A cobertura é feita com um cremoso glacê de baunilha que é delicadamente decorado com confeitos coloridos, tornando-o perfeito para qualquer ocasião.',
    7.99,
    '/images/11.jpg',
    'cupcakes',
    50,
    true,
    false,
    3
),
(
    'cupcake-caramelo',
    'Cupcake de Caramelo',
    'O cupcake de caramelo é uma indulgência doce e reconfortante. A base do bolo tem um sabor de caramelo suave, e é recheado com um creme de caramelo pegajoso que flui no centro quando você o morde. A cobertura é generosamente coberta com um glacê de caramelo cremoso e pode ser decorada com flocos de sal marinho para um contraste saboroso.',
    7.99,
    '/images/15.jpg',
    'cupcakes',
    50,
    true,
    false,
    4
),
(
    'cupcake-doce-leite',
    'Cupcake de Doce de Leite',
    'Este cupcake é uma celebração do doce de leite, com uma base de bolo que possui um toque de doçura característico. O recheio é uma camada de doce de leite cremoso que adiciona uma textura rica e um sabor irresistível. A cobertura é coberta com mais doce de leite e pode ser decorada com um toque de canela em pó para realçar os sabores.',
    7.99,
    '/images/16.jpg',
    'cupcakes',
    50,
    true,
    false,
    5
);

-- ============================================================================
-- SEED DATA: Funcionários de teste
-- ============================================================================
-- Senha: "admin123" (use bcrypt no Next.js para gerar hash real)
INSERT INTO employees (username, password_hash, full_name, email, role, is_active) VALUES
('admin', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5PEk3n618KKju', 'Administrador Sistema', 'admin@cakeecia.com', 'admin', true),
('funcionario', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5PEk3n618KKju', 'Funcionário Teste', 'staff@cakeecia.com', 'staff', true);

-- ============================================================================
-- SEED DATA: Usuário cliente de teste
-- ============================================================================
-- Senha: "cliente123"
INSERT INTO users (username, email, password_hash, full_name, birth_date, cpf, phone, email_verified, is_active) VALUES
('joao_silva', 'joao.silva@email.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5PEk3n618KKju', 'João da Silva', '1990-05-15', '123.456.789-00', '(11) 98765-4321', true, true);

-- Endereço do João
INSERT INTO addresses (user_id, street, number, neighborhood, complement, city, state, zipcode, is_default) VALUES
(1, 'Rua da Amostra', '123', 'Centro', 'Apto 45', 'Cidade Exemplo', 'SP', '01234-567', true);

-- ============================================================================
-- VIEWS ÚTEIS
-- ============================================================================

-- View: Resumo de pedidos
CREATE OR REPLACE VIEW vw_orders_summary AS
SELECT 
    o.id,
    o.order_number,
    u.full_name as customer_name,
    u.email as customer_email,
    o.total_amount,
    o.payment_method,
    o.payment_status,
    o.order_status,
    o.created_at,
    o.delivered_at,
    COUNT(oi.id) as total_items,
    SUM(oi.quantity) as total_quantity
FROM orders o
JOIN users u ON o.user_id = u.id
LEFT JOIN order_items oi ON o.id = oi.order_id
GROUP BY o.id, u.full_name, u.email;

-- View: Produtos com média de avaliações
CREATE OR REPLACE VIEW vw_products_with_ratings AS
SELECT 
    p.id,
    p.name,
    p.description,
    p.price,
    p.image_url,
    p.category,
    p.stock_quantity,
    p.is_available,
    COALESCE(AVG(pr.rating), 0) as avg_rating,
    COUNT(pr.id) as review_count
FROM products p
LEFT JOIN product_reviews pr ON p.id = pr.product_id AND pr.is_published = true
GROUP BY p.id;

-- View: Dashboard de vendas
CREATE OR REPLACE VIEW vw_sales_dashboard AS
SELECT 
    COUNT(DISTINCT o.id) as total_orders,
    COUNT(DISTINCT o.user_id) as total_customers,
    SUM(o.total_amount) as total_revenue,
    AVG(o.total_amount) as avg_order_value,
    COUNT(CASE WHEN o.order_status = 'delivered' THEN 1 END) as delivered_orders,
    COUNT(CASE WHEN o.order_status = 'cancelled' THEN 1 END) as cancelled_orders
FROM orders o
WHERE o.created_at >= CURRENT_DATE - INTERVAL '30 days';

-- ============================================================================
-- FUNÇÃO: Gerar número de pedido único
-- ============================================================================
CREATE OR REPLACE FUNCTION generate_order_number() RETURNS TEXT AS $$
DECLARE
    new_number TEXT;
    exists_count INT;
BEGIN
    LOOP
        new_number := 'ORD-' || TO_CHAR(NOW(), 'YYYYMMDD') || '-' || LPAD(FLOOR(RANDOM() * 10000)::TEXT, 4, '0');
        SELECT COUNT(*) INTO exists_count FROM orders WHERE order_number = new_number;
        EXIT WHEN exists_count = 0;
    END LOOP;
    RETURN new_number;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- FUNÇÃO: Atualizar estoque após pedido
-- ============================================================================
CREATE OR REPLACE FUNCTION update_product_stock() RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE products 
        SET stock_quantity = stock_quantity - NEW.quantity 
        WHERE id = NEW.product_id;
    ELSIF TG_OP = 'UPDATE' THEN
        UPDATE products 
        SET stock_quantity = stock_quantity + OLD.quantity - NEW.quantity 
        WHERE id = NEW.product_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE products 
        SET stock_quantity = stock_quantity + OLD.quantity 
        WHERE id = OLD.product_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_stock AFTER INSERT OR UPDATE OR DELETE ON order_items
    FOR EACH ROW EXECUTE FUNCTION update_product_stock();

-- ============================================================================
-- COMENTÁRIOS NAS TABELAS (Documentação)
-- ============================================================================
COMMENT ON TABLE users IS 'Cadastro de clientes do sistema';
COMMENT ON TABLE employees IS 'Cadastro de funcionários (admin, gerentes, atendentes)';
COMMENT ON TABLE products IS 'Catálogo de produtos (cupcakes)';
COMMENT ON TABLE orders IS 'Pedidos realizados pelos clientes';
COMMENT ON TABLE order_items IS 'Itens individuais de cada pedido';
COMMENT ON TABLE addresses IS 'Endereços de entrega dos clientes';
COMMENT ON TABLE payments IS 'Registro de transações de pagamento';
COMMENT ON TABLE order_history IS 'Histórico de mudanças de status dos pedidos';
COMMENT ON TABLE product_reviews IS 'Avaliações e comentários sobre produtos';
COMMENT ON TABLE wishlists IS 'Lista de desejos dos clientes';
COMMENT ON TABLE sessions IS 'Sessões de autenticação (NextAuth.js)';

-- ============================================================================
-- FIM DO SCRIPT
-- ============================================================================

-- Para executar este script:
-- psql -U seu_usuario -d nome_do_banco -f DATABASE_MIGRATION_SCRIPT.sql
