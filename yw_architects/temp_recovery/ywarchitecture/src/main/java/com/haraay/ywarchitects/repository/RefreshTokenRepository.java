package com.haraay.ywarchitects.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.haraay.ywarchitects.model.RefreshToken;


public interface RefreshTokenRepository extends JpaRepository<RefreshToken, Long> {

	Optional<RefreshToken> findByToken(String requestRefreshToken);

	@Query("SELECT r FROM RefreshToken r WHERE r.user.email =:email")
	RefreshToken findByUserEmail(@Param("email") String email);
	
	
	
    
}
