package com.deadlock.repository;

import java.util.List;

import com.deadlock.entity.Product;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface ProductRepository extends JpaRepository<Product, Long> {

  @Modifying
  @Query("delete from Product p where p.name = :name")
  int deleteByName(@Param("name") String name);
}

