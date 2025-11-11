resource "datadog_monitor" "lambda_cost_monitor" {
  name              = "Lambda Cost Monitor"
  type              = "metric alert"
  query             = "avg:aws.lambda.enhanced.invocations{*} + avg:aws.lambda.enhanced.duration{*} + avg:aws.lambda.enhanced.max_memory_used{*}"
  message           = "Lambda function cost is increasing!"
  thresholds        = "critical: 1000"
  notify_no_data    = true
  no_data_timeframe = 30
}
