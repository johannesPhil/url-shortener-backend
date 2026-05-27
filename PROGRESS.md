# URL Shortener - Project Progress & Learning Notes

> **Project Goal:** Build a URL shortener API while learning Ruby/Rails patterns + Cloud Deployment

---

## ✅ Completed (What's Working)

### 1. Core Service Layer (Service Object Pattern)
Located in `app/services/` - following Rails best practice of extracting business logic from models.

| Service | Purpose | Ruby Patterns Used |
|---------|---------|-------------------|
| `UrlNormalizer` | Validates & normalizes URLs (scheme, host, query sorting) | Custom exceptions, `URI` module, early returns |
| `UrlIdentifier` | Creates SHA256 fingerprints for deduplication | Module methods (functional style), `Digest` |
| `SlugGenerator` | Generates unique 6-char alphanumeric slugs | `SecureRandom`, guard clause |
| `ShortUrlCreator` | Orchestrates creation with retries | Transaction blocks, retry logic, error handling |

**Key Learning:** Service objects keep models thin and make testing easier. Notice how `ShortUrlCreator.call()` provides a clean API - this is the "Command Pattern" in Ruby.

### 2. Database Layer
- **Model:** `ShortUrl` with validations (presence, uniqueness, numericality)
- **Migrations:** Nullable slugs (allows delayed assignment), fingerprint column for deduplication
- **Index:** Unique on `slug` and `fingerprint`

**Key Learning:** The `allow_nil: true` on slug validation enables a pattern where slugs can be generated asynchronously or in a separate step.

### 3. Test Suite (RSpec)
- Service specs with mocking (`allow().to receive()`)
- FactoryBot for test data
- Transaction isolation for DB tests

**Key Learning:** Notice how we mock `UrlNormalizer` in `ShortUrlCreator` tests - this is "test isolation" and prevents one service's bugs from cascading into others' tests.

### 4. API Endpoints (All Working)
- **POST /api/v1/short_urls** - Creates shortened URLs with error handling ✓
- **GET /:slug** - Redirects to original URL, tracks visits ✓
- **GET /api/v1/short_urls/:slug/stats** - Returns visit count and original URL ✓

### 5. Infrastructure & Security
- **Rack::Attack Rate Limiting** - 10 requests/60s per IP ✓
- **Production Dockerfile** - Multi-stage build, optimized for performance ✓
- **Kamal Deployment** - Already configured for deployment (config/deploy.yml) ✓
- **CI/CD Setup** - GitHub Actions for testing, linting, security scanning ✓

### 6. Infrastructure & Manual Deployment (Alibaba Cloud Migration)
Completed the manual production deployment after pivoting from Oracle Cloud to Alibaba Cloud, establishing a hardened Ubuntu 22.04 environment with secure Rails 8 orchestration.

| Component | Implementation | Learning Outcome |
|:---|:---|:---|
| **Cloud Provider** | Alibaba Cloud ECS (Ubuntu 22.04) | Managed the provider pivot and configured Alibaba Cloud Security Groups for ports `80`/`443`. |
| **OS Hardening** | `ufw` firewall rules | Added host-level network protection alongside cloud firewall controls. |
| **Environment Config** | `/etc/default/url-shortener` | Followed FHS conventions for production environment variables and service injection. |
| **Database** | PostgreSQL 14 | Standardized production auth on `scram-sha-256` password encryption. |
| **Rails 8 Solid Suite** | Dedicated `solid_cache`, `solid_cable`, and `solid_queue` database entries | Resolved `ActiveRecord::AdapterNotSpecified` errors from Rails 8's database-backed adapters. |
| **Process Mgmt** | Systemd | Created a resilient service unit with automatic restarts, secure `EnvironmentFile` loading, and logs redirected to `/var/www/url-shortener/log/`. |
| **Credential Isolation** | Restricted configuration vault | Moved database passwords and `SECRET_KEY_BASE` out of the unit file into a `600`-permission config file. |
| **Reverse Proxy** | Nginx | Forwarded external traffic from ports `80`/`443` to Puma while preserving request headers. |

