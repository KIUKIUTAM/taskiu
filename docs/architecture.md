# Taskiu 架構圖（Mermaid）

本文件用 Mermaid 描述 Taskiu 的系統架構、部署拓樸與核心流程。可直接在支援 Mermaid 的 Markdown 檢視器中渲染。

## 系統拓樸（部署/網路）

```mermaid
flowchart LR
  U[使用者] --> B[瀏覽器 / React SPA]

  B -->|HTTPS| CF[Cloudflare Tunnel\ncloudflared]
  CF --> NG[Nginx Reverse Proxy\n/taskiu/*]

  NG --> FE[Frontend\n(taskiu-frontend)\n靜態資源]
  NG -->|/taskiu/api/*| BE[Backend\n(taskiu-backend)\nSpring Boot]

  BE --> PG[(PostgreSQL 16)\n核心資料]
  BE --> MG[(MongoDB 7)\nRefresh Token / 文件資料]
  BE --> RD[(Redis 7)\nCache]
  BE --> MQ[(RabbitMQ)\n事件/背景任務]
  BE --> S3[(MinIO)\nObject Storage]
  BE --> SMTP[SMTP Mail]
  BE --> OAUTH[Google / GitHub OAuth2]
```

### Nginx 路由分流
- `/taskiu/` → 前端（靜態資源 / SPA）
- `/taskiu/api/` → 後端 API

參考設定：[nginx.conf](file:///f:/taskiu/nginx.conf)、[docker-compose.yaml](file:///f:/taskiu/docker-compose.yaml)

## Backend（Spring Boot）模組關係

```mermaid
flowchart TB
  subgraph API[Controllers / REST API]
    TeamCtrl[TeamController\n/api/teams]
    ProjCtrl[ProjectController\n/api/teams/{teamId}/projects]
    AuthCtrl[Auth Controller(s)\n/api/auth/*]
  end

  subgraph AOP[Security AOP]
    TeamRoleAspect[RequireTeamRoleAspect\n@RequireTeamRole + @TeamId]
    PermAspect[PermissionAspect\n@Permission]
  end

  subgraph Service[Services]
    TeamSvc[TeamService]
    ProjSvc[ProjectService]
    AuthSvc[AuthService]
    RefreshSvc[RefreshTokenService]
    MinioProj[ProjectPictureMinioService]
    MinioBase[BaseMinioService]
  end

  subgraph Data[Repositories / Storage]
    TeamRepo[TeamRepository\n(PostgreSQL/JPA)]
    ProjRepo[ProjectRepository\n(PostgreSQL/JPA)]
    UserRepo[UserRepository\n(PostgreSQL/JPA)]
    RefreshRepo[RefreshToken Repository\n(MongoDB)]
    Cache[(Redis)]
    MQ[(RabbitMQ)]
    S3[(MinIO)]
  end

  TeamCtrl --> TeamSvc --> TeamRepo
  ProjCtrl --> ProjSvc --> ProjRepo
  AuthCtrl --> AuthSvc --> UserRepo
  AuthSvc --> RefreshSvc --> RefreshRepo

  TeamRoleAspect -.攔截/授權.-> TeamCtrl
  TeamRoleAspect -.攔截/授權.-> ProjCtrl
  PermAspect -.攔截/授權.-> API

  ProjSvc --> MinioProj --> MinioBase --> S3
  Service --> Cache
  Service --> MQ
```

重點檔案：
- Team API：[TeamController.java](file:///f:/taskiu/taskiu-backend/src/main/java/com/tavinki/taskiu/modules/teams/controller/TeamController.java)
- Project API：[ProjectController.java](file:///f:/taskiu/taskiu-backend/src/main/java/com/tavinki/taskiu/modules/project/controller/ProjectController.java)
- Team RBAC AOP：[RequireTeamRoleAspect.java](file:///f:/taskiu/taskiu-backend/src/main/java/com/tavinki/taskiu/common/aspect/RequireTeamRoleAspect.java)
- MinIO 基礎服務：[BaseMinioService.java](file:///f:/taskiu/taskiu-backend/src/main/java/com/tavinki/taskiu/common/minio/BaseMinioService.java)

## Team 權限檢查流程（@RequireTeamRole + @TeamId）

```mermaid
sequenceDiagram
  autonumber
  actor U as 使用者
  participant FE as React
  participant BE as Spring Boot
  participant AOP as RequireTeamRoleAspect
  participant TS as TeamService
  participant DB as PostgreSQL

  U->>FE: 操作（例如：邀請成員 / 列表成員）
  FE->>BE: 呼叫 /api/teams/{teamId}/members
  BE->>AOP: 進入 Controller 方法
  AOP->>AOP: 解析 @TeamId 參數取得 teamId
  AOP->>TS: 查詢使用者在該 team 的角色
  TS->>DB: 讀取 TeamMember / Role
  DB-->>TS: 回傳角色
  TS-->>AOP: role
  alt 有權限
    AOP-->>BE: 放行
    BE-->>FE: 200 OK
  else 無權限
    AOP-->>BE: throw AccessDeniedException
    BE-->>FE: 403 Forbidden
  end
```

## Project 圖片上傳 + Presigned URL 顯示流程

```mermaid
sequenceDiagram
  autonumber
  actor U as 使用者
  participant FE as React
  participant BE as Spring Boot
  participant S3 as MinIO
  participant DB as PostgreSQL

  U->>FE: 建立/更新 Project，選擇圖片
  FE->>BE: POST /api/teams/{teamId}/projects (multipart: data + file)
  BE->>S3: PutObject(projects/...key...)
  S3-->>BE: OK
  BE->>DB: 保存 projectPicture=objectKey
  DB-->>BE: OK
  BE->>S3: 生成 Presigned GET URL（短期有效）
  S3-->>BE: presignedUrl
  BE-->>FE: 回傳 Project（含 projectPictureUrl）
  FE-->>U: img src=projectPictureUrl 顯示圖片
```

## Frontend（React）頁面與資料流

```mermaid
flowchart TB
  subgraph Routes[Routes]
    RTeam[/team/]
    RTeamId[/team/:teamId/]
  end

  subgraph Pages[Workplace Pages]
    TeamPage[Team Page\n列表 + 建立 Team]
    TeamDetail[Team Detail\nMembers + Projects]
  end

  subgraph DataClient[Data Layer]
    Axios[Axios privateClient\nJWT/refresh interceptors]
    RQ[TanStack Query\nuseQuery/useMutation]
    Api[teamApi]
  end

  RTeam --> TeamPage
  RTeamId --> TeamDetail

  TeamPage --> RQ --> Api --> Axios
  TeamDetail --> RQ --> Api --> Axios
```

相關檔案：
- Team 列表頁：[Team/index.tsx](file:///f:/taskiu/taskiu-frontend/src/page/workplace/Team/index.tsx)
- Team 詳情頁：[TeamDetail/index.tsx](file:///f:/taskiu/taskiu-frontend/src/page/workplace/TeamDetail/index.tsx)
- API Client：[teamApi.ts](file:///f:/taskiu/taskiu-frontend/src/api/Team/teamApi.ts)
- 路由定義：[index.tsx](file:///f:/taskiu/taskiu-frontend/src/router/index.tsx)

