provider "aws" {
  region     = "us-west-1"
}


resource "aws_sqs_queue" "terraform_queue" {
  name                      = "terraform-example"
  delay_seconds             = 120
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10

  tags {
    Environment = "production"
  }
}

resource "aws_cloudwatch_metric_alarm" "sqs-threshold-reached" {
  alarm_name          = "sqs-threshold"
  comparison_operator = "LessThanOrEqualToThreshold"
  threshold           = "1"
  evaluation_periods  = "1"
  statistic           = "Average"
  period              = "300"
  metric_name         = "SQSQueueSize"
  namespace           = "SQS"
  alarm_description   = "Alarms when prod update queue totals >=200,000"
  alarm_actions       = ["arn:aws:sns:us-west-1::email-blast"]
  dimensions {
    queue = "terraform_queue"
  }
}
