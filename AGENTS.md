# TEZA Lot Lab

## Project context

- This repository is a Thai-first coffee lot management application. The root application uses Next.js App Router, React, TypeScript, Prisma, PostgreSQL, and Ollama.
- `components/workspace.tsx` coordinates state and API calls; dashboard, lot management, chat and edit dialog live in separate files under `components/`. Shared types are in `components/workspace-types.ts`. API routes are in `app/api/`; Prisma client is in `lib/db.ts`.
- `prisma/schema.prisma` defines the current application schema; `prisma/migrations/` contains database migrations. `docker-compose.yml` runs a local PostgreSQL service named `db` with a persistent volume.
- `prototype/` contains earlier examples; `docs/` contains planning and a draft schema. Treat these as references, not proof that their full functionality exists in the application.

## Working conventions

- Preserve Thai text as UTF-8. On Windows, avoid piping non-ASCII source through a shell with an unknown code page. After editing, verify Thai text is intact in the actual files; question marks replacing Thai characters are data loss, not a font issue.
- Keep the interface Thai-first, responsive, and consistent with the existing green TEZA styling. Use existing libraries and components where appropriate; do not claim a library is in use unless it actually is.
- Validate input on the server and keep database access and AI provider calls on the server. Keep secrets in environment variables; never commit `.env` or real credentials.
- Use Prisma migrations for schema changes. Do not rewrite an applied migration, reset a database, or remove Docker volumes without explicit authorization. Preserve existing data.
- Database, Ollama, and market availability must be represented honestly. Do not invent inspection results, coffee grades, prices, live market information, or device readings. Preserve the source of observations.
- The current app does not provide authentication, authorization, live device integration, or real marketplace sales. Do not imply these are implemented without verifying and implementing them.
- Chat currently uses the selected lot as context and keeps conversation history in the browser session. Protect against disclosing unrelated data when extending it.

## Verification

- Install dependencies with `npm install`; generate Prisma client with `npm run db:generate`; apply existing migrations with `npm run db:migrate`; start with `npm run dev`.
- Run `npm run build` or an appropriate targeted check for code changes, and test affected flows when their services are available. Report any blocked checks clearly.
- PostgreSQL runs separately from Next.js. `DATABASE_URL` in `.env` must match the actual database user, password, host, and database name; do not assume local credentials.
- Ollama is configured through `OLLAMA_URL` and `OLLAMA_MODEL`. Check model availability before claiming AI integration was tested.
