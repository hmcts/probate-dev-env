# Probate Dev Env

Scripts to set up the Probate development environment.

## Usage

Create the environment:

```
npx @hmcts/probate-dev-env --create
```

Start the environment:

```
npx @hmcts/probate-dev-env
```

Stop the environment:

```
npx @hmcts/probate-dev-env --stop
```

### Custom compose file

A custom docker-compose file can be specified using an environment:

```
COMPOSE_FILE="-f docker/custom/compose.yml" npx @hmcts/probate-dev-env
```

There are assumptions that the fees database will exist and that the CCD services have been specified in the compose file.

## Dependencies

This script requires:

- Azure CLI
- Docker & Docker compose
- jq
- curl
- psql (Postgres client)

## License

The MIT License (MIT)

Copyright (c) 2017 HMCTS (HM Courts & Tribunals Service)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
