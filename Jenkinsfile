pipeline {
  agent { docker {image 'keyurbitw/terraform-docker'}}
  stages {
    stage('Download the Cluster Spec') {
      steps{
        sh 'curl https://raw.githubusercontent.com/keyurbitw/clusterspecs/main/devops-eks-cluster-clusterspec.yaml > clusterspec.yaml'
        sh 'cat clusterspec.yaml | yq .spec > terraform.tfvars.json'
      }
    }
    stage('Clone Terraform EKS Source'){
      steps{
        git branch: 'main', credentialsId: 'GitCreds', url: 'https://github.com/keyurbitw/eks-terraform.git'
        sh 'ls -al'
      }
    }
    stage('Teraform Init'){
      steps {
        sh 'echo "Initializing Terraform"'
        sh 'terraform init'
      }
    }
    stage('Terraform Plan'){
      steps {
        sh 'terraform plan -input=false --var-file=terraform-tfvars.json -out=terraform.out'
        input('Do you want to proceed with Terraform Apply')
      }
    }
    stage('Terraform Apply'){
      steps {
        sh 'terraform apply terraform.out -input=false'
      }
    }
    stage('Save Terraform Output')
      steps {
        sh 'terraform output cluster-kubeconfig > eks-kubeconfig'
        sh 'terraform output worker-node-private-key > woker-node-key'
      }
  }
}
