# V.38 IaC

**Repo: https://github.com/00aughar/azure-Mov25.git**

**August Hartwig** 
**MOV25** 
**x/x**


För godkänt började jag med template mallen *miljo-skelett.json* och byggde upp strukturen där en NSG med öppen webbregel för port 80 & 443, VNEt & subnät samt ett storage account. Namn och region gjorde som parametrar.

```
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "metadata": {
    "note": "SKELETT att bygga vidare i. Strukturen finns, men resources ar tom med flit. Fyll i sjalv. Att gora (G): en NSG med en webbregel (portar 80 och 443), ett VNet med ett subnat, och ett storage account. For VG: lagg till en VM och koppla ihop resurserna med dependsOn. Titta i de enkla exempelfilerna for monstret: varje resurs har type, apiVersion, name, location och properties. Parametrarna har defaultvarden, sa du kan deploya direkt med: az deployment group create -g rg-novatrix --template-file miljo-skelett.json (eller gor en egen parameterfil nar du vill styra vardena)."
  },
  
  "parameters": {
    "namePrefix": {
      "type": "string",
      "defaultValue": "novatrix",
      "metadata": { "description": "Prefix for alla resursnamn, sa att allt hanger ihop." }
    },
    "location": {
      "type": "string",
      "defaultValue": "swedencentral",
      "metadata": { "description": "Region for resurserna." }
    },
      "storageName": {
    "type": "string",
    "metadata": { "description": "Globalt unikt namn, endast gemener och siffror, max 24 tecken." }
  }
  },
  "variables": {
  "nsgWebName": "[concat('nsg-', parameters('namePrefix'), '-web')]",
  "vnetName": "[concat('vnet-', parameters('namePrefix'))]",
  "subnetWebName": "snet-web",
  "subnetWebPrefix": "10.20.1.0/24",
  "vnetPrefix": "10.20.0.0/16"
  },
  "resources": [
        {
      "type": "Microsoft.Storage/storageAccounts",
      "apiVersion": "2016-01-01",
      "name": "[parameters('storageName')]",
      "location": "[parameters('location')]",
      "sku": { "name": "Standard_LRS" },
      "kind": "Storage"
    }
    ,
    {
  "type": "Microsoft.Network/networkSecurityGroups",
  "apiVersion": "2017-06-01",
  "name": "[variables('nsgWebName')]",
  "location": "[parameters('location')]",
  "properties": {
    "securityRules": [
      {
        "name": "allow-web",
        "properties": {
          "priority": 100,
          "direction": "Inbound",
          "access": "Allow",
          "protocol": "Tcp",
          "sourceAddressPrefix": "Internet",
          "sourcePortRange": "*",
          "destinationAddressPrefix": "*",
          "destinationPortRanges": ["80", "443"]
        }
      }
    ]
  }
}
,
{
  "type": "Microsoft.Network/virtualNetworks",
  "apiVersion": "2017-06-01",
  "name": "[variables('vnetName')]",
  "location": "[parameters('location')]",
  "dependsOn": [
    "[resourceId('Microsoft.Network/networkSecurityGroups', variables('nsgWebName'))]"
  ],
  "properties": {
    "addressSpace": {
      "addressPrefixes": ["[variables('vnetPrefix')]"]
    },
    "subnets": [
      {
        "name": "[variables('subnetWebName')]",
        "properties": {
          "addressPrefix": "[variables('subnetWebPrefix')]",
          "networkSecurityGroup": {
            "id": "[resourceId('Microsoft.Network/networkSecurityGroups', variables('nsgWebName'))]"
          }
        }
      }
    ]
  }
}

  ],
  "outputs": {
  }
}
```


Testa template med what-if:

```
az deployment group what-if --resource-group rg-novatrix --template-file miljo-skelett.json
```

Deploya template:

```
az deployment group create \
  --resource-group rg-novatrix \
  --template-file miljo-skelett.json
```
Kontrollera resurser i resursgrupp:

```
az resource list --resource-group rg-novatrix -o table
```
