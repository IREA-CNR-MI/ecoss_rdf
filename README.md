# ecoss_rdf
RFD resources for ECOSS Project development

ECOSS - project.
Streaming ECOADS sites information to RDF
26/11/2020 Paolo Tagliolato

Chiamata JQ per ottenere relazione tra siti ecoss e parametri

Output di esempio:
```
<https://deims.org/96969205-cfdf-41d8-979f-ff881ea8dc8b> ecoss:observes <http://vocabs.lter-europe.net/EnvThes/30179> .
```

Dal portale di Ecoss, all’url https://ecoads.eu/sitesjson/ è disponibile un elenco (limitato per fare i test) dei siti deims, con molte informazioni. 
Primo esperimento è di costruire un turtle/rdf filtrando l’informazione ed esponendo in RDF solo i legami tra siti e parametri. Questa informazione potrà essere letta anche da app come quella shiny in preparazione da parte di Alessandro Oggioni.

Esempio di chiamata con CURL (da bash)
```bash
curl https://ecoads.eu/sitesjson/ | jq --raw-output '.[0]|{site_uri:"\(.id.prefix)\(.id.suffix)", site_title:.title, param: .attributes.focusDesignScale.parameters[]} |
[.site_uri, .site_title, .param.uri, .param.label] |
"<\(.[0])> ecoss:observes <\(.[2])> ."'
```

Dove la query jq è:
```jq
.[0]|{site_uri:"\(.id.prefix)\(.id.suffix)", site_title:.title, param: .attributes.focusDesignScale.parameters[]} |
[.site_uri, .site_title, .param.uri, .param.label] |
"<\(.[0])> ecoss:observes <\(.[2])> ."
```

In questo esempio si produce una sentenza con solo due delle informazioni trovate (l’ultima riga dell’istruzione crea una stringa prendendo dal vettore alla penultima riga il componente 0 e il componente 2), ossia site_uri e param.uri. Già così si potrebbero comporre sentenze usando anche gli altri due valori disponibili nel vettore, ossia site_title e param_label.

L’esperimento è preparatorio al lavoro di comporre una query jq e di eseguirla direttamente sul server richiamandola da python, in modo da esporre direttamente RDF ad un nuovo endpoint.
Un job periodico potrà poi programmare l’aggiornamento del grafo RDF risultante su un endpoint sparql (fuseki, indicativamente) richiamando su di esso (anche da remoto) una 

```SPARQL
DELETE WHERE {?s ?p ?o}
```

e una

```SPARQL
LOAD <indirizzo nuovo endpoint>
```

Esempio di codice python per fare la sincronizzazione su un endpoint sparql in scrittura:
```python
def synchSparqlEndpoint(endpoint="http://example.fuseki.org/mydatasourcetoupdate/", user="", password="", source_endpoint="https://ecoads.eu/sitesjson/rdf/"):
   import requests
   import os

   url = "{endpoint}update".format(endpoint=os.getenv("SPARQL_ENDPOINT", endpoint))
   user = os.getenv("SPARQL_ENDPOINT_USER", user)
   password = os.getenv("SPARQL_ENDPOINT_PASSWORD", password)

   dataDelete = {'update': 'DELETE \nwhere{?s ?p ?o}\n\n#'}

   responseDelete = requests.post(url, data=dataDelete,
                            auth=('user', 'password'))

   if responseDelete.status_code == 200:
       dataLoad = {'update': 'LOAD <{source_endpoint}>'.format(source_endpoint = source_endpoint)}
       responseLoad = requests.post(url, data=dataLoad,
                                auth=('user', 'password'))

   return responseDelete, responseLoad
```
