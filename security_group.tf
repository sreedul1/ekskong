

data "aws_subnet_ids" "this" {
  vpc_id = var.eks_vpc_id
}

data "aws_subnet" "this" {
  for_each = data.aws_subnet_ids.this.ids
  id       = each.value
}

output "subnet_cidr_blocks" {
  value = [for s in data.aws_subnet.this : s.cidr_block]
}

##################   SECURITY GROUP ##################

resource "aws_security_group" "main_eksclustersg" {
  name        = "${var.cluster_name}-${var.environment_id}-ekscluster-sg"
  description = "Cluster communication with worker nodes"
  vpc_id      = var.eks_vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [for s in data.aws_subnet.this : s.cidr_block]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [for s in data.aws_subnet.this : s.cidr_block]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_name}-${var.environment_id}-eks-sg"
  }
}

