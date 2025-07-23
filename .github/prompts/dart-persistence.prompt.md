**Objective:**  
Develop a shared Dart backend codebase that can be abstracted and deployed across multiple environments, supporting robust data and media management, synchronization, and collaboration.

---

**Requirements:**

1. **Client-Side (Mobile/Desktop Flutter Apps):**
   - **Offline-First:** Operate fully offline, persisting all data and media locally.
   - **LAN Collaboration:** Enable real-time or near-real-time data/media sync and collaboration with other devices on the same local network.
   - **Cloud Sync:** When online, automatically synchronize local and LAN changes with a shared AWS backend (see section 2).
   - **Sync Logic:** 
     - Local changes sync to LAN and cloud when available.
     - LAN changes sync to cloud when available.
     - Ensure conflict resolution and data consistency.
   - **Developer Support:** Support developer/debug modes, allowing attachment of debuggers (e.g., VS Code, Edge:Inspect) in all scenarios.
   - **Media & Data Handling:** Efficiently manage both structured data and large media files (images, videos, etc.).
   - **REST API:** Expose a RESTful API for data/media access by external clients.
   - **Storage Preference:** Prefer AWS DynamoDB for structured data and S3 for media, but allow for pluggable storage backends.
   - **Object IDs:** Use UUIDv7 for all object identifiers.
   - **Sync Status:** Provide APIs for clients to query sync status and progress for both data and media.

2. **Cloud-Side (AWS Serverless):**
   - **Shared Code:** Package relevant backend logic for deployment in AWS Lambda and other serverless services.
   - **AWS Integration:** Use DynamoDB for data and S3 for media storage.
   - **API Access:** Expose endpoints for client-side backends to sync and retrieve data/media.
   - **Extensibility:** Design for easy extension to other cloud providers or storage solutions if needed.

---

**Design Goals:**
- Modular, testable, and reusable codebase.
- Clear separation of concerns between sync logic, storage, and API layers.
- Robust error handling, conflict resolution, and user feedback mechanisms.
- Support for both production and developer/debug workflows.
