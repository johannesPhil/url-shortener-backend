# Engineering Quality Checklist

## 1. Proper Database Design

* [ ] Correct normalization strategy
* [ ] Proper indexes
* [ ] Unique constraints where needed
* [ ] Foreign keys enforced
* [ ] Transactions used correctly
* [ ] Query efficiency considered
* [ ] Race conditions considered
* [ ] Idempotency handled
* [ ] Retry-safe operations
* [ ] Migrations reversible

---

## 2. Reliability Thinking

* [ ] Failure paths considered
* [ ] Duplicate processing prevented
* [ ] Partial writes avoided
* [ ] Graceful error handling
* [ ] Controlled retries
* [ ] Timeouts configured
* [ ] Safe rollback behavior
* [ ] App survives malformed input
* [ ] Background jobs designed safely

---

## 3. Backend Architecture

* [ ] Separation of concerns
* [ ] Business logic not mixed into routes/controllers
* [ ] Reusable service structure
* [ ] Config separated from code
* [ ] Consistent API responses
* [ ] Structured logging
* [ ] Environment-aware configuration

---

## 4. Infrastructure Ownership

* [ ] Linux basics understood
* [ ] SSH workflow comfortable
* [ ] Reverse proxy setup understood
* [ ] Process management understood
* [ ] Database management basics understood
* [ ] DNS + HTTPS setup understood
* [ ] Deployment reproducible

---

## 5. CI/CD Engineering

* [ ] Understand every YAML step
* [ ] Automated tests on push
* [ ] Automated deployment pipeline
* [ ] Secrets handled safely
* [ ] Rollback strategy exists
* [ ] Deployments reproducible

---

## 6. Observability

* [ ] Logs meaningful
* [ ] Health checks exist
* [ ] Failures traceable
* [ ] Monitoring considered
* [ ] Crash visibility exists

---

## 7. Production Thinking

* [ ] What happens under load?
* [ ] What happens if DB dies?
* [ ] What happens if deploy fails?
* [ ] What happens during retries?
* [ ] What happens during duplicate requests?
* [ ] What is the recovery strategy?

---

# Progression Roadmap

## Phase 1 — Single VM Deployment

Goal:
Understand the machine.

Stack:

* Ubuntu VM
* Ruby app
* PostgreSQL
* Nginx
* systemd

Learn:

* Linux basics
* SSH
* Nginx
* PostgreSQL management
* DNS
* HTTPS
* Process management

Deliverable:

* Public deployed app
* HTTPS enabled
* Auto-start on reboot
* Logs inspectable

---

## Phase 2 — CI/CD Automation

Goal:
Stop manual deployments.

Learn:

* GitHub Actions
* YAML structure
* Secrets
* Automated testing
* Automated deployment

Deliverable:

* Push triggers tests
* Successful build deploys automatically

---

## Phase 3 — Containerization

Goal:
Understand runtime isolation.

Learn:

* Docker
* Docker Compose
* Volumes
* Networking
* Image lifecycle

Deliverable:

* App fully containerized
* Reproducible environment

---

## Phase 4 — Production Hardening

Goal:
Operate reliably.

Learn:

* Monitoring
* Backups
* Rate limiting
* Health checks
* Resource management
* Security basics

Deliverable:

* Observable + recoverable deployment

---

## Phase 5 — Scaling Concepts

Goal:
Understand state management and asynchronous processing.

Learn:

* Rails Solid Queue
* Rails.cache
* Cache invalidation
* Background processing
* Horizontal scaling concepts

Optional:

* Redis
    - Compare Redis with Rails Solid Queue and Solid Cache
    - Understand when an in-memory datastore becomes advantageous

Deliverable:

* Reliable asynchronous processing
* Efficient caching
* Understand trade-offs between database-backed and in-memory infrastructure

---

## Phase 6 — Kubernetes (Later)

Only after:

* Linux
* Docker
* Networking
* Deployment
* Observability

are actually comfortable.
