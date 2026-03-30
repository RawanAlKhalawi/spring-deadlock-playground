package com.deadlock.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "table_b")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class TableB {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String description;

    @Column(nullable = false)
    private Integer amount;

//    @ManyToOne(fetch = FetchType.LAZY)
//    @JoinColumn(name = "table_a_id")
//    @JsonIgnore
//    private TableA tableA;
}

