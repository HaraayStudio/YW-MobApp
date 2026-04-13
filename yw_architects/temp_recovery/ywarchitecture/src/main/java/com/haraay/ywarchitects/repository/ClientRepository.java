package com.haraay.ywarchitects.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import com.haraay.ywarchitects.model.Client;

public interface ClientRepository extends JpaRepository<Client, Long> {

	@Query("SELECT c FROM Client c ORDER BY c.id DESC")
    List<Client> findAllDesc();
}
