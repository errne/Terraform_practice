resource "datadog_monitor" "lambda_error_monitor" {
  name    = "Lambda Error Monitor"
  type    = "metric alert"
  query   = "avg(last_5m):sum:aws.lambda.errors.count{*} by {functionname} > 5"
  message = "High number of errors on lambda function @slack-channel"

  thresholds = {
    critical = 5
    warning  = 3
  }

  notify_no_data    = false
  no_data_timeframe = 20

  tags = ["terraform", "lambda", "error-monitoring"]
}
