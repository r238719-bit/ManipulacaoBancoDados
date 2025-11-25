# 🏦 SISTEMA BANCÁRIO COM SQLite
println("="^60)
println("🏦 SISTEMA BANCÁRIO - SQLite COM JULIA")
println("="^60)

# 1. CARREGAR PACOTES
println("1. 📦 CARREGANDO PACOTES...")
using SQLite, DataFrames, DBInterface, Dates
println("   ✅ SQLite, DataFrames, DBInterface, Dates")

# 2. CRIAR BANCO DE DADOS
println("2. 🗄️ CRIANDO BANCO DE DADOS...")
db = SQLite.DB("sistema_bancario.db")
println("   ✅ Banco 'sistema_bancario.db' criado")

# 3. CRIAR TABELAS RELACIONADAS
println("3. 📊 CRIANDO TABELAS RELACIONADAS...")

SQLite.execute(db, """
CREATE TABLE IF NOT EXISTS clientes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL,
    cpf TEXT UNIQUE,
    data_cadastro TEXT
)
""")

SQLite.execute(db, """
CREATE TABLE IF NOT EXISTS contas (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    cliente_id INTEGER,
    saldo REAL DEFAULT 0.0,
    tipo_conta TEXT,
    data_abertura TEXT,
    FOREIGN KEY(cliente_id) REFERENCES clientes(id)
)
""")

SQLite.execute(db, """
CREATE TABLE IF NOT EXISTS transacoes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    conta_id INTEGER,
    tipo TEXT,
    valor REAL,
    descricao TEXT,
    data_transacao TEXT,
    FOREIGN KEY(conta_id) REFERENCES contas(id)
)
""")
println("   ✅ Tabelas relacionadas criadas")

# 4. INSERIR DADOS FICTÍCIOS
println("4. 📝 INSERINDO DADOS BANCÁRIOS...")

# Clientes
clientes = [
    ("Carlos Silva", "111.222.333-44", string(now())),
    ("Marina Oliveira", "555.666.777-88", string(now())),
    ("Roberto Santos", "999.888.777-66", string(now())),
    ("Fernanda Lima", "444.333.222-11", string(now()))
]

for cliente in clientes
    SQLite.execute(db, "INSERT INTO clientes (nome, cpf, data_cadastro) VALUES (?, ?, ?)", cliente)
end

# Contas bancárias
contas = [
    (1, 1500.0, "Corrente", string(now())),
    (2, 3200.0, "Poupança", string(now())),
    (3, 800.0, "Corrente", string(now())),
    (4, 4500.0, "Investimento", string(now()))
]

for conta in contas
    SQLite.execute(db, "INSERT INTO contas (cliente_id, saldo, tipo_conta, data_abertura) VALUES (?, ?, ?, ?)", conta)
end

println("   ✅ ", length(clientes), " clientes e ", length(contas), " contas inseridos")

# 5. CONSULTAS AVANÇADAS COM JOIN
println("5. 🔍 CONSULTAS BANCÁRIAS AVANÇADAS...")

println("\n   a) CLIENTES COM SUAS CONTAS:")
clientes_contas = DBInterface.execute(db, """
    SELECT 
        c.nome as cliente,
        c.cpf,
        co.tipo_conta,
        co.saldo,
        co.data_abertura
    FROM clientes c
    JOIN contas co ON c.id = co.cliente_id
    ORDER BY co.saldo DESC
""")
df_clientes = DataFrame(clientes_contas)
println(df_clientes)

println("\n   b) SALDOS POR TIPO DE CONTA:")
saldos_tipo = DBInterface.execute(db, """
    SELECT 
        tipo_conta,
        COUNT(*) as quantidade_contas,
        SUM(saldo) as saldo_total,
        AVG(saldo) as saldo_medio,
        MAX(saldo) as maior_saldo
    FROM contas 
    GROUP BY tipo_conta
    ORDER BY saldo_total DESC
""")
df_saldos = DataFrame(saldos_tipo)
println(df_saldos)

println("\n   c) TOP 3 CLIENTES COM MAIOR SALDO:")
top_clientes = DBInterface.execute(db, """
    SELECT 
        c.nome as cliente,
        co.tipo_conta,
        co.saldo
    FROM clientes c
    JOIN contas co ON c.id = co.cliente_id
    ORDER BY co.saldo DESC
    LIMIT 3
""")
df_top = DataFrame(top_clientes)
println(df_top)

# 6. ANÁLISE FINANCEIRA
println("6. 📈 ANÁLISE FINANCEIRA...")

patrimonio = DBInterface.execute(db, """
    SELECT 
        COUNT(DISTINCT c.id) as total_clientes,
        COUNT(co.id) as total_contas,
        SUM(co.saldo) as patrimonio_total,
        AVG(co.saldo) as saldo_medio_geral
    FROM clientes c
    JOIN contas co ON c.id = co.cliente_id
""")
df_patrimonio = DataFrame(patrimonio)
println("   💰 Patrimônio Total do Banco:")
println(df_patrimonio)

# 7. FIM
println("="^60)
println("🎉 SISTEMA BANCÁRIO CONCLUÍDO COM SUCESSO!")
println("📊 O que foi realizado:")
println("   ✅ Banco com 3 tabelas relacionadas")
println("   ✅ Dados fictícios de clientes e contas")
println("   ✅ Consultas com JOIN entre tabelas")
println("   ✅ Análise financeira completa")
println("="^60)