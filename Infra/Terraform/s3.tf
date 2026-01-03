resource "random_id" "suffix" {
  byte_length = 4
}

# Ce bucket sera créé par "terraform apply" 

resource "aws_s3_bucket" "audit_reports" {
  bucket = "devsecops-compliance-reports-${var.project_name}" 
  force_destroy = true 

  tags = {
  Description = "DevSecOps scan reports storage"
  Name        = "DevSecOps Compliance Reports"
  Environment = "Dev"
  }
}

# On bloque l'accès public pour la compliance
resource "aws_s3_bucket_public_access_block" "audit_reports_block" {
  bucket = aws_s3_bucket.audit_reports.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket" "ansible_files" {
  bucket = "ansible-files-${random_id.suffix.hex}"
  force_destroy = true  
  tags = {
    Name        = "Ansible files"
    Environment = "Dev"
  }
}

# Required for setting bucket as ObjectWriter 
resource "aws_s3_bucket_ownership_controls" "ansible_files" {
  bucket = aws_s3_bucket.ansible_files.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Optional: Block all public access
resource "aws_s3_bucket_public_access_block" "ansible_files" {
  bucket = aws_s3_bucket.ansible_files.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
resource "aws_s3_object" "ansible_files" {
  depends_on = [ aws_s3_bucket.ansible_files ]

  for_each = {
    for file in fileset("${path.root}/../Ansible", "**") :
    file => file
  }

  bucket = aws_s3_bucket.ansible_files.id
  key    = each.key
  source = "${path.root}/../Ansible/${each.key}"

}