# Breadboarding Worked Example: Mapping an Existing System

A worked reference showing how to breadboard an existing system to trace how a single data store is modified and read across multiple entry points.

This is a worked reference for the breadboarding skill. See SKILL.md for the canonical
table format and concepts.

## Example A: Mapping an Existing System

This example shows breadboarding an existing system to understand how data flows through multiple entry points.

### Input

Workflow to understand: "How is `admin_organisation_countries` modified and read downstream? There are multiple entry points: manual edit, checkbox toggle, and batch job."

### Output

**Places**

| # | Place | Description |
|---|-------|-------------|
| P1 | SSO Admin — User Change Page | Django admin page where a user's roles and admin countries are edited |
| P1.1 | Permissions fieldset | Role/permission checkboxes within the SSO Admin page |
| P1.2 | User admin fieldset (superuser only) | filter_horizontal for admin countries, superuser-gated |
| P2 | TRIGGER: Batch Cleanup | Scheduled CLI entry point that reconciles admin countries |
| P3 | sso-dwbn-theme | Theme package handling signal/task logic and country reconciliation |
| P4 | DWConnect — Center Page | Downstream center page that reads country admins |
| P5 | TRIGGER: External API Request | External API entry point reading user object data |
| P6 | Data Stores | Persistent M2M and organisation records |

**UI Affordances**

| # | Place | Component | Affordance | Control | Wires Out | Returns To |
|---|-------|-----------|------------|---------|-----------|------------|
| U1 | P1.1 | SSO Admin | `role_profiles` checkboxes | render | — | — |
| U2 | P1.1 | SSO Admin | "Country Admin" checkbox | click | toggles selection | — |
| U3 | P1.2 | SSO Admin | `admin_countries` filter_horizontal | render | — | — |
| U4 | P1.2 | SSO Admin | Available countries list | render | — | — |
| U5 | P1.2 | SSO Admin | Selected countries list | render | — | — |
| U6 | P1.2 | SSO Admin | Add → / Remove ← | click | modifies selection | — |
| U7 | P1 | SSO Admin | Save button | click | → N3 | — |
| U20 | P4 | DWConnect | "Country admins" section | render | — | — |
| U21 | P5 | (unknown) | System email "From" field | render | — | — |

**Code Affordances**

| # | Place | Component | Affordance | Control | Wires Out | Returns To |
|---|-------|-----------|------------|---------|-----------|------------|
| N1 | P1 | sso/accounts/admin | `get_fieldsets()` | call | → U3 (conditional) | — |
| N2 | P1 | sso/accounts/models | `get_administrable_user_countries()` | call | — | → U4 |
| N3 | P1 | sso/accounts/admin | `save_form()` | call | → N4, → N5 | — |
| N4 | P1 | Django Admin | Form M2M save | call | → S2 | — |
| N5 | P1 | sso/forms/mixins | `_update_user_m2m()` | call | → S1, → N6 | — |
| N6 | P1 | sso/signals | `user_m2m_field_updated` signal | signal | → N10 | — |
| N7 | P2 | CLI/Scheduler | `manage.py dwbn_cleanup` | invoke | → N15 | — |
| N10 | P3 | sso-dwbn-theme | `dwbn_user_m2m_field_updated()` | receive | → N11 | — |
| N11 | P3 | sso-dwbn-theme | `dwbn_user_m2m_field_updated_task()` | call | → N12 | — |
| N12 | P3 | sso-dwbn-theme | Country Admin added AND zero admin countries? | conditional | → N20 | — |
| N15 | P3 | sso-dwbn-theme | `admin_changes()` | call | → N16 | — |
| N16 | P3 | sso-dwbn-theme | For each Country Admin: home center country missing? | loop | → N20 | — |
| N20 | P3 | sso-dwbn-theme | Get home center's country | call | → N21 | — |
| N21 | P3 | sso-dwbn-theme | `admin_organisation_countries.add()` | call | → S2 | — |
| N22 | P3 | sso-dwbn-theme | `update_last_modified()` | call | — | — |
| N30 | P4 | dwconnect2-backend | `findCenterAdmins()` | call | — | → U20 |
| N31 | P5 | sso/api | `get_object_data()` | call | — | → external |