**Key Learning:** Manual deployment bridged the gap between Rails code, Linux process management, cloud networking, and production security. Keeping secrets outside the service unit and inside an FHS-aligned vault makes the setup safer and easier to operate.

### 7. CI/CD Pipeline & Automated Deployment
| Component | Implementation | Learning Outcome |
|:---|:---|:---|
| **CI Quality Gate** | Embedded `actions/checkout@v6` alongside automated security auditing (`brakeman`), formatting compliance (`rubocop`), and database-driven orchestration (`rspec` running against live, ephemeral `postgres:14` service containers). | Built a true gatekeeper system. If syntax style, static security assessments, or data unit specs fail in the virtual runner, the entire delivery sequence safely aborts to protect production. |
| **Atomic Updates** | Replaced unstable inline `git pull` calls with a sequence using `git fetch origin master` followed by an explicit `git reset --hard origin/master`. | Learned how to prevent pipeline failures caused by accidental, untracked local file modifications or auto-generated logs conflicting on the live host environment. |
| **Dependency Lock** | Hardcoded internal Bundler routing strictly to local storage execution paths using `bundle config set --local path 'vendor/bundle'` and matching exclusions. | Solved dependency isolation. Tracking `.bundle/config` ensures the server encapsulates application dependencies locally within the project directory without requiring global root updates. |
| **Secure Command Execution** | Layered targeted `appleboy/ssh-action@v1.0.3` hooks using repository secrets (`SERVER_HOST`, `SERVER_USER`, `SSH_PRIVATE_KEY`). | Mastered headless automation. By mapping root keys down to explicit `.ssh/authorized_keys` with tight permissions (`700`/`600`), GitHub can deploy securely over non-interactive shell limits. |

### 8. Principle of Least Privilege & Secure Host Hardening
| Component | Implementation | Learning Outcome |
|:---|:---|:---|
| **Sudo Restriction Vault** | Stripped the `deployer` user from the global `sudo` or `admin` Unix groups. Invoked `sudo visudo` to append an explicit bypass rule: `deployer ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart url-shortener`. | Mastered privilege isolation. If the CI/CD pipeline or the application process itself is compromised, the attacker is completely trapped in an unprivileged scope and cannot alter host firewalls, read other user environments, or install system packages. |
| **Configuration Vault Guard** | Located application-level database credentials and the Rails `SECRET_KEY_BASE` away from standard repository scripts. Stored them inside `/etc/default/url-shortener` with system permissions locked down strictly to `chown deployer:deployer` and `chmod 600`. | Learned to prevent data leaks via environment sniffing. Restricting read/write access exclusively to the system process owner prevents other local system accounts or unprivileged users from extracting production tokens. |
| **Targeted Folder Ownership** | Ran `chown -R deployer:deployer /var/www/url-shortener` across the workspace, combined with standard directory permissions (`755` for folders, `644` for files). | Eliminated the dangerous "fix" of using `sudo` to bypass local permission roadblocks. Because `deployer` natively owns the application code layer, dependencies and migrations compile smoothly without elevating process executions to root. |
| **Secure Systemd Execution Scope** | Configured the application's `.service` unit descriptor file with explicit execution Directives: `User=deployer` and `Group=deployer`. | Enforced a sandboxed runtime environment. By executing the Puma application server under a regular, restricted daemon context instead of root, a remote code execution exploit cannot compromise the core Linux kernel filesystem. |

---

## 💥 Engineering Battles & Lessons Learned (The "Gotchas")

### 1. The Linux Permissions & Security Maze
- **The Challenge:** Giving the automated CI/CD pipeline enough execution context to deploy updates without exposing root server privileges.
- **The Fix:** Stripped the `deployer` user out of the broad system `sudo` group to enforce the Principle of Least Privilege. Wrote a hyper-targeted `visudo` exception configuration (`deployer ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart url-shortener`) to restrict elevated access strictly to application reboots, while carefully balancing permission layers on the app folder and environment files.

