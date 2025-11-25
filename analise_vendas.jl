# 📊 ANÁLISE DE VENDAS COM SQLite
println("="^60)
println("📊 SISTEMA DE ANÁLISE DE VENDAS - SQLite COM JULIA")
println("="^60)

# 1. CARREGAR PACOTES
println("1. 📦 CARREGANDO PACOTES...")
using SQLite, DataFrames, DBInterface, Dates, Random
println("   ✅ SQLite, DataFrames, DBInterface, Dates, Random")

# 2. CRIAR BANCO DE DADOS
println("2. 🗄️ CRIANDO BANCO DE DADOS...")
db = SQLite.DB("analise_vendas.db")
println("   ✅ Banco 'analise_vendas.db' criado")

# 3. CRIAR TABELAS
println("3. 📊 CRIANDO TABELAS DE VENDAS...")

SQLite.execute(db, """
CREATE TABLE IF NOT EXISTS vendedores (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL,
    regiao TEXT,
    data_admissao TEXT
)
""")

SQLite.execute(db, """
CREATE TABLE IF NOT EXISTS produtos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL,
    categoria TEXT,
    preco_unitario REAL
)
""")

SQLite.execute(db, """
CREATE TABLE IF NOT EXISTS vendas (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    vendedor_id INTEGER,
    produto_id INTEGER,
    quantidade INTEGER,
    valor_total REAL,
    data_venda TEXT,
    cliente TEXT,
    FOREIGN KEY(vendedor_id) REFERENCES vendedores(id),
    FOREIGN KEY(produto_id) REFERENCES produtos(id)
)
""")
println("   ✅ Tabelas criadas")

# 4. INSERIR DADOS FICTÍCIOS
println("4. 📝 GERANDO DADOS DE VENDAS FICTÍCIOS...")

# Vendedores
vendedores = [
    ("Ana Costa", "Sul", string(now() - Day(365))),
    ("Carlos Lima", "Norte", string(now() - Day(200))),
    ("Mariana Santos", "Sudeste", string(now() - Day(150))),
    ("Roberto Alves", "Nordeste", string(now() - Day(300)))
]

for vendedor in vendedores
    SQLite.execute(db, "INSERT INTO vendedores (nome, regiao, data_admissao) VALUES (?, ?, ?)", vendedor)
end

# Produtos
produtos = [
    ("Notebook Gamer", "Eletrônicos", 3500.0),
    ("Smartphone Premium", "Eletrônicos", 1200.0),
    ("Tablet", "Eletrônicos", 800.0),
    ("Cadeira Ergonômica", "Móveis", 650.0),
    ("Mesa Escritório", "Móveis", 1200.0),
    ("Livro Técnico", "Livros", 89.9),
    ("Headphone", "Acessórios", 250.0)
]

for produto in produtos
    SQLite.execute(db, "INSERT INTO produtos (nome, categoria, preco_unitario) VALUES (?, ?, ?)", produto)
end

# Gerar vendas aleatórias (50 vendas)
Random.seed!(123)  # Para resultados consistentes
vendas_data = []

clientes = ["Empresa A", "Empresa B", "Empresa C", "Cliente Vip", "Cliente Normal", "Startup X"]

for i in 1:50
    vendedor_id = rand(1:4)
    produto_id = rand(1:7)
    quantidade = rand(1:10)
    
    # Buscar preço do produto
    preco_result = DBInterface.execute(db, "SELECT preco_unitario FROM produtos WHERE id = ?", [produto_id])
    preco_unitario = first(DataFrame(preco_result)).preco_unitario
    
    valor_total = round(quantidade * preco_unitario, digits=2)
    data_venda = string(now() - Day(rand(0:90)))  # Vendas dos últimos 3 meses
    cliente = rand(clientes)
    
    push!(vendas_data, (vendedor_id, produto_id, quantidade, valor_total, data_venda, cliente))
end

for venda in vendas_data
    SQLite.execute(db, """
        INSERT INTO vendas (vendedor_id, produto_id, quantidade, valor_total, data_venda, cliente) 
        VALUES (?, ?, ?, ?, ?, ?)
    """, venda)
end

println("   ✅ ", length(vendedores), " vendedores, ", length(produtos), " produtos e ", length(vendas_data), " vendas inseridos")

# 5. ANÁLISES DETALHADAS
println("5. 🔍 ANÁLISES DETALHADAS DE VENDAS...")

println("\n   a) DESEMPENHO POR VENDEDOR:")
desempenho_vendedores = DBInterface.execute(db, """
    SELECT 
        v.nome as vendedor,
        v.regiao,
        COUNT(ve.id) as total_vendas,
        SUM(ve.valor_total) as receita_total,
        AVG(ve.valor_total) as ticket_medio,
        MAX(ve.valor_total) as maior_venda
    FROM vendedores v
    JOIN vendas ve ON v.id = ve.vendedor_id
    GROUP BY v.nome, v.regiao
    ORDER BY receita_total DESC
""")
df_vendedores = DataFrame(desempenho_vendedores)
println(df_vendedores)