**Data Stores**

| # | Place | Store | Description |
|---|-------|-------|-------------|
| S1 | P6 | `role_profiles` | M2M: which role profiles a user has |
| S2 | P6 | `admin_organisation_countries` | M2M: which countries a user administers |
| S3 | P6 | `organisations` | User's home center(s) |

**Mermaid Diagram**

```mermaid
flowchart TB
    subgraph stores["P6: DATA STORES"]
        S1["S1: role_profiles"]
        S2["S2: admin_organisation_countries"]
        S3["S3: organisations"]
    end

    subgraph ssoAdmin["P1: SSO Admin — User Change Page"]
        subgraph permissions["P1.1: Permissions fieldset"]
            U1["U1: role_profiles checkboxes"]
            U2["U2: 'Country Admin' checkbox"]
        end

        subgraph userAdmin["P1.2: User admin fieldset (superuser only)"]
            U3["U3: admin_countries filter_horizontal"]
            U4["U4: Available countries"]
            U5["U5: Selected countries"]
            U6["U6: Add → / Remove ←"]
        end

        U7["U7: Save button"]
        N1["N1: get_fieldsets()"]
        N2["N2: get_administrable_user_countries()"]
        N3["N3: save_form()"]
        N4["N4: Form M2M save"]
        N5["N5: _update_user_m2m()"]
        N6["N6: user_m2m_field_updated signal"]

        N1 -->|is_superuser| userAdmin
        U3 --> U4
        U3 --> U5
        U6 --> U5
        N2 -.-> U4

        U2 --> U7
        U6 --> U7
        U7 --> N3
        N3 --> N4
        N3 --> N5
        N5 --> N6
    end

    subgraph trigger["P2: TRIGGER: Batch Cleanup"]
        N7["N7: manage.py dwbn_cleanup"]
    end

    subgraph theme["P3: sso-dwbn-theme"]
        N10["N10: dwbn_user_m2m_field_updated()"]
        N11["N11: dwbn_user_m2m_field_updated_task()"]
        N12["N12: Country Admin added AND zero admin countries?"]
        N15["N15: admin_changes()"]
        N16["N16: For each Country Admin: home center country missing?"]
        N20["N20: Get home center's country"]
        N21["N21: admin_organisation_countries.add()"]
        N22["N22: update_last_modified()"]

        N6 --> N10
        N10 --> N11
        N11 --> N12
        N7 --> N15
        N15 --> N16
        N12 -->|yes| N20
        N16 -->|yes| N20
        N20 --> N21
        N21 --> N22
    end

    subgraph dwconnect["P4: DWConnect — Center Page"]
        N30["N30: findCenterAdmins()"]
        U20["U20: 'Country admins' section"]

        N30 --> U20
    end

    subgraph api["P5: TRIGGER: External API Request"]
        N31["N31: get_object_data()"]
    end

    U21["U21: System email 'From' field"]

    N4 --> S2
    N5 --> S1
    N21 --> S2
    S1 -.-> N15
    S3 -.-> N16
    S3 -.-> N20
    S2 -.-> U5
    S2 -.-> N30
    S2 -.-> N31
    S2 -.-> U21

    classDef ui fill:#ffb6c1,stroke:#d87093,color:#000
    classDef nonui fill:#d3d3d3,stroke:#808080,color:#000
    classDef store fill:#e6e6fa,stroke:#9370db,color:#000
    classDef condition fill:#fffacd,stroke:#daa520,color:#000
    classDef trigger fill:#98fb98,stroke:#228b22,color:#000

    class U1,U2,U3,U4,U5,U6,U7,U20,U21 ui
    class N1,N2,N3,N4,N5,N6,N10,N11,N15,N20,N21,N22,N30,N31 nonui
    class N12,N16 condition
    class N7 trigger
    class S1,S2,S3 store
```

---
