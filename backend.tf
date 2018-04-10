terraform {
   backend "s3" {
	bucket= "terraform-state-luislongo-123"
	key= "terraform/docker-demo-3"
	region= "eu-west-1"
   }
}
