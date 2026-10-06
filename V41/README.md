# V.41 Tenta

**Repo: https://github.com/00aughar/azure-Mov25.git**

**August Hartwig** 
**MOV25** 
**x/x**

Skapa resursgruppen
```
az group create --name rg-nordvik --location swedencentral
```

Skapa grupper förvaltare & ekonomi
```
az ad group create --display-name grp-nordvik-forvaltare --mail-nickname grp-nordvik-forvaltare
az ad group create --display-name grp-nordvik-ekonomi --mail-nickname grp-nordvik-ekonomi
```

Deploya
```
az group create --name rg-nordvik --location swedencentral \
  --tags foretag=nordvik projekt=hyresgastportal avdelning=forvaltning miljo=test

az deployment group validate --resource-group rg-nordvik \
  --template-file main.json --parameters @main.parameters.json

az deployment group what-if --resource-group rg-nordvik \
  --template-file main.json --parameters @main.parameters.json

az deployment group create --resource-group rg-nordvik --name nordvik-v1 \
  --template-file main.json --parameters @main.parameters.json
```