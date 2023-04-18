# VECTR

## Configuration
Please check https://docs.vectr.io

### ENV File

Create a .env file in your deployment directory with the following. 
```
# .env file

VECTR_HOSTNAME=sravectr.internal
VECTR_PORT=8081

# defaults to warn, debug useful for development
VECTR_CONTAINER_LOG_LEVEL="DEBUG"

MONGO_INITDB_ROOT_USERNAME=admin

# PLEASE change this and store it in a safe place.  Encrypted data like passwords
# to integrate with external systems (like TAXII) use this key
VECTR_DATA_KEY=CHANGEMENOW

# ALSO change and store in a safe place
MONGO_INITDB_ROOT_PASSWORD=CHANGEMENOW

# JWT signing (JWS) and encryption (JWE) keys
# Do not use the same value for both signing and encryption!
JWS_KEY=CHANGEME
JWE_KEY=CHANGEMENOW
```

### /etc/hosts file

Modify /etc/hosts to include your VECTR_HOSTNAME

```
127.0.0.1       localhost
...
127.0.0.1       sravectr.internal
```

## Run

```docker-compose -p <vectr-project-name> up``` 

vectr-project-name is your choice, something like *vectrdev1* recommended 