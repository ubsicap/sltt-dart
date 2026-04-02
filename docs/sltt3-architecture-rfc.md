# RFC: SLTT 3 Platform Architecture

Status: Draft for discussion
Last updated: 2026-04-02
Primary audience: Product and engineering
Secondary audience: Outside technical partners
Related milestone: 2026 Milestone 4 - Architecture Documentation

## 1. Summary

SLTT 3 needs an architecture that supports offline-first operation and networked collaboration, stable API contracts, and a clear path to future deployment shapes beyond the initial 2026 desktop-first product. This RFC recommends a platform architecture in which Flutter clients and future clients consume a shared REST API and synchronization model, while core server and merge logic remain portable enough to run in cloud and LAN-hosted environments.

The recommendation is intentionally flexible at the API surface while still expressing a preferred synchronization path. SLTT 3 supports both change-based and state-based downsyncing. For Dart and Flutter clients, sequential change-based downsync with local state materialization may prove more performant and cost-effective, while also building confidence in future LAN-hosted operation. Full entity-state retrieval can then supplement this as a fallback for repair, initial loading, and interoperability with other clients and systems.

This RFC is not intended to finalize every implementation detail. Its purpose is to align product and engineering around a recommended architecture, identify validation work that must happen in 2026, and preserve a credible path to future capabilities including LAN collaboration, mobile clients, reporting dashboards, and external reporting APIs.

## 2. Context

SLTT 2.0 delivered meaningful value for sign language translation teams, but the product accumulated technical and workflow pressure in several areas:

- Browser and PWA constraints complicated installation, permissions, disk space management, video processing, and offline reliability.
- Lack of backend state persistence meant new clients had to sequentially download long change histories and forced the reporting backend to duplicate replay logic in order to process and serve state.
- Lack of local state persistence meant clients had to replay long change histories on every load, leading to performance issues and, as projects grew, potential memory pressure.
- Too much client-specific merging and state logic made portability challenging and led to duplicated logic across other clients and systems, rather than allowing state to be served through a stable API and changes to be processed with shared code.
- The single-track timeline became overloaded with patches, comments, references, and other concerns that should evolve more independently.
- Current and future clients need a clearer contract for sync, auth, state retrieval, and integrations.

At the same time, SLTT 3 is expected to support a broader product surface than the initial 2026 roadmap alone. In addition to desktop-first delivery, the platform needs to leave room for:

- full offline collaboration with LAN-hosted local team storage,
- mobile clients optimized for phone and tablet workflows,
- reporting dashboards for internal monitoring and planning,
- external reporting APIs for partner access,
- future integrations that depend on stable server-side behavior rather than client-specific logic.

## 3. Problem Statement

SLTT 3 needs an offline-first, API-based platform architecture that can:

- support day-to-day client operation with predictable sync behavior,
- provide a reliable fallback path when client and server state diverge,
- allow clients to persist state locally so they can lazy-load data, lower memory usage, and shorten startup time,
- preserve the option for any suitable device to become a LAN host for a local team,
- avoid coupling reporting and partner integrations to raw sync storage,
- support future clients without forcing all business logic into each client implementation.

While a more state-pull-heavy API model could temporarily reduce client complexity during downsync and help guarantee consistency, this RFC recommends a different default: support state-based pulling, but treat change-based downsync as the primary operating mode for Dart and Flutter clients so the same merge and materialization logic used in the backend is battle-tested in the clients that may later act as LAN hosts.

## 4. Goals

- Define a recommended target architecture for SLTT 3 platform services and clients.
- Clarify the preferred sync model and the role of full entity-state retrieval.
- Clarify the role of persisted local state in startup performance, lazy loading, and memory usage.
- Show how 2026 milestones fit into a coherent longer-term architecture.
- Preserve architectural headroom for LAN collaboration, mobile clients, reporting, and partner APIs.
- Separate current implemented facts from target architecture and validation work.

## 5. Non-Goals

