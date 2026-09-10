# V.37 Storage

**Repo: https://github.com/00aughar/azure-Mov25.git**

**August Hartwig** 
**MOV25** 
**x/x**

## 1. Skapa ett Storage Account

Via Azure portalen navigera till *Storage Account* och skapa ett storage account för resursgruppen *rg-novatrix*. Namn *stnovatrix552*, Typ *Blob storage* och redundans *LRS*

Syftet är att ha en samlingsplats där all vår lagring kommer att samlas

## 2. Skapa en blob container och ladda upp en fil

Navigera till Storage Account *stnovatrix552* och välj *Containers*. Skapa ny container, namn *arenden*. Öppna sedan containern *arenden* och välj upload och välj en fil. Öppna filen och testa besöka dens URL för att säkerställa att den är privat.

## 3. Verifiera att storage account/container är i rätt resursgrupp

Se till att storage account *stnovatrix552*, blob container *arenden* & upladad fil (blob) ligger i resursgruppen *rg-novatrix*

## 4. Generera SAS token för enskild fil

Navigera till blob container *arenden* och välj uppladdad fil. Välj Generate SAS och välj ett snävt tidspann och generate

## 5. Sätt RBAC på Storage Account

Navigera till storage account *stnovatrix552* och Access Control (IAM) och välj rollen *Storage Blob Data Reader* och tilldela på managed identity *id-novatrix-app*

## 6. Verifiera Secure transfer & Blob anonymous access

Navigera till storage account *stnovatrix552* och Configuration. Kontrollera att Secure Transfer är Enabled & Blob anonymous access är disabled

Verifiera att det funkar genom att besöka en blobs anonyma URL och se om det blir nekad. Då är publik åtkomst avstängd.


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
  --role "Storage Blob Data Reader" \
  --assignee cb7bff1b-d2c7-4f37-8983-e114969d0902 \
  --scope "//subscriptions/c65a0fbb-a7a6-42f1-8743-0e248b213c2c/resourceGroups/rg-novatrix/providers/Microsoft.Storage/storageAccounts/stnovatrix775"
```

# Stäng publik åtkomst

  ```
az storage account update --name stnovatrix --allow-blob-public-access false
  ```

# Generera SAS för blob

Hämta blobens url och definera när SAS token ska gå ut.

  ```
az storage blob generate-sas --blob-url https://stnovatrix775.blob.core.windows.net/arenden/web-browsers.jpeg --permissions r --expiry 2026-09-10T23:59:00Z --account-name stnovatrix775
  ```

## Motivering till Lagringslösnning

Lagringslösningen tillämpar Hot storage som default på Storage Account *stnovatrix775* vilket innebär att blobar på blob container *arenden* också kategoriseraas som hot storage. Anledningen till detta är att det blir billigare att öppna filerna som öppnas regelbundet och det går snabbare jämfört med ifall vi hade haft Cool storage där varje gång en fil öppnas blir en dyrare kostnad om den öppnas regelbundet och det går långsamare.

Blob delas ut med en SAS token vilket innebär att vi tillämpar least privledge till en viss nivå. Åtkomsten till filen blir tillfälig inom en kort tidsram och är bunden till den privata länken. Detta är en mycket säkrare lösning än med enkla nycklar som inte har någon tidsbegränsing och ger åtkomst till vem som helst som får tag i nyckeln.

RBAC tillämpas genom att ge Managed Identity *id-novatrix-app* RBAC rollen *Storage Blob Data Reader* för storage account *stnovatrix775*. Syftet är att begränsa läsrättigheterna till en hanterad identitet istället för enskilda användarkonton. 