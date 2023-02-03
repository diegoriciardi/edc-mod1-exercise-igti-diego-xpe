resource "aws_s3_bucket_object" "job_spark" {
  bucket = aws_s3_bucket.datalake.id
  key    = "emr-code/pyspark/job_spark_from_tf.py"
  acl    = "private"
  source = "../job_spark_from_tf.py"
  etag   = filemd5("../job_spark_from_tf.py")
}

resource "aws_s3_bucket_object" "delta_insert" {
  bucket = aws_s3_bucket.datalake.id
  key    = "emr-code/pyspark/01_delta_spark_insert_from_tf.py"
  acl    = "private"
  source = "../etl/01_delta_spark_insert_from_tf.py"
  etag   = filemd5("../etl/01_delta_spark_insert_from_tf.py")
}

resource "aws_s3_bucket_object" "delta_upsert" {
  bucket = aws_s3_bucket.datalake.id
  key    = "emr-code/pyspark/02_delta_spark_upsert_from_tf.py"
  acl    = "private"
  source = "../etl/02_delta_spark_upsert_from_tf.py"
  etag   = filemd5("../etl/02_delta_spark_upsert_from_tf.py")
}
