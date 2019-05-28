provider "aws" {
    access_key = "${var.access_id}"
    secret_key = "${var.secret_id}"
    region     = "us-east-2"
}

resource "aws_vpc" "k8s_pronto_world_dev" {
    assign_generated_ipv6_cidr_block = true
    cidr_block                       = "10.30.8.0/21"

    tags = {
        Name         = "k8s-pronto-world-dev"
        environment  = "dev"
        product-area = "pronto-world"
    }
}

resource "aws_subnet" "k8s_pronto_world_public_subnet_zone_a" {
    vpc_id = "${aws_vpc.k8s_pronto_world_dev.id}"

    assign_ipv6_address_on_creation = true
    availability_zone               = "us-east-2a"
    cidr_block                      = "10.30.8.0/24"
    ipv6_cidr_block                 = "${cidrsubnet(aws_vpc.k8s_pronto_world_dev.ipv6_cidr_block, 8, 0)}"

    tags = {
        Name         = "k8s-pronto-world-dev-public-subnet-zone-a"
        environment  = "dev"
        product-area = "pronto-world"
    }
}

resource "aws_subnet" "k8s_pronto_world_public_subnet_zone_b" {
    vpc_id = "${aws_vpc.k8s_pronto_world_dev.id}"

    assign_ipv6_address_on_creation = true
    availability_zone               = "us-east-2b"
    cidr_block                      = "10.30.9.0/24"
    ipv6_cidr_block                 = "${cidrsubnet(aws_vpc.k8s_pronto_world_dev.ipv6_cidr_block, 8, 1)}"

    tags = {
        Name         = "k8s-pronto-world-dev-public-subnet-zone-b"
        environment  = "dev"
        product-area = "pronto-world"
    }
}

resource "aws_subnet" "k8s_pronto_world_public_subnet_zone_c" {
    vpc_id = "${aws_vpc.k8s_pronto_world_dev.id}"

    assign_ipv6_address_on_creation = true
    availability_zone               = "us-east-2c"
    cidr_block                      = "10.30.10.0/24"
    ipv6_cidr_block                 = "${cidrsubnet(aws_vpc.k8s_pronto_world_dev.ipv6_cidr_block, 8, 2)}"

    tags = {
        Name         = "k8s-pronto-world-dev-public-subnet-zone-c"
        environment  = "dev"
        product-area = "k8s-pronto-world"
    }
}

resource "aws_internet_gateway" "k8s_pronto_world_dev_internet_gateway" {
  vpc_id = "${aws_vpc.k8s_pronto_world_dev.id}"

  tags = {
    Name         = "k8s-pronto-world-dev-internet-gateway"
    environment  = "dev"
    product-area = "pronto-world"
  }
}

resource "aws_route_table" "k8s_pronto_world_dev_public_route_table" {
    vpc_id = "${aws_vpc.k8s_pronto_world_dev.id}"

    route {
        cidr_block     = "0.0.0.0/0"
        nat_gateway_id = "${aws_internet_gateway.k8s_pronto_world_dev_internet_gateway.id}"
    }

    route {
        cidr_block                = "10.254.248.0/21"
        vpc_peering_connection_id = "${aws_vpc_peering_connection.bash_station.id}"
    }

    tags = {
        Name         = "k8s-pronto-world-dev-public-route-table"
        environment  = "dev"
        product-area = "pronto-world"
    }
}

resource "aws_route_table_association" "k8s_pronto_world_dev_public_route_table_association_zone_a" {
    subnet_id       = "${aws_subnet.k8s_pronto_world_public_subnet_zone_a.id}"
    route_table_id  = "${aws_route_table.k8s_pronto_world_dev_public_route_table.id}"
}

resource "aws_route_table_association" "k8s_pronto_world_dev_public_route_table_association_zone_b" {
    subnet_id       = "${aws_subnet.k8s_pronto_world_public_subnet_zone_b.id}"
    route_table_id  = "${aws_route_table.k8s_pronto_world_dev_public_route_table.id}"
}

resource "aws_route_table_association" "k8s_pronto_world_dev_public_route_table_association_zone_c" {
    subnet_id       = "${aws_subnet.k8s_pronto_world_public_subnet_zone_c.id}"
    route_table_id  = "${aws_route_table.k8s_pronto_world_dev_public_route_table.id}"
}

resource "aws_security_group" "allow_ssh" {
    name = "allow-ssh"
    description = "All ssh conn"
    vpc_id = "${aws_vpc.k8s_pronto_world_dev.id}"

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow SSH inbound traffic"
    }

    tags = {
        Name         = "allow-ssh"
        environment  = "dev"
        product-area = "pronto-world"
    }
}

resource "aws_security_group" "allow_internet_outbound" {
    name = "allow_internet_outbound"
    description = "Allow Internet outbound"
    vpc_id = "${aws_vpc.k8s_pronto_world_dev.id}"

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow Internet Outbound"
    }

    tags = {
        Name         = "allow_internet_outbound"
        environment  = "dev"
        product-area = "pronto-world"
    }
}

