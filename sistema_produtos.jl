# 🏷️ SISTEMA DE PRODUTOS COM SQLite
println("="^50)
println("🏷️ SISTEMA DE PRODUTOS - SQLite COM JULIA")
println("="^50)

using SQLite, DataFrames

println("1. Criando banco...")
db = SQLite.DB("sistema_produtos.db")  # ← AGORA COM ARQUIVO!
println("   ✅ Banco '01_sistema_produtos.db' criado")

println("2. Criando tabela...")
SQLite.execute(db, "CREATE TABLE produtos (id INTEGER, nome TEXT, preco REAL)")
println("   ✅ Tabela criada")

println("3. Inserindo dados...")
SQLite.execute(db, "INSERT INTO produtos VALUES (1, 'Notebook', 2500.0)")
SQLite.execute(db, "INSERT INTO produtos VALUES (2, 'Mouse', 89.9)")
SQLite.execute(db, "INSERT INTO produtos VALUES (3, 'Teclado', 199.9)")
println("   ✅ Dados inseridos")

println("4. Consultando dados...")
resultado = DBInterface.execute(db, "SELECT * FROM produtos")
df = DataFrame(resultado)
println("   ✅ Dados:")
println(df)

println("🎉 FIM DO SISTEMA DE PRODUTOS!")