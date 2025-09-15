# 🚀 Planoras

**Next.js 15 + GraphQL + TypeScript + Prisma**

## Quick Start

```bash
# Install & setup
pnpm install
cp .env.example .env.local
pnpm prisma:migrate:dev
pnpm prisma:seed
pnpm codegen
pnpm dev
```

## Commands

```bash
# Create model
pnpm clix:b create User

# Register pagination
pnpm clix:b paginate User

# Generate types
pnpm codegen:b
pnpm codegen:f
pnpm codegen
```

## Documentation

📚 **[Complete Documentation →](https://github.com/clix002/nextjs-graphql-boilerplate/wiki)**

### Quick Links

**Backend**
- 🏗️ [Backend Architecture](https://github.com/clix002/nextjs-graphql-boilerplate/wiki/backend-architecture)
- 📊 [Pagination System](https://github.com/clix002/nextjs-graphql-boilerplate/wiki/pagination)
- 🚨 [Error Handling](https://github.com/clix002/nextjs-graphql-boilerplate/wiki/errors)
- 🏭 [Context Factories](https://github.com/clix002/nextjs-graphql-boilerplate/wiki/backend/context-factories)
- 🛠 [CLI Tools](https://github.com/clix002/nextjs-graphql-boilerplate/wiki/cli)

**Frontend**
- 🎨 [Frontend Architecture](https://github.com/clix002/nextjs-graphql-boilerplate/wiki/frontend/frontend-architecture)
- 🚀 [Apollo Client](https://github.com/clix002/nextjs-graphql-boilerplate/wiki/frontend/apollo-client)
- 📝 [Form Management](https://github.com/clix002/nextjs-graphql-boilerplate/wiki/frontend/forms)
- 🧩 [Components](https://github.com/clix002/nextjs-graphql-boilerplate/wiki/frontend/components)
- ⚡ [Performance](https://github.com/clix002/nextjs-graphql-boilerplate/wiki/frontend/performance)

## Features

- ✅ GraphQL API with Apollo Server
- ✅ Type-safe with TypeScript
- ✅ Database with Prisma ORM
- ✅ Pagination system
- ✅ Error handling
- ✅ CLI tools for scaffolding
- ✅ Conventional commits with Husky

---

**Built with ❤️**