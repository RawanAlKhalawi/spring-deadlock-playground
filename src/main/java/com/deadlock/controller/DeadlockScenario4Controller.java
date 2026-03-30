package com.deadlock.controller;

import com.deadlock.entity.OrderItem;
import com.deadlock.service.DeadlockScenario4Service;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/scenario4")
@RequiredArgsConstructor
public class DeadlockScenario4Controller {

    private final DeadlockScenario4Service service;

    @GetMapping("/order-items-with-join/{productId}")
    public ResponseEntity<List<String>> findOrderItemsWithJoin(
            @PathVariable Long productId) {
        try {
            List<String> items = service.findOrderItemsByProductIdWithJoin(productId);
            return ResponseEntity.ok(items);
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }

    @PutMapping("/update-product")
    public ResponseEntity<String> updateProduct(
            @RequestParam Long productId,
            @RequestParam String newName,
            @RequestParam Double newPrice) {
        try {
            service.updateProduct(productId, newName, newPrice);
            return ResponseEntity.ok("Product updated successfully");
        } catch (Exception e) {
            return ResponseEntity.internalServerError()
                    .body("Error: " + e.getMessage());
        }
    }
}

