resource "aws_s3_bucket" "terraform-state" {
    bucket = "terraform-state-luislongo-123"
    acl = "private"

    tags {
        Name = "Terraform state"
    }
}
