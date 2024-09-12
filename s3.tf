resource "random_string" "bucket_suffix" {
  length  = 8
  special = false  
  upper   = false  
}

resource "aws_s3_bucket" "netspi_bucket" {
  bucket = "netspi-${random_string.bucket_suffix.result}"

  tags = {
    Name        = "Net SPI Bucket"
  }
}

resource "aws_s3_bucket_public_access_block" "netspi_access" {
  bucket = aws_s3_bucket.netspi_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "allow_access_from_same_account" {
  bucket = aws_s3_bucket.netspi_bucket.id
  policy = data.aws_iam_policy_document.allow_access_from_same_account.json
}

data "aws_iam_policy_document" "allow_access_from_same_account" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::123456789:root"] 
    }

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.netspi_bucket.arn,        
      "${aws_s3_bucket.netspi_bucket.arn}/*", 
    ]
  }
}

output "aws_s3_bucket_id" {
  value = aws_s3_bucket.netspi_bucket.id
}