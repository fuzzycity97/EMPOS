# Changelog

All notable changes to the EMPOS (Enterprise Multi-Industry Point of Sale & Clinical Operating System) project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.1.0] - Unreleased

### Added
- **Restaurant Visual Table Map (`RestaurantTableMapWidget`)**: Interactive 2D draggable and zoomable floor plan built with `InteractiveViewer` and `GestureDetector`. Allows restaurant cashiers and servers to visually view dining areas, drag and arrange table configurations, inspect table occupancy statuses (Available, Occupied, Billed, Reserved), and seamlessly park or resume dine-in tabs.
- **Kitchen Display System (`KitchenDisplaySystemPage`)**: Kanban-style horizontal order rail for the `kitchen` role. Displays active tickets across prep stages (New, Cooking, Ready, Served), with live elapsed cook timers, priority badges, item modifiers, and server name tags.
- **Doctor Station Attachments & Radiograph Lightbox (`DoctorAttachmentsLightbox`)**: Medical document and imaging dock embedded in the Doctor Station. Enables uploading and viewing patient attachments (X-Rays, Ultrasound scans, Lab reports, DICOM radiograph placeholders) with interactive zoom, rotate, and full-screen lightbox inspection.
- **LAN Sync Full Data Payload Synchronization**: Upgraded distributed synchronization across isolated Hive multi-instance databases (`INSTANCE_ID=1` and `INSTANCE_ID=2`). `CheckInPatientEvent` and `CompleteVisitEvent` now broadcast complete JSON payloads of `PatientProfile` and `ClinicVisit`. Receiving peer stations automatically extract payloads and explicitly insert them into their local databases before dispatching queue refreshes.
- **Connection Recovery Auto-Sync (State Reconciliation)**: Implemented automatic handshake state reconciliation upon connection or network drop recovery. When a client node connects to the host, it transmits `sync.request_active_state`. The host station intercepts the request, aggregates all active clinic visits (`waiting` and `inExamination`) and associated patients, and broadcasts `sync.full_state_response`. The client automatically ingests and batch-upserts the entities into its local Hive database before dispatching a queue refresh, guaranteeing zero UI desync even after network dropouts or late joins.

