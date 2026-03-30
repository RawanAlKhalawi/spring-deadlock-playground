package com.deadlock.repository;

import java.util.List;

import com.deadlock.entity.TableA;
import com.deadlock.entity.TableB;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface TableBRepository extends JpaRepository<TableB, Long> {

  @Query("select b from TableB b where b.description = :description")
  List<TableB> findAllByDescription(@Param("description") String description);

  @Modifying
  @Query("update TableB b set b.amount = b.amount + 1 where b.description = :description")
  int updateAmountByDescription(@Param("description") String description);

  @Query(value = "SELECT * FROM table_b WHERE description = :description", nativeQuery = true)
  List<TableB> findAllByDescriptionNative(@Param("description") String description);

  @Modifying
  @Query(value = "UPDATE table_b SET amount = amount + 1 WHERE description = :description", nativeQuery = true)
  int updateAmountByDescriptionNative(@Param("description") String description);

}

