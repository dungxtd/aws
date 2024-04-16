resource "aws_lb" "external_lb" {
  count              = var.create_extlb ? 1 : 0
  name               = "${var.common_prefix}-ext-lb-${var.environment}"
  load_balancer_type = "network"
  internal           = "false"
  subnets            = var.vpc_public_subnets

  enable_cross_zone_load_balancing = true

  tags = merge(
    local.global_tags,
    {
      "Name" = lower("${var.common_prefix}-ext-lb-${var.environment}")
    }
  )
}

# HTTP
resource "aws_lb_listener" "external_lb_listener_http" {
  count             = var.create_extlb ? 1 : 0
  load_balancer_arn = aws_lb.external_lb[count.index].arn

  protocol = "TCP"
  port     = var.extlb_http_port

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.external_lb_tg_http[count.index].arn
  }

  tags = merge(
    local.global_tags,
    {
      "Name" = lower("${var.common_prefix}-http-listener-${var.environment}")
    }
  )
}

resource "aws_lb_target_group" "external_lb_tg_http" {
  count             = var.create_extlb ? 1 : 0
  port              = var.extlb_listener_http_port
  protocol          = "TCP"
  vpc_id            = var.vpc_id
  proxy_protocol_v2 = true

  depends_on = [
    aws_lb.external_lb
  ]

  health_check {
    protocol = "TCP"
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    local.global_tags,
    {
      "Name" = lower("${var.common_prefix}-ext-lb-tg-http-${var.environment}")
    }
  )
}

resource "aws_autoscaling_attachment" "target_http" {
  count = var.create_extlb ? 1 : 0
  depends_on = [
    aws_autoscaling_group.k8s_workers_asg,
    aws_lb_target_group.external_lb_tg_http
  ]

  autoscaling_group_name = aws_autoscaling_group.k8s_workers_asg.name
  lb_target_group_arn    = aws_lb_target_group.external_lb_tg_http[count.index].arn
}

# HTTPS
resource "aws_lb_listener" "external_lb_listener_https" {
  count             = var.create_extlb ? 1 : 0
  load_balancer_arn = aws_lb.external_lb[count.index].arn

  protocol = "TCP"
  port     = var.extlb_https_port

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.external_lb_tg_https[count.index].arn
  }

  tags = merge(
    local.global_tags,
    {
      "Name" = lower("${var.common_prefix}-https-listener-${var.environment}")
    }
  )
}

resource "aws_lb_target_group" "external_lb_tg_https" {
  count             = var.create_extlb ? 1 : 0
  port              = var.extlb_listener_https_port
  protocol          = "TCP"
  vpc_id            = var.vpc_id
  proxy_protocol_v2 = true

  depends_on = [
    aws_lb.external_lb
  ]

  health_check {
    protocol = "TCP"
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    local.global_tags,
    {
      "Name" = lower("${var.common_prefix}-ext-lb-tg-https-${var.environment}")
    }
  )
}

resource "aws_autoscaling_attachment" "target_https" {
  count = var.create_extlb ? 1 : 0
  depends_on = [
    aws_autoscaling_group.k8s_workers_asg,
    aws_lb_target_group.external_lb_tg_https
  ]

  autoscaling_group_name = aws_autoscaling_group.k8s_workers_asg.name
  lb_target_group_arn    = aws_lb_target_group.external_lb_tg_https[count.index].arn
}

# kubeapi

resource "aws_lb_listener" "external_lb_listener_kubeapi" {
  count             = var.expose_kubeapi ? 1 : 0
  load_balancer_arn = aws_lb.external_lb[count.index].arn

  protocol = "TCP"
  port     = var.kube_api_port

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.external_lb_tg_kubeapi[count.index].arn
  }

  tags = merge(
    local.global_tags,
    {
      "Name" = lower("${var.common_prefix}-kubeapi-listener-${var.environment}")
    }
  )
}

resource "aws_lb_target_group" "external_lb_tg_kubeapi" {
  count    = var.expose_kubeapi ? 1 : 0
  port     = var.kube_api_port
  protocol = "TCP"
  vpc_id   = var.vpc_id

  depends_on = [
    aws_lb.external_lb
  ]

  health_check {
    protocol = "TCP"
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    local.global_tags,
    {
      "Name" = lower("${var.common_prefix}-ext-lb-tg-kubeapi-${var.environment}")
    }
  )
}

resource "aws_autoscaling_attachment" "target_kubeapi" {
  count = var.expose_kubeapi ? 1 : 0
  depends_on = [
    aws_autoscaling_group.k8s_servers_asg,
    aws_lb_target_group.external_lb_tg_kubeapi
  ]

  autoscaling_group_name = aws_autoscaling_group.k8s_servers_asg.name
  lb_target_group_arn    = aws_lb_target_group.external_lb_tg_kubeapi[count.index].arn
}