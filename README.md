# Gobierto ETL for Esplugues

ETL scripts for Gobierto Esplugues site: https://portalobert.esplugues.cat/

## Setup

Install dependencies:

```bash
brew install freetds
sudo ARCHFLAGS="-arch x86_64" gem install tiny_tds
```

Copy `.env` file:

```bash
cp .env.example .env && ln -s .env .rbenv-vars
```

And fill in the values.

This repository relies heavily in [gobierto_budgets_data](https://github.com/PopulateTools/gobierto_budgets_data)

## Available operations

- gobierto_plans/extractor
- gobierto_plans/importer
