data "aws_s3_bucket" "existing" {
  count  = var.use_existing_bucket ? 1 : 0
  bucket = var.existing_bucket_name
}

locals {
  bucket_name = var.use_existing_bucket ? var.existing_bucket_name : "${var.project_name}-raw-data"
}

resource "null_resource" "empty_s3_bucket" {
  triggers = {
    bucket_name = local.bucket_name
  }

  provisioner "local-exec" {
    command = "aws s3 rm s3://${local.bucket_name} --recursive"
  }

  depends_on = [aws_s3_bucket.raw_data]
}

resource "aws_s3_bucket" "raw_data" {
  bucket        = "${var.project_name}-raw-data"
  force_destroy = true

  tags = {
    Name        = "${var.project_name}-raw-data"
    Environment = "Dev"
  }

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_s3_bucket_versioning" "raw_data" {
  bucket = aws_s3_bucket.raw_data.id
  versioning_configuration {
    status = "Enabled"
  }

}

resource "aws_s3_bucket_server_side_encryption_configuration" "raw_data" {
  bucket = aws_s3_bucket.raw_data.id

  rule {
    apply_server_side_encryption_by_default {
      # Use AES256 for server-side encryption
      sse_algorithm = "AES256"
    }
  }

}

resource "aws_s3_object" "data_directory" {
  depends_on = [null_resource.empty_s3_bucket]
  bucket     = aws_s3_bucket.raw_data.id
  key        = "data/"
  content    = ""
}

resource "aws_s3_object" "temperature_data" {
  depends_on   = [null_resource.empty_s3_bucket]
  bucket       = aws_s3_bucket.raw_data.id
  key          = "data/temperature_data.csv"
  source       = "./../data/temperature_data.csv"
  content_type = "text/csv"
}

#GLUE
resource "aws_iam_role" "glue_role" {
  name                  = "AWSGlueServiceRole-dml-temperature-analysis"
  force_detach_policies = true
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
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "glue_service_role" {
  role       = aws_iam_role.glue_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_role_policy_attachment" "service_s3_access" {
  role       = aws_iam_role.glue_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

#GLUE RESOURCES
#Databse
resource "aws_glue_catalog_database" "main" {
  name = "dml_temperature-analysis-catalog"

  create_table_default_permission {
    permissions = ["SELECT"]
    principal {
      data_lake_principal_identifier = "IAM_ALLOWED_PRINCIPALS"
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_glue_crawler" "name" {
  name          = "dml-temperature-analysis-crawler"
  database_name = aws_glue_catalog_database.main.name
  role          = aws_iam_role.glue_role.name
  schedule      = "cron(0 1 * * ? *)"

  s3_target {
    path = "s3://${aws_s3_bucket.raw_data.id}/data/"
  }
  schema_change_policy {
    delete_behavior = "LOG"
    update_behavior = "UPDATE_IN_DATABASE"
  }
  recrawl_policy {
    recrawl_behavior = "CRAWL_EVERYTHING"
  }
  lineage_configuration {
    crawler_lineage_settings = "DISABLE"
  }
  lake_formation_configuration {
    use_lake_formation_credentials = false
  }
  configuration = jsonencode({
    Version = 1.0
    Grouping = {
      TableLevelConfiguration = 3
    }
  })

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_s3_bucket.raw_data, aws_s3_object.data_directory, aws_iam_role_policy_attachment.glue_service_role]
}
