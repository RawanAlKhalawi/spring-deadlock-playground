package com.deadlock.service;

import com.deadlock.entity.UserTransaction;
import com.deadlock.repository.UserTransactionRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.concurrent.TimeUnit;

/**
 * Scenario 1: Long-Lived Transaction with External API Call
 * 
 * This service demonstrates a deadlock scenario where:
 * - A transaction is opened at the beginning of a method
 * - The method makes a call to an external API that takes a long time
 * - During this delay, database locks remain held
 * - Concurrent requests attempt to access the same resources, causing deadlocks
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class DeadlockScenario1Service {

    private final UserTransactionRepository userTransactionRepository;

    @Transactional
    public void processTransactionWithExternalApiCall(Long userId, BigDecimal amount) {
        log.info("Starting transaction for user: {}, amount: {}", userId, amount);

        // Step 1: Begin transaction and acquire lock on user's transactions
        UserTransaction transaction = new UserTransaction();
        transaction.setUserId(userId);
        transaction.setAmount(amount);
        transaction.setStatus("PENDING");
        transaction.setCreatedAt(LocalDateTime.now());
        userTransactionRepository.save(transaction);

        // Step 2: update amount
        userTransactionRepository.updateAmount(userId);

        log.info("Transaction saved, lock acquired. Now calling external API...");
        
        // Step 3: Simulate external API call that takes a long time
        // This keeps the transaction open and locks held
        try {
            simulateExternalApiCall();
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            log.error("External API call interrupted", e);
        }

//        // Step 4: Update transaction status
        transaction.setStatus("COMPLETED");
        userTransactionRepository.save(transaction);

        log.info("Transaction completed for user: {}", userId);
    }

    /**
     * Gets all transactions for a specific user, then updates them.
     * This method causes deadlocks when called concurrently with processTransactionWithExternalApiCall
     * because they access the same rows in different orders.
     */
    @Transactional
    public List<UserTransaction> getTransactionsByUserId(Long userId) {
        log.info("Getting transactions for user: {}", userId);
        List<UserTransaction> transactions = userTransactionRepository.findByUserId(userId);
        log.info("Found {} transactions for user {}", transactions.size(), userId);
        return transactions;
    }

    /**
     * Simulates an external API call that takes 200 seconds
     * In a real scenario, this would be an HTTP call to an external service
     */
    private void simulateExternalApiCall() throws InterruptedException {
        log.info("Calling external API... (this will take 200 seconds)");
        TimeUnit.SECONDS.sleep(200);
        log.info("External API call completed");
    }
}

