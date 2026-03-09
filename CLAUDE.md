# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
bin/setup              # Initial setup (installs deps, prepares DB)
bin/dev                # Start dev server (Rails + Tailwind CSS watcher)
bundle exec rspec      # Run full test suite
bundle exec rspec spec/path/to/file_spec.rb  # Run a single test file
bin/rubocop            # Ruby linting (StandardRB / Omakase style)
bin/brakeman --no-pager  # Security vulnerability scan
bundle exec annotaterb   # Annotate models with schema info
```

## Architecture

This is a Rails 8 trading journal application for tracking trades and analyzing performance. It targets the Taiwan futures/equities market.

**Core Models**
- `User` — authentication (bcrypt), risk settings (JSON column), initial capital
- `TradeLog` — individual trades: date, product, quantities, prices, PnL (gross/net), commissions, taxes; supports CSV import from Taiwan broker reports
- `BrokerAccount` — multiple broker accounts per user
- `MonthReport` — pre-aggregated monthly statistics for display performance

**Services** (`app/services/`)
- `AnalyzeTradeLogs` — computes win rate, profit/loss ratios, consecutive losses, average PnL from a collection of trade logs
- `ParseTradeReport` — parses broker CSV reports with Chinese-language column headers into `TradeLog` attributes
- `PlotTradeRecords` — generates trade visualization data

**Controllers**
- `TradeSummariesController` — main dashboard; daily/weekly/monthly views with charts
- `TradeLogsController` — trade creation, CSV import, deletion
- `TradePlotsController` — trade visualization

**Frontend**
- Hotwire (Turbo + Stimulus) for interactivity
- Tailwind CSS for styling
- Chartkick for charts
- Importmap (no Node/webpack)

**Testing**
- RSpec with FactoryBot (`spec/factories/`)
- Aggregate failures enabled by default

**Deployment**
- Kamal to Docker on `ledger.tomohung.com`
- SQLite3 as the primary database (persistent volume in production)
- Solid Queue / Cache / Cable for background jobs, caching, WebSockets
