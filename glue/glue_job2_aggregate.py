from pyspark.sql import SparkSession
from pyspark.sql.functions import window, avg, col

spark = SparkSession.builder.getOrCreate()

df = spark.read.parquet("s3://my-iot-processed-data-aaxbcr74fvd34oszunx/clean/")
df = df.withColumn("timestamp", col("timestamp").cast("timestamp"))

agg = df.groupBy(
    window(col("timestamp"), "5 minutes")
).agg(
    avg("temperature").alias("avg_temperature"),
    avg("humidity").alias("avg_humidity")
)

agg.write.mode("overwrite").parquet(
    "s3://my-iot-processed-data-aaxbcr74fvd34oszunx/aggregated/"
)
