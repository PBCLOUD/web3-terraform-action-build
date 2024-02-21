provider "github" {
  token = "xxx"

}
terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "6.0.0-beta"
    }
  }
}

# Create a custom action repository
resource "github_repository" "action_build_repo" {
  name         = "test-action-build"
  description  = "Custom action repository"
  auto_init = true
  has_wiki      = true
  visibility      = "public"
  
}

resource "github_actions_secret" "example_secret" {
  repository       = github_repository.action_build_repo.name
  secret_name      = "example_secret_name"
  plaintext_value  = "Test"
}

# Get the list of YAML files and their paths in the specified folder and subdirectories
locals {
  yaml_files = glob("./terraform-code/**/*.*")
}

# Create File for Terraform Build for each YAML file
resource "github_repository_file" "actionFiles" {
  for_each = { for idx, file in local.yaml_files : idx => file }
  
  repository          = github_repository.action_build_repo.name
  branch              = "main"
  file                = substr(each.value, strlen("./terraform-code/") + 1) // Get the relative path
  content             = file(each.value)
  commit_message      = "Managed by Terraform"
  commit_author       = "Terraform Automation"
  commit_email        = "terraform@purplebox.com"
  overwrite_on_create = true
}