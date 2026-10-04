# V40, nivå 2 (container). Novatrix kundtjänstsida paketerad som en container.
# Bygg i molnet (ingen lokal Docker behövs):
#   az acr build --registry novatrixacr652 --image novatrix-app:v1 .
# Kör i Azure Container Instances:
#   az container create --resource-group rg-novatrix --name novatrix-webb \
#     --image novatrixacr652.azurecr.io/novatrix-app:v1 --ports 80 \
#     --dns-name-label novatrix-webb-652
FROM nginx:alpine

# Kopiera samma Novatrix-sida in i nginx webbrot
COPY index.html /usr/share/nginx/html/index.html

# Containern lyssnar på port 80
EXPOSE 80