-- ==========================================
-- Schema: Boca Louca Burguer v1.0
-- Foco: registro de pedidos, clientes,
--       controle de estoque e autenticação
-- ==========================================

-- 1. USUARIOS
-- Usuario único do sistema — só o Caio
-- A senha é um hash gerado pelo Python (werkzeug)
CREATE TABLE usuarios (
    id      INTEGER PRIMARY KEY AUTOINCREMENT,
    usuario TEXT NOT NULL UNIQUE,
    senha   TEXT NOT NULL
);

-- 2. CLIENTES
CREATE TABLE clientes (
    id        INTEGER PRIMARY KEY AUTOINCREMENT,
    nome      TEXT NOT NULL,
    telefone  TEXT,
    endereco  TEXT
);

-- 3. INGREDIENTES
-- unidade: 'un' = unidades, 'g' = gramas,
--          'dose' = 30g de cheddar, 'fatia' = fatias
CREATE TABLE ingredientes (
    id      INTEGER PRIMARY KEY AUTOINCREMENT,
    nome    TEXT NOT NULL UNIQUE,
    unidade TEXT NOT NULL
);

-- 4. ESTOQUE
CREATE TABLE estoque (
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    ingrediente_id INTEGER NOT NULL UNIQUE,
    quantidade     REAL DEFAULT 0,
    qtd_minima     REAL DEFAULT 0,
    atualizado_em  DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ingrediente_id) REFERENCES ingredientes(id)
);

-- 5. PRODUTOS
CREATE TABLE produtos (
    id    INTEGER PRIMARY KEY AUTOINCREMENT,
    nome  TEXT NOT NULL,
    ativo INTEGER DEFAULT 1
);

-- 6. RECEITAS
-- Quanto de cada ingrediente cada produto consome
CREATE TABLE receitas (
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    produto_id     INTEGER NOT NULL,
    ingrediente_id INTEGER NOT NULL,
    quantidade     REAL NOT NULL,
    FOREIGN KEY (produto_id)     REFERENCES produtos(id),
    FOREIGN KEY (ingrediente_id) REFERENCES ingredientes(id)
);

-- 7. PEDIDOS
-- status: 'aberto'     = sendo montado
--         'confirmado' = foi para cozinha, estoque deduzido
--         'cancelado'
CREATE TABLE pedidos (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    cliente_id INTEGER NOT NULL,
    status     TEXT DEFAULT 'aberto',
    criado_em  DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);

-- 8. ITENS_PEDIDO
-- Cada linha da comanda: qual produto e quantas unidades
CREATE TABLE itens_pedido (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    pedido_id  INTEGER NOT NULL,
    produto_id INTEGER NOT NULL,
    quantidade INTEGER NOT NULL,
    FOREIGN KEY (pedido_id)  REFERENCES pedidos(id),
    FOREIGN KEY (produto_id) REFERENCES produtos(id)
);

-- ==========================================
-- DADOS: Ingredientes
-- ==========================================
INSERT INTO ingredientes (nome, unidade) VALUES
    ('pao brioche',           'un'),
    ('pao comum',             'un'),
    ('hamburger bovino 100g', 'un'),
    ('hamburger industrial',  'un'),
    ('cheddar',               'dose'),
    ('bacon fatiado',         'fatia'),
    ('bacon cubos',           'g'),
    ('picles',                'fatia'),
    ('tomate',                'fatia'),
    ('alface',                'folha'),
    ('mussarela empanada',    'g'),
    ('maionese',              'g'),
    ('barbecue',              'g'),
    ('cebola caramelizada',   'g'),
    ('batata frita',          'g');

-- ==========================================
-- DADOS: Estoque inicial zerado
-- antes de começar a operar
-- ==========================================
INSERT INTO estoque (ingrediente_id, quantidade, qtd_minima)
SELECT id, 0, 0 FROM ingredientes;

-- ==========================================
-- DADOS: Produtos do cardápio
-- ==========================================
INSERT INTO produtos (nome) VALUES
    ('Triplo Transtorno'),
    ('Loucura Clássica'),
    ('X-Surto Bacon'),
    ('King Insano'),
    ('Cheddar Insano'),
    ('X-Doido'),
    ('Fritas Individual'),
    ('Fritas Família'),
    ('Fritas Lobotômicas');

-- ==========================================
-- DADOS: Receitas
-- ==========================================

-- Triplo Transtorno: 1 pao brioche, 3 cheddar, 3x hamburger 100g, 30g maionese
INSERT INTO receitas (produto_id, ingrediente_id, quantidade) VALUES
    (1, (SELECT id FROM ingredientes WHERE nome='pao brioche'),           1),
    (1, (SELECT id FROM ingredientes WHERE nome='cheddar'),               3),
    (1, (SELECT id FROM ingredientes WHERE nome='hamburger bovino 100g'), 3),
    (1, (SELECT id FROM ingredientes WHERE nome='maionese'),             30);

