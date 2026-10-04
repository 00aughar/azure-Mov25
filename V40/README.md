# V.40 Virtualiseringsnivåer

**Repo: https://github.com/00aughar/azure-Mov25.git**

**August Hartwig** 
**MOV25** 
**x/x**

Container för snabb driftsättning. Formuläret tillgänglig för användare. Balans mellan självkontroll och ingen kontroll



Skapa acr

```
az acr create --resource-group rg-novatrix --name novatrixacr652 --sku basic
```

Bygg imagen i molnet
```
az acr build --registry novatrixacr652 --image novatrix-app:v1 .
```




Kör containern
```
az container create
```