- Finalizing every database schema for every entity type.
- Finalizing every UI workflow for desktop or mobile.
- Locking in a final reporting schema or analytics stack in 2026.
- Specifying every auth endpoint and policy detail in this document.
- Replacing follow-up ADRs for sync performance, auth, search, or reporting implementation details.

## 6. Current State

The current codebase already provides a strong starting point for the recommended platform direction:

- The backend already exposes a REST API and self-documented `/api/help` endpoint in [../packages/sltt_core/lib/src/api/base_rest_api_server.dart](../packages/sltt_core/lib/src/api/base_rest_api_server.dart).
- The current AWS design already separates shared infrastructure from environment-specific API deployments in [../packages/aws_backend/serverless-shared-infra.yml](../packages/aws_backend/serverless-shared-infra.yml) and [../packages/aws_backend/serverless-secondary-infra.yml](../packages/aws_backend/serverless-secondary-infra.yml).
- The current sync model already distinguishes change storage and entity state concerns.
- The current implementation work on concurrent entity-state downloads demonstrates that state retrieval remains important, especially for recovery and performance testing.
- The current direction toward persisted entity state also creates room for lazy loading and lower memory pressure, which should improve startup behavior for larger projects.

This RFC therefore builds on existing architecture rather than replacing it with a wholly new conceptual model.

## 7. Recommended Architecture

### 7.1 Core Principle

SLTT 3 adopts an offline-first synchronization model that supports both change-based and state-based downsyncing.

For Dart and Flutter clients, the normal operating mode is sequential change-based downsync followed by local state materialization. This is expected to reduce read costs and deliver more state updates per MB than frequent full-state transfers. To detect divergence from server state, clients compare local and server `stateDataHash` values. When a mismatch is detected, or when bootstrap, recovery, benchmarking, or interoperability needs make it preferable, clients can fall back to entity-state API requests to pull full state.

This design keeps the architecture flexible while making one preference explicit: SLTT should battle-test the same change ingestion, merge, and materialization path that future LAN hosts will need to run.

### 7.2 Target Platform Shape

The recommended target shape is:

- Flutter clients and future clients consume a stable REST API.
- The backend runs as Dart server logic in cloud-hosted environments and, where needed later, LAN-hosted environments.
- Shared cloud infrastructure owns durable shared resources such as DynamoDB, S3, CloudFront, and cross-account configuration.
- Environment-specific API deployments host the operational API surface.
- Clients primarily downsync changes and materialize state locally.
- Clients persist enough local state to support lazy loading, faster startup, and a lower memory profile.
- Clients compare local and cloud `stateDataHash` values to detect divergence.
- Clients selectively use full entity-state retrieval when change replay is not the best option.
- Reporting and dashboard use cases are served by a reporting layer, not by direct client-side aggregation over operational sync data.

## 8. Synchronization and State Model

### 8.1 Preferred Normal Flow

The preferred normal flow for Dart and Flutter clients is:

1. Client submits changes to the server.
2. Client downsyncs ordered changes from the server.
3. Client applies those changes locally and materializes entity state.
4. Client persists enough local state to support lazy loading and avoid replaying all history on every startup.
5. Client compares local and remote `stateDataHash` values.
6. If hashes match, the client continues normal operation.
7. If hashes diverge, the client selectively requests full entity state for repair or re-baselining.

### 8.2 Why Prefer Change-Based Downsync

Change-based downsync is preferred because it:

- exercises the merge and materialization path that future LAN hosts will depend on,
- keeps clients closer to being promotable into local hosts,
- is expected to reduce read costs,
- is expected to deliver more state updates per MB transferred,
- allows clients to persist state and lazy-load data as needed instead of loading or replaying everything up front,
- helps reduce memory pressure and shorten time to first useful interaction,
- keeps operational sync behavior conceptually aligned across cloud and LAN deployment shapes.

### 8.3 Why Preserve State-Based Downsync

State-based downsync remains important because it:

- provides a recovery path when state divergence is detected,
- supports fast bootstrap and repair flows,
- can be parallelized across REST requests,
- may outperform change replay in some high-volume scenarios,
- provides an interoperability path for clients that do not share Dart merge logic.

### 8.4 Validation Requirement

The architecture should not assume that one path always wins. Benchmarking with realistic high-volume datasets should compare:

- change-based downsync cost,
- full state retrieval cost,
- end-to-end time to materialize equivalent client-visible state,
- API read costs,
- payload size,
- server load,
- user-perceived responsiveness.

This validation work should inform later tuning, but should not change the architectural preference that Dart and Flutter clients normally exercise the change-based path.

## 9. API Model

The API should be organized around stable server-side contracts rather than client-specific embedded business logic.

The operational API should include:

- change submission and retrieval,
- entity-state retrieval,
- media access and multipart upload flows,
- auth and authorization endpoints,
- domain and entity discovery where appropriate,
- health and self-documentation endpoints.

The current self-documented API model in [../packages/sltt_core/lib/src/api/base_rest_api_server.dart](../packages/sltt_core/lib/src/api/base_rest_api_server.dart) is a useful base because it keeps runtime behavior and documentation close together. That said, it also means API evolution must stay disciplined so `/api/help` remains aligned with actual handlers.

The RFC recommends distinguishing at least three logical API surfaces over time:

- operational sync and media APIs,
- admin and maintenance APIs,
- reporting and partner-facing APIs.

These do not all need to be physically separate in 2026, but they should be treated as distinct contract categories.

## 10. Deployment Shapes

### 10.1 Cloud-Hosted Shared Collaboration

The current AWS direction remains the recommended primary deployment shape for shared collaboration:

- shared infrastructure stack for durable shared resources,
- environment-specific API deployments for dev, staging, and production,
- shared storage and media services,
- centralized auth and integration points.

### 10.2 LAN-Hosted Local Team Collaboration

Future SLTT should also support a local-team-storage or LAN-hosted mode in which a suitable device runs the same core server and merge logic for nearby team devices.

The architecture implication is important: if any suitable client device may later become a host, then the merge and materialization path should be validated in ordinary client operation now, not treated as server-only behavior hidden in the cloud.

This does not mean every client becomes a host by default. It means the architecture should preserve host portability.

### 10.3 Mobile Clients

Mobile clients should consume the same auth, sync, and entity-state contracts as desktop, but with a deliberately narrower product scope and mobile-appropriate UX. The architecture should therefore favor shared domain logic and contracts, while keeping UI and workflow scope distinct.

## 11. Operational Data vs Reporting Data

SLTT operational sync APIs exist to create, fetch, merge, and materialize working project data. Reporting use cases are different. They answer questions such as project activity, progress, usage trends, and partner-facing summaries.

For that reason, this RFC recommends that reporting services and dashboards be built on a reporting or analytics pipeline rather than direct client-side aggregation over operational sync data.

That means:

- operational sync/state storage remains optimized for collaboration and correctness,
- reporting data is derived into reporting-friendly summaries and server-side projections,
- dashboards read curated reporting data,
- external reporting APIs expose stable, partner-oriented reporting contracts rather than raw sync storage semantics.

This separation reduces the risk that dashboard queries, partner reporting, or client-side aggregation will distort or overload operational collaboration systems. It also avoids forcing reporting systems to independently replay long operational change histories just to reconstruct the state they need to serve.

## 12. Requirements Mapping

The architecture should explicitly support the following requirement themes:

