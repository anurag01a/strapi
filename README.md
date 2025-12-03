# Pull Request (Strapi-specific)

## PR Title: Strapi Implementation LocalHost

### 🌟 PR Information
**Date**: [2025-12-03]  
**Author**: Anurag Sharma  
**Team**: Scripts-Smith  
**Ticket/Task**: Task 1

---

## 📝 Description

### What does this PR do?
- Adds/updates Strapi functionality related to [content-type / auth / custom controller / route / middleware].  
- Implements server-side validations and a small test suite for the changed endpoints.

### Why is this change necessary?
- To support [feature/bugfix], enforce data integrity, and provide consistent API responses for the frontend.

---

## 🔄 Type of Change
- [ ] 🐛 Bug fix
- [x] ✨ New feature / improvement (select as appropriate)
- [ ] 📝 Documentation update
- [ ] 🔧 Code refactoring
- [ ] ✅ Test update

---

## 📋 Checklist

### Code Quality
- [x] Code follows project style guidelines
- [x] Self-review performed
- [x] No debug console.log left

### Testing
- [x] Local manual testing completed
- [x] Unit/integration tests added for affected endpoints

### Documentation
- [x] README or API docs updated (if applicable)

---

## 🧪 Implementation Details

### Files Changed (example — replace with actual files)
- strapi/src/api/post/controllers/post.js
- strapi/src/api/post/services/post.js
- strapi/config/plugins.js
- strapi/tests/post.test.js

### Key Changes
1. Add Post content-type with custom controller
   - File: src/api/post/controllers/post.js
   - Reason: Support new public blog-post endpoint with custom filtering and sanitization.

2. Add service for complex DB operations
   - File: src/api/post/services/post.js
   - Reason: Centralize business logic and make controller thin for easier testing.

3. Update auth/plugin config
   - File: config/plugins.js
   - Reason: Allow public read access for posts while protecting write routes.

4. Add tests
   - File: tests/post.test.js
   - Reason: Verify API contract and core behaviors (create/read/list).

---

## 🧪 Testing Instructions

### How to test locally (Windows)
1. Open integrated terminal in project root: PowerShell or CMD.
2. Install / build:
   - npm install
3. Start Strapi in development:
   - npm run develop
4. Run tests:
   - npx jest tests/post.test.js

### Quick API tests (curl)
- List posts (public):
```bash
curl -s http://localhost:1337/api/posts | jq
```
Create post (requires auth — replace <TOKEN>):
```
curl -X POST http://localhost:1337/api/posts \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"data":{"title":"Test","content":"Body"}}'
```
