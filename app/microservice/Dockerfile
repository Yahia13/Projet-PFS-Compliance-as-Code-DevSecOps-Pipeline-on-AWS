# Utilisation d'une image légère et stable
FROM python:3.9-slim

WORKDIR /app

# Copie des dépendances et installation
COPY src/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copie du code source
COPY src/ .

# --- SECTION SÉCURITÉ (Compliance) ---
# On crée un utilisateur sans privilèges
RUN useradd -m devsecops
# On donne les droits sur le dossier à cet utilisateur
RUN chown -R devsecops:devsecops /app
# On bascule sur cet utilisateur
USER devsecops

# Flask par défaut tourne sur le 5000
EXPOSE 5000

CMD ["python", "app.py"]