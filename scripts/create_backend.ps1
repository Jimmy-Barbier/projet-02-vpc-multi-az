# Script de création du backend Terraform
# A exécuter UNE SEULE FOIS avant terraform init

Write-Host "Creation du backend Terraform S3 + DynamoDB..." -ForegroundColor Cyan

# Variables
$BUCKET_NAME = "projet-02-terraform-state"
$TABLE_NAME = "projet-02-terraform-locks"
$REGION = "eu-west-3"

# Création du bucket S3
Write-Host "Creation du bucket S3 : $BUCKET_NAME" -ForegroundColor Yellow
aws s3 mb s3://$BUCKET_NAME --region $REGION

# Activation du versioning
Write-Host "Activation du versioning S3..." -ForegroundColor Yellow
aws s3api put-bucket-versioning `
  --bucket $BUCKET_NAME `
  --versioning-configuration Status=Enabled

# Activation du chiffrement
Write-Host "Activation du chiffrement S3..." -ForegroundColor Yellow
aws s3api put-bucket-encryption `
  --bucket $BUCKET_NAME `
  --server-side-encryption-configuration "{\"Rules\":[{\"ApplyServerSideEncryptionByDefault\":{\"SSEAlgorithm\":\"AES256\"}}]}"

# Blocage accès public
Write-Host "Blocage acces public S3..." -ForegroundColor Yellow
aws s3api put-public-access-block `
  --bucket $BUCKET_NAME `
  --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

# Création table DynamoDB
Write-Host "Creation de la table DynamoDB : $TABLE_NAME" -ForegroundColor Yellow
aws dynamodb create-table `
  --table-name $TABLE_NAME `
  --attribute-definitions AttributeName=LockID,AttributeType=S `
  --key-schema AttributeName=LockID,KeyType=HASH `
  --billing-mode PAY_PER_REQUEST `
  --region $REGION

Write-Host "Backend Terraform cree avec succes !" -ForegroundColor Green
Write-Host "Tu peux maintenant lancer : terraform init" -ForegroundColor Green