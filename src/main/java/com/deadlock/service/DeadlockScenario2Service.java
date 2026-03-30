package com.deadlock.service;

import java.util.List;

import com.deadlock.entity.TableA;
import com.deadlock.entity.TableB;
import com.deadlock.repository.TableARepository;
import com.deadlock.repository.TableBRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Isolation;
import org.springframework.transaction.annotation.Transactional;

/**
 * Scenario 2: Inconsistent Read–Write Order Across Transactions
 * <p>
 * Transaction T1: updates TableB, then Reads TableA
 * Transaction T2: updates TableA, then Reads TableB
 * <p>
 * When both run concurrently, each holds a lock the other needs → deadlock
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class DeadlockScenario2Service {

  private final TableARepository tableARepository;

  private final TableBRepository tableBRepository;

  /**
   * Transaction T1: updates TableB, then reads TableA
   */
  @Transactional
  public void transactionT1(String tableAName, String tableBDescription) {
    log.info("T1: Starting transaction - will update TableB, then read TableA");

    // Step 1: Update TableB (needs exclusive lock)
    int tableBList = tableBRepository.updateAmountByDescription(tableBDescription);
    log.info("T1: Updated TableB {} ", tableBList);

    // Step 2: Read from TableA (acquires shared lock)
    List<TableA> tableAList = tableARepository.findAllByName(tableAName);
    log.info("T1: Locked {} records from TableA", tableAList.size());

    log.info("T1: Transaction completed");
  }

  /**
   * Transaction T2: updates TableA, then reads TableB
   */
  @Transactional
  public void transactionT2(String tableAName, String tableBDescription) {
    log.info("T2: Starting transaction - will update TableA, then read TableB ");

    // Step 1: Update TableA (needs exclusive lock)
    int tableAList = tableARepository.updateValueByName(tableAName);
    log.info("T2: Updated TableA {} ", tableAList);

    // Step 2: Read from TableB (acquires shared lock)
    List<TableB> tableBList = tableBRepository.findAllByDescription(tableBDescription);
    log.info("T2: Locked {} records from TableB", tableBList.size());

    log.info("T2: Transaction completed");
  }


}


//With UPDATE-first:
//
//UPDATE acquires exclusive lock
//Exclusive lock persists until COMMIT
//When the other transaction tries to SELECT those same rows, it gets blocked by the exclusive lock
//Both transactions are now waiting on each other → Deadlock!
//
//With SELECT-first:
//
//SELECT reads data
//Lock is released immediately (in default READ_COMMITTED)
//No lock is held when UPDATE executes
//No circular wait → No deadlock

