
import pandas as pd
# Caminho para o arquivo CSV (ajuste conforme sua pasta)
caminho = "C:/Users/crist/Downloads/archive (5)/flights.csv"

# Criar um dicionário acumulador para os resultados
resultados = []


for chunk in pd.read_csv(caminho, chunksize=10000):
    # Selecionar apenas as companhias de interesse
    chunk = chunk[chunk['AIRLINE'].isin(['AA', 'DL', 'UA', 'US'])]
    
    # Remover valores nulos relevantes
    chunk = chunk.dropna(subset=['ARRIVAL_DELAY', 'YEAR', 'MONTH', 'DAY'])
    
    # Criar coluna de atraso > 10 min
    chunk['ATRASADO'] = chunk['ARRIVAL_DELAY'] > 10
    
    # Agrupar por data e companhia
    agrupado = (
        chunk.groupby(['YEAR', 'MONTH', 'DAY', 'AIRLINE'])
             .agg(total_voos=('ARRIVAL_DELAY', 'count'),
                  atrasados=('ATRASADO', 'sum'))
             .reset_index()
    )
    
    # Calcular percentual de atrasos
    agrupado['percentual_atrasados'] = (agrupado['atrasados'] / agrupado['total_voos']) * 100
    
    # Guardar no acumulador
    resultados.append(agrupado)

# Concatenar todos os chunks
if resultados:  # verificar se a lista não está vazia
    df_resultado = pd.concat(resultados)
    
    # Agrupar novamente para consolidar datas repetidas
    df_final = (
        df_resultado.groupby(['YEAR', 'MONTH', 'DAY', 'AIRLINE'])
                    .agg(total_voos=('total_voos', 'sum'),
                         atrasados=('atrasados', 'sum'))
                    .reset_index()
    )

    df_final['percentual_atrasados'] = (df_final['atrasados'] / df_final['total_voos']) * 100


    print(df_final.head())
else:
    print("Nenhum dado encontrado para as companhias filtradas.")


#questão 2:
def getStats(input, pos):
    """
    Calcula estatísticas suficientes de atraso por companhia e dia.
    
    input : DataFrame (chunk do CSV)
    pos   : argumento de posicionamento (não utilizado)
    
    Retorna: DataFrame (tibble) com YEAR, MONTH, DAY, AIRLINE, total_voos, atrasados
    """
    
    # Filtrar apenas as companhias de interesse
    df = input[input['AIRLINE'].isin(['AA', 'DL', 'UA', 'US'])].copy()
    
    # Remover valores faltantes nas colunas de interesse
    df = df.dropna(subset=['ARRIVAL_DELAY', 'YEAR', 'MONTH', 'DAY'])
    
    # Criar coluna indicadora de atraso > 10 minutos
    df['ATRASADO'] = df['ARRIVAL_DELAY'] > 10
    
    # Agrupar por dia e companhia
    agrupado = (
        df.groupby(['YEAR', 'MONTH', 'DAY', 'AIRLINE'])
          .agg(
              total_voos=('ARRIVAL_DELAY', 'count'),
              atrasados=('ATRASADO', 'sum')
          )
          .reset_index()
    )
    
    return agrupado

#questão 3:
# Caminho do arquivo CSV dentro do ZIP (já extraído ou especificar zip path + CSV name)
arquivo = r"C:/Users/crist/Downloads/archive (5)/flights.csv"

# Colunas de interesse
colunas = ['YEAR', 'MONTH', 'DAY', 'AIRLINE', 'ARRIVAL_DELAY']

# Lista para armazenar resultados de cada chunk
resultados = []

# Leitura em chunks de 100.000 registros
for pos, chunk in enumerate(pd.read_csv(arquivo, chunksize=100000, usecols=colunas)):
    # Aplicar a função getStats para o chunk
    stats = getStats(chunk, pos)
    resultados.append(stats)

# Concatenar todos os resultados
df_final = pd.concat(resultados, ignore_index=True)

# Consolidar grupos repetidos (mesmo dia e mesma companhia podem aparecer em vários chunks)
df_final = (
    df_final.groupby(['YEAR', 'MONTH', 'DAY', 'AIRLINE'])
            .agg(total_voos=('total_voos', 'sum'),
                 atrasados=('atrasados', 'sum'))
            .reset_index()
)

# Calcular percentual de atrasos
df_final['percentual_atrasados'] = (df_final['atrasados'] / df_final['total_voos']) * 100

# Visualizar as primeiras linhas
print(df_final.head())

def computeStats(df):
    """
    Recebe um DataFrame com YEAR, MONTH, DAY, AIRLINE, total_voos, atrasados
    e retorna um tibble com:
    - Cia: sigla da companhia aérea
    - Data: formato AAAA-MM-DD
    - Perc: percentual de atraso no intervalo [0,1]
    """
    
    # Consolidar por dia e companhia caso existam múltiplos chunks
    df_agg = (
        df.groupby(['YEAR', 'MONTH', 'DAY', 'AIRLINE'])
          .agg(total_voos=('total_voos', 'sum'),
               atrasados=('atrasados', 'sum'))
          .reset_index()
    )
    
    # Calcular percentual de atraso (0 a 1)
    df_agg['Perc'] = df_agg['atrasados'] / df_agg['total_voos']
    
    # Criar coluna Data no formato AAAA-MM-DD
    df_agg['Data'] = pd.to_datetime(df_agg[['YEAR', 'MONTH', 'DAY']])
    
    # Selecionar apenas as colunas solicitadas e renomear
    df_final = df_agg[['AIRLINE', 'Data', 'Perc']].rename(columns={'AIRLINE': 'Cia'})
    
    return df_final