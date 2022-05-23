# Sinatra server example

## Installation

```bash
cp config-app.json.example config-app.json
# edit to add your credentials

bundle install
```

## Usage

Launch Sinatra server in terminal:

```bash
ruby config.ru
```

Try some requests:

```bash
curl -i -X POST http://localhost:4567/authenticate/alice
curl -i -X GET http://localhost:4567/me/tanker_secret_identity
curl -i -X GET http://localhost:4567/users/alice/tanker_public_identity

curl -i -X POST http://localhost:4567/authenticate/bob
curl -i -X GET http://localhost:4567/me/tanker_secret_identity
curl -i -X GET http://localhost:4567/users/alice/tanker_public_identity
curl -i -X GET http://localhost:4567/users/bob/tanker_public_identity
```
