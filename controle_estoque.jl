# 📦 CONTROLE DE ESTOQUE COM SQLite
println("="^60)
println("📦 SISTEMA DE CONTROLE DE ESTOQUE - SQLite COM JULIA")
println("="^60)

# 1. CARREGAR PACOTES
println("1. 📦 CARREGANDO PACOTES...")
using SQLite, DataFrames, DBInterface, Dates
println("   ✅ SQLite, DataFrames, DBInterface, Dates")

# 2. CRIAR BANCO DE DADOS
println("2. 🗄️ CRIANDO BANCO DE DADOS...")
db = SQLite.DB("controle_estoque.db")
println("   ✅ Banco 'controle_estoque.db' criado")

# 3. CRIAR TABELAS
println("3. 📊 CRIANDO TABELAS...")

SQLite.execute(db, """
CREATE TABLE IF NOT EXISTS categorias (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT UNIQUE
)
""")

SQLite.execute(db, """
CREATE TABLE IF NOT EXISTS produtos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL,
    categoria_id INTEGER,
    preco_custo REAL,
    preco_venda REAL,
    estoque_minimo INTEGER,
    estoque_atual INTEGER,
    data_cadastro TEXT,
    FOREIGN KEY(categoria_id) REFERENCES categorias(id)
)
""")

SQLite.execute(db, """
CREATE TABLE IF NOT EXISTS movimentacoes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    produto_id INTEGER,
    tipo TEXT,
    quantidade INTEGER,
    data_movimentacao TEXT,
    FOREIGN KEY(produto_id) REFERENCES produtos(id)
)
""")
println("   ✅ Tabelas criadas")

# 4. INSERIR DADOS FICTÍCIOS
println("4. 📝 INSERINDO DADOS DE ESTOQUE...")

# Categorias
categorias = ["Eletrônicos", "Móveis", "Livros", "Roupas", "Esportes"]
for cat in categorias
    SQLite.execute(db, "INSERT OR IGNORE INTO categorias (nome) VALUES (?)", [cat])
end

# Produtos
produtos = [
    ("Smartphone Samsung", 1, 800.0, 1200.0, 5, 15, string(now())),
    ("Notebook Dell", 1, 2000.0, 2800.0, 3, 8, string(now())),
    ("Tablet Apple", 1, 1500.0, 2200.0, 4, 12, string(now())),
    ("Sofá 3 lugares", 2, 1500.0, 2200.0, 2, 4, string(now())),
    ("Mesa de Escritório", 2, 800.0, 1200.0, 3, 6, string(now())),
    ("Livro Julia Programming", 3, 50.0, 89.9, 10, 25, string(now())),
    ("Camiseta Básica", 4, 15.0, 29.9, 20, 50, string(now())),
    ("Tênis Esportivo", 5, 120.0, 199.9, 8, 15, string(now()))
]

for prod in produtos
    SQLite.execute(db, """
        INSERT INTO produtos (nome, categoria_id, preco_custo, preco_venda, estoque_minimo, estoque_atual, data_cadastro) 
        VALUES (?, ?, ?, ?, ?, ?, ?)
    """, prod)
end

println("   ✅ ", length(categorias), " categorias e ", length(produtos), " produtos inseridos")

# 5. CONSULTAS E ANÁLISES
println("5. 🔍 ANÁLISES DE ESTOQUE...")

println("\n   a) PRODUTOS POR CATEGORIA:")
produtos_categoria = DBInterface.execute(db, """
    SELECT 
        c.nome as categoria,
        COUNT(p.id) as total_produtos,
        SUM(p.estoque_atual) as estoque_total
    FROM produtos p
    JOIN categorias c ON p.categoria_id = c.id
    GROUP BY c.nome
    ORDER BY estoque_total DESC
""")
df_categorias = DataFrame(produtos_categoria)
println(df_categorias)

println("\n   b) LUCRO POTENCIAL POR CATEGORIA:")
lucro_categorias = DBInterface.execute(db, """
    SELECT 
        c.nome as categoria,
        COUNT(p.id) as total_produtos,
        SUM((p.preco_venda - p.preco_custo) * p.estoque_atual) as lucro_potencial,
        AVG(p.preco_venda - p.preco_custo) as margem_media,
        ROUND(AVG((p.preco_venda - p.preco_custo) / p.preco_custo * 100), 2) as margem_percentual_media
    FROM produtos p
    JOIN categorias c ON p.categoria_id = c.id
    GROUP BY c.nome
    ORDER BY lucro_potencial DESC
""")
df_lucro = DataFrame(lucro_categorias)
println(df_lucro)

println("\n   c) PRODUTOS COM ESTOQUE BAIXO:")
estoque_baixo = DBInterface.execute(db, """
    SELECT 
        p.nome,
        c.nome as categoria,
        p.estoque_atual,
        p.estoque_minimo,
        (p.estoque_atual - p.estoque_minimo) as diferenca
    FROM produtos p
    JOIN categorias c ON p.categoria_id = c.id
    WHERE p.estoque_atual <= p.estoque_minimo + 2
    ORDER BY diferenca ASC
""")
df_baixo = DataFrame(estoque_baixo)
if nrow(df_baixo) > 0
    println("   ⚠️  ATENÇÃO: Produtos com estoque baixo!")
    println(df_baixo)
else
    println("   ✅ Todos os produtos com estoque adequado")
end

println("\n   d) TOP 5 PRODUTOS MAIS LUCRATIVOS:")
top_lucrativos = DBInterface.execute(db, """
    SELECT 
        p.nome,
        c.nome as categoria,
        p.estoque_atual,
        (p.preco_venda - p.preco_custo) as lucro_unitario,
        ((p.preco_venda - p.preco_custo) * p.estoque_atual) as lucro_total
    FROM produtos p
    JOIN categorias c ON p.categoria_id = c.id
    ORDER BY lucro_total DESC
    LIMIT 5
""")
df_top = DataFrame(top_lucrativos)
println(df_top)

# 6. RESUMO GERAL
println("6. 📊 RESUMO GERAL DO ESTOQUE...")

resumo = DBInterface.execute(db, """
    SELECT 
        COUNT(*) as total_produtos,
        SUM(estoque_atual) as total_itens_estoque,
        SUM(preco_custo * estoque_atual) as investimento_total,
        SUM(preco_venda * estoque_atual) as valor_mercado,
        SUM((preco_venda - preco_custo) * estoque_atual) as lucro_potencial_total
    FROM produtos
""")
df_resumo = DataFrame(resumo)
println("   💰 Resumo Financeiro:")
println(df_resumo)

# 7. FIM
println("="^60)
println("🎉 CONTROLE DE ESTOQUE CONCLUÍDO COM SUCESSO!")
println("📈 O que foi realizado:")
println("   ✅ Sistema completo de categorias e produtos")
println("   ✅ Cálculos de lucro e margens")
println("   ✅ Alertas de estoque baixo")
println("   ✅ Análise financeira detalhada")
println("="^60)