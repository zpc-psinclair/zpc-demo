##### Output:



provider "azurerm" {
  features {}
}

##### AWS Accounts #####:

module "aws-card-processing-dev" {
 source = "./modules/aws/dev/card_processing"
}



##### Azure subscriptions  #####: 

//***** Staging:

module "azure-mission-critical-staging" {
 source = "./modules/azure/staging/azure-mission-critical-staging"
 subscription = "56b6df76-a0ac-4789-aeaf-22f96ddc0010"
}


module "azure-corp-shared-staging" {
 source = "./modules/azure/staging/azure-corp-shared-staging"
 subscription = "92f20396-4c9c-499e-99e1-b0fcd5116acf"
}


//***** Dev:

module "azure-mission-critical-dev" {
 source = "./modules/azure/dev/azure-mission-critical-dev"
 subscription = "b0551d56-3e8b-4446-9a5b-1443eb009e16"
}



/*

module "azure-corp-shared-dev" {
 source = "./modules/azure/dev/azure-corp-shared-dev"
 subscription = ""
}


//***** Prod:


module "azure-mission-critical-prod" {
 source = "./modules/azure/prod/azure-mission-critical-prod"
 subscription = ""
}

module "azure-corp-shared-prod" {
 source = "./modules/azure/prod/azure-corp-shared-prod"
 subscription = ""
}
*/

##### GCP projects  #####: 

/*
//***** Staging:

module "gcp-hr-staging" {
 source = "./modules/azure/staging/azure-mission-critical-staging"
 subscription = "56b6df76-a0ac-4789-aeaf-22f96ddc0010"
}


module "gcp-finance-staging" {
 source = "./modules/azure/staging/azure-corp-shared-staging"
 subscription = "92f20396-4c9c-499e-99e1-b0fcd5116acf"
}

*/
//***** Dev:

/*

module "gcp-hr-dev" {
 source = "./modules/azure/dev/azure-mission-critical-dev"
 subscription = "b0551d56-3e8b-4446-9a5b-1443eb009e16"
}

*/


module "gcp-erp-dev" {
 source = "./modules/gcp/dev/erp"
 project = "cwp-sales-c-proj-2"
}


/*

//***** Prod:


module "gcp-hr-prod" {
 source = "./modules/azure/prod/azure-mission-critical-prod"
 subscription = ""
}

*/

module "gcp-erp-prod" {
 source = "./modules/gcp/prod/erp"
 project = "cwp-sales-a-proj-1"
}
