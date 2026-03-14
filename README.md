# Taskiu - Modern Enterprise-Grade Task Management System

![Status](https://img.shields.io/badge/Status-In%20Development-yellow)
![Java](https://img.shields.io/badge/Java-21-orange)
![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.5-green)
![React](https://img.shields.io/badge/React-19-blue)
![Architecture](https://img.shields.io/badge/Architecture-Clean--DDD-brightgreen)

Taskiu is a robust, full-stack task management platform built with modern architectural patterns. It bridges the gap between traditional monolithic simplicity and enterprise-level scalability, featuring a polyglot persistence layer and a secure, stateless authentication flow.

## 🛠️ Core Skills & Expertise

This project showcases a comprehensive suite of modern software engineering skills:

### **1. Advanced Spring Boot Architecture**
- **Spring Boot 3.5 & Java 21**: Leveraging the latest LTS features like Virtual Threads and Pattern Matching.
- **Aspect-Oriented Programming (AOP)**: Custom annotations like `@RequireTeamRole` and `@Permission` handled via AOP to decouple security logic from business services.
- **Domain-Driven Design (DDD)**: Clean separation of concerns with rich domain models and module-based packaging.

### **2. Polyglot Persistence & Distributed Systems**
- **Relational Data**: **PostgreSQL** for consistent core business entities (Users, Teams, Tasks).
- **NoSQL / Document Store**: **MongoDB** for flexible, unstructured data like audit logs and dynamic attributes.
- **In-Memory Cache**: **Redis** for high-performance distributed caching and session management.
- **Asynchronous Messaging**: **RabbitMQ** for event-driven architecture and background task processing.
- **S3 Object Storage**: **MinIO** integration for secure, scalable file and avatar management.

### **3. Security & Identity Management**
- **Stateless Authentication**: Custom **JWT (JSON Web Token)** flow with secure **HttpOnly Cookie** rotation for Refresh Tokens.
- **OAuth2 Integration**: Seamless identity delegation with **Google** and **GitHub**.
- **RBAC & ABAC**: Sophisticated Role-Based and Attribute-Based Access Control enforcing hierarchy at Company, Team, and Project levels.
- **CORS & CSP**: Hardened security headers and cross-origin resource sharing policies.

### **4. Modern Frontend Engineering (React 19)**
- **React 19 + TypeScript**: Utilizing the newest React features with strict type safety.
- **Declarative UI**: Built with **Ant Design (v6)** and **TailwindCSS (v4)** for a beautiful, responsive UX.
- **State Management**: 
    - **TanStack Query (React Query)**: For efficient server-state synchronization, caching, and optimistic updates.
    - **Zustand**: For lightweight, performant client-side state management.
- **i18n**: Multi-language support (English / Traditional Chinese) using **i18next**.

### **5. DevOps & Cloud Infrastructure**
- **Containerization**: Full **Docker** ecosystem orchestrating 8+ services via Docker Compose.
- **Secure Networking**: Reverse proxy setup using **Nginx** and **Cloudflare Tunnels**.
- **CI/CD Readiness**: Structured for automated testing and deployment.

## 🚀 Key Features

- 🔐 **Secure Auth**: OAuth2 + JWT with Refresh Token rotation.
- 👥 **Team Management**: Granular role assignments (Owner, Admin, Member).
- 📁 **Cloud Storage**: Integrated MinIO for all file attachments.
- 📬 **Email Service**: Automated verification and notification via SMTP + Thymeleaf templates.
- 🛡️ **Bot Protection**: Cloudflare Turnstile integration for human verification.

## 📦 Project Structure

```bash
taskiu/
├── taskiu-backend/     # Spring Boot API (Java 21, Gradle)
├── taskiu-frontend/    # React Client (TypeScript, Vite)
├── dev-dockerCompose/  # Local development infrastructure
└── docker-compose.yaml # Production-ready orchestration
```

## 🗺️ 架構圖

- 系統/模組/流程圖（Mermaid）：[architecture.md](file:///f:/taskiu/docs/architecture.md)

## 🚀 Getting Started

### Prerequisites
- Docker & Docker Compose
- Java 21 SDK
- Node.js 20+

### Run with Docker
```bash
docker-compose up -d
```
Access the application at `http://localhost`.

---
*Built with ❤️ by [Your Name]*
