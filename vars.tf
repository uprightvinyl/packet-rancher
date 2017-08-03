/* variable "aws_access_key" {
  description = "aws_access_key"
}

  variable "aws_secret_key" {
  description = "aws_secret_key"
}

  variable "route53_zone_id" {
  description = "Route53 Zone ID"
}

*/

variable "packet_api_key" {
  description = "Packet API key"
}

variable "packet_project_id" {
  description = "Packet Project ID"
}

variable "packet_facility" {
  description = "Packet facility: US East(ewr1), US West(sjc1), or EU(ams1). Default: ewr1"
  default = "ewr1"
}

variable "packet_rancher_server_type" {
  description = "Packet server type used for Rancher servers. Default: baremetal_1"
  default = "baremetal_1"
}

variable "packet_rancher_agent_type" {
  description = "Packet server type used for Rancher agents. Default: baremetal_1"
  default = "baremetal_1"
}

variable "fqdn" {
  description = "FQDN for hosts. Appended to device name. Default is blank"
  default = ""
}

variable "packet_ssh_public_key_path" {
  description = "Path to your public SSH key path"
}

variable "rancher_mysql_root_password" {
  description = "Root password for the mysql instance used by rancher server"
}

variable "rancher_mysql_cattle_password" {
  description = "Password for cattle user for the rancher server mysql database"
}




