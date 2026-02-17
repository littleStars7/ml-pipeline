provider "aws" {
  region = "us-east-1"
}

# -----------------------
# S3 Buckets
# -----------------------

resource "aws_s3_bucket" "raw" {
  bucket = "my-iot-raw-data-aaxbcr74fvd34oszunx"
}

resource "aws_s3_bucket" "processed" {
  bucket = "my-iot-processed-data-aaxbcr74fvd34oszunx"
}

resource "aws_s3_bucket" "models" {
  bucket = "my-iot-models-aaxbcr74fvd34oszunx"
}

//dummy
resource "aws_s3_object" "aggregated_csv" {
  bucket = aws_s3_bucket.processed.id
  key    = "aggregated/sensor_data.csv"
  source = "../data/sensor_data.csv"  # go up one level, then into data/
}


resource "aws_s3_object" "models_placeholder" {
  bucket = aws_s3_bucket.models.id
  key    = "output/.keep"
  content = ""
}
# -----------------------
# Glue IAM Role
# -----------------------

resource "aws_iam_role" "glue_role" {
  name = "glue-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "glue.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "glue_s3" {
  role       = aws_iam_role.glue_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "glue_basic" {
  role       = aws_iam_role.glue_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

# -----------------------
# Glue Jobs
# -----------------------

resource "aws_glue_job" "job_clean" {
  name     = "glue-job-clean"
  role_arn = aws_iam_role.glue_role.arn

  command {
    name            = "glueetl"
    python_version  = "3"
    script_location = "s3://my-glue-scripts-aaxbcr74fvd34oszunx/glue_job1_clean.py"
  }

  worker_type       = "G.1X"
  number_of_workers = 2
  glue_version      = "4.0"
}

resource "aws_glue_job" "job_agg" {
  name     = "glue-job-agg"
  role_arn = aws_iam_role.glue_role.arn

  command {
    name            = "glueetl"
    python_version  = "3"
    script_location = "s3://my-glue-scripts-aaxbcr74fvd34oszunx/glue_job2_aggregate.py"
  }

  worker_type       = "G.1X"
  number_of_workers = 2
  glue_version      = "4.0"
}

resource "aws_glue_trigger" "trigger_agg" {
  name = "trigger-job-agg"
  type = "CONDITIONAL"

  actions {
    job_name = aws_glue_job.job_agg.name
  }

  predicate {
    conditions {
      job_name = aws_glue_job.job_clean.name
      state    = "SUCCEEDED"
    }
  }
}

##I did training model step in aws concole

# -----------------------
# SageMaker IAM Role
# -----------------------

resource "aws_iam_role" "sagemaker_role" {
  name = "sagemaker-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "sagemaker.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "sagemaker_s3" {
  role       = aws_iam_role.sagemaker_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "sagemaker_basic" {
  role       = aws_iam_role.sagemaker_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"
}


# -----------------------
# SageMaker Deployment (The "Endpoint")
# -----------------------

resource "aws_sagemaker_model" "iot_model" {
  name               = "iot-sensor-model"
  execution_role_arn = aws_iam_role.sagemaker_role.arn

  primary_container {
    image = "382416733822.dkr.ecr.us-east-1.amazonaws.com/linear-learner:latest"
    # Update the timestamp folder below AFTER your first successful training
    model_data_url = "s3://my-iot-model-output/iot-trainingjob-v2/output/model.tar.gz"
  }
}

resource "aws_sagemaker_endpoint_configuration" "iot_config" {
  name = "iot-model-config"
  production_variants {
    variant_name           = "all-traffic"
    model_name            = aws_sagemaker_model.iot_model.name
    initial_instance_count = 1
    instance_type          = "ml.t2.medium" # Smallest available hosting instance
  }
}

resource "aws_sagemaker_endpoint" "iot_endpoint" {
  name                 = "iot-prediction-endpoint"
  endpoint_config_name = aws_sagemaker_endpoint_configuration.iot_config.name
}






