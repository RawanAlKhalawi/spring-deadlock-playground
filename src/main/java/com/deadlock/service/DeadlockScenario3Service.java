package com.deadlock.service;

import com.deadlock.entity.Product;
import com.deadlock.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.Random;

/**
 * Scenario 3: Concurrent Delete and Insert on the Same Table
 * 
 * A transaction performs bulk DELETE and INSERT operations on the same table.
 * Multiple concurrent requests execute the same logic.
 * Each transaction acquires different row or index locks.
 * Transactions end up waiting on each other, causing intermittent deadlocks.
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class DeadlockScenario3Service {

    private final ProductRepository productRepository;
    private static final int BATCH_SIZE = 20000;
    private final Random random = new Random();

    /**
     * This method performs bulk DELETE and INSERT operations on the Product table.
     * When multiple threads execute this concurrently, deadlocks can occur.
     * 
     * The method:
     * 1. Deletes 20000 rows from the product table
     * 2. Inserts 20000 new rows with new information
     */
    @Transactional
    public void deleteAndInsertProducts(String name) {
        log.info("Starting bulk delete and insert operations - Deleting {} rows, then inserting {} rows",
                BATCH_SIZE, BATCH_SIZE);

        // Step 1: Delete 20000 rows
      int deleted = productRepository.deleteByName(name);
      log.info("Deleted {} rows with name {}", deleted, name);


      // Step 2: Insert 20000 new rows
        // This acquires locks on index pages and can conflict with other concurrent transactions
        List<Product> newProducts = new ArrayList<>();
        for (int i = 0; i < BATCH_SIZE; i++) {
            Product product = new Product();
            product.setName(name);
            product.setQuantity(random.nextInt(100) + 1);
            product.setPrice(random.nextDouble() * 100 + 10);
            newProducts.add(product);
        }

        productRepository.saveAll(newProducts);
        log.info("Inserted {} new products", newProducts.size());

        log.info("Bulk delete and insert operations completed");
    }
}

//T1 acquires table X lock for DELETE
//T2 tries to acquire table X lock for its DELETE → WAITS
//T1 completes DELETE, tries INSERT → may wait on T2's pending lock request
//Circular wait → DEADLOCK