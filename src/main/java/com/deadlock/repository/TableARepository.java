package com.deadlock.repository;

import java.util.List;

import com.deadlock.entity.TableA;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface TableARepository extends JpaRepository<TableA, Long> {

  @Query("select a from TableA a where a.name = :name")
  List<TableA> findAllByName(@Param("name") String name);

  @Modifying
  @Query("update TableA a set a.value = a.value + 1 where a.name = :name")
  int updateValueByName(@Param("name") String name);

  @Query(value = "SELECT * FROM table_a WHERE name = :name", nativeQuery = true)
  List<TableA> findAllByNameNative(@Param("name") String name);

  @Modifying
  @Query(value = "UPDATE table_a SET value = value + 1 WHERE name = :name", nativeQuery = true)
  int updateValueByNameNative(@Param("name") String name);
}

