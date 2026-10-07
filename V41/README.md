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


## Tjänsten och nivå val: 
Jag valde att bygga portalen på en virtuell maskin i Azure portalen *vm-nordvik-web*, Storlek *Standard D2als v6 (2 vcpus, 4 GiB memory)* med Operativsystemet *ubuntu-24_04-lts*. VMen är en IaaS tjänst, Azure sköter den fysiska hårdvaran medans jag sköter ansvar för operativsystemet, uppdateringar och applikationer. Jag valde VM lösningen för att lasten är låg med cirka 5-10 samtida användare med en topp vid 120. Hela miljön byggs upp med kod (IaC). Begränsningarna med denna lösning tas upp i del A.

## Konfigurationen:
 Maskinen konfigureras upp automatiskt med cloud-init filen *cloud-init-nordvik.txt* som skickas med i ARM-mallen *main.json* och tillhörande parameterfil *main.parameters.json*. Cloud-init filen konfigurerar Python bibliotken (flask, azure-identity och azure-storage-blob), lägger ut applikationen och registrerar den som tjänsten *felanmalan.service*. En ny VM blir därav identiskt konfigurerad om den behöver byggas upp igen, förutom det manuella steget för flödets address som näms nedan.

## Applikationen:
 Formuläret som innehåller fält för: rubrik, kategori, fastighet, beskrivning, bild, namn & e-post som sedan tas emot av flask-appen i bakrunden. När anmälan skickas sparar appen innehållet i en JSON-fil *arende-<id>.json* i blob container *anmalningar*, bifogade bilder sparas som en egen blob i containern. Appen anropar flödet för varje anmälan. Akuta kategorier (värme, vatten och lås) markeras med *urgent*, vilket flödet använder för att skicka ett direktmejl.

## Åtkomst till lagringen:
Applikationen använder den användartilldelade hanterade identiteten *id-nordvik-portal*, som har rollen *Storage Blob Data Contributor* på containern *anmalningar*. Därför finns inga nycklar eller lösenord i koden eller i repot. Flödets adress (FLOW_URL) är en hemlighet och lämnas tom i repot. Den sätts manuellt på VM:en efter uppstart.

## Bildbevis och test av tjänst

Formuläret:
![alt text](<formulär compute.png>)

Formulär ID:
![alt text](<formulär compute ID.png>)

Blobar mottagna:
![alt text](<blobar mottagna compute.png>)

JSON text blob:
![alt text](<JSON compute.png>)

# Delmoment 2, IAM
Konfigurera identiteter och behörigheter för Nordviks roller enligt least privilege: hyresgäst ser och skapar
sina egna anmälningar, förvaltare hanterar dem, ekonomi har läsande insyn. Ge även portalen en hanterad
identitet för att nå lagringen.

## Principen:
Rollerna följer least privilege. Varje identitet får lägsta möjliga rättighet, på lägsta möjliga nivå. Alla roller är därför tilldelade på containernivå och inte på hela lagringskontot, och tilldelas grupper i stället för enskilda personer. Det gör att en ny förvaltare bara behöver läggas till i en grupp. Grupperna *grp-nordvik-forvaltare* och *grp-nordvik-ekonomi* skapades i Entra ID, och deras object-ID:n skickas in som parametrar till mallen (forvaltareGroupId, ekonomiGroupId).

## Rollmodell

| Roll | Identitet | Azure-roll | Scope | Motivering |
|---|---|---|---|---|
| Hyresgäst | Ingen Azure-identitet | Ingen | – | Hyresgäster når aldrig lagringen direkt, utan skickar anmälningar via formuläret. Appen skriver åt dem. |
| Förvaltare | `grp-nordvik-forvaltare` | Storage Blob Data Contributor | `anmalningar` och `dokument` | Ska kunna läsa, skriva och hantera anmälningar och dokument. |
| Ekonomi | `grp-nordvik-ekonomi` | Storage Blob Data Reader | `anmalningar` och `dokument` | Läsande insyn utan rätt att ändra eller ladda upp. |
| Portalen | `id-nordvik-portal` (användartilldelad hanterad identitet) | Storage Blob Data Contributor | Endast `anmalningar` | Appen ska bara skriva anmälningar och bilder. Ingen åtkomst till `dokument`. |

## Hanterad identitet
Portalen använder en användartilldelad hanterad identitet i stället för nycklar. Nyckelåtkomst är dessutom avstängd (allowSharedKeyAccess: false), så identiteten är det enda sättet för appen att nå lagringen.

## Verifiering och bildbevis

Kontroll rolltilldening:
![alt text](<rolltilldelningar bevis.png>)

anmalningar IAM:
![alt text](<anmälningar IAM.png>)

Ekonomi användare åtkomst anmalningar:
![alt text](<anmälningar legolas åtkomst.png>)

Förvaltare användare åtkomst anmalningar:
![alt text](<anmälningar anna åtkomst.png>)

Ekonomi användare åtkomst dokument:
![alt text](<dokument åtkomst legolas.png>)

Förvaltare användare åtkomst dokument:
![alt text](<dokument åtkomst anna.png>)

Medlemmar ekonomi:
![alt text](<ekonomi medlem.png>)

Medlemmar förvaltare:
![alt text](<förvaltare medlem.png>)

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