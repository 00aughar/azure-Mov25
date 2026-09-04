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

3. Skapa nätverksäkerhetsgrupper (NSG) 

Portar öppnas med tankesättet Least Privledge. Minsta möjliga antal portar som behövs öppnas baserat på att dem fyller en funktion. 

Via Azure portalen navigera till Network securit groups och skapa en security group. Säkerhetsgruppen gäller för resursgrupp *rg-novatrix* och heter *nsg-web*.

Navigera till säkerhetsgruppen *nsg-web* och välj "Inbound security rules" och lägger till:
- *allow-web* Tillåt inkommande trafik på portar *80* och *443* för web trafik
- *allow-ssh-admin* Tillåt inkommande trafik på port *22* endast för min lokala IP-address

4. Koppla NSG till subnätet

Navigera till säkerhetsgruppen *nsg-web* och koppla till *vnet-novatrix* subnät *snet-web*





Skiss