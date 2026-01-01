# Ce bucket sera créé par "terraform apply" 

resource "aws_s3_bucket" "audit_reports" {
  bucket = "devsecops-compliance-reports-${var.project_name}" 

  tags = {
    Description = "Stockage des rapports de scan (Trivy, Checkov, etc.)"
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