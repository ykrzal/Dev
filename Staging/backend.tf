terraform {
  backend "remote" {
    organization    = "TerraCloudZoom"

    workspaces {
      name          = "Staging"
    }
  }
}
