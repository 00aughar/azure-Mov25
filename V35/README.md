# V.35 Novatrix, IAM och identitet

**Repo: https://github.com/00aughar/azure-Mov25.git**

**August Hartwig** 
**MOV25** 
**x/x**

1. Skapa användare i Azure portalen via Entra.

Användarkontona ämnade åt tjänsten/åtkomsten alltså inget vanligt användarkonto 

2. Skapa säkerhetsgrupp i azure portalen via Entra

3. RBAC, behörighet & scope

Tilldela roll till säkerhetsgrupp och sätt scope på vilka resursgrupper som ska styras av medlemmarna. Tillämpa least privledge.

Drift avdelningen har contributor behörighet på resursgrupp rg-novatrix. Motivering: bygger och sköter underhåll av miljön.

Utveckling avdelningen har reader behörighet på resursgrupp rg-novatrix. Motivering: Ser över miljön.

![alt text](Rolltilldelningar.png)

4. Verifiering RBAC

1. Verifiering via Azure portalen. Gå till resursen i azure portalen och access control kontrollerar jag avdelningskontot för båda användarna. Där får jag en överblick på vilken rolltildening dem har och att dem tillhör grupptilldelningen.

![alt text](<Kontroll utveckling.png>)
![alt text](<Kontroll drift.png>)

2. Verifiera via att gå in via kontot och testa så rolltildelningen tillämpas.

![alt text](<erik starta VM test.png>)

5. Skapa Managed Identity

Skapad managed identity för kommande utveckling av Novatrix formulär applikation. Tilldelad till resursgrupp "rg-Novatrix"

![alt text](<managed identity.png>)

6. Challenge

Scriptet "rbac-novatrix.sh" automatiserar rolltildeningen (RBAC) för Novatrix miljön via Azure CLI. Med scriptet slipper jag bygga upp behörighetsstrukturen via manuella steg och gör att miljön blir repoducerbar. 

Scriptet delas upp i följande steg:

1. Definera variabler som används. Här har vi resursgruppen som grupperna ska tilldelas behörighet till. Prenumerations ID defineras.

```
RESOURCE_GROUP="rg-novatrix"
DRIFT_GROUP="Novatrix-Drift"
DEV_GROUP="Novatrix-Utveckling"
SUBSCRIPTION_ID="c65a0fbb-a7a6-42f1-8743-0e248b213c2c"
``` 

2. Scopet hämtas genom att ta fram ID på resursgruppen som ska tilldeas behörigheter för resursgrupperna.

```
RG_ID=$(az group show --name "$RESOURCE_GROUP" --query id -o tsv)
```

3. Unikt ID på säkerhetsgrupperna hämtas från Entra ID. *"Novatrix-Drift"* & *"Novatrix-Utveckling"* 

```
DRIFT_GROUP_ID=$(az ad group show --group "$DRIFT_GROUP" --query id -o tsv)
DEV_GROUP_ID=$(az ad group show --group "$DEV_GROUP" --query id -o tsv)

```

4. RBAC tilldelning på resursgruppen *"rg-novatrix"*.

- *Novatrix-Drift* tilldelas *Contributor* för att kunna utföra nödvändigt underhåll av resurserna i resursgruppen. Exemepelvis hantera, starta & konfigurera resurserna, men inte hantera andras behörigheter. Endast Owner får göra detta.

- *Novatrix-Utveckling* tilldelas *Reader* för att kunna granska statusen, nätverkskonfigurationen & loggar på resurserna utan att riskera att oavsiktliga ändringar eller driftstörningar görs. 

```
az role assignment create \
  --assignee-object-id "$DRIFT_GROUP_ID" \
  --assignee-principal-type Group \
  --role "Contributor" \
  --scope "$RG_ID"

az role assignment create \
  --assignee-object-id "$DEV_GROUP_ID" \
  --assignee-principal-type Group \
  --role "Reader" \
  --scope "$RG_ID"
```

Resultat:
![alt text](<VG del tilldelning-1.png>)