### 2. The SSH Key Mix-Up
- **The Challenge:** Cloud environments inject default SSH authorization structures exclusively into the root host workspace, rejecting automated CI connection requests targeting the new unprivileged deployment user.
- **The Fix:** Created a standalone `.ssh` directory manually within the `deployer` user scope, migrated authorized public tracking records from root, and hard-locked permissions down to strict `700` (directory) and `600` (file) guidelines to satisfy SSH host validation requirements.

### 3. The "Moving rbenv" Nightmare
- **The Challenge:** Transitioning a local user-scoped Ruby runtime (`/root/.rbenv`) into a shared system environment path (`/opt/rbenv`) broke multiple internal dependencies.
- **The Hurdles:**
  - *The Symlink Trap:* Symlinking binaries back to `/root/` instantly failed because the unprivileged application user lacked directory visibility.
  - *Hardcoded Shebangs:* Relocating directories broke internal core scripts for `gem` and `bundle` which maintained internal references (`#!/root/.rbenv/...`) hardcoded at the top of their execution files.
  - *The Segmentation Fault:* Running global string replacements via `sed` on compiled Ruby binaries corrupted machine code signatures, causing immediate core dumps.
- **The Fix:** Completely deleted the corrupted system-level Ruby version and triggered a clean, fresh compilation from source targeting the `/opt/rbenv` prefix path, stabilizing system-wide access.

### 4. The Non-Interactive Shell "Black Hole"
- **The Challenge:** Non-interactive automated SSH sessions initialized by CI/CD workflows bypass user profile generation hooks (`.bashrc`, `.profile`), dropping execution environments out of the system `$PATH` and triggering `bundle: command not found` exceptions.
- **The Fix:** Generated global, permanent system symlinks inside `/usr/local/bin/` pointing directly to `/opt/rbenv/shims/`, ensuring core runtime shims remain universally accessible across all shell interaction layers.

### 5. Gem Management & The Sudo Trap
- **The Challenge:** Preventing shared, root-owned `rbenv` directories from forcing the unprivileged `deployer` user to invoke `sudo` when installing application dependencies.
- **The Fix:** Bound execution tasks locally using `bundle config set --local path 'vendor/bundle'`. This dropped tracking directories directly into the isolated project folder owned by `deployer`. The local configuration files (`.bundle/config`) are safely tracked in Git, while ignoring the massive `vendor/bundle` cargo dependencies via `.gitignore`.

### 6. The Nginx IPv4 vs. IPv6 Trap
- **The Challenge:** Nginx and Puma processes ran perfectly in isolation but threw gateway errors when bridged together.
- **The Fix:** Diagnosed that Linux resolves `localhost` references natively down to the IPv6 loopback interface (`::1`), while Puma was listening exclusively on the standard IPv4 channel (`127.0.0.1`). Explicitly hardcoded the upstream destination signature inside Nginx to `proxy_pass http://127.0.0.1:3000;` to align the network traffic.

### 7. Systemd User Isolation
- **The Challenge:** Shielding the core OS environment from file write manipulation or arbitrary command execution vulnerabilities in the event of an application exploit.
- **The Fix:** Adjusted the system service unit configuration to enforce `User=deployer` context handling. Since folder visibility constraints and logs were pre-mapped directly to the `deployer` ownership profile, the runtime layer retained standard permission mechanics without needing root tracking privileges.

---

## 🎯 Next Steps (Priority Order)


### Phase 1 - Containerized Deployment
Learning: Docker image builds, registries, Kamal, zero-downtime deployment

1. **Docker Image Pipeline**
   - Build Docker image on push to main
   - Push to GHCR (GitHub Container Registry)
   - Promote a tested image instead of rebuilding on the server
   - **Concepts:** container registries, image tags, immutable releases