### Fixed
- **Patient Intake Dialog (`PatientIntakeDialog`)**: Resolved doctor routing ambiguity in clinic reception. Replaced the free-text doctor input with a validated `DropdownButtonFormField` populated with seeded system IDs (`usr_doctor` / `Dr. Sarah Connor`) to ensure exact LAN WebSocket routing to the target Doctor Station peer. Added dedicated numeric `TextField` for Patient Age and phone `TextField` for Contact Number.
- **Clinic Consumables Auto-Deduction (`CompleteVisitUseCase`)**: Fixed runtime type inference error during consumable inventory deduction where querying `allProducts` failed `orElse` fallback typing. Explicitly typed `allProducts` as `List<Product>` ensuring seamless auto-deductions.
- **LAN Sync State Reconciliation (`LanSyncRepositoryImpl` & `ClinicBloc`)**: Fixed LAN Sync Race Condition and Silent Parsing Error on Reconnect. Added an 800ms handshake delay in `connectToHost` to ensure the Host socket registry is fully established before requesting active state. Ensured safe JSON serialization of all registered patients on the Host and wrapped Client ingestion in strict try/catch mapping with awaited Hive batch-upserts before triggering queue reloads.
- **LAN Sync Intermediate Status Broadcast & Conflict Resolution (`ClinicBloc` & `MessageRoutes`)**: Fixed Stale Data Overwrite and added `visit.updated` broadcasting. Intermediate visit status changes (e.g. `waiting` -> `inExamination` when "Call In" is triggered) now broadcast `MessageRoutes.syncVisitUpdated` with full `Patient` and `ClinicVisit` payloads. Ingested state payloads in `_handleSyncFullStateResponse` and the LAN listener now perform status weight conflict resolution (`completed`=3, `inExamination`=2, `waiting`=1), preventing stale node overwrites and firing counter-sync updates back to stale peers.
- **Reception Checkout & Billing State Binding (`ClinicBloc`, `ClinicState` & `ClinicReceptionPage`)**: Fixed Vanishing Patient bug. `ClinicRepositoryImpl.getQueue` now includes `completed` visits, `ClinicBloc` populates the dedicated `billingVisits` state list in `ClinicLoaded`, and `ClinicReceptionPage` directly binds the "Checkout & Billing" tab to `billingVisits`, ensuring completed patient visits seamlessly appear ready for copay collection and receipt printing.
- **Client Auto-Reconnect & Handshake Reconciliation (`LanSyncRepositoryImpl`)**: Fixed Host-Drop Reconnection Flaw. Added an automatic reconnection loop upon server disconnects. On every successful connection and reconnection, the client enforces the 800ms delay and re-transmits `sync.request_active_state` to reconcile any missed state from restarted host servers.
- **Doctor Name Display Translation (`ClinicReceptionPage`)**: Added `formatDoctorName` UI mapper in `ClinicReceptionPage` to translate raw seeded IDs (`usr_doctor`, `usr_doctor_2`, `usr_doctor_tarek`, `usr_doctor_oncall`) into clean human-readable names (`Dr. Sarah Connor`, `Dr. Tarek Dental Lead`, `Dr. On-Call Physician`) with capitalized fallback across Queue and Billing lists.
- **Bulletproof Multi-Ping Handshake (`LanSyncRepositoryImpl`)**: Hardened client state reconciliation with a 3-stage multi-ping handshake (`sync.request_active_state` dispatched at 1s, 3s, and 6s), ensuring slow-booting or initializing Host BLoCs never drop client reconnection sync requests.
- **WhatsApp-Style Offline Outbox Event Queue (`LanSyncRepositoryImpl`)**: Implemented local Outbox Pattern with Hive box `'empos_offline_sync_queue'`. Outgoing broadcast events dispatched while offline or when peers/channels are unavailable are persisted locally to disk instead of dropped. Upon peer reconnection (for clients) or peer join (for hosts), the outbox is automatically flushed in FIFO order before triggering state reconciliation handshake.

---

## [1.0.0] - 2026-08-29

### Added
- **Core Architecture**: Full Clean Architecture implementation with strict Domain, Data, and Presentation separation, 100% `StatelessWidget` UI, and BLoC state management.
- **Universal Multi-Industry Engine**: Configurable store blueprint engine covering 11 industry verticals and 41 sub-categories with granular Rule A software/hardware toggles and Rule B typed search indexing.
- **LAN Sync Engine**: Distributed peer-to-peer WebSocket event synchronization hub and client (`LanSyncRepository`) operating on port 9090 with automatic reconnection and structured envelope routing (`MessageRoutes`).
- **Role-Based Access Control (RBAC)**: Secure PIN lock authentication screen (`PinLockScreen`), user session management (`AuthBloc`), and granular UI role guards (`RoleGuardWidget`) supporting Admin, Manager, Cashier, Doctor, Receptionist, and Technician roles.
- **Hardware Peripherals Drivers**: Direct TCP socket driver for ESC/POS thermal receipt printers (port 9100), RJ11 electronic cash drawer kick pulse generation (`0x1B, 0x70, 0x00, 0x19, 0xFA`), and USB HID keyboard-wedge barcode scanner diagnostic feed.
- **Deep Business Engines**:
  - Automated procedure-to-consumables inventory deduction upon dental/medical examination completion.
  - First-Expire, First-Out (FEFO) batch picking algorithm and customer loyalty points accrual (1 pt / 10 currency units).
  - Consolidated Daily Z-Report aggregating shift transactions, cash drawer variance, tax splits, and category revenue breakdowns.
- **Developer RMM Console**: Live remote fleet management console (`DeveloperConsolePage`) with real-time station heartbeats, latency ping diagnostics, remote command dispatch, and OTA software update distribution.
- **Multi-Instance Testing Support**: Environment-based Hive database isolation (`INSTANCE_ID`) enabling concurrent desktop instances without file lock collisions.
- **Testing**: 172 unit, BLoC, and widget test cases with 100% pass rate.
