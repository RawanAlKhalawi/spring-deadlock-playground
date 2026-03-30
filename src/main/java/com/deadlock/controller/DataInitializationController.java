package com.deadlock.controller;

import com.deadlock.entity.*;
import com.deadlock.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;

/**
 * Controller to initialize test data for deadlock scenarios
 */
@RestController
@RequestMapping("/api/init")
@RequiredArgsConstructor
public class DataInitializationController {

    private final TableARepository tableARepository;
    private final TableBRepository tableBRepository;
    private final ProductRepository productRepository;
    private final OrderItemRepository orderItemRepository;
    private final UserTransactionRepository userTransactionRepository;

    @PostMapping("/setup")
    public ResponseEntity<String> setupTestData() {
        try {
            // Initialize TableA and TableB for Scenario 2
            TableA tableA = new TableA();
            tableA.setName("TableA-1");
            tableA.setValue(100);
            tableA = tableARepository.save(tableA);

            TableB tableB = new TableB();
            tableB.setDescription("TableB-1");
            tableB.setAmount(200);
            tableB = tableBRepository.save(tableB);

            // Initialize Products for Scenario 3
            Product product1 = new Product();
            product1.setName("Product-1");
            product1.setQuantity(50);
            product1.setPrice(29.99);
            product1 = productRepository.save(product1);

            Product product2 = new Product();
            product2.setName("Product-2");
            product2.setQuantity(30);
            product2.setPrice(49.99);
            product2 = productRepository.save(product2);

            Product product3 = new Product();
            product3.setName("Product-3");
            product3.setQuantity(20);
            product3.setPrice(19.99);
            product3 = productRepository.save(product3);

            // Initialize OrderItems for Scenario 4
            OrderItem orderItem1 = new OrderItem();
            orderItem1.setItemName("OrderItem-1");
            orderItem1.setProduct(product1);
            orderItem1.setQuantity(2);
            orderItemRepository.save(orderItem1);

            OrderItem orderItem2 = new OrderItem();
            orderItem2.setItemName("OrderItem-2");
            orderItem2.setProduct(product1);
            orderItem2.setQuantity(1);
            orderItemRepository.save(orderItem2);

            OrderItem orderItem3 = new OrderItem();
            orderItem3.setItemName("OrderItem-3");
            orderItem3.setProduct(product2);
            orderItem3.setQuantity(3);
            orderItemRepository.save(orderItem3);

            // Initialize UserTransaction for Scenario 1
            UserTransaction transaction = new UserTransaction();
            transaction.setUserId(1L);
            transaction.setAmount(new BigDecimal("100.00"));
            transaction.setStatus("INITIAL");
            transaction.setCreatedAt(LocalDateTime.now());
            userTransactionRepository.save(transaction);

            return ResponseEntity.ok(String.format(
                    "Test data initialized:\n" +
                    "TableA id=%d, TableB id=%d\n" +
                    "Product1 id=%d, Product2 id=%d, Product3 id=%d\n" +
                    "OrderItems created for Product1 and Product2\n" +
                    "UserTransaction created for userId=1",
                    tableA.getId(), tableB.getId(),
                    product1.getId(), product2.getId(), product3.getId()
            ));
        } catch (Exception e) {
            return ResponseEntity.internalServerError()
                    .body("Error initializing data: " + e.getMessage());
        }
    }

    @PostMapping("/setup-bulk-products")
    public ResponseEntity<String> setupBulkProducts(
            @org.springframework.web.bind.annotation.RequestParam(defaultValue = "25000") int count) {
        try {
            Random random = new Random();
            List<Product> products = new ArrayList<>();
            
            for (int i = 0; i < count; i++) {
                Product product = new Product();
                product.setName("Product-Bulk-" + i);
                product.setQuantity(random.nextInt(100) + 1);
                product.setPrice(random.nextDouble() * 100 + 10);
                products.add(product);
            }
            
            productRepository.saveAll(products);
            
            return ResponseEntity.ok(String.format(
                    "Created %d bulk products for Scenario 3 testing", count
            ));
        } catch (Exception e) {
            return ResponseEntity.internalServerError()
                    .body("Error initializing bulk products: " + e.getMessage());
        }
    }
}