2. **Kamal Deployment**
   - Deploy containerized app to Alibaba Cloud ECS
   - Automated rollbacks
   - **Concepts:** Docker orchestration, zero-downtime deploys

### Phase 2 - Features (After deployment is stable)

3. **OmniAuth Integration**
   - Google/Facebook login for "my links" feature
   - User owns their shortened URLs
   - **Ruby Concept:** Middleware, OAuth flows, session management in API mode

4. **IP/Location Analytics**
   - Track visitor IP, country, city
   - Enhanced stats endpoint
   - **Ruby Concept:** Geolocation gems, analytics data modeling

5. **Background Job for Analytics**
   - Move visit incrementing to Solid Queue
   - **Ruby Concept:** Active Job, async processing

---

## 🐛 Known Issues

None currently - MVP is stable and deployment-ready!

---

## 📚 Ruby/Rails Concepts Used

| Concept | Where You Used It |
|---------|-------------------|
| Service Objects | `app/services/` |
| Custom Exceptions | `UrlNormalizer::InvalidUrl`, `ShortUrlCreator::Error` |
| Transactions | `ShortUrl.transaction` |
| Retry Logic | `rescue` + `retry` with attempt counter |
| Secure Random | `SecureRandom.alphanumeric` |
| SHA256 Digest | `Digest::SHA256.hexdigest` |
| Validation DSL | `validates :field, presence: true` |
| Factory Pattern | FactoryBot in specs |
| Mocking/Stubbing | `allow().to receive()` in tests |

---

## 🚀 Quick Start Commands

```bash
# Run tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/services/url_creator_spec.rb

# Interactive console
rails console

# Check routes
rails routes

# Database console
rails dbconsole

# Start dev server
rails server
```

## 🚀 Deployment Roadmap

```bash
# Phase 1: Manual Deployment (completed on Alibaba Cloud)
# 1. Provision Alibaba Cloud ECS
# 2. Install Ruby, PostgreSQL, Nginx
# 3. Configure systemd service
# 4. Configure Nginx reverse proxy
# 5. Secure environment variables in /etc/default/url-shortener

# Phase 2: Automate the manual deployment
# 1. Run tests in GitHub Actions
# 2. SSH into Alibaba Cloud ECS from CI
# 3. Pull latest code and run bundle/rails tasks
# 4. Restart the systemd service
# 5. Run smoke checks against production

# Phase 3: HTTPS and production hardening
# 1. Issue Let's Encrypt certificate
# 2. Enable Nginx SSL
# 3. Add monitoring and health checks

# Phase 4: Containerized Deployment
# 1. Docker build locally
# 2. Push to GHCR
# 3. Deploy with Kamal
```

---

## 📊 Learning Progress Summary

| Category | Status | Comments |
|----------|--------|----------|
| **Ruby/Rails Basics** | ✅ Done | Service objects, transactions, validations mastered |
| **API Design** | ✅ Done | RESTful endpoints, JSON responses, error handling |
| **Testing** | ✅ Done | RSpec, mocking, FactoryBot fluent |
| **Database Design** | ✅ Done | Migrations, indexes, deduplication strategy |
| **Security** | ✅ Partial | Rate limiting done; OAuth/auth pending |
| **Deployment** | ✅ Done | Manual deployment completed on Alibaba Cloud ECS |
| **CI/CD** | 🚧 Planned | GitHub Actions → SSH/systemd deploy → GHCR → Kamal |
| **Monitoring** | 📋 Planned | Health checks and alerting after HTTPS |
| **Analytics** | 📋 Planned | Geolocation tracking for URLs |

## Architecture Decisions

- **API-only Rails:** Chosen for lightweight JSON API (no views, sessions by default)
- **Service Layer:** Extracted business logic from models for testability
- **Fingerprint Column:** Enables deduplication without comparing long URLs
- **Nullable Slugs:** Allows flexible slug generation strategies

---

*Last updated: May 2026*
