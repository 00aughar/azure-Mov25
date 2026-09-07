# V.36 Nätverk och säkerhet

**Repo: https://github.com/00aughar/azure-Mov25.git**

**August Hartwig** 
**MOV25** 
**x/x**

1. Skapa ett VNET

Via Azure portalen navigerar jag till virtuella nätverk. Skapar ett nytt virtuellt nätverk för nätverksresursen *rg-novatrix* som jag döper till *vnet-novatrix* i regionen *Sweden Central*.

2. Skapa subnäten

Navigera till *vnet-novatrix* och välja subnät. Skapa nytt subnät.

- *snet-web* för subnät till webserver
- *snet-db* för databas och lagrning

Syftet är att skydda nätverkets olika delar. Uppdelningen görs med tydlig namngiving på vilken roll inom nätverket subnätet har.

3. Skapa nätverksäkerhetsgrupper (NSG) 

Portar öppnas med tankesättet Least Privledge. Minsta möjliga antal portar som behövs öppnas baserat på att dem fyller en funktion. 

Via Azure portalen navigera till Network securit groups och skapa en security group. Säkerhetsgruppen gäller för resursgrupp *rg-novatrix* och heter *nsg-web*.

Navigera till säkerhetsgruppen *nsg-web* och välj "Inbound security rules" och lägger till:
- *allow-web* Tillåt inkommande trafik på portar *80* och *443* för web trafik
- *allow-ssh-admin* Tillåt inkommande trafik på port *22* endast från min lokala IP-address

4. Koppla NSG till subnätet

Navigera till säkerhetsgruppen *nsg-web* och koppla till *vnet-novatrix* subnät *snet-web*. När säkerhetsgruppen är kopplad till det virtuella nätverket slår det in även på subnäten. 

5. Placera VM i rätt subnät

Navigera till den virutella maskinen *vm-novatrix-web* och se till att den är avstängd för att skapa en snapshot av maskinens hårddisk. Därefter ta bort den virutella maskinen för att starta upp en ny virtuell maskin med snapshoten.

När den nya virtuella maskinen skapas välj att nätverkskortet (NIC) är låst till rätt vnet *vnet-novatrix* 

6. Verifiera att SSH följer NSG regler

Via Azure Portalen navigera till Network Watcher > IP flow verify. Testa trafiken via en okänd IP address för att testa NSG regel *allow-ssh-admin* på port *22* blir nekad.



7. Skiss Nätverksdesign & NSG Tabell

| Regel | Riktning | Källa | Port | Åtgärd | Motivering |
|---|---|---|---|---|---|
| allow-web | Inbound | Internet | 80, 443 | Allow | Formuläret ska vara publikt nåbart |
| allow-ssh-admin | Inbound | Lokal IP-adress | 22 | Allow | Endast administratör ska kunna hantera VM:en |
| deny-all-inbound | Inbound | Any | Any | Deny | Explicit stäng allt annat |