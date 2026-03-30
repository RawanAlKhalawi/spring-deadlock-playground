package com.deadlock.controller;

import com.deadlock.service.DeadlockScenario2Service;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/scenario2")
@RequiredArgsConstructor
public class DeadlockScenario2Controller {

    private final DeadlockScenario2Service service;

    @PostMapping("/transaction-t1")
    public ResponseEntity<String> transactionT1(
            @RequestParam String tableAName, @RequestParam String tableBDescription) {
        try {
            service.transactionT1(tableAName, tableBDescription);
            return ResponseEntity.ok("Transaction T1 completed successfully");
        } catch (Exception e) {
            return ResponseEntity.internalServerError()
                    .body("Error: " + e.getMessage());
        }
    }

    @PostMapping("/transaction-t2")
    public ResponseEntity<String> transactionT2(
        @RequestParam String tableAName, @RequestParam String tableBDescription) {
        try {
            service.transactionT2(tableAName, tableBDescription);
            return ResponseEntity.ok("Transaction T2 completed successfully");
        } catch (Exception e) {
            return ResponseEntity.internalServerError()
                    .body("Error: " + e.getMessage());
        }
    }
}

