terraform {
  backend "remote" {
    organization    = "OrgName"

    workspaces {
      name          = "WorkspaceName"
    }
  }
}
