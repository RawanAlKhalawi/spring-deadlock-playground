package com.deadlock;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.transaction.annotation.EnableTransactionManagement;

@SpringBootApplication
@EnableTransactionManagement
public class DeadlockSimulationApplication {

    public static void main(String[] args) {
        SpringApplication.run(DeadlockSimulationApplication.class, args);
    }
}

