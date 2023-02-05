import logging
import sys

from pyspark.sql import SparkSession
from pyspark.sql.functions import col, min, max, lit

# Configuracao de logs de aplicacao
logging.basicConfig(stream=sys.stdout)
logger = logging.getLogger('datalake_enem_small_upsert')
logger.setLevel(logging.DEBUG)

# Definicao da Spark Session
spark = (SparkSession.builder.appName("DeltaExercise")
    .config("spark.jars.packages", "io.delta:delta-core_2.12:1.0.0")
    .config("spark.sql.extensions", "io.delta.sql.DeltaSparkSessionExtension")
    .config("spark.sql.catalog.spark_catalog", "org.apache.spark.sql.delta.catalog.DeltaCatalog")
    .getOrCreate()
)


logger.info("Importing delta.tables...")
from delta.tables import *


logger.info("Produzindo novos dados...")
enemnovo = (
    spark.read.format("delta")
    .load("s3://datalake-igti-diego-xpe-tf-producao-615564902404/staging-zone/enem")
)

# Define algumas inscricoes (chaves) que serao alteradas
# inscricoes = [190001595656,
#             190001421546,
#             190001133210,
#             190001199383,
#             190001237802,
#             190001782198,
#             190001421548,
#             190001595657,
#             190001592264,
#             190001592266,
#             190001592265,
#             190001475147,
#             190001867756,
#             190001133211,
#             190001237803,
#             190001493186,
#             190001421547,
#             190001493187,
#             190001210202,
#             190001421549,
#             190001595658,
#             190002037437,
#             190001421550,
#             190001595659,
#             190001421551,
#             190001237804,
#             190001867757,
#             190001184600,
#             190001692704,
#             190001867758,
#             190002037438,
#             190001595660,
#             190001237805,
#             190001705260,
#             190001421552,
#             190001867759,
#             190001595661,
#             190001042834,
#             190001237806,
#             190001595662,
#             190001421553,
#             190001475148,
#             190001421554,
#             190001493188,
#             190002037439,
#             190001421555,
#             190001480442,
#             190001493189,
#             190001705261,
#             190001421556]

inscricoes = [200001057103,
200005623263,
200004631550,
200006500531,
200006021667,
200003978782,
200005196811,
200004510306,
200005523324,
200006285164,
200005508024,
200004071986,
200001171529,
200003662034,
200002667539,
200001132058,
200005727864,
200003368475,
200003538967,
200006019293,
200003079275,
200002100646,
200005035645,
200005623016,
200005190210,
200005049744,
200003532397,
200002980781,
200004338133,
200005359971,
200002380951,
200004514199,
200001477251,
200001768332,
200003386573,
200005849771,
200002909364,
200005783386,
200001599821,
200006764348,
200003421161,
200004496477,
200006336107,
200005191460,
200003663507,
200005545080,
200004738445,
200001432962,
200001116403,
200001165364,
200003524339,
200003656084,
200003456115,
200006583910,
200003061357,
200006286692,
200002641007,
200006044752,
200002489209,
200002665404,
200004044263,
200003736522,
200001135568,
200005430591,
200005859598,
200003757541]


logger.info("Reduz a 50 casos e faz updates internos no municipio de residencia")
enemnovo = enemnovo.where(enemnovo.NU_INSCRICAO.isin(inscricoes))
# enemnovo = enemnovo.withColumn("NO_MUNICIPIO_RESIDENCIA", lit("NOVA CIDADE")).withColumn("CO_MUNICIPIO_RESIDENCIA", lit(10000000))
enemnovo = enemnovo.withColumn("NO_MUNICIPIO_ESC", lit("NOVA CIDADE")).withColumn("CO_MUNICIPIO_ESC", lit(10000000))

logger.info("Pega os dados do Enem velhos na tabela Delta...")
enemvelho = DeltaTable.forPath(spark, "s3://datalake-igti-diego-xpe-tf-producao-615564902404/staging-zone/enem")


logger.info("Realiza o UPSERT...")
(
    enemvelho.alias("old")
    .merge(enemnovo.alias("new"), "old.NU_INSCRICAO = new.NU_INSCRICAO")
    .whenMatchedUpdateAll()
    .whenNotMatchedInsertAll()
    .execute()
)

logger.info("Atualizacao completa! \n\n")

logger.info("Gera manifesto symlink...")
enemvelho.generate("symlink_format_manifest")

logger.info("Manifesto gerado.")