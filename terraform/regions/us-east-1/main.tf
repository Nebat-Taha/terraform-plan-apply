module "sqs" {
  source     = "../../modules/sqs"
  queue_name = "us-east-1-csv-processing"
}
