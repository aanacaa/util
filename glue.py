import sys
import json
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from awsglue.context import GlueContext
from awsglue.job import Job
from pyspark.context import SparkContext
from pyspark.sql import functions as F
from pyspark.sql.types import StructType, StructField, StringType, TimestampType

# Configuração do Glue Context
args = getResolvedOptions(sys.argv, ['JOB_NAME'])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

# 1. Ler dados do DynamoDB
dynamo_table = "nome_da_tabela_dynamodb"
dyf = glueContext.create_dynamic_frame.from_options(
    connection_type="dynamodb",
    connection_options={
        "tableName": dynamo_table,
        "useScan": True
    }
)

# 2. Converter DynamicFrame para DataFrame para maior flexibilidade
df = dyf.toDF()

# 3. Filtrar apenas os itens com `item = 'contrato'`
df_filtered = df.filter(F.col("item") == "contrato")

# 4. Explodir e transformar os JSONs de detalhes_x e detalhes_y
# Assumindo que as colunas detalhes_x e detalhes_y são armazenadas como JSON strings
schema_x = StructType([
    StructField("cod_identificador", StringType(), True),
    StructField("email", StringType(), True),
    StructField("data_limite", StringType(), True)
])

schema_y = StructType([
    StructField("responsavel", StringType(), True),
    StructField("aprovador", StringType(), True)
])

df_transformed = df_filtered \
    .withColumn("detalhes_x", F.from_json(F.col("detalhes_x"), schema_x)) \
    .withColumn("detalhes_y", F.from_json(F.col("detalhes_y"), schema_y)) \
    .select(
        F.col("item"),
        F.to_date(F.col("data")).alias("data_registro"),
        F.col("detalhes_x.cod_identificador"),
        F.col("detalhes_x.email"),
        F.to_date(F.col("detalhes_x.data_limite")).alias("data_limite"),
        F.col("detalhes_y.responsavel"),
        F.col("detalhes_y.aprovador"),
        F.date_format(F.col("data"), "yyyy-MM-dd").alias("particao")
    )

# 5. Gravar os dados no S3 em formato Parquet com partição ano_mes_dia
output_path = "s3://seu-bucket/caminho-dos-dados/"
df_transformed.write.mode("overwrite").partitionBy("particao").parquet(output_path)

# 6. Criar a tabela catalogada no Glue Data Catalog
glueContext.create_dynamic_frame.from_catalog(
    database="seu_database_glue",
    table_name="tabela_catalogada",
    transformation_ctx="transformando"
)

# Finalizar o job
job.commit()
