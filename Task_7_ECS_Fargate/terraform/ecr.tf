resource "aws_ecr_repository" "app" {
  name                 = "strapi-app"
  image_tag_mutability = "MUTABLE"

  force_delete = true # For easy cleanup/localstack

  image_scanning_configuration {
    scan_on_push = true
  }
}
