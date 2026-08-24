# V.34 Novatrix, driftsättning av webbserver i Azure

**Repo: https://github.com/00aughar/azure-Mov25.git**

**August Hartwig** 
**MOV25** 
**20/8**

**Innehåll**
- Resursgrupp och provisionerat VM
- SSH nyckel & anslutning till VM
- Serverkonfiguration och installation av Nginx
- Driftsättning
- Verifiering

## 1. Resursgrupp och provisionerat VM

Via Azure Portalen skapa resursgrupp **"rg-novatrix-V34"**.

Provisionerat VM **"vm-novatrix-web"** skapad via Azure Portalen inom resursgrupp **"rg-novatrix-V34"**

- VM har operativsystem **"Ubuntu Server LTS 24.04 - x64 Gen2"** 
- Azure klassning på VM **"B2ats_v2"**

Port **80** för **(HTTP)** och **22** för **(SSH)** öppnad på VM via Azure Portalen för trafik

Resultat: 

![alt text](image-1.png)
![alt text](image.png)
![alt text](image-2.png)

## 2. SSH nyckel & anslutning till VM

SSH nyckel genererad via Azure för fjärranslutning till VM **"vm-novatrix-web"**

Navigering till SSH nyckel:
```cd "C:\Skolarbete\Microsoft Azure\V.34"```

Sätt behörighet på nyckel:
1. ```icacls .\vm-novatrix-web_key.pem /inheritance:r```
2. ```icacls.\vm-novatrix-web_key.pem /grant:r "$($env:USERNAME):R"```

Anslut till server:
```ssh -i .\vm-novatrix-web_key.pem azureuser@172.160.243.203```

Resultat: ![alt text](<anslutning och nyckel.png>)

## 3. Serverkonfiguration och installation av Nginx

1. Serverkonfiguration & uppdatering

Sökning av uppdateringar på VM: ```sudo apt update```

Nedladdning & uppdatering av server: ```server sudo apt upgrade -y```

2. Installation av Nginx

Installationskript: ```sudo apt install nginx -y```

Kontrollera att Nginx är installerad: ```systemctl status nginx```

Reslutat: ![alt text](<nginx installerad.png>)

## 4. Driftsättning

Konfiguration av html websidan

Navigera till nginx innehållssida ```cd /var/www/html/```

Redigering av innehållssida ```sudo nano index.html```


html websida konfiguration:

```
<!DOCTYPE html>
<html>
<head>
<title>Welcome to Novatrix</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to Novatrix</h1>
<p></p>

<form>
  <label for="name">Namn:</label><br>
  <input type="text" id="name" name="name"<br>
  <br><label for="mail">Mail:</label><br>
  <input type="text" id="mail" na  <br><label>
<br><label for="mail">Meddelande:</label><br>
<input type="text" id="msg" na <br><label>
<input type="submit" value="Skicka"
</form>


</body>
</html>
```

## 5. Verifiering

Besök websidan via serverns publika IP-address

Reslutat: ![alt text](<nginx fixad.png>)

## Challenge Cloud init automation konfiguration 

Jag påbörjar en ny konfiguration av en virutell maskin efter jag har skapat en resursgrupp. Virtuell maskin konfigureras på samma sätt som vid tidigare moment. Under konfiguration navigerar jag till "Avancerat" där jag fyller i min "cloud.init.yaml" kod för att konfigurera vad maskinen ska göra vid uppstart. 

![alt text](image-3.png)

Verifiering: Efter HTTP port 80 öppnats besök den offentliga IP-addressen för maskinen för att verifiera att konfiguration efter cloud.init scriptet har fungerat. Samt anslut via SSH till den virtuella maskinen via terminalen.


![alt text](image-5.png)![alt text](image-6.png)