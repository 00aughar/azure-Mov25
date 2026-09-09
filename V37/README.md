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

