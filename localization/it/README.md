# Playbook Ansible per la distribuzione di un nodo Commercio Network
Il playbook configura un server per essere un full node di Commercio Network e installa uno script che rileva se il nodo sta perdendo blocchi.
Se il nodo perde blocchi, verrà inoltrato un messaggio su un canale slack a scelta.

**ATTENZIONE: Il playbook può essere utilizzato solo per mainnet. Non utilizzarlo per testnet o devnet o localnet.**


## Prerequisiti
I prerequisiti per utilizzare questo playbook sono:
* Avere un server su cui installare il nodo
* Avere installato Python3 (versione >= 3.5)
     * Per verificare la versione:
         ```bash
         python3 -V
         ```
* Avere installato ansible (versione >= core 2.9)
     * Per verificare la versione:
         ```bash
         ansible --version
         ```
* Avere `gantsign.golang` installato per ansible
     * Per installarlo:
         ```bash
         ansible-galaxy install gantsign.golang
         ```
## Utilizzo
Per utilizzare il playbook è necessario procedere come segue:

1. Crea e aggiungi il file `hosts.ini` alla directory principale di questo repository. [File host di esempio](.hosts.ini). parametri:
      * `ansible_host`: IP della macchina
      * `moniker`: nome del nodo
      * `external_drive`: parametro opzionale per specificare se il database del nodo deve essere installato su un disco esterno. Utilizzare questo parametro per specificare il percorso del disco
      * `comm_user`: nome dell'utente che verrà creato e utilizzato dal servizio nodo
      * `sync_type`: questo parametro decide come avviene la sincronizzazione del database.
      Puoi avere 5 valori:
          * `pull`: la sincronizzazione avviene eseguendo un `rsync` dal nuovo nodo al nodo da cui si sincronizza.
          * `push`: la sincronizzazione avviene eseguendo un `rsync` dal nodo da cui si sincronizza al nuovo nodo.
          * `dump`: la sincronizzazione avviene scaricando il dump su disco e scompattandolo.
          * `statesync`: la sincronizzazione avviene tramite statesync.
          * `nessuno`: la sincronizzazione avviene normalmente.
    
      Puoi modificare il comportamento del playbook in base alle variabili indicate nel file "all" situato nel percorso "main/group_vars". Di seguito la tabella del loro significato:
      | Nome variabile | Utilizzo |
      | -- | -- |
      | `bin_version` | Versione del binario Commercionetworkd da utilizzare |
      | `chain_id` | ID catena blockchain |
      | `genesis` | URL del file Genesis |
      | `comm_repo` | Percorso e nome dove viene scaricato il repository binario di Commercio.network |
      | `home_folder` | Home dove è installata la cartella `.commercionetwork` |
      | `go_path` | Percorso dell'installazione go |
      | `cosmovisor_version` | Versione di Cosmovisor da installare |
      | `sync_node` | IP del nodo da cui eseguire la sincronizzazione in caso di `sync_type` = `push` o `pull` |
      | `sync_node_home_folder` | Cartella home del nodo da cui eseguire la sincronizzazione in caso di `sync_type` = `push` o `pull` |
      | `trust_rpc1` | Primo RPC da cui eseguire la sincronizzazione in caso di `sync_type` = `statesync` |
      | `trust_rpc2` | Secondo RPC da cui eseguire la sincronizzazione in caso di `sync_type` = `statesync` |
      | `slack_hook` | Webhook dove inviare report sul nodo. **Nessuno script verrà installato se un webhook non è impostato** |

2. Procedi con l'esecuzione del playbook `main`:
```bash
ansible-playbook -i host.ini main/commercio.yml
```

Esegui il playbook dalla cartella principale di questo repository.

### Installazione manuale dello script
Se non si sceglie di installare lo script tramite il playbook lo si può installare manualmente, ecco come:
1. Copia lo script da `main/post_install/tasks/test_height.sh` sul server
2. Sostituisci la variabile `{{ slack_hook }}` nel file con un tuo webhook slack
3. Aggiungi lo script ad un crontab utilizzando il comando `crontab -e`. Suggeriamo di eseguire lo script ogni 5 minuti

## Risoluzione dei problemi
Potrebbero verificarsi errori durante l'avvio del playbook. Questi sono i più comuni:

1. Durante il passaggio `install_binary: Run 'make' on target` potrebbe verificarsi un errore nella compilazione del binario a causa del mancato superamento del test `TestProcessTestSuite`.
Il playbook ignorerà l'errore e continuerà l'esecuzione. Il binario viene comunque compilato e funzionerà correttamente.

2. Durante la fase `setup_configuration: Download genesis file`, potrebbe verificarsi un possibile errore nel download di genesis. Questo errore è causato dal fatto che Github non risponde correttamente alla richiesta. In questo caso il playbook si fermerà. Questo errore si verifica raramente e sarà sufficiente riavviare il playbook per completare la configurazione.