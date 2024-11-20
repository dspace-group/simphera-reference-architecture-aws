
terraform {
  backend "s3" {
    #The name of the bucket to be used to store the terraform state. You need to create this container manually.
    bucket = "vr-terraformstates"

    #The name of the file to be used inside the container to be used for this terraform state.
    key = "simphera.tfstate"

    #The region of the bucket.
    region = "eu-central-1"

    #AWS profile to use
    profile = "wtc-development"
  }
}
