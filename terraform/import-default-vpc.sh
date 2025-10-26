#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Auto-import default VPC and its subresources into Terraform state
# Creates Terraform stubs and imports existing AWS resources
# Requires: AWS CLI + jq + Terraform already initialized in this folder
# ------------------------------------------------------------------------------

set -euo pipefail

OUTFILE="generated-default-vpc.tf"
LOGFILE="import-default-vpc.log"
> "$LOGFILE"

echo "🔍 Detecting default VPC..."
VPC_ID=$(aws ec2 describe-vpcs --filters "Name=is-default,Values=true" --query "Vpcs[0].VpcId" --output text)
if [[ "$VPC_ID" == "None" ]]; then
  echo "❌ No default VPC found!"
  exit 1
fi
echo "✅ Found default VPC: $VPC_ID"

echo "# Auto-generated Terraform stubs for default VPC: $VPC_ID" > "$OUTFILE"
echo "" >> "$OUTFILE"

# --- VPC ---------------------------------------------------------------------
CIDR=$(aws ec2 describe-vpcs --vpc-ids "$VPC_ID" --query "Vpcs[0].CidrBlock" --output text)
echo "resource \"aws_vpc\" \"default\" {" >> "$OUTFILE"
echo "  cidr_block           = \"$CIDR\"" >> "$OUTFILE"
echo "  enable_dns_support   = true" >> "$OUTFILE"
echo "  enable_dns_hostnames = true" >> "$OUTFILE"
echo "  tags = { Name = \"default\" }" >> "$OUTFILE"
echo "}" >> "$OUTFILE"
echo "" >> "$OUTFILE"
echo "terraform import aws_vpc.default $VPC_ID" >> "$LOGFILE"

# --- Internet Gateway --------------------------------------------------------
IGW_ID=$(aws ec2 describe-internet-gateways \
  --filters "Name=attachment.vpc-id,Values=$VPC_ID" \
  --query "InternetGateways[0].InternetGatewayId" --output text 2>/dev/null || true)
if [[ "$IGW_ID" != "None" && -n "$IGW_ID" ]]; then
  echo "resource \"aws_internet_gateway\" \"default_igw\" {" >> "$OUTFILE"
  echo "  vpc_id = aws_vpc.default.id" >> "$OUTFILE"
  echo "  tags = { Name = \"DefaultInternetGateway\" }" >> "$OUTFILE"
  echo "}" >> "$OUTFILE"
  echo "" >> "$OUTFILE"
  echo "terraform import aws_internet_gateway.default_igw $IGW_ID" >> "$LOGFILE"
  echo "✅ Found Internet Gateway: $IGW_ID"
fi

# --- Subnets -----------------------------------------------------------------
aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" \
  --query "Subnets[*].{id:SubnetId,cidr:CidrBlock,az:AvailabilityZone}" \
  --output json | jq -c '.[]' | while read -r sn; do
  ID=$(echo "$sn" | jq -r .id)
  CIDR=$(echo "$sn" | jq -r .cidr)
  AZ=$(echo "$sn" | jq -r .az)
  NAME=$(echo "$AZ" | tr -dc 'a-zA-Z0-9')
  echo "resource \"aws_subnet\" \"default_${NAME}\" {" >> "$OUTFILE"
  echo "  vpc_id     = aws_vpc.default.id" >> "$OUTFILE"
  echo "  cidr_block = \"$CIDR\"" >> "$OUTFILE"
  echo "  availability_zone = \"$AZ\"" >> "$OUTFILE"
  echo "  tags = { Name = \"DefaultSubnet-$AZ\" }" >> "$OUTFILE"
  echo "}" >> "$OUTFILE"
  echo "" >> "$OUTFILE"
  echo "terraform import aws_subnet.default_${NAME} $ID" >> "$LOGFILE"
  echo "✅ Found Subnet: $ID ($AZ)"
done

# --- Route Tables ------------------------------------------------------------
aws ec2 describe-route-tables --filters "Name=vpc-id,Values=$VPC_ID" \
  --query "RouteTables[*].RouteTableId" --output text | tr '\t' '\n' | while read -r rtb; do
  echo "resource \"aws_route_table\" \"rt_${rtb}\" {" >> "$OUTFILE"
  echo "  vpc_id = aws_vpc.default.id" >> "$OUTFILE"
  echo "  tags = { Name = \"Imported-$rtb\" }" >> "$OUTFILE"
  echo "}" >> "$OUTFILE"
  echo "" >> "$OUTFILE"
  echo "terraform import aws_route_table.rt_${rtb} $rtb" >> "$LOGFILE"
  echo "✅ Found Route Table: $rtb"
done

# --- Default Security Group --------------------------------------------------
SG_ID=$(aws ec2 describe-security-groups \
  --filters "Name=vpc-id,Values=$VPC_ID" "Name=group-name,Values=default" \
  --query "SecurityGroups[0].GroupId" --output text)
if [[ "$SG_ID" != "None" ]]; then
  echo "resource \"aws_security_group\" \"default_sg\" {" >> "$OUTFILE"
  echo "  vpc_id = aws_vpc.default.id" >> "$OUTFILE"
  echo "  name   = \"default\"" >> "$OUTFILE"
  echo "  description = \"Default VPC security group\"" >> "$OUTFILE"
  echo "}" >> "$OUTFILE"
  echo "" >> "$OUTFILE"
  echo "terraform import aws_security_group.default_sg $SG_ID" >> "$LOGFILE"
  echo "✅ Found Default Security Group: $SG_ID"
fi

# -----------------------------------------------------------------------------
echo ""
echo "✅ Terraform stub file written to: $OUTFILE"
echo "✅ Import commands written to: $LOGFILE"
echo ""

# --- Run the imports automatically ------------------------------------------
echo "⚙️  Importing resources into Terraform state..."
while read -r line; do
  echo "→ $line"
  eval "$line"
done < "$LOGFILE"

echo ""
echo "✅ All resources imported successfully!"
echo "Now run: terraform plan"

