data "aws_acm_certificate" "godbolt-org-et-al" {
  domain      = "godbolt.org"
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}

data "aws_acm_certificate" "static-ce-cdn-net" {
  domain      = "static.ce-cdn.net"
  most_recent = true
}

resource "aws_cloudfront_distribution" "ce-godbolt-org" {
  origin {
    domain_name = "compiler-explorer.s3.amazonaws.com"
    origin_id   = "S3-compiler-explorer"
  }
  origin {
    domain_name = aws_alb.GccExplorerApp.dns_name
    origin_id   = "ALB-compiler-explorer"
    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_read_timeout      = 60
      origin_keepalive_timeout = 60
      origin_protocol_policy   = "https-only"
      origin_ssl_protocols     = [
        "TLSv1",
        "TLSv1.2",
        "TLSv1.1"
      ]
    }
  }

  enabled          = true
  is_ipv6_enabled  = true
  retain_on_delete = true
  aliases          = [
    "godbolt.org",
    "*.godbolt.org"
  ]

  viewer_certificate {
    acm_certificate_arn      = data.aws_acm_certificate.godbolt-org-et-al.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.1_2016"
  }

  logging_config {
    include_cookies = false
    bucket          = "compiler-explorer-logs.s3.amazonaws.com"
    prefix          = "cloudfront/"
  }

  http_version = "http2"

  restrictions {
    geo_restriction {
      restriction_type = "blacklist"
      locations        = [
        "CU",
        "IR",
        "KP",
        "SD",
        "SY"
      ]
    }
  }

  # Message of the day stuff, served from s3
  ordered_cache_behavior {
    allowed_methods        = [
      "GET",
      "HEAD"
    ]
    cached_methods         = [
      "GET",
      "HEAD"
    ]
    forwarded_values {
      cookies {
        forward = "none"
      }
      query_string = false
    }
    path_pattern           = "motd/*"
    target_origin_id       = "S3-compiler-explorer"
    viewer_protocol_policy = "redirect-to-https"
  }

  # Admin stuff, also served from s3
  ordered_cache_behavior {
    allowed_methods        = [
      "GET",
      "HEAD"
    ]
    cached_methods         = [
      "GET",
      "HEAD"
    ]
    forwarded_values {
      cookies {
        forward = "none"
      }
      query_string = false
    }
    path_pattern           = "admin/*"
    target_origin_id       = "S3-compiler-explorer"
    viewer_protocol_policy = "redirect-to-https"
  }

  default_cache_behavior {
    allowed_methods        = [
      "HEAD",
      "DELETE",
      "POST",
      "GET",
      "OPTIONS",
      "PUT",
      "PATCH"
    ]
    cached_methods         = [
      "HEAD",
      "GET"
    ]
    forwarded_values {
      cookies {
        forward = "none"
      }
      query_string = true
      headers      = [
        "Accept",
        "Host",
        "CloudFront-Is-Mobile-Viewer"
      ]
    }
    target_origin_id       = "ALB-compiler-explorer"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
  }

  custom_error_response {
    error_code            = 503
    response_code         = 503
    error_caching_min_ttl = 5
    response_page_path    = "/admin/503.html"
  }
  web_acl_id = aws_wafv2_web_acl.rate_limit.arn
}

