package com.deadlock.service;

import com.deadlock.entity.OrderItem;
import com.deadlock.entity.Product;
import com.deadlock.repository.OrderItemRepository;
import com.deadlock.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.TimeUnit;

/**
 * Scenario 4: Unnecessary JPA Join Due to Lazy ManyToOne Mapping
 * 
 * Entity A (OrderItem) is queried using the ID of entity B (Product).
 * JPA generates a JOIN between A and B, even though the ManyToOne B association is lazy.
 * At the same time, the B table (Product) is being updated by another transaction.
 * The generated JOIN causes lock contention and results in a deadlock.
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class DeadlockScenario4Service {

    private final OrderItemRepository orderItemRepository;
    private final ProductRepository productRepository;

    /**
     * PROBLEMATIC: This method causes a JOIN even though product is lazy.
     * When another transaction updates the Product table concurrently, deadlocks can occur.
     */
    @Transactional
    public List<String> findOrderItemsByProductIdWithJoin(Long productId) {
        log.info("Finding order items by product id={} (will cause JOIN)", productId);

        // This query causes JPA to generate a JOIN to the Product table
        // even though the ManyToOne relationship is lazy
        List<OrderItem> orderItems = orderItemRepository.findByProduct_NameOrProduct_Id(productId.toString(), productId);
        
        log.info("Found {} order items", orderItems.size());

        // Accessing the product (even if lazy) can trigger additional queries
        // that may conflict with concurrent updates
      List<String> productNames = new ArrayList<>();
      for (OrderItem item : orderItems) {
        // Accessing lazy-loaded product properties
        String productName = item.getProduct().getName();
        productNames.add(item.getItemName() + ":" + item.getProduct().getName());
        log.info("OrderItem id={}, product name={}", item.getId(), productName);
      }
        
        return productNames;
    }


    /**
     * This method updates a product concurrently.
     * When combined with findOrderItemsByProductIdWithJoin, deadlocks can occur.
     */
    @Transactional
    public void updateProduct(Long productId, String newName, Double newPrice) {
        log.info("Updating product id={}", productId);
        
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new RuntimeException("Product not found: " + productId));
        product.setName(newName);
        product.setPrice(newPrice);
        productRepository.save(product);
        
        log.info("Product updated: id={}, name={}, price={}",
                productId, newName, newPrice);
    }

}

