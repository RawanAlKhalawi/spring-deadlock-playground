# OrderItemRepository Methods - Differences Explained

## Overview

The `OrderItemRepository` contains three methods to find `OrderItem` entities by `productId`. Each method has different behavior regarding JOINs and can affect deadlock scenarios.

## Method Comparison

### 1. `findByProductIdWithJoin` (PROBLEMATIC - Causes Deadlocks)

```java
@Query("SELECT oi FROM OrderItem oi WHERE oi.product.id = :productId")
List<OrderItem> findByProductIdWithJoin(@Param("productId") Long productId);
```

**What it does:**
- Uses JPQL (Java Persistence Query Language)
- Accesses `oi.product.id` which requires navigating the relationship
- **JPA/Hibernate generates a JOIN** to the `product` table even though `product` is marked as `LAZY`

**Generated SQL (approximate):**
```sql
SELECT oi.* 
FROM order_item oi
INNER JOIN product p ON oi.product_id = p.id
WHERE p.id = :productId
```

**Why it causes deadlocks:**
- The JOIN acquires locks on the `product` table
- When another transaction updates the `product` table concurrently, lock contention occurs
- This can lead to deadlocks when multiple transactions run simultaneously

**Used in:** `DeadlockScenario4Service.findOrderItemsByProductIdWithJoin()`

---

### 2. `findByProductIdDirect` (NOT ACTUALLY FIXED - Same as above)

```java
@Query("SELECT oi FROM OrderItem oi WHERE oi.product.id = :productId")
List<OrderItem> findByProductIdDirect(@Param("productId") Long productId);
```

**Current Issue:**
- ⚠️ **This method is IDENTICAL to `findByProductIdWithJoin`**
- The comment says "avoids JOIN" but it doesn't - it still uses the same JPQL query
- This is a bug/inconsistency in the code

**What it should be:**
- Should use a different approach to avoid JOIN
- Currently not used correctly in the service

**Note:** The service actually uses `findByProductIdNative` for the "fixed" version, which is correct.

---

### 3. `findByProductIdNative` (FIXED VERSION - Avoids JOIN)

```java
@Query(value = "SELECT * FROM order_item WHERE product_id = :productId", nativeQuery = true)
List<OrderItem> findByProductIdNative(@Param("productId") Long productId);
```

**What it does:**
- Uses **native SQL query** (not JPQL)
- Directly queries the foreign key column `product_id` in the `order_item` table
- **NO JOIN** to the `product` table

**Generated SQL:**
```sql
SELECT * 
FROM order_item 
WHERE product_id = :productId
```

**Why it avoids deadlocks:**
- Only accesses the `order_item` table
- Does not acquire locks on the `product` table
- No lock contention when `product` table is updated concurrently

**Used in:** `DeadlockScenario4Service.findOrderItemsByProductIdDirect()`

---

## Visual Comparison

### Method 1: With JOIN (Problematic)
```
┌─────────────┐         ┌─────────────┐
│ order_item  │────────▶│  product    │  ← JOIN causes locks
└─────────────┘         └─────────────┘
     │                         │
     └─────────────────────────┘
         Locks both tables
```

### Method 3: Native Query (Fixed)
```
┌─────────────┐
│ order_item  │  ← Only queries this table
└─────────────┘
     │
     └─ Uses product_id column directly
         No JOIN, no locks on product table
```

---

## Deadlock Scenario

### When Deadlocks Occur:

**Transaction 1:**
```java
findByProductIdWithJoin(productId)  // Acquires lock on product table via JOIN
```

**Transaction 2 (concurrent):**
```java
updateProduct(productId, ...)  // Tries to acquire lock on product table
```

**Result:** Both transactions wait on each other → **DEADLOCK**

### When Deadlocks DON'T Occur:

**Transaction 1:**
```java
findByProductIdNative(productId)  // Only queries order_item table
```

**Transaction 2 (concurrent):**
```java
updateProduct(productId, ...)  // Updates product table
```

**Result:** No lock contention → **NO DEADLOCK**

---

## Recommendations

1. **Use `findByProductIdNative`** for production code to avoid deadlocks
2. **Use `findByProductIdWithJoin`** only for testing/debugging deadlock scenarios
3. **Fix or remove `findByProductIdDirect`** - it's currently redundant

---

## SQL Execution Plans

### With JOIN (Method 1):
```
|--Nested Loops(Inner Join)
   |--Index Scan (order_item.product_id index)
   |--Clustered Index Seek (product.id)
       ↑ Locks acquired on product table
```

### Native Query (Method 3):
```
|--Index Scan (order_item.product_id index)
   ↑ Only locks on order_item table
```

---

## Performance Impact

- **With JOIN**: Slightly slower due to JOIN operation, but more importantly causes lock contention
- **Native Query**: Faster, no JOIN overhead, no lock contention

---

## Best Practices

1. **Avoid JOINs when you only need the foreign key value**
2. **Use native queries for simple foreign key lookups**
3. **Be aware that JPQL `oi.product.id` triggers JOINs even with LAZY relationships**
4. **Test deadlock scenarios with both approaches to understand the difference**

