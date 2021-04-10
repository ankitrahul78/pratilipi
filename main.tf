terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.36"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "ap-south-1"
}

# Create a bucket
resource "aws_s3_bucket" "b1" {
  bucket = "pratilipi-ankit"
  acl    = "private"   # or can be "public-read"
  tags = {
    Name        = "pratilipi-ankit"
    Environment = "Dev"
  }
}
# Upload an object
resource "aws_s3_bucket_object" "object" {
  bucket = aws_s3_bucket.b1.id
  key    = "file.csv"
  acl    = "public-read"  # or can be "public-read"
  source = "file.csv"
#   etag = filemd5("myfiles/yourfile.txt")

}


resource "aws_vpc" "test" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_subnet" "public-subnet" {
  # creates a subnet
  cidr_block        = "${cidrsubnet(aws_vpc.test.cidr_block, 3, 1)}"
  vpc_id            = "${aws_vpc.test.id}"
  availability_zone = "ap-south-1a"
}


resource "aws_security_group" "ingress-ssh-test" {
  name   = "allow-ssh-sg"
  vpc_id = "${aws_vpc.test.id}"

  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]

    from_port = 22
    to_port   = 22
    protocol  = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ingress-http-test" {
  name   = "allow-http-sg"
  vpc_id = "${aws_vpc.test.id}"

  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]

    from_port = 80
    to_port   = 80
    protocol  = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ingress-https-test" {
  name   = "allow-https-sg"
  vpc_id = "${aws_vpc.test.id}"

  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]

    from_port = 443
    to_port   = 443
    protocol  = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "ec2_access_role" {
  name               = "agent-role"
  assume_role_policy = "${file("assumerolepolicy.json")}"
}

resource "aws_iam_policy_attachment" "test-attach" {
  name       = "agent-role-attachment"
  roles      = ["${aws_iam_role.ec2_access_role.name}"]
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "test_profile" {
  name  = "test_profile"
  role = "${aws_iam_role.ec2_access_role.name}"
}

resource "aws_eip" "ip-test" {
  instance = "${aws_instance.test_worker.id}"
  vpc      = true
}

resource "aws_internet_gateway" "test-gw" {
  vpc_id = "${aws_vpc.test.id}"
}

resource "aws_route_table" "route-table-test" {
  vpc_id = "${aws_vpc.test.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.test-gw.id}"
  }
}

resource "aws_route_table_association" "subnet-association" {
  subnet_id      = "${aws_subnet.public-subnet.id}"
  route_table_id = "${aws_route_table.route-table-test.id}"
}

# Add ssh key for server access
resource "aws_key_pair" "spot_key" {
  key_name   = "spot_key"
  public_key = "${file("/XXX/XXXX/.ssh/id_rsa.pub")}"
}


# Spot instance request
resource "aws_spot_instance_request" "test_worker" {
  ami                    = "ami-id"
  spot_price             = "0.085"
  instance_type          = "c5.large"
  spot_type              = "one-time"
  block_duration_minutes = "120"
  wait_for_fulfillment   = "true"
  key_name               = "spot_key"
  iam_instance_profile = "${aws_iam_instance_profile.test_profile.name}"

  security_groups = ["${aws_security_group.ingress-ssh-test.id}", "${aws_security_group.ingress-http-test.id}",
  "${aws_security_group.ingress-https-test.id}"]
  subnet_id = "${aws_subnet.public-subnet.id}"
}

