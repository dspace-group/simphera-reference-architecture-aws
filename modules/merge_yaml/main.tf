terraform {
  required_providers {
    utils = {
      source = "cloudposse/utils"
    }
  }
}


data "utils_deep_merge_yaml" "merged" {
  input = var.merge_list
}
