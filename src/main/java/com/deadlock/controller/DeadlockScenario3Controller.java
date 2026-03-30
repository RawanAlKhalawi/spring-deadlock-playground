package com.deadlock.controller;

import com.deadlock.service.DeadlockScenario3Service;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/scenario3")
@RequiredArgsConstructor
public class DeadlockScenario3Controller {

  private final DeadlockScenario3Service service;

  @PostMapping("/delete-and-insert")
  public ResponseEntity<String> deleteAndInsert(
      @RequestParam(required = false, defaultValue = "cases-3") String name) {
    try {
      service.deleteAndInsertProducts(name);
      return ResponseEntity.ok("Bulk delete and insert completed successfully");
    } catch (Exception e) {
      return ResponseEntity.internalServerError()
          .body("Error: " + e.getMessage());
    }
  }

}

