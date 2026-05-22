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

---

## 🎯 Next Steps (Priority Order)

<!-- ### Phase 1 - Production Hardening
Learning: DNS, SSL/TLS, monitoring, operational polish -->

<!-- 1. **HTTPS Setup**
   - Install Let's Encrypt certificate
   - Configure Nginx SSL
   - **Concepts:** DNS, SSL/TLS, cert management

2. **Monitoring & Health Checks**
   - Add uptime checks
   - Review production logs from `/var/www/url-shortener/log/`
   - **Concepts:** observability, incident triage, service reliability -->

### Phase 1 - CI/CD Automation
Learning: GitHub Actions, SSH automation, release scripts, systemd-based deploys

1. **CI Quality Gate**
   - Run RSpec on every push and pull request
   - Add linting/security checks before deployment
   - Keep deployment blocked unless tests pass
   - **Concepts:** YAML workflows, build status, failing fast

2. **Automated Manual Deployment**
   - Use GitHub Actions to SSH into the Alibaba Cloud ECS instance
   - Pull the latest code, install dependencies, run migrations, and restart the systemd service
   - Reuse the existing Nginx, Puma, PostgreSQL, and `/etc/default/url-shortener` setup
   - **Concepts:** SSH keys, deploy users, non-interactive shell scripts, systemd orchestration

3. **Release Safety**
   - Add a deploy script with clear steps and failure handling
   - Keep a simple rollback path using previous Git commits
   - Run smoke checks against the live app after restart
   - **Concepts:** idempotent scripts, rollback thinking, health verification

### Phase 2 - Containerized Deployment
Learning: Docker image builds, registries, Kamal, zero-downtime deployment

4. **Docker Image Pipeline**
   - Build Docker image on push to main
   - Push to GHCR (GitHub Container Registry)
   - Promote a tested image instead of rebuilding on the server
   - **Concepts:** container registries, image tags, immutable releases

5. **Kamal Deployment**
   - Deploy containerized app to Alibaba Cloud ECS
   - Automated rollbacks
   - **Concepts:** Docker orchestration, zero-downtime deploys

### Phase 3 - Features (After deployment is stable)

6. **OmniAuth Integration**
   - Google/Facebook login for "my links" feature
   - User owns their shortened URLs
   - **Ruby Concept:** Middleware, OAuth flows, session management in API mode

7. **IP/Location Analytics**
   - Track visitor IP, country, city
   - Enhanced stats endpoint
   - **Ruby Concept:** Geolocation gems, analytics data modeling

8. **Background Job for Analytics**
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
