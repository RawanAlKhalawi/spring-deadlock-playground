package com.deadlock.repository;

import com.deadlock.entity.OrderItem;
import com.deadlock.entity.Product;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface OrderItemRepository extends JpaRepository<OrderItem, Long> {


  List<OrderItem> findByProduct_Id(Long productId);

  List<OrderItem> findByProduct(Product product);

  List<OrderItem> findByProduct_NameOrProduct_Id(String name, Long productId);

}

