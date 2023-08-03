terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
  }
}
variable "github_token" {
   type        = string
   description = "GitHub Personal Access Token"
}
provider "github" {
  token  = var.github_token
}

resource "github_repository" "github-terraform-task-alonabelak" {
  name            = "Github terraform repository"
  description     = "My repository description" 
  visibility      = "public" 

  default_branch  = "develop"

  template {
    owner = "Practical-DevOps-GitHub"
    repository = "github-terraform-task-alonabelak"
    filename = ".github/pull_request_template.md"
  }
}

resource "github_repository_collaborator" "softservedata" {
  repository = "github-terraform-task-alonabelak"
  username   = "softservedata" 
  permission = "push" 
}

resource "github_branch_protection" "main" {
  repository = "github-terraform-task-alonabelak"
  branch     = "main"

  required_pull_request_reviews {
    dismiss_stale_reviews = true
    require_code_owner_reviews = true
    required_approving_review_count = 1
  }
}

resource "github_branch_protection" "develop" {
  repository = "github-terraform-task-alonabelak"
  branch     = "develop"

  required_pull_request_reviews {
    dismiss_stale_reviews = true
    required_approving_review_count = 2
  }

  enforce_admins = true
}

resource "github_repository_codeowners" "softservedata" {
  repository = "github-terraform-task-alonabelak"
  owner      = "softservedata"  
  path       = "/"
}

resource "github_actions_secret" "terraform_secret" {
  repository = "github-terraform-task-alonabelak"  
  name       = "TERRAFORM"
  value      = base64encode(file("main.tf"))
}
resource "github_repository_webhook" "discord_webhook" {
  repository    = "github-terraform-task-alonabelak"
  name          = "discord"
  active        = true
  events        = ["pull_request"]
  configuration = jsonencode({
    url          = "https://discord.com/api/webhooks/1131652598424928266/AsBM5lLUvocbERBQglFtiDfF_J97B6AmBJ8Igc14VuONL5NcITfA_6N7R9UX5VapeMWP" 
    content_type = "json"
  })
}
resource "github_actions_secret" "pat_secret" {
  repository = "github-terraform-task-alonabelak"
  secret_name = "PAT"
  plaintext_value = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQD92B17TcO3Uhmi4Aif9Gua0xmmZArnmO48sWR/bz7OwmUiBqy3xU2v2aAulVdSdaxNiVtEnyW3Rkzg8JLePp52KE65Zn7H/jzdzXPEOrweTCWy/2fmIMcYYzkjz8+MyhSuUkvK7QsM90DPutk5Kkq0VCAwbC/9USmxboidhCuAqO1pc1pQVupBbK+9gn+6gxIsWLJBgcdPV/0pgp4hkr9+Rf5CbxM959tuVBgW8Rv5w4gikDjIRajO27CcvzYVtUMj8gA64umcpPT7iNkGsvQdY/CrrPrqtlNF5RwGIr3nYIjDj850aOqoSHC1ujlTAgx5pkqdDNZxZnsJjAs6fdr4WDbyDJ5tNoxE/rUxUuQNkUim9OPDgxy8edteVL+bgcseudL5RLzYYuIi5T30zSkPXizi6ihNapkksAWXcMgv2e+6Rhwz5GaxS6oiPHiQBj3u6m+UyhIDHtOEaxLOAI49jWJd+E7x9OviJwtKNz+1CgmHPc2WPAhJ1UTCdHNA6G8=" 
}
