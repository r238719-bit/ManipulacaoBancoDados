# TRABALHO ACADÊMICO - SQLite COM JULIA
println("="^60)
println("TRABALHO: MANIPULAÇÃO DE BANCO DE DADOS COM SQLite E JULIA")
println("="^60)

# 1. CARREGAR PACOTES
println("1. 📦 CARREGANDO PACOTES...")
using SQLite, DataFrames, DBInterface, Dates
println("   ✅ SQLite, DataFrames, DBInterface, Dates")

# 2. CRIAR BANCO DE DADOS
println("2. 🗄️ CRIANDO BANCO DE DADOS...")
db = SQLite.DB("sistema_estudantes.db")
println("   ✅ Banco 'trabalho_academico.db' criado")

# 3. CRIAR TABELA DE ESTUDANTES
println("3. 📊 CRIANDO TABELA DE ESTUDANTES...")
SQLite.execute(db, """
CREATE TABLE IF NOT EXISTS estudantes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL,
    curso TEXT,
    nota REAL,
    data_cadastro TEXT
)
""")
println("   ✅ Tabela 'estudantes' criada")

# 4. INSERIR DADOS
println("4. 📝 INSERINDO DADOS...")
estudantes = [
    ("Ana Silva", "Computação", 8.5, string(now())),
    ("João Santos", "Matemática", 7.2, string(now())),
    ("Maria Oliveira", "Física", 9.1, string(now())),
    ("Pedro Costa", "Computação", 6.8, string(now())),
    ("Carla Lima", "Matemática", 8.9, string(now()))
]

for estudante in estudantes
    SQLite.execute(db, """
    INSERT INTO estudantes (nome, curso, nota, data_cadastro) 
    VALUES (?, ?, ?, ?)
    """, estudante)
end
println("   ✅ ", length(estudantes), " estudantes inseridos")

# 5. CONSULTAS E ANÁLISES
println("5. 🔍 REALIZANDO CONSULTAS...")

println("\n   a) TODOS OS ESTUDANTES:")
todos = DBInterface.execute(db, "SELECT * FROM estudantes")
df_todos = DataFrame(todos)
println(df_todos)

println("\n   b) ESTUDANTES DE COMPUTAÇÃO:")
computacao = DBInterface.execute(db, "SELECT * FROM estudantes WHERE curso = 'Computação'")
df_comp = DataFrame(computacao)
println(df_comp)

println("\n   c) ESTUDANTES COM NOTA > 8.0:")
notas_altas = DBInterface.execute(db, "SELECT nome, curso, nota FROM estudantes WHERE nota > 8.0 ORDER BY nota DESC")
df_notas = DataFrame(notas_altas)
println(df_notas)

println("\n   d) ESTATÍSTICAS POR CURSO:")
estatisticas = DBInterface.execute(db, """
    SELECT 
        curso,
        COUNT(*) as quantidade,
        AVG(nota) as media_nota,
        MAX(nota) as melhor_nota,
        MIN(nota) as menor_nota
    FROM estudantes 
    GROUP BY curso
    ORDER BY media_nota DESC
""")
df_estatisticas = DataFrame(estatisticas)
println(df_estatisticas)

# 6. ATUALIZAR DADOS
println("6. ✏️ ATUALIZANDO DADOS...")
SQLite.execute(db, "UPDATE estudantes SET nota = 7.5 WHERE nome = 'Pedro Costa'")
println("   ✅ Nota do Pedro Costa atualizada")

# 7. EXCLUIR DADOS
println("7. 🗑️ EXCLUINDO DADOS...")
SQLite.execute(db, "DELETE FROM estudantes WHERE nota < 6.0")
println("   ✅ Estudantes com nota baixa removidos")

# 8. CONSULTA FINAL
println("8. 📈 RESULTADO FINAL:")
final = DBInterface.execute(db, "SELECT * FROM estudantes")
df_final = DataFrame(final)
println(df_final)

# 9. RESUMO ESTATÍSTICO
println("9. 📊 RESUMO ESTATÍSTICO:")
total_estudantes = DBInterface.execute(db, "SELECT COUNT(*) as total FROM estudantes")
media_geral = DBInterface.execute(db, "SELECT AVG(nota) as media FROM estudantes")

df_total = DataFrame(total_estudantes)
df_media = DataFrame(media_geral)

println("   📍 Total de estudantes: ", first(df_total).total)
println("   📍 Média geral das notas: ", round(first(df_media).media, digits=2))

# 10. FIM
println("="^60)
println("🎉 TRABALHO CONCLUÍDO COM SUCESSO!")
println("📚 O que foi realizado:")
println("   ✅ Banco de dados SQLite criado")
println("   ✅ Tabela de estudantes com estrutura completa")
println("   ✅ Operações CRUD (Create, Read, Update, Delete)")
println("   ✅ Consultas complexas com agregação")
println("   ✅ Análises estatísticas")
println("="^60)