# Resource Query Helpers — Mahmoud (Phase 2)

This document defines the sorting, filtering, searching, and pagination rules for the Resource Library module.

---

## Sorting

1. **Newest resources**
   - `orderBy("createdAt", descending: true)`

2. **Most downloaded**
   - `orderBy("downloadCount", descending: true)`

---

## Filtering

1. **By course**
   - `where("courseCode", isEqualTo: courseCode)`

2. **By tag**
   - `where("tags", arrayContains: tag)`

3. **Active resources only**
   - `where("isActive", isEqualTo: true)`

---

## Searching

- **Client-side search:**
  - Filter resources by checking if the title contains the query string.

- **Firestore-based search (optional):**
  - `where("title", isGreaterThanOrEqualTo: query)`
  - `where("title", isLessThan: query + '\uf8ff')`

---

## Pagination

- Use `limit(N)` to control page size.
- Use `startAfterDocument(lastDocument)` to fetch the next batch.

---
