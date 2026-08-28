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

4.

1. Verifiering via Azure portalen. Gå till resursen i azure portalen och access control kontrollerar jag avdelningskontot för båda användarna. Där får jag en överblick på vilken rolltildening dem har och att dem tillhör grupptilldelningen.

2. Verifiera via att gå in via kontot och testa så rolltildelningen tillämpas.