/******************************************
  Use templates to read from list of maps
 *****************************************/
data "template_file" "secondary_range_names" {
  count    = "${length(var.secondary_ranges)}"
  template = "${lookup(var.secondary_ranges[count.index], "range_name", "")}"
}

data "template_file" "secondary_range_cidrs" {
  count    = "${length(var.secondary_ranges)}"
  template = "${lookup(var.secondary_ranges[count.index], "ip_cidr_range", "")}"
}

/******************************************
  Define local variables for use in outputs
 *****************************************/
locals {
  subnetwork_type = "${var.create_secondary_ranges ? "secondary_range" : "normal"}"

  name_output = {
    secondary_range = "${element(concat(google_compute_subnetwork.ranged.*.name, list("")), 0)}"
    normal          = "${element(concat(google_compute_subnetwork.basic.*.name, list("")), 0)}"
  }

  gateway_address_output = {
    secondary_range = "${element(concat(google_compute_subnetwork.ranged.*.gateway_address, list("")), 0)}"
    normal          = "${element(concat(google_compute_subnetwork.basic.*.gateway_address, list("")), 0)}"
  }

  self_link_output = {
    secondary_range = "${element(concat(google_compute_subnetwork.ranged.*.self_link, list("")), 0)}"
    normal          = "${element(concat(google_compute_subnetwork.basic.*.self_link, list("")), 0)}"
  }

  ip_cidr_range_output = {
    secondary_range = "${element(concat(google_compute_subnetwork.ranged.*.ip_cidr_range, list("")), 0)}"
    normal          = "${element(concat(google_compute_subnetwork.basic.*.ip_cidr_range, list("")), 0)}"
  }


  secondary_range_names_output = {
    secondary_range = "${data.template_file.secondary_range_names.*.rendered}"
    normal          = []
  }

  secondary_range_cidrs_output = {
    secondary_range = "${data.template_file.secondary_range_cidrs.*.rendered}"
    normal          = []
  }

  name                  = "${local.name_output[local.subnetwork_type]}"
  description           = "${var.name} subnetwork"
  gateway_address       = "${local.gateway_address_output[local.subnetwork_type]}"
  self_link             = "${local.self_link_output[local.subnetwork_type]}"
  ip_cidr_range         = "${local.ip_cidr_range_output[local.subnetwork_type]}"
  secondary_range_names = "${local.secondary_range_names_output[local.subnetwork_type]}"
  secondary_range_cidrs = "${local.secondary_range_cidrs_output[local.subnetwork_type]}"
}