| Theme | Architectural Response |
| --- | --- |
| Multi-track timeline | Separate entity/state models and APIs so patches, comments, markers, and other tracks can evolve independently while still aligning through shared synchronization contracts. |
| TRL workflow redesign | Move resource workflows behind dedicated backend contracts instead of embedding them in altered translation object flows. |
| Multi-Bible support | Keep the client free to render multiple synchronized datasets while relying on stable backend/state contracts rather than client-specific business logic. |
| REST API centralization | Put business logic behind stable API contracts shared across desktop, mobile, and future partner integrations. |
| Persisted local state | Persist enough local state to support lazy loading, lower memory usage, shorter startup time, and reliable divergence detection through `stateDataHash`. |
| Mobile product | Reuse auth, sync, and state contracts while allowing scoped feature sets and mobile-specific UX. |
| Deep search | Treat search as a server-side capability or service tier that can evolve independently from client workflows. |
| First-party auth | Centralize auth, token issuance, and permission enforcement in backend services rather than UI-specific flows. |
| LAN collaboration | Keep merge/materialization portable enough that a suitable device can host local collaboration in the future. |
| Reporting dashboard | Build on a reporting pipeline rather than direct aggregation over sync tables. |
| External reporting API | Expose a stable partner-facing reporting surface that is conceptually separate from operational sync APIs. |

## 13. 2026 Milestone Alignment

This RFC should support the 2026 milestones as follows:

| Milestone | Architectural implication |
| --- | --- |
| Milestone 4: architecture documentation | This RFC, requirements mapping, and feature transition material align product and engineering around the target platform shape. |
| Q2: endpoints documented and serving mock data | The API model and route categories should be stable enough to support mocked endpoint delivery before all internals are complete. |
| Q3: core backend functions | Auth, sync, state retrieval, and entity lifecycles should be implemented against the architecture described here. |
| Q3: migration proof | Existing SLTT 2.0 project data should be migrated into the new model enough to validate sync and state behavior. |
| Q4: usage data pipeline | The operational/reporting separation should begin to take concrete shape. |
| Q4: integrations and feature flags | The architecture should support new integrations without forcing product logic back into clients. |

## 14. Open Decisions

The following decisions should be discussed explicitly rather than left implicit:

- API versioning strategy and compatibility expectations.
- Auth architecture, token model, and project-scoped authorization rules.
- Search architecture and indexing boundaries.
- Sync conflict semantics and user-visible recovery behavior.
- Exact use of `stateDataHash` in divergence detection, repair, and observability.
- Benchmarks and success criteria for change-based versus state-based downsync.
- LAN deployment topology, trust model, and host promotion rules.
- Reporting data pipeline boundaries and retention policies.
- Whether the external reporting API is read-only or includes operational actions.

## 15. Risks and Tradeoffs

### 15.1 Change-Based Downsync Risk

Change replay may be more serialized and could underperform full-state retrieval in some scenarios. This is why benchmarking remains required.

### 15.2 State-Based Downsync Risk

A state-heavy default could weaken confidence in the merge/materialization path needed for future host portability and could increase read cost or payload size.

### 15.3 Reporting Risk

If reporting grows directly out of sync tables and client-side aggregation, operational systems may become harder to scale, reason about, and expose safely to partners.

### 15.4 Scope Risk

If the RFC tries to settle every implementation detail, it will slow down Milestone 4 without improving clarity. This document should hold the platform line while leaving room for follow-up ADRs.

## 16. Recommended Next Steps

1. Review this RFC with product and engineering together.
2. Confirm the preferred sync wording and the role of `stateDataHash`-based divergence detection.
3. Identify which Q2 mock endpoints should reflect the long-term route categories.
4. Define benchmark scenarios comparing change-based and state-based downsync at realistic data volumes.
5. Split unresolved topics into follow-up ADRs for auth, search, reporting, and LAN hosting.

## 17. Discussion Questions

1. Is the team aligned that SLTT 3 should support both change-based and state-based downsyncing, while preferring change-based downsync for Dart and Flutter clients?
2. Does the team agree that merge and state materialization should be battle-tested in ordinary client operation to preserve future LAN host portability?
3. Which scenarios should trigger full entity-state retrieval automatically versus manually?
4. What benchmark data volume and success thresholds are enough to validate the sync model choice?
5. Should reporting and partner-facing APIs be treated as separate products from the start, even if they share infrastructure early on?
