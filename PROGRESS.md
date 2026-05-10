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

---

## 🎯 Next Steps (Priority Order)

### Phase 1 - Manual Deployment (In Progress)
Learning: Linux basics, SSH, reverse proxy, process management

1. **Manual Deploy to Oracle Cloud VM**
   - SSH into VM
   - Install Ruby, PostgreSQL, Nginx
   - Git clone app
   - Configure systemd for auto-start
   - Set up Nginx reverse proxy
   - **Concepts:** SSH workflows, Linux processes, HTTP reverse proxying

2. **HTTPS Setup**
   - Install Let's Encrypt certificate
   - Configure Nginx SSL
   - **Concepts:** DNS, SSL/TLS, cert management

### Phase 2 - CI/CD Automation
Learning: GitHub Actions, automated testing, automated deployment

3. **GitHub Actions Workflow**
   - Build Docker image on push to main
   - Push to GHCR (GitHub Container Registry)
   - Automated tests before deployment
   - **Concepts:** YAML workflows, container registries, CI/CD pipelines

4. **Kamal Deployment**
   - Deploy containerized app to Oracle VM
   - Automated rollbacks
   - **Concepts:** Docker orchestration, zero-downtime deploys

### Phase 3 - Features (After deployment is stable)

5. **OmniAuth Integration**
   - Google/Facebook login for "my links" feature
   - User owns their shortened URLs
   - **Ruby Concept:** Middleware, OAuth flows, session management in API mode

6. **IP/Location Analytics**
   - Track visitor IP, country, city
   - Enhanced stats endpoint
   - **Ruby Concept:** Geolocation gems, analytics data modeling

7. **Background Job for Analytics**
   - Move visit incrementing to Solid Queue
   - **Ruby Concept:** Active Job, async processing

---

## 🐛 Known Issues

None currently - MVP is stable and deployment-ready!

---

## 📚 Ruby/Rails Concepts You've Used

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

```basDevelopment Commands

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
# Phase 1: Manual Deployment
# 1. SSH to Oracle VM
# 2. Install dependencies
# 3. Git clone
# 4. systemd service
# 5. Nginx reverse proxy

# Phase 2: Containerized Deployment
# 1. Docker build locally
# 2. Push to GHCR
# 3. Deploy with Kamal

---

## 📊 Learning Progress Summary

| Category | Status | Comments |
|----------|--------|----------|
| **Ruby/Rails Basics** | ✅ Done | Service objects, transactions, validations mastered |
| **API Design** | ✅ Done | RESTful endpoints, JSON responses, error handling |
| **Testing** | ✅ Done | RSpec, mocking, FactoryBot fluent |
| **Database Design** | ✅ Done | Migrations, indexes, deduplication strategy |
| **Security** | ✅ Partial | Rate limiting done; OAuth/auth pending |
| **Deployment** | 🚧 In Progress | Manual deployment on Oracle Cloud |
| **CI/CD** | 🚧 Planned | GitHub Actions → GHCR → Kamal |
| **Monitoring** | 📋 Planned | Logging, health checks after deploy |
| **Analytics** | 📋 Planned | Geolocation tracking for URLs |

*Last updated: MayD Automation
# 1. GitHub Actions on push
# 2. Auto-deploy on success
```

## Architecture Decisions

- **API-only Rails:** Chosen for lightweight JSON API (no views, sessions by default)
- **Service Layer:** Extracted business logic from models for testability
- **Fingerprint Column:** Enables deduplication without comparing long URLs
- **Nullable Slugs:** Allows flexible slug generation strategies

---

*Last updated: April 2026*
