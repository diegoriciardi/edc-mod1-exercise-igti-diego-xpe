# comentario para modificar o arquivo .py
from pyspark.sql.functions import mean, max, min, col, count
from pyspark import SparkSession

spark = (
    SparkSession
    .builder
    .appName("ExerciseSparkIAC")
    .getOrCreate()
)

# ler os dados do enem

enem = (
    spark
    .read
    .format("csv")
    .option("header", True)
    .option("inferSchema", True)
    .option("delimiter", ";")
    .load("s3://datalake-igti-diego-xpe-tf-producao-615564902404/raw-data/enem/")
)

(
    enem
    .write
    .mode("overwrite")
    .format("parquet")
    .partitionBy("year")
    .save("s3://datalake-igti-diego-xpe-tf-producao-615564902404/staging/enem")
)