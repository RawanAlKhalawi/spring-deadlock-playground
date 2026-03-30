package com.deadlock.repository;

import com.deadlock.entity.UserTransaction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface UserTransactionRepository extends JpaRepository<UserTransaction, Long> {
    List<UserTransaction> findByUserId(Long userId);

  @Modifying
  @Query("update UserTransaction u set u.amount = u.amount + 1 where u.userId = :userId")
  int updateAmount(@Param("userId") Long userId);
}

