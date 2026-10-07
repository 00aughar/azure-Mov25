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

Del A, Dokumentation
Redogör för de centrala Azure-tjänster du använder inom Compute, nätverk och storage, och förklara
virtualiseringsnivåerna VM, containers och serverless samt vilken nivå du valt för Nordviks portal och varför.

Del B, Praktisk lösning
Planera och implementera infrastrukturen för hyresgästportalen med felanmälan:

Översikt

Webformulär > Blob Container > PowerAutomate flöde > Sharepoint lista > 


# Delmoment 1, Compute
Provisionera värdmiljön för portalen och driftsätt sidan med felanmälningsformuläret (rubrik, beskrivning,
bild).

Resursgrupp - *rg-nordvik*
VM - *vm-nordvik-web*


Värdmiljön för felanmälningsformuläret byggdes upp med konfigurationsfilen *cloud-init-nordvik.txt*. Konfigurationsfilen bygger webformuläret och applikationen i bakrunden som tar emot skickade formulär och bilder som sedan skickas vidare till blob-container *anmalningar*.

Tjänsten och nivå val: Jag valde att bygga portalen på en virtuell maskin i Azure portalen *vm-nordvik-web*, Storlek *Standard D2als v6 (2 vcpus, 4 GiB memory)* med Operativsystemet *ubuntu-24_04-lts*. VMen är en IaaS tjänst, Azure sköter den fysiska hårdvaran medans jag sköter ansvar för operativsystemet, uppdateringar och applikationer. Jag valde VM lösningen för att lasten är låg med cirka 5-10 samtida användare med en topp vid 120. Hela miljön byggs upp med kod (IaC). Begränsningarna med denna lösning tas upp i del A.

Konfigurationen: Maskinen konfigureras upp automatiskt med cloud-init filen *cloud-init-nordvik.txt* som skickas med i ARM-mallen *main.json* och tillhörande parameterfil *main.parameters.json*. Cloud-init filen konfigurerar Python bibliotken (flask, azure-identity och azure-storage-blob), lägger ut applikationen och registrerar den som tjänsten *felanmalan.service*. En ny VM blir därav identiskt konfigurerad om den behöver byggas upp igen.

Applikationen: Formuläret som innehåller fält för: rubrik, kategori, fastighet, beskrivning, bild, namn & e-post som sedan tas emot av flask-appen i bakrunden. När anmälan skickas sparar appen innehållet i en JSON-fil *arende-<id>.json* i blob container *anmalningar* tillsammans med eventuell bild. Väljs någon av följande kategorier i bifogat formulär "värme, vatten & lås" markeras dem som akuta (urgent) som appen anropar vidare till power-automate flödet *nordvik-felanmälan-http* som sedan sköter notis och SharePoint listan.

# Delmoment 2, IAM
Konfigurera identiteter och behörigheter för Nordviks roller enligt least privilege: hyresgäst ser och skapar
sina egna anmälningar, förvaltare hanterar dem, ekonomi har läsande insyn. Ge även portalen en hanterad
identitet för att nå lagringen.



# Delmoment 3, Nätverk och säkerhet
Bygg ett säkert nätverk runt lösningen med defense in depth. Portalen är publikt nåbar, medan lagringen av
anmälningar och bilder ligger skyddad.

# Delmoment 4, Storage
Koppla säker lagring för portalens dokument och bilder, så att en felanmälan med bild kan sparas.

# Delmoment 5, IaC
Provisionera lösningen med ARM-templates, versionshanterat i GitHub, så att den kan återskapas från repot.

# Delmoment 6, Automation och integration
Bygg ett arbetsflöde med Power Automate som integrerar Nordviks Microsoft 365: en inskickad felanmälan skapar
en post i en SharePoint-lista och en notis till förvaltaren i Teams eller Outlook.

## Beskrivning av PowerAutomate flödet *nordvik-felanmälan-http*

1. Trigger: När en HTTP-begäran tas emot (appen anropar flödets URL med anmälans JSON).
2. Skapa objekt (SharePoint): skapar en post i listan Felanmälningar med rubrik, kategori, fastighet, beskrivning, anmälare, datum och bild.
3. Publicera meddelande (Teams): notis till kanalen Förvaltare.
4. Villkor: urgent är lika med sant.
- Sant: Skicka e-post (V2) med ämnet "Akut ärende".
- Falskt: ingen åtgärd.

JSON schemat för trigger:
```
{
    "type": "object",
    "properties": {
        "id": {
            "type": "string"
        },
        "title": {
            "type": "string"
        },
        "description": {
            "type": "string"
        },
        "category": {
            "type": "string"
        },
        "urgent": {
            "type": "boolean"
        },
        "property": {
            "type": "string"
        },
        "name": {
            "type": "string"
        },
        "mail": {
            "type": "string"
        },
        "status": {
            "type": "string"
        },
        "created": {
            "type": "string"
        },
        "image": {
            "type": "string"
        }
    }
}
```

# Delmoment 7, Dokumentation
Beskriv hur lösningen planerats, implementerats och kan återskapas.