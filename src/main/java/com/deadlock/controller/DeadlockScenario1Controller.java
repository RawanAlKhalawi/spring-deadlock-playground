package com.deadlock.controller;

import com.deadlock.entity.UserTransaction;
import com.deadlock.service.DeadlockScenario1Service;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;

@RestController
@RequestMapping("/api/scenario1")
@RequiredArgsConstructor
public class DeadlockScenario1Controller {

    private final DeadlockScenario1Service service;

    @PostMapping("/process-transaction")
    public ResponseEntity<String> processTransaction(
            @RequestParam Long userId,
            @RequestParam BigDecimal amount) {
        try {
            service.processTransactionWithExternalApiCall(userId, amount);
            return ResponseEntity.ok("Transaction processed successfully");
        } catch (Exception e) {
            return ResponseEntity.internalServerError()
                    .body("Error: " + e.getMessage());
        }
    }


    @GetMapping("/transactions/user/{userId}")
    public ResponseEntity<List<UserTransaction>> getTransactionsByUserId(
            @PathVariable Long userId) {
        try {
            List<UserTransaction> transactions = service.getTransactionsByUserId(userId);
            return ResponseEntity.ok(transactions);
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }
}

