resource "aws_sns_topic" "alerts" {
  name = "bedrock-alerts"
}

resource "aws_cloudwatch_metric_alarm" "node_cpu_high" {
  alarm_name          = "bedrock-node-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "node_cpu_utilization"
  namespace           = "ContainerInsights"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Node CPU utilization above 80%"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    ClusterName = aws_eks_cluster.bedrock.name
  }
}

resource "aws_cloudwatch_metric_alarm" "node_memory_high" {
  alarm_name          = "bedrock-node-memory-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "node_memory_utilization"
  namespace           = "ContainerInsights"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Node memory utilization above 80%"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    ClusterName = aws_eks_cluster.bedrock.name
  }
}

resource "aws_cloudwatch_dashboard" "bedrock" {
  dashboard_name = "bedrock-platform-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["ContainerInsights", "node_cpu_utilization", "ClusterName", aws_eks_cluster.bedrock.name]
          ]
          period = 300
          stat   = "Average"
          region = "us-east-1"
          title  = "Node CPU Utilization"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["ContainerInsights", "node_memory_utilization", "ClusterName", aws_eks_cluster.bedrock.name]
          ]
          period = 300
          stat   = "Average"
          region = "us-east-1"
          title  = "Node Memory Utilization"
        }
      },
      {
        type   = "log"
        x      = 0
        y      = 6
        width  = 24
        height = 6
        properties = {
          query  = "SOURCE '/aws/lambda/bedrock-asset-processor' | fields @timestamp, @message | sort @timestamp desc | limit 20"
          region = "us-east-1"
          title  = "Recent Lambda Invocations"
        }
      }
    ]
  })
}
