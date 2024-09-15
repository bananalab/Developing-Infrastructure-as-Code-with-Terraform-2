data "aws_eks_cluster" "example" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "example" {
  name = var.cluster_name
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.example.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.example.certificate_authority[0].data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", var.cluster_name]
    }
  }
}

resource "helm_release" "atlantis" {
  namespace        = "atlantis"
  name             = "atlantis"
  repository       = "https://runatlantis.github.io/helm-charts"
  chart            = "atlantis"
  version          = "5.5.0"
  wait             = true
  create_namespace = true
}
