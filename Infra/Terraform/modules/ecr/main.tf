resource "aws_ecr_repository" "app_repo" {
  name                 = "${var.project_name}-repo"
  image_tag_mutability = "MUTABLE"

  # Sécurité : Active le scan basique d'AWS dès qu'une image est poussée
  image_scanning_configuration {
    scan_on_push = true
  }

  # Sécurité : Chiffrement de l'image au repos
  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name = "${var.project_name}-repo"
  }
}

# Optionnel : Politique de nettoyage (Lifecycle Policy)
# Supprime les vieilles images pour ne pas payer de stockage inutilement
resource "aws_ecr_lifecycle_policy" "cleanup" {
  repository = aws_ecr_repository.app_repo.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Garder seulement les 10 dernières images"
      selection = {
        tagStatus     = "any"
        countType     = "imageCountMoreThan"
        countNumber   = 10
      }
      action = {
        type = "expire"
      }
    }]
  })
}