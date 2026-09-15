# V.37 Storage

**Repo: https://github.com/00aughar/azure-Mov25.git**

**August Hartwig** 
**MOV25** 
**15/9**

## 1. Skapa ett Storage Account

Via Azure portalen navigera till *Storage Account* och skapa ett storage account för resursgruppen *rg-novatrix*. Namn *stnovatrix552*, Typ *Blob storage* och redundans *LRS*

Syftet är att ha en samlingsplats där all vår lagring kommer att samlas.



## 2. Skapa en blob container och ladda upp en fil

Navigera till Storage Account *stnovatrix552* och välj *Containers*. Skapa ny container, namn *arenden*. Öppna sedan containern *arenden* och välj upload och välj en fil. Öppna filen och testa besöka dens URL för att säkerställa att den är privat.

Syftet med en blob container är att få en samlingsplats för tjänsterna som ska lagra sin data.

## 3. Verifiera att storage account/container är i rätt resursgrupp

Se till att storage account *stnovatrix552*, blob container *arenden* & upladad fil (blob) ligger i resursgruppen *rg-novatrix*

![alt text](<storage account verifiering-1.png>)

![alt text](<fil verifiering.png>)

## 4. Generera SAS token för enskild fil

Navigera till blob container *arenden* och välj uppladdad fil. Välj Generate SAS och välj ett snävt tidspann och generate.

Syftet är att kunna öppna blobar säkert utan en publik nyckel. Med en tidsbegränsad generad URL är datan mindre exponerad och minskar risken att läcka ut.

![alt text](<SAS token.png>)

## 5. Sätt RBAC på Storage Account med hanterad identitet

Navigera till storage account *stnovatrix552* och blob container *arenden*, välj Access Control (IAM) och välj rollen *Storage Blob Data Reader* och tilldela på managed identity *id-novatrix-app*.

Syftet med detta är att ha tryggare åtkomst till innehållet i blob containern och slippa använda enskilda nycklar som kan hamna i fel händer. Endast applikationen ska kunna läsa innehåll och blobar i container *arenden*.

![alt text](<IAM form app arenden.png>)

## 6. Verifiera Secure transfer & Blob anonymous access

Navigera till storage account *stnovatrix552* och Configuration. Kontrollera att Secure Transfer är Enabled & Blob anonymous access är disabled

![alt text](<Verifiering secure transfer.png>)

Verifiera att det funkar genom att besöka en blobs anonyma URL och se om det blir nekad. Då är publik åtkomst avstängd.

![alt text](<Privat Blob.png>)

## Challenge


Skapa storage account, definera namn, vilken prestanda och redundans (LRS), modern kontotyp & resursgruppen.

```
az storage account create --name stnovatrix775 --sku Standard_LRS --kind StorageV2 --resource-group rg-novatrix

```
Skapa storage container. Namngivning, vilket storage account. Auth-mode login, istället för att använda en nyckel.

```
az storage container create --name arenden --account-name stnovatrix775 --auth-mode login
```

Ladda upp en fil till containern

```
az storage blob upload --container-name arenden --name web-browsers.jpeg --file ./web-browsers.jpeg --account-name stnovatrix775

```

Verifiera 1. Lista containrar 2.Lista blobar i container

```
#1.
az storage container list -o table --account-name stnovatrix775

#2. 
az storage blob list -o table --account-name stnovatrix775 --container-name arenden

```
Reslutat: ![alt text](<Verifiera container & fil script.png>)

# Tilldela RBAC roll till managed identity

Role = RBAC rollen
Assigne = Object (principal) ID (Managed Identity)
Scope = Storage account resource ID (Endpoints Azure Portalen)

```
az role assignment create \
  --role "Storage Blob Data Contributor" \
  --assignee cb7bff1b-d2c7-4f37-8983-e114969d0902 \
  --scope "//subscriptions/c65a0fbb-a7a6-42f1-8743-0e248b213c2c/resourceGroups/rg-novatrix/providers/Microsoft.Storage/storageAccounts/stnovatrix775"
```

# Stäng publik åtkomst

  ```
az storage account update --name stnovatrix --allow-blob-public-access false
  ```

# Generera SAS token för blob

Generera token för blobens url och definera när SAS token ska gå ut.

  ```
az storage blob generate-sas --blob-url https://stnovatrix775.blob.core.windows.net/arenden/web-browsers.jpeg --permissions r --expiry 2026-09-10T23:59:00Z --account-name stnovatrix775
  ```


## Motivering till Lagringslösnning

Kostnad för lagring, lagringsskydd & redundas
- Lagringslösningen tillämpar Hot storage som default på Storage Account *stnovatrix775* vilket innebär att blobar på blob container *arenden* också kategoriseras som hot storage. Anledningen till detta val av lagring är att det blir billigare att öppna filerna då dem förväntas öppnas regelbundet för att se svar och filer från ifyllda formulär.
- Lagringen har en LRS redundans vilket innebär att tre kopior av datan lagras inom ett datascenter. Detta är billigaste lösningen och fungerar för nuvarande miljö då det främst är en testmiljö.

- RBAC tillämpas genom att appen skriver ärenden och bilaga till storage blob containern utan att använda lösenord och nyckel. den virtuella maskinen *vm-novatrix-web* med applikationen *arendeapp.service* autentiserar sig genom sin hanterade identitet som *Blob Data Contributor*. Detta gör att appen endast får rätt till containern och inte hela kontot och kan skriva in datan från ifyllda formulär.

- Vid behov kan blob delas ut med en SAS token vilket innebär att vi tillämpar least privledge till en viss nivå. Åtkomsten till filen blir tillfälig inom en kort tidsram och är bunden till den privata länken. Detta är en mycket säkrare lösning än med enkla nycklar som inte har någon tidsbegränsing och ger åtkomst till vem som helst som får tag i nyckeln.

## Förberedd virtuell maskin för backend ärende appen och mottagande av formulär till storage account

För att formuläret som fylls i behövs en backend applikation som kan skriva av ifylld data till vår storage account. Genom att använda veckans *cloud-init.txt* byggs en VM upp med applikationen *app.py*, html sidan *index.html* & azure bibliotket. Detta driftsätter miljön och skapar en fungerande formulär websida.


Testa skicka ett ifyllt formulär:
![alt text](<ifyllt formulär.png>)

Skickat:
![alt text](<ärende skickat.png>)

Kolla om formulär och blob har skrivits över till blob container:
![alt text](<mottaget formulär blob.png>)

Kolla blobens innehåll via Azure:
![alt text](<Bifogad bild formulär.png>)

![alt text](<formulär info.png>)


Verifiera att ärenden har kommit till blob container via script:

```
az storage blob list --account-name stnovatrix775 --container-name arenden --auth-mode login --output table
```
Resultat:

![alt text](<ärenden verifiering terminal.png>)