# URL Shortener - Project Progress & Learning Notes

> **Project Goal:** Build a URL shortener API while learning Ruby/Rails patterns

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

---

## 🎯 Next Steps (Priority Order)

### High Priority - API Layer
These will teach you Rails controllers, routing, and JSON API patterns:

1. **Create Short URL Endpoint**
   - `POST /api/v1/urls` - accepts `{ "url": "https://..." }`
   - Returns `{ "slug": "abc123", "short_url": "http://localhost:3000/abc123" }`
   - **Ruby Concept:** Strong parameters, `rescue_from` for error handling

2. **Redirect Endpoint**
   - `GET /:slug` - looks up slug, increments `visits`, redirects
   - **Ruby Concept:** `find_by!` (bang method that raises), `redirect_to`

3. **Stats Endpoint**
   - `GET /api/v1/urls/:slug/stats` - returns visit count
   - **Ruby Concept:** Serializer patterns (jbuilder or plain `as_json`)

### Medium Priority - Infrastructure

4. **Rack::Attack Configuration**
   - Rate limiting on URL creation (prevent abuse)
   - **Ruby Concept:** Rack middleware, initializer configuration

5. **OmniAuth Integration**
   - Google/Facebook login for "my links" feature
   - **Ruby Concept:** Middleware, OAuth flows, session management in API mode

### Low Priority - Polish

6. **Background Job for Analytics**
   - Move visit incrementing to Solid Queue
   - **Ruby Concept:** Active Job, async processing

---

## 🐛 Known Issues to Fix

1. **Broken Test:** `spec/services/url_creator_spec.rb:34` has an empty `it` block
2. **Schema Drift:** Run `rails db:migrate` to apply fingerprint migration to schema.rb
3. **Slug Validation Mismatch:** Model allows nil, factory always generates one - decide on one approach

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
```

---

## 💡 Suggested Learning Path

1. **Start with the Redirect endpoint** - simplest, teaches controller + routing basics
2. **Add the Create endpoint** - introduces strong params, JSON responses, error handling
3. **Configure Rack::Attack** - learn middleware stack
4. **Add request specs** - integration testing with real HTTP requests

---

## Architecture Decisions

- **API-only Rails:** Chosen for lightweight JSON API (no views, sessions by default)
- **Service Layer:** Extracted business logic from models for testability
- **Fingerprint Column:** Enables deduplication without comparing long URLs
- **Nullable Slugs:** Allows flexible slug generation strategies

---

*Last updated: April 2026*
