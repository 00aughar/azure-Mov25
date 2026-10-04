# V.40 Virtualiseringsnivåer

**Repo: https://github.com/00aughar/azure-Mov25.git**

**August Hartwig** 
**MOV25** 
**x/x**





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
![alt text](Verifiera.png)

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

Hämta addresen och besök formulärsidan

```
novatrix-app-652.swedencentral.azurecontainer.io
```

Resultat:

![alt text](<Formulär uppe.png>)

# Motivering

Virtualiseringsnivåerna

VM - Hög kontroll men mycket egen drift, egna skript och underhåll. Tar längre tid att starta upp från grunden. Körtid per sekund när den är aktiv, dyrare i längden då den debiteras även när den är overkasam

Container - För en lätt & snabb driftsättning som är portabel. Formuläret tillgänglig för användare. Balans mellan självkontroll och ingen kontroll. Kostnaden baseras på allokerade resurser, container som är aktiv kostar lika mycket även om den inte tar emot ärenden. Däremot sparas kostnader för driftunderhåll då vi slipper hantera ett operativsystem.

Serverless - Tar bort servern och blir endast en tjänst endast uppbyggd på kod. Underhåll och drift försvinner och blir enkel att hålla igång. Kostnad per körning, passar för tjänster som inte behöver nås konstant

Skillnader


VG
Novatrix behov, kostnad, skalbarhet och drift, och
beskriv hur du skulle optimera lösningen.