#!/bin/bash

# Variables
resourceGroup="acdnd-c4-project"
location="eastus"
osType="UbuntuLTS"
vmssName="udacity-vmss"
adminName="udacityadmin"
storageAccount="udacitydiag$RANDOM"
bePoolName="$vmssName-bepool"
lbName="$vmssName-lb"
lbRule="$lbName-network-rule"
nsgName="$vmssName-nsg"
vnetName="$vmssName-vnet"
subnetName="$vnetName-subnet"
probeName="tcpProbe"
vmSize="Standard_B2s"
storageType="Standard_LRS"

# Create resource group
echo "Creating resource group $resourceGroup..."

#az group create --name acdnd-c4-project --location eastus

echo "Resource group created: $resourceGroup"

# Create Storage account
echo "Creating storage account $storageAccount"

az storage account create \
--name $storageAccount \
--resource-group $resourceGroup \
--location $location \
--sku Standard_LRS

echo "Storage account created: $storageAccount"

# Create Network Security Group
echo "Creating network security group $nsgName"

az network nsg create \
--resource-group $resourceGroup \
--name $nsgName \
--verbose

echo "Network security group created: $nsgName"

# Create VM Scale Set
echo "Creating VM scale set $vmssName"

az vmss create \
  --resource-group $resourceGroup \
  --name $vmssName \
  --image $osType \
  --vm-sku $vmSize \
  --nsg $nsgName \
  --subnet $subnetName \
  --vnet-name $vnetName \
  --backend-pool-name $bePoolName \
  --storage-sku $storageType \
  --load-balancer $lbName \
  --custom-data cloud-init.txt \
  --upgrade-policy-mode automatic \
  --admin-username $adminName \
  --generate-ssh-keys \
  --verbose

echo "VM scale set created: $vmssName"

# Associate NSG with VMSS subnet
echo "Associating NSG: $nsgName with subnet: $subnetName"

az network vnet subnet update \
--resource-group $resourceGroup \
--name $subnetName \
--vnet-name $vnetName \
--network-security-group $nsgName \
--verbose

echo "NSG: $nsgName associated with subnet: $subnetName"

# Create Health Probe
echo "Creating health probe $probeName"

az network lb probe create \
  --resource-group $resourceGroup \
  --lb-name $lbName \
  --name $probeName \
  --protocol tcp \
  --port 80 \
  --interval 5 \
  --threshold 2 \
  --verbose

echo "Health probe created: $probeName"

# Create Network Load Balancer Rule
echo "Creating network load balancer rule $lbRule"

az network lb rule create \
  --resource-group $resourceGroup \
  --name $lbRule \
  --lb-name $lbName \
  --probe-name $probeName \
  --backend-pool-name $bePoolName \
  --backend-port 80 \
  --frontend-ip-name loadBalancerFrontEnd \
  --frontend-port 80 \
  --protocol tcp \
  --verbose

echo "Network load balancer rule created: $lbRule"

# Add port 80 to inbound rule NSG
echo "Adding port 80 to NSG $nsgName"

az network nsg rule create \
--resource-group $resourceGroup \
--nsg-name $nsgName \
--name Port_80 \
--destination-port-ranges 80 \
--direction Inbound \
--priority 100 \
--verbose

echo "Port 80 added to NSG: $nsgName"

# Add port 22 to inbound rule NSG
echo "Adding port 22 to NSG $nsgName"

az network nsg rule create \
--resource-group $resourceGroup \
--nsg-name $nsgName \
--name Port_22 \
--destination-port-ranges 22 \
--direction Inbound \
--priority 110 \
--verbose

az vmss list-instance-connection-info --resource-group acdnd-c4-project --name udacity-vmss

echo "Port 22 added to NSG: $nsgName"

echo "VMSS script completed!"
#cd azure-vote 
#scp -i /home/andi/.ssh/id_rsa.pub -P 50000 requirements.txt  udacityadmin@52.149.156.238:
#scp -i /home/andi/.ssh/id_rsa.pub -P 50000 -r ./azure-vote  udacityadmin@52.149.156.238:
#scp -i /home/andi/.ssh/id_rsa.pub -P 50001 requirements.txt  udacityadmin@52.149.156.238:
#scp -i /home/andi/.ssh/id_rsa.pub -P 50001 -r ./azure-vote  udacityadmin@52.149.156.238:

#ssh -p 50000 udacityadmin@52.149.156.238
#sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.6 1
#sudo apt install python3-pip
#pip3 install -r requirements.txt
#python3 ./azure-vote/main.py