println("\n   b) VENDAS POR CATEGORIA DE PRODUTO:")
vendas_categoria = DBInterface.execute(db, """
    SELECT 
        p.categoria,
        COUNT(v.id) as total_vendas,
        SUM(v.quantidade) as total_itens,
        SUM(v.valor_total) as receita_total,
        ROUND(SUM(v.valor_total) * 100.0 / (SELECT SUM(valor_total) FROM vendas), 2) as percentual_receita
    FROM produtos p
    JOIN vendas v ON p.id = v.produto_id
    GROUP BY p.categoria
    ORDER BY receita_total DESC
""")
df_categorias = DataFrame(vendas_categoria)
println(df_categorias)

println("\n   c) TOP 5 PRODUTOS MAIS VENDIDOS:")
top_produtos = DBInterface.execute(db, """
    SELECT 
        p.nome as produto,
        p.categoria,
        SUM(v.quantidade) as total_vendido,
        SUM(v.valor_total) as receita_total,
        COUNT(v.id) as vezes_vendido
    FROM produtos p
    JOIN vendas v ON p.id = v.produto_id
    GROUP BY p.nome, p.categoria
    ORDER BY receita_total DESC
    LIMIT 5
""")
df_top_produtos = DataFrame(top_produtos)
println(df_top_produtos)

println("\n   d) ANÁLISE POR REGIÃO:")
vendas_regiao = DBInterface.execute(db, """
    SELECT 
        v.regiao,
        COUNT(ve.id) as total_vendas,
        SUM(ve.valor_total) as receita_total,
        AVG(ve.valor_total) as ticket_medio_regiao,
        COUNT(DISTINCT ve.cliente) as clientes_unicos
    FROM vendedores v
    JOIN vendas ve ON v.id = ve.vendedor_id
    GROUP BY v.regiao
    ORDER BY receita_total DESC
""")
df_regioes = DataFrame(vendas_regiao)
println(df_regioes)

println("\n   e) CLIENTES MAIS VALIOSOS:")
clientes_top = DBInterface.execute(db, """
    SELECT 
        cliente,
        COUNT(*) as total_compras,
        SUM(valor_total) as total_gasto,
        AVG(valor_total) as ticket_medio,
        MAX(valor_total) as maior_compra
    FROM vendas
    GROUP BY cliente
    HAVING total_compras >= 2
    ORDER BY total_gasto DESC
    LIMIT 5
""")
df_clientes = DataFrame(clientes_top)
println(df_clientes)

# 6. MÉTRICAS GERAIS
println("6. 📈 MÉTRICAS GERAIS DE PERFORMANCE...")

metricas_gerais = DBInterface.execute(db, """
    SELECT 
        COUNT(*) as total_vendas,
        SUM(valor_total) as receita_total,
        AVG(valor_total) as ticket_medio_geral,
        MAX(valor_total) as maior_venda,
        MIN(valor_total) as menor_venda,
        COUNT(DISTINCT cliente) as total_clientes,
        COUNT(DISTINCT vendedor_id) as vendedores_ativos
    FROM vendas
""")
df_metricas = DataFrame(metricas_gerais)
println("   💰 Métricas Gerais:")
println(df_metricas)

# Calcular crescimento (últimos 30 dias vs anteriores)
crescimento = DBInterface.execute(db, """
    WITH ultimos_30_dias AS (
        SELECT SUM(valor_total) as receita_30_dias
        FROM vendas 
        WHERE date(data_venda) >= date('now', '-30 days')
    ),
    anteriores_30_dias AS (
        SELECT SUM(valor_total) as receita_60_30_dias
        FROM vendas 
        WHERE date(data_venda) BETWEEN date('now', '-60 days') AND date('now', '-31 days')
    )
    SELECT 
        u.receita_30_dias,
        a.receita_60_30_dias,
        ROUND((u.receita_30_dias - a.receita_60_30_dias) * 100.0 / a.receita_60_30_dias, 2) as crescimento_percentual
    FROM ultimos_30_dias u, anteriores_30_dias a
""")
df_crescimento = DataFrame(crescimento)
println("\n   📊 Análise de Crescimento (últimos 30 dias):")
println(df_crescimento)

# 7. FIM
println("="^60)
println("🎉 ANÁLISE DE VENDAS CONCLUÍDA COM SUCESSO!")
println("📊 O que foi realizado:")
println("   ✅ Sistema completo de vendas com múltiplas tabelas")
println("   ✅ Análise de desempenho por vendedor e região")
println("   ✅ Segmentação por categoria e produto")
println("   ✅ Identificação de clientes mais valiosos")
println("   ✅ Métricas de crescimento e performance")
println("="^60)