
# kwvm

**kwvm** è uno script Bash progettato per gestire monitor virtuali su sistemi Linux, specificamente adattato per ambienti KDE utilizzando strumenti come [krfb-virtualmonitor](https://invent.kde.org/network/krfb). Questo script consente agli utenti di creare, modificare, eliminare e gestire monitor virtuali in modo efficiente.

**Nota**: Questo script è compatibile **solo con KDE in esecuzione su Wayland**.

## Indice

- [Caratteristiche](#caratteristiche)
- [Installazione](#installazione)
- [Configurazione](#configurazione)
- [Utilizzo](#utilizzo)
- [Comandi](#comandi)
- [Esempi](#esempi)
- [Licenza](#licenza)
- [Contributi](#contributi)

## Caratteristiche

- **Crea Monitor Virtuali**: Crea facilmente nuovi monitor virtuali con impostazioni personalizzabili.
- **Modifica Monitor Esistenti**: Aggiorna le impostazioni per i monitor virtuali esistenti.
- **Elimina Monitor**: Rimuovi monitor virtuali non più necessari.
- **Avvia e Ferma Monitor**: Controlla lo stato dei monitor virtuali.
- **Elenca Tutti i Monitor**: Visualizza un elenco di tutti i monitor creati con i dettagli.
- **Verifica di Compatibilità**: Verifica l'ambiente operativo e la presenza degli strumenti necessari.

## Installazione

Per installare **kwvm**, segui questi passaggi:

1. **Clona il Repository**:  
   git clone https://github.com/yourusername/kwvm.git  
   cd kwvm

2. **Rendi Eseguibile lo Script**:  
   chmod +x kwvm.sh

Puoi posizionare lo script in qualsiasi directory preferisci. Ad esempio, se posizioni lo script in una cartella denominata `kwvm` nella tua home directory (`$HOME/kwvm`), al primo avvio, lo script creerà le directory necessarie per i file di configurazione e monitor all'interno di questa cartella, come `$HOME/kwvm/config` e `$HOME/kwvm/vmonitors`.

## Configurazione

La prima volta che esegui lo script, verrà avviato automaticamente un processo di configurazione:

./kwvm.sh

Questa configurazione:
- Creerà le directory necessarie (`vmonitors` e `config`).
- Genererà un file di configurazione predefinito.
- Verificherà l'ambiente di sistema (ad es. Wayland, KDE, `krfb-virtualmonitor`).

## Utilizzo

Per utilizzare **kwvm**, esegui lo script con uno dei comandi disponibili:

./kwvm.sh <comando> [opzioni]

## Comandi

- **create, c**: Crea un nuovo monitor virtuale.
- **edit, e**: Modifica un monitor virtuale esistente per ID o nome.
- **delete, d**: Elimina un monitor virtuale specificato per ID o nome.
- **list, l**: Elenca tutti i monitor virtuali.
- **start, s**: Avvia un monitor virtuale specificato per ID o nome.
- **stop, x**: Ferma un monitor virtuale specificato per ID o nome.
- **killall, k**: Termina tutti i monitor virtuali. Usa `-f` per terminare forzatamente tutti i processi `krfb-virtualmonitor`.
- **alias, a**: Imposta o rimuove l'alias per questo script.
- **help, h**: Mostra le informazioni di aiuto.

## Esempi

- **Crea un Nuovo Monitor Virtuale**:  
  ./kwvm.sh create

- **Modifica un Monitor per Nome**:  
  ./kwvm.sh edit monitor1

- **Elimina un Monitor per ID**:  
  ./kwvm.sh delete 2

- **Elenca Tutti i Monitor**:  
  ./kwvm.sh list

- **Avvia un Monitor per Nome**:  
  ./kwvm.sh start monitor1

- **Ferma un Monitor per ID**:  
  ./kwvm.sh stop 2

- **Termina Tutti i Monitor**:  
  ./kwvm.sh killall

- **Termina Forzatamente Tutti i Processi `krfb-virtualmonitor`**:  
  ./kwvm.sh killall -f

## Licenza

Questo progetto è concesso in licenza sotto la GNU General Public License v3 (GPLv3) con termini aggiuntivi. Vedi il file [LICENSE](LICENSE) per i dettagli.

## Contributi

Contributi sono benvenuti! Per favore, fai un fork del repository e invia una pull request con le tue modifiche. Assicurati di seguire lo stile di codifica esistente e includere eventuali test necessari con il tuo contributo.

Per ulteriori informazioni su `krfb-virtualmonitor`, visita il [repository GitLab di KDE](https://invent.kde.org/network/krfb).

---

Per la versione inglese di questo README, fai riferimento al [README in Inglese](README.md).
