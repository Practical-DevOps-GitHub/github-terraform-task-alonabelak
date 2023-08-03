provider "github" {
  token  = var.github_token
  owner = "Practical-DevOps-GitHub"
}

variable "token" {
  type      = string
  sensitive = true
}

variable "github_token" {
   type        = string
   description = "GitHub Personal Access Token"
   sensitive = true
}


variable "repository_name" {
  description = "The name of the repository."
  type        = string
  default     = "github-terraform-task-alonabelak"
}

resource "github_repository_collaborator" "softservedata" {
  repository = var.repository_name
  username   = "softservedata" 
  permission = "admin" 
}

resource "github_branch" "develop" {
  repository    = var.repository_name
  branch        = "develop"
  source_branch = "main"
}
resource "github_branch_default" "this" {
  branch     = "develop"
  repository = var.repository_name
  depends_on = [github_branch.develop]
}

resource "github_branch_protection" "main" {
  pattern       = "main"
  repository_id = var.repository_name
  required_pull_request_reviews {
    require_code_owner_reviews      = true
    required_approving_review_count = 1
  }
}

resource "github_branch_protection" "develop" {
  pattern ="develop"
  repository_id=var.repostiroy_name
  required_pull_request_reviews {
    dismiss_stale_reviews = true
    required_approving_review_count = 2
  }
  enforce_admins = true
}

resource "tls_private_key" "deploy_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "github_repository_deploy_key" "deploy_key" {
  key        = tls_private_key.deploy_key.public_key_openssh
  repository = var.repository_name
  title      = "DEPLOY_KEY"
}
resource "github_repository_file" "pull_request_template" {
  content             = <<EOT
  ## Describe your changes

  ## Issue ticket number and link

  ## Checklist before requesting a review
  - [ ] I have performed a self-review of my code
  - [ ] If it is a core feature, I have added thorough tests
  - [ ] Do we need to implement analytics?
  - [ ] Will this be part of a product update? If yes, please write one phrase about this update
  EOT
  file                = ".github/pull_request_template.md"
  repository          = var.repository_name
  overwrite_on_create = true
  branch              = "main"
}

resource "github_repository_file" "codeowners_main" {
  content             = <<EOT
  * @softservedata
  EOT
  file                = "CODEOWNERS"
  repository          = var.repository_name
  branch              = "main"
  overwrite_on_create = true
}

resource "github_actions_secret" "terraform_secret" {
  repository = "github-terraform-task-alonabelak"  
  secret_name  = "TERRAFORM"
  value      = base64encode(file("main.tf"))
}
resource "github_repository_webhook" "discord_webhook" {
  repository    = var.repostirot_name
  active        = true
  events        = ["pull_request"]
  configuration = { 
    jsonencode({
      url          = "https://discord.com/api/webhooks/1131652598424928266/AsBM5lLUvocbERBQglFtiDfF_J97B6AmBJ8Igc14VuONL5NcITfA_6N7R9UX5VapeMWP" 
      content_type = "json"
      })
  }
}
resource "github_actions_secret" "pat_secret" {
  repository = var.repository_name
  secret_name = "PAT"
  plaintext_value = var.action_token
}
