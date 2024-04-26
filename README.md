---

# Guida per l'Accesso al Terminale del Container MariaDB

## Introduzione
Questa guida fornisce istruzioni su come accedere al terminale del container MariaDB nel tuo ambiente Docker e interagire direttamente con il database.

## Accesso al Terminale del Container MariaDB

### 1. Trova il Nome del Container MariaDB
Utilizza il comando `docker ps` per visualizzare tutti i container in esecuzione sul tuo sistema Docker e identifica il nome del container MariaDB dalla lista.

```bash
docker ps
```

### 2. Accedi al Terminale del Container
Avvia un terminale all'interno del container MariaDB utilizzando il comando `docker exec`:

```bash
docker exec -it nome_del_container_mariadb bash
```

Sostituisci `nome_del_container_mariadb` con il nome effettivo del tuo container MariaDB.

### 3. Avvia il Client MySQL
Una volta all'interno del terminale del container MariaDB, avvia il client MySQL utilizzando il comando `mysql`:

```bash
mysql -u nome_utente -p
```

Sostituisci `nome_utente` con il nome utente appropriato per accedere al database MariaDB.

### 4. Inserisci la Password
Verrà richiesto di inserire la password dell'utente. Inseriscila e premi Invio.

### 5. Interagisci con il Database
Una volta connesso al server MariaDB, puoi eseguire comandi SQL come `SHOW DATABASES;`, `USE nome_del_database;`, `SHOW TABLES;`, ecc., per esplorare e gestire il database.

```sql
SHOW DATABASES;
USE nome_del_database;
SHOW TABLES;
```

Oppure, puoi eseguire direttamente il comando `mysql` con la tua query SQL come argomento senza interagire con il prompt MySQL interattivo:

```bash
mysql -u nome_utente -p -e "SHOW DATABASES;"
```