# TODO - the duplication is rubbish
# Though note the differences: logging and aliases (at least).
resource "aws_cloudfront_distribution" "compiler-explorer-com" {
  origin {
    domain_name = "compiler-explorer.s3.amazonaws.com"
    origin_id   = "S3-compiler-explorer"
  }
  origin {
    domain_name = aws_alb.GccExplorerApp.dns_name
    origin_id   = "ALB-compiler-explorer"
    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_read_timeout      = 60
      origin_keepalive_timeout = 60
      origin_protocol_policy   = "https-only"
      origin_ssl_protocols     = [
        "TLSv1",
        "TLSv1.2",
        "TLSv1.1"
      ]
    }
  }

  enabled          = true
  is_ipv6_enabled  = true
  retain_on_delete = true
  aliases          = [
    "compiler-explorer.com",
    "*.compiler-explorer.com"
  ]

  viewer_certificate {
    acm_certificate_arn      = data.aws_acm_certificate.godbolt-org-et-al.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.1_2016"
  }

  logging_config {
    include_cookies = false
    bucket          = "compiler-explorer-logs.s3.amazonaws.com"
    prefix          = "cloudfront/"
  }

  http_version = "http2"

  restrictions {
    geo_restriction {
      restriction_type = "blacklist"
      locations        = [
        "CU",
        "IR",
        "KP",
        "SD",
        "SY"
      ]
    }
  }

  # Message of the day stuff, served from s3
  ordered_cache_behavior {
    allowed_methods        = [
      "GET",
      "HEAD"
    ]
    cached_methods         = [
      "GET",
      "HEAD"
    ]
    forwarded_values {
      cookies {
        forward = "none"
      }
      query_string = false
    }
    path_pattern           = "motd/*"
    target_origin_id       = "S3-compiler-explorer"
    viewer_protocol_policy = "redirect-to-https"
  }

  # Admin stuff, also served from s3
  ordered_cache_behavior {
    allowed_methods        = [
      "GET",
      "HEAD"
    ]
    cached_methods         = [
      "GET",
      "HEAD"
    ]
    forwarded_values {
      cookies {
        forward = "none"
      }
      query_string = false
    }
    path_pattern           = "admin/*"
    target_origin_id       = "S3-compiler-explorer"
    viewer_protocol_policy = "redirect-to-https"
  }

  default_cache_behavior {
    allowed_methods        = [
      "HEAD",
      "DELETE",
      "POST",
      "GET",
      "OPTIONS",
      "PUT",
      "PATCH"
    ]
    cached_methods         = [
      "HEAD",
      "GET"
    ]
    forwarded_values {
      cookies {
        forward = "none"
      }
      query_string = true
      headers      = [
        "Accept",
        "Host",
        "CloudFront-Is-Mobile-Viewer"
      ]
    }
    target_origin_id       = "ALB-compiler-explorer"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
  }

  custom_error_response {
    error_code            = 503
    response_code         = 503
    error_caching_min_ttl = 5
    response_page_path    = "/admin/503.html"
  }
  web_acl_id = aws_wafv2_web_acl.rate_limit.arn
}

resource "aws_cloudfront_distribution" "godbo-lt" {
  origin {
    domain_name = "compiler-explorer.s3.amazonaws.com"
    origin_id   = "S3-compiler-explorer"
  }
  origin {
    domain_name = aws_alb.GccExplorerApp.dns_name
    origin_id   = "ALB-compiler-explorer"
    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_read_timeout      = 60
      origin_keepalive_timeout = 60
      origin_protocol_policy   = "https-only"
      origin_ssl_protocols     = [
        "TLSv1",
        "TLSv1.2",
        "TLSv1.1"
      ]
    }
  }

  enabled          = true
  is_ipv6_enabled  = true
  retain_on_delete = true
  aliases          = [
    "godbo.lt",
    "*.godbo.lt"
  ]

  viewer_certificate {
    acm_certificate_arn      = data.aws_acm_certificate.godbolt-org-et-al.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.1_2016"
  }

  logging_config {
    include_cookies = false
    bucket          = "compiler-explorer-logs.s3.amazonaws.com"
    prefix          = "cloudfront/"
  }

  http_version = "http2"

  restrictions {
    geo_restriction {
      restriction_type = "blacklist"
      locations        = [
        "CU",
        "IR",
        "KP",
        "SD",
        "SY"
      ]
    }
  }

  # Message of the day stuff, served from s3
  ordered_cache_behavior {
    allowed_methods        = [
      "GET",
      "HEAD"
    ]
    cached_methods         = [
      "GET",
      "HEAD"
    ]
    forwarded_values {
      cookies {
        forward = "none"
      }
      query_string = false
    }
    path_pattern           = "motd/*"
    target_origin_id       = "S3-compiler-explorer"
    viewer_protocol_policy = "redirect-to-https"
  }

  # Admin stuff, also served from s3
  ordered_cache_behavior {
    allowed_methods        = [
      "GET",
      "HEAD"
    ]
    cached_methods         = [
      "GET",
      "HEAD"
    ]
    forwarded_values {
      cookies {
        forward = "none"
      }
      query_string = false
    }
    path_pattern           = "admin/*"
    target_origin_id       = "S3-compiler-explorer"
    viewer_protocol_policy = "redirect-to-https"
  }

  default_cache_behavior {
    allowed_methods        = [
      "HEAD",
      "DELETE",
      "POST",
      "GET",
      "OPTIONS",
      "PUT",
      "PATCH"
    ]
    cached_methods         = [
      "HEAD",
      "GET"
    ]
    forwarded_values {
      cookies {
        forward = "none"
      }
      query_string = true
      headers      = [
        "Accept",
        "Host",
        "CloudFront-Is-Mobile-Viewer"
      ]
    }
    target_origin_id       = "ALB-compiler-explorer"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
  }

  custom_error_response {
    error_code            = 503
    response_code         = 503
    error_caching_min_ttl = 5
    response_page_path    = "/admin/503.html"
  }

  web_acl_id = aws_wafv2_web_acl.rate_limit.arn
}

