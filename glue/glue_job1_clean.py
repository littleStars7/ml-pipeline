from pyspark.sql import SparkSession
from pyspark.sql.functions import col

spark = SparkSession.builder.getOrCreate()

df = spark.read.option("header", "true").csv("s3://my-iot-raw-data-aaxbcr74fvd34oszunx/")

df_clean = df.dropna() \
    .withColumn("temperature", col("temperature").cast("double")) \
    .withColumn("humidity", col("humidity").cast("double"))

df_clean.write.mode("overwrite").parquet(
    "s3://my-iot-processed-data-aaxbcr74fvd34oszunx/clean/"
)
