terraform {
  cloud {
    organization = "girishmaddineni"

    workspaces {
      name = "dev"
    }
  }
}