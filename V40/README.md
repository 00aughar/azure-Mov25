# V.40 Virtualiseringsnivåer

**Repo: https://github.com/00aughar/azure-Mov25.git**

**August Hartwig** 
**MOV25** 
**x/x**

Container för snabb driftsättning. Formuläret tillgänglig för användare. Balans mellan självkontroll och ingen kontroll



Skapa acr register i resursgrupp *rg-novatrix* och namnge till *novatrixacr652*.

```
az acr create --resource-group rg-novatrix --name novatrixacr652 --sku basic
```

Bygg imagen i molnet
```
az acr build --registry novatrixacr652 --image novatrix-app:v1 .
```

Verifiera
```
az acr repository list --name novatrixacr652 --output table
```

Aktivera adminanvändare på ACR

```
az acr update --name novatrixacr652 --admin-enabled true
```

Kör containern
```
ACR_PW=$(az acr credential show --name novatrixacr652 --query "passwords[0].value" -o tsv)

az container create --resource-group rg-novatrix --name novatrix-app \
  --image novatrixacr652.azurecr.io/novatrix-app:v1 \
  --os-type Linux --cpu 1 --memory 1 --ports 80 \
  --dns-name-label novatrix-app-652 \
  --registry-username novatrixacr652 --registry-password "$ACR_PW"
```

Hämta addresen

```
novatrix-app-652.swedencentral.azurecontainer.io
```