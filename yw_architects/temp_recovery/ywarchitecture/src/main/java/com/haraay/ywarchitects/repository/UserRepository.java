package com.haraay.ywarchitects.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import com.haraay.ywarchitects.model.User;

public interface UserRepository extends JpaRepository<User, Long>{
	
	Optional<User> findByEmail(String email);

	@Query("SELECT u FROM User u WHERE u.role <> 'ADMIN'")
	List<User> findAllEmplyees();

	
	@Query("SELECT u FROM User u WHERE u.role <> 'ADMIN' ORDER BY u.id DESC")
	List<User> findAllEmployeesDesc();

	@Query("SELECT u FROM User u WHERE  u.status = 'INACTIVE' ORDER BY u.id DESC")
	List<User> findAllInactiveEmployees();

}
