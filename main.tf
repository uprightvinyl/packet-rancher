/*

This Terraform file creates an external volume and three hosts.

The first host is attached via the packet.net api to the external volume. MySQL is started in a container and
the data persisted to the external volume.

Rancher server is also deployed to the same server and a second server.

*/

# Create a new block volume to allow persistent storage even if a host is lost
resource "packet_volume" "ranch-ewr-vol1" {
  description   = "ranch-ewr-vol1"
  facility      = "${var.packet_facility}"
  project_id    = "${var.packet_project_id}"
  plan          = "storage_1"
  size          = 100
  billing_cycle = "hourly"

  snapshot_policies = {
    snapshot_frequency = "1hour"

    snapshot_count = 24
  }

  snapshot_policies = {
    snapshot_frequency = "1day"

    snapshot_count = 7
  }
}

# Create the first rancher server for ewr1 facility. This will run Rancher Server and MySQL.
resource "packet_device" "ranch-ewr-1-s1" {
  hostname         = "ranch-ewr-1-s1.${var.fqdn}"
  plan             = "${var.packet_rancher_server_type}"
  facility         = "ewr1"
  operating_system = "centos_7"
  billing_cycle    = "hourly"
  project_id       = "${var.packet_project_id}"

# output the device id of this server so we can use it for attaching the volume created earlier
 provisioner "file" {
    connection {
      type     = "ssh"
      user     = "root"
      private_key = "${file("${var.packet_ssh_public_key_path}")}"
    }
    content     = "{\n \"device_id\":\"${packet_device.ranch-ewr-1-s1.id}\"\n}"
    destination = "/tmp/ranch-ewr-1-s1-device_id.json"
 }

  provisioner "remote-exec" {
  connection {
    type     = "ssh"
    user     = "root"
    private_key = "${file("${var.packet_ssh_public_key_path}")}"
    }

    inline = [
      #Attach the external volume via packet.net api
      "curl -X POST --header 'Accept: application/json' --header 'X-Auth-Token: ${var.packet_api_key}' --header 'Content-Type: application/json' 'https://api.packet.net/storage/${packet_volume.ranch-ewr-vol1.id}/attachments' -d @/tmp/ranch-ewr-1-s1-device_id.json",
      #Next we attach, format, mount and make the mount persist reboots
      "vol=$(packet-block-storage-attach -m queue | awk '/mapper/ { print $3 }')",
      "mkfs.ext4 $vol",
      "mkdir -p /storage/vol1",
      "mount -t ext4 $vol /storage/vol1",
      "echo \"$vol /storage/vol1 ext4 _netdev 0 0\" >> /etc/fstab",
      #next create the directories
      "mkdir -p /storage/vol1/docker/rancher-mysql/data",
      "mkdir -p /storage/vol1/nfs/rancher/data",
      #start up NFS services. This would be used for a persistent storage service in Rancher
      "systemctl enable nfs-server.service",
      "systemctl start nfs-server.service"
      #start docker
      "sudo yum -y install docker",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      #start mysql container with cattle database setup for rancher
      "sudo docker run -d --restart=unless-stopped --name=rancher-mysql -p 3306:3306 --volume=/storage/vol1/docker/rancher-mysql/data:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=${var.rancher_mysql_root_password} -e MYSQL_DATABASE=cattle -e MYSQL_USER=cattle -e MYSQL_PASSWORD=${var.rancher_mysql_cattle_password} mysql",
      #start rancher server pointing at mysql on same server, using external volume
      "sudo docker run -d --restart=unless-stopped --name=rancher-server -p 8080:8080 -p 9345:9345 rancher/server --db-host ${packet_device.ranch-ewr-1-s1.network.0.address} --db-port 3306 --db-user cattle --db-pass ${var.rancher_mysql_cattle_password} --db-name cattle --advertise-address ${packet_device.ranch-ewr-1-s1.network.0.address}",
    ]
  }
}

# Create the second rancher server for ewr1 facility. This will run Rancher Server only.
resource "packet_device" "ranch-ewr-1-s2" {
  hostname         = "ranch-ewr-1-s2.${var.fqdn}"
  plan             = "${var.packet_rancher_server_type}"
  facility         = "ewr1"
  operating_system = "centos_7"
  billing_cycle    = "hourly"
  project_id       = "${var.packet_project_id}"

  provisioner "remote-exec" {
  connection {
    type     = "ssh"
    user     = "root"
    private_key = "${file("${var.packet_ssh_public_key_path}")}"
    }
    inline = [
      "sudo yum -y install docker",
      "sudo systemctl start docker",
      "sudo docker run -d --restart=unless-stopped --name=rancher-server -p 8080:8080 -p 9345:9345 rancher/server --db-host ${packet_device.ranch-ewr-1-s1.network.0.address} --db-port 3306 --db-user cattle --db-pass ${var.rancher_mysql_cattle_password} --db-name cattle --advertise-address ${packet_device.ranch-ewr-1-s2.network.0.address}",
    ]
  }
}

#Create a server which will be used just for the rancher agent
resource "packet_device" "ranch-ewr-1-a1" {
  hostname         = "ranch-ewr-1-a1.${var.fqdn}"
  plan             = "${var.packet_rancher_server_type}"
  facility         = "ewr1"
  operating_system = "centos_7"
  billing_cycle    = "hourly"
  project_id       = "${var.packet_project_id}"

  provisioner "remote-exec" {
  connection {
    type     = "ssh"
    user     = "root"
    private_key = "${file("${var.packet_ssh_public_key_path}")}"
    }
    inline = [
      "sudo yum -y install docker",
      "sudo systemctl start docker",
 ]
  }
}