resource "aws_cloudfront_distribution" "static-ce-cdn-net" {
  origin {
    domain_name = "ce-cdn.net.s3.amazonaws.com"
    origin_id   = "S3-ce-cdn.net"
  }

  enabled          = true
  is_ipv6_enabled  = true
  retain_on_delete = true
  aliases          = [
    "static.ce-cdn.net"
  ]

  viewer_certificate {
    acm_certificate_arn      = data.aws_acm_certificate.static-ce-cdn-net.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.1_2016"
  }

  logging_config {
    include_cookies = false
    bucket          = "compiler-explorer-logs.s3.amazonaws.com"
    prefix          = "cloudfront/"
  }

  http_version = "http2"

  restrictions {
    geo_restriction {
      restriction_type = "blacklist"
      locations        = [
        "CU",
        "IR",
        "KP",
        "SD",
        "SY"
      ]
    }
  }

  default_cache_behavior {
    allowed_methods        = [
      "HEAD",
      "GET",
      "OPTIONS"
    ]
    cached_methods         = [
      "HEAD",
      "GET",
      "OPTIONS"
    ]
    forwarded_values {
      cookies {
        forward = "none"
      }
      headers                 = [
        # see https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/header-caching.html#header-caching-web-cors
        "Origin",
        "Access-Control-Request-Headers",
        "Access-Control-Request-Method"
      ]
      query_string            = true
      query_string_cache_keys = [
        "v"
      ]
    }
    target_origin_id       = "S3-ce-cdn.net"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
  }
}

resource "aws_wafv2_web_acl" "rate_limit" {
  name  = "RateLimitCompilerExplorer"
  scope = "CLOUDFRONT"
  default_action {
    allow {}
  }

  rule {
    name     = "RateLimitPost"
    priority = 1
    action {
      //      block {}
      count {}
    }
    statement {
      rate_based_statement {
        // Limit to this many per 5 minutes (300 seconds)
        limit              = 300
        aggregate_key_type = "IP"
        scope_down_statement {
          byte_match_statement {
            positional_constraint = "EXACTLY"
            search_string         = "POST"
            field_to_match {
              method {}
            }
            text_transformation {
              priority = 0
              type     = "NONE"
            }
          }
        }
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "ce_rate_limited_blocked"
      sampled_requests_enabled   = true
    }
  }
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "ce_rate_limited_ok"
    sampled_requests_enabled   = true
  }
}

resource "aws_cloudfront_distribution" "nsolid-compiler-explorer-com" {
  origin {
    domain_name = aws_alb.GccExplorerApp.dns_name
    origin_id   = "ALB-compiler-explorer"
    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_read_timeout      = 60
      origin_keepalive_timeout = 60
      origin_protocol_policy   = "https-only"
      origin_ssl_protocols     = [
        "TLSv1",
        "TLSv1.2",
        "TLSv1.1"
      ]
    }
  }

  enabled          = true
  is_ipv6_enabled  = true
  aliases          = [
    "nsolid.compiler-explorer.com"
  ]

  viewer_certificate {
    acm_certificate_arn      = data.aws_acm_certificate.godbolt-org-et-al.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.1_2016"
  }

  logging_config {
    include_cookies = false
    bucket          = "compiler-explorer-logs.s3.amazonaws.com"
    prefix          = "cloudfront/"
  }

  http_version = "http2"

  restrictions {
    geo_restriction {
      restriction_type = "blacklist"
      locations        = [
        "CU",
        "IR",
        "KP",
        "SD",
        "SY"
      ]
    }
  }

  default_cache_behavior {
    allowed_methods        = [
      "HEAD",
      "DELETE",
      "POST",
      "GET",
      "OPTIONS",
      "PUT",
      "PATCH"
    ]
    cached_methods         = [
      "HEAD",
      "GET"
    ]
    forwarded_values {
      cookies {
        forward = "whitelist"
        whitelisted_names = ["nsolid-session", "nsolid-refresh"]
      }
      query_string = true
      headers      = [
        "Accept",
        "Host",
        "CloudFront-Is-Mobile-Viewer"
      ]
    }
    target_origin_id       = "ALB-compiler-explorer"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
  }

  web_acl_id = aws_wafv2_web_acl.rate_limit.arn
}