resource "aws_security_group" "allow_all_tpc_and_udp" {
    name = "allow_all_tpc_and_udp"
    description = "All all tpc and udp protocol"
    vpc_id = "${aws_vpc.k8s_pronto_world_dev.id}"

    ingress {
        from_port   = 0
        to_port     = 65535
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow TCP Inbound"
    }

    ingress {
        from_port   = 0
        to_port     = 65535
        protocol    = "udp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow UDP Inbound"
    }

    tags = {
        Name         = "allow_all_tcp_and_udp"
        environment  = "dev"
        product-area = "pronto-world"
    }
}

resource "aws_security_group" "allow_http_https" {
    name = "allow_http_https"
    description = "Allow http and https"
    vpc_id = "${aws_vpc.k8s_pronto_world_dev.id}"

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow Http inbound traffic"
    }


    ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow Https inbound traffic"
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow Internet Outbound"
    }

    tags = {
        Name         = "allow_http_https"
        environment  = "dev"
        product-area = "pronto-world"
    }
}

resource "aws_instance" "k8s_pronto_world_dev_master" {
    subnet_id       = "${aws_subnet.k8s_pronto_world_public_subnet_zone_a.id}"
    security_groups = [
        "${aws_security_group.allow_http_https.id}",
        "${aws_security_group.allow_ssh.id}",
        "${aws_security_group.allow_all_tpc_and_udp.id}"
    ]

    ami           = "ami-08d658f84a6d84a80"
    instance_type = "t2.medium"
    key_name      = "rocket-ssh-credential"
    associate_public_ip_address = true

    root_block_device {
        iops        = "600"
        volume_size = 50
        volume_type = "gp2"
    }

    volume_tags {
        Name         = "k8s-pronto-world-dev"
        environment  = "dev"
        product-area = "pronto-world"
    }

    tags = {
        Name         = "kubernetes-pronto-world-dev-master"
        environment  = "dev"
        product-area = "pronto-world"
    }
}

resource "aws_instance" "k8s_pronto_world_dev_worker" {
    subnet_id       = "${aws_subnet.k8s_pronto_world_public_subnet_zone_b.id}"
    security_groups = [
        "${aws_security_group.allow_http_https.id}",
        "${aws_security_group.allow_ssh.id}",
        "${aws_security_group.allow_all_tpc_and_udp.id}"
    ]

    ami           = "ami-08d658f84a6d84a80"
    instance_type = "t2.medium"
    key_name      = "rocket-ssh-credential"
    associate_public_ip_address = true

    root_block_device {
        iops        = "600"
        volume_size = 50
        volume_type = "gp2"
    }

    volume_tags {
        Name         = "k8s-pronto-world-dev"
        environment  = "dev"
        product-area = "pronto-world"
    }

    tags = {
        Name         = "kubernetes-pronto-world-dev-worker"
        environment  = "dev"
        product-area = "pronto-world"
    }
}

resource "aws_instance" "k8s_pronto_world_dev_nfs" {
    subnet_id       = "${aws_subnet.k8s_pronto_world_public_subnet_zone_c.id}"
    security_groups = [
        "${aws_security_group.allow_internet_outbound.id}",
        "${aws_security_group.allow_ssh.id}",
        "${aws_security_group.allow_all_tpc_and_udp.id}"
    ]

    ami           = "ami-08d658f84a6d84a80"
    instance_type = "t2.medium"
    key_name      = "rocket-ssh-credential"
    associate_public_ip_address = true

    root_block_device {
        iops        = "600"
        volume_size = 100
        volume_type = "gp2"
    }

    volume_tags {
        Name         = "k8s-pronto-world-dev"
        environment  = "dev"
        product-area = "pronto-world"
    }

    tags = {
        Name         = "kubernetes-pronto-world-dev-nfs"
        environment  = "dev"
        product-area = "pronto-world"
    }
}

data "template_file" "inventory" {
    template = "${file("../ansible/inventory.tpl")}"

    depends_on = [
        "aws_eip_association.k8s_pronto_world_dev_master_ip",
        "aws_eip_association.k8s_pronto_world_dev_worker_ip",
        "aws_eip_association.k8s_pronto_world_dev_nfs_ip",
    ]

    vars {
        master_node = "${aws_eip.k8s_pronto_world_dev_instance_ip_master.public_ip}"
        worker_node = "${aws_eip.k8s_pronto_world_dev_instance_ip_worker.public_ip}"
        nfs_node    = "${aws_eip.k8s_pronto_world_dev_instance_ip_nfs.public_ip}"
    }
}

resource "null_resource" "cmd" {
    triggers {
        template_rendered = "${data.template_file.inventory.rendered}"
    }

    provisioner "local-exec" {
        command = "echo '${data.template_file.inventory.rendered}' > ../ansible/development"
    }
}
