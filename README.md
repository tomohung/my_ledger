# my_ledger

A Rails 8 trading journal. It imports the CSV statements a Taiwanese futures broker
produces — Chinese column headers and all — and turns them into the performance
analytics a discretionary trader actually needs to review: win rate, profit factor,
expectancy, maximum drawdown, consecutive-loss streaks, and P&L broken down by
weekday, product and risk multiple.

Built and run for myself. It has been in daily use since April 2025.

## What it does

**Import.** `ParseTradeReport` reads broker CSV exports with Chinese-language column
headers and normalises them into trade records. Futures and options are both handled —
options rows carry strike price, call/put and contract month — as are multiple
currencies and multiple broker accounts per user.

**Analyse.** `AnalyzeTradeLogs` computes the review metrics in one pass over a trade
collection: win rate, average win/loss, profit factor, expectancy, maximum drawdown
(absolute and percentage), longest losing streak by trade and by day, equity curve,
and breakdowns by weekday and by product.

**Review.** Four dashboards — daily, weekly, monthly, overall — built from thirteen
Hotwire partials: equity curve, cumulative and per-period P&L charts, a calendar
heatmap, weekday analysis, risk-based P&L distribution, and capital risk management.

## Notable decisions

The parts of this project I would actually want to talk about.

**Rails 8 built-in authentication instead of Devise.** Sessions, bcrypt and the
password-reset mailer come from the framework generator. For a single-tenant app,
Devise is a dependency and an upgrade obligation bought for features that are not
used.

**SQLite in production, on purpose.** Solid Queue, Solid Cache and Solid Cable all run
against SQLite on the same persistent volume. The whole app is one container deployed
with Kamal and fronted by Thruster — no Postgres, no Redis, no separate worker host.
For a single-user journal that reads far more than it writes, the operational
simplicity is worth more than the headroom.

**Monthly figures are pre-aggregated, not recomputed.** `MonthReport` stores each
month's totals behind a unique `(user_id, report_date)` index. The overall dashboard
spans years of trades; recomputing every month on every page view would make the page
slower for no benefit, since a closed month does not change.

**Risk is sized from initial capital, not ending capital.** Sizing from the running
balance means position size drifts upward through a winning streak and collapses
through a losing one — exactly backwards from what a drawdown calls for. Fixing the
denominator makes the risk number comparable across the whole year.

**P&L colours follow the accounting convention, not the chart convention.** In Taiwan,
red means *up* on a price chart. In a ledger, red means *loss*. This app is a ledger,
so profit is blue and loss is red — deliberately the opposite of what the same user
sees in their trading platform. Consistency with the document type beat consistency
with the neighbouring app.

**Brakeman runs in CI, and it has caught something.** A trade-type filter passed raw
query parameters into `url_for`; the fix was an explicit parameter allowlist. The
value of a scanner in the pipeline is entirely in the case where it is not just
decorative.

**No Node.** Importmap for JavaScript, Propshaft for assets, Tailwind via
`tailwindcss-rails`. Nothing in the build depends on npm.

## Stack

Rails 8.1 · Ruby · SQLite3 · Hotwire (Turbo + Stimulus) · Tailwind CSS · Chartkick ·
Pagy · Solid Queue / Cache / Cable · Propshaft · Importmap · Kamal + Thruster + Docker

## Development

```bash
bin/setup     # install dependencies, prepare the database
bin/dev       # Rails server + Tailwind watcher
```

## Testing and CI

```bash
bundle exec rspec                    # full suite
bundle exec rspec spec/models        # a subset
bin/rubocop                          # StandardRB
bin/brakeman --no-pager              # security scan
```

RSpec with FactoryBot, covering models, services and requests. Aggregate failures are
on by default.

GitHub Actions runs four jobs on every push:

| Job | What it does |
|---|---|
| `scan_ruby` | Brakeman static analysis for Rails security issues |
| `scan_js` | `importmap audit` for known JavaScript dependency advisories |
| `test` | RSpec, including system tests in headless Chrome; failed-test screenshots are uploaded as artifacts |
| `lint` | StandardRB |

Locally the same gates run earlier: a Claude Code post-edit hook runs StandardRB on
save, and a pre-commit hook runs StandardRB, RSpec and Brakeman before a commit is
allowed.

## Deployment

Kamal to a single Docker host, with SQLite on a persistent volume and Thruster in
front of Puma.

```bash
export KAMAL_HOST=<server ip>
export KAMAL_APP_DOMAIN=<public hostname>
export KAMAL_REGISTRY_USERNAME=<registry user>

bin/kamal deploy
```

No infrastructure details are committed. Kamal renders `config/deploy.yml` through ERB
before parsing it, so the host, domain and registry user are read from the environment;
the checked-in defaults are RFC 5737 / RFC 2606 reserved values, which are deliberately
not routable, so a deploy with the variables unset fails rather than reaching somewhere
unintended. Secrets come from the environment or a password manager via
`.kamal/secrets`, and `config/master.key` is gitignored.

## Project status

Feature-complete for what I need it to do. The last behavioural change was in May 2026;
everything since has been dependency maintenance.

That maintenance is deliberately automated rather than abandoned: Dependabot opens the
PRs, the full CI suite gates them, and a custom `/merge-dependabot` command merges only
the PRs that are green on every check — for the ones that are not, it pulls the failing
run logs, distinguishes a real regression from a pre-existing warning, and rebases PRs
that are blocked behind another update. Keeping a finished app current should cost
close to nothing, and here it does.

## License

MIT — see [LICENSE](LICENSE).