-- Loucura Clássica: 1 pao, 4 picles, 1 cheddar, 1 hamburger 100g, 30g maionese
INSERT INTO receitas (produto_id, ingrediente_id, quantidade) VALUES
    (2, (SELECT id FROM ingredientes WHERE nome='pao comum'),             1),
    (2, (SELECT id FROM ingredientes WHERE nome='picles'),                4),
    (2, (SELECT id FROM ingredientes WHERE nome='cheddar'),               1),
    (2, (SELECT id FROM ingredientes WHERE nome='hamburger bovino 100g'), 1),
    (2, (SELECT id FROM ingredientes WHERE nome='maionese'),             30);

-- X-Surto Bacon: 1 pao, 2 bacon fatiado, 2 cheddar, 2 hamburger 100g, 30g barbecue
INSERT INTO receitas (produto_id, ingrediente_id, quantidade) VALUES
    (3, (SELECT id FROM ingredientes WHERE nome='pao comum'),             1),
    (3, (SELECT id FROM ingredientes WHERE nome='bacon fatiado'),         2),
    (3, (SELECT id FROM ingredientes WHERE nome='cheddar'),               2),
    (3, (SELECT id FROM ingredientes WHERE nome='hamburger bovino 100g'), 2),
    (3, (SELECT id FROM ingredientes WHERE nome='barbecue'),             30);

-- King Insano: 1 pao, 1 tomate, 1 alface, 60g maionese,
--             4 picles, 2 hamburger 100g, 80g mussarela
INSERT INTO receitas (produto_id, ingrediente_id, quantidade) VALUES
    (4, (SELECT id FROM ingredientes WHERE nome='pao comum'),             1),
    (4, (SELECT id FROM ingredientes WHERE nome='tomate'),                1),
    (4, (SELECT id FROM ingredientes WHERE nome='alface'),                1),
    (4, (SELECT id FROM ingredientes WHERE nome='maionese'),             60),
    (4, (SELECT id FROM ingredientes WHERE nome='picles'),                4),
    (4, (SELECT id FROM ingredientes WHERE nome='hamburger bovino 100g'), 2),
    (4, (SELECT id FROM ingredientes WHERE nome='mussarela empanada'),   80);

-- Cheddar Insano: 1 pao, 3 cheddar, 30g cebola caramelizada, 1 hamburger 100g
INSERT INTO receitas (produto_id, ingrediente_id, quantidade) VALUES
    (5, (SELECT id FROM ingredientes WHERE nome='pao comum'),             1),
    (5, (SELECT id FROM ingredientes WHERE nome='cheddar'),               3),
    (5, (SELECT id FROM ingredientes WHERE nome='cebola caramelizada'),  30),
    (5, (SELECT id FROM ingredientes WHERE nome='hamburger bovino 100g'), 1);

-- X-Doido: 1 pao, 30g barbecue, 4 picles, 1 hamburger industrial,
--          1 cheddar, 30g maionese
INSERT INTO receitas (produto_id, ingrediente_id, quantidade) VALUES
    (6, (SELECT id FROM ingredientes WHERE nome='pao comum'),            1),
    (6, (SELECT id FROM ingredientes WHERE nome='barbecue'),            30),
    (6, (SELECT id FROM ingredientes WHERE nome='picles'),               4),
    (6, (SELECT id FROM ingredientes WHERE nome='hamburger industrial'), 1),
    (6, (SELECT id FROM ingredientes WHERE nome='cheddar'),              1),
    (6, (SELECT id FROM ingredientes WHERE nome='maionese'),            30);

-- Fritas Individual: 300g batata
INSERT INTO receitas (produto_id, ingrediente_id, quantidade) VALUES
    (7, (SELECT id FROM ingredientes WHERE nome='batata frita'), 300);

-- Fritas Família: 400g batata
INSERT INTO receitas (produto_id, ingrediente_id, quantidade) VALUES
    (8, (SELECT id FROM ingredientes WHERE nome='batata frita'), 400);

-- Fritas Lobotômicas: 400g batata, 50g bacon cubos, 3 cheddar
INSERT INTO receitas (produto_id, ingrediente_id, quantidade) VALUES
    (9, (SELECT id FROM ingredientes WHERE nome='batata frita'),  400),
    (9, (SELECT id FROM ingredientes WHERE nome='bacon cubos'),    50),
    (9, (SELECT id FROM ingredientes WHERE nome='cheddar'),         3);

