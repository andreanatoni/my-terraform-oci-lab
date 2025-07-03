resource "oci_autoscaling_auto_scaling_configuration" "lab_autoscaling_config" {
  auto_scaling_resources {
    id   = var.lab_instance_pool_id
    type = "instancePool"
  }
  compartment_id       = var.compartment_id
  cool_down_in_seconds = "300"
  display_name         = "lab_autoscaling_config"

  is_enabled = "true"
  policies {
    capacity {
      initial = "1"
      max     = "3"
      min     = "1"
    }
    display_name = "lab_autoscaling_policy"
    is_enabled   = "true"
    policy_type  = "threshold"
    rules {
      action {
        type  = "CHANGE_COUNT_BY"
        value = "1"
      }
      display_name = "scale-out-rule"
      metric {
        metric_type = "CPU_UTILIZATION"
        threshold {
          operator = "GT"
          value    = "75"
        }
      }
    }
    rules {
      action {
        type  = "CHANGE_COUNT_BY"
        value = "-1"
      }
      display_name = "scale-in-rule"
      metric {
        metric_type = "CPU_UTILIZATION"
        threshold {
          operator = "LT"
          value    = "25"
        }
      }
    }
  }
}

