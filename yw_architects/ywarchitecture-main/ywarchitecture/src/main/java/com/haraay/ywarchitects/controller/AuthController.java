package com.haraay.ywarchitects.controller;

import java.time.LocalDateTime;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;

import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.haraay.ywarchitects.dto.AuthResponse;
import com.haraay.ywarchitects.dto.TokenRefreshRequest;
import com.haraay.ywarchitects.dto.TokenRefreshResponse;
import com.haraay.ywarchitects.exception.TokenRefreshException;
import com.haraay.ywarchitects.model.Client;
import com.haraay.ywarchitects.model.RefreshToken;
import com.haraay.ywarchitects.model.User;
import com.haraay.ywarchitects.repository.RefreshTokenRepository;

import com.haraay.ywarchitects.service.UserService;
import com.haraay.ywarchitects.util.ClientCustomUserDetails;
import com.haraay.ywarchitects.util.CustomUserDetails;
import com.haraay.ywarchitects.util.JwtUtil;

@RestController
@RequestMapping("/api/auth")

public class AuthController {
	

	@Autowired
	private JwtUtil jwtUtil;

	@Autowired
	private UserService userService;

	@Autowired
	private RefreshTokenRepository refreshTokenRepository;
	
	@Autowired
	@Qualifier("userAuthManager")
	private AuthenticationManager authenticationManager;        // for /login and /adminlogin

	@Autowired
	@Qualifier("clientAuthManager")
	private AuthenticationManager clientAuthenticationManager;  // for /clientlogin

	@PostMapping("/login")
	public ResponseEntity<?> login(@RequestParam("email") String email, @RequestParam("password") String password) {
		try {
			Authentication authentication = authenticationManager
					.authenticate(new UsernamePasswordAuthenticationToken(email, password));

			CustomUserDetails userDetails = (CustomUserDetails) authentication.getPrincipal();
			User user = userDetails.getUser();

			// Check for USER  IS ACTIVE before proceeding with token generation
			if (!user.getStatus().equals("ACTIVE")) {
				return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Unauthorized: NO MORE ACCESS!");
			}

			String uEmail = userDetails.getUsername();

			RefreshToken oldRefreshToken = refreshTokenRepository.findByUserEmail(uEmail);
			if (oldRefreshToken != null) {
				refreshTokenRepository.delete(oldRefreshToken);
			}

			String accessToken = jwtUtil.generateAccessToken(user);
			String refreshToken = jwtUtil.generateRefreshToken(user);// , userAgent

			// Save refresh token
			RefreshToken refreshTokenEntity = new RefreshToken();
			refreshTokenEntity.setUser(user);
			refreshTokenEntity.setToken(refreshToken);
			// refreshTokenEntity.setDeviceInfo(userAgent);
			refreshTokenEntity.setExpiryDate(LocalDateTime.now().plusWeeks(2));
			refreshTokenRepository.save(refreshTokenEntity);

			return ResponseEntity.ok(new AuthResponse(accessToken, refreshToken));
		} catch (BadCredentialsException e) {
			return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid email or password");
		}
	}

	@PostMapping("/refresh")
	public ResponseEntity<?> refreshToken(@RequestBody TokenRefreshRequest request) {
		String requestRefreshToken = request.getRefreshToken();

		Optional<RefreshToken> optionalRefreshToken = refreshTokenRepository.findByToken(requestRefreshToken);
		if (optionalRefreshToken.isPresent()
				&& optionalRefreshToken.get().getExpiryDate().isAfter(LocalDateTime.now())) {
			RefreshToken token = optionalRefreshToken.get();
			User user = token.getUser();
			String newAccessToken = jwtUtil.generateAccessToken(user);
			return ResponseEntity.ok(new TokenRefreshResponse(user.getEmail(), newAccessToken, requestRefreshToken));
		} else {
			throw new TokenRefreshException("Refresh token not found or expired");
		}
	}

	@PostMapping("/logout")
	public ResponseEntity<?> logout(@RequestBody TokenRefreshRequest request) {
		if (request != null) {
			String token = request.getRefreshToken();
			Optional<RefreshToken> optionalRefreshToken = refreshTokenRepository.findByToken(token);

			refreshTokenRepository.delete(optionalRefreshToken.get());

			return ResponseEntity.ok("Logout");
		} else
			return ResponseEntity.ok("Logout");

	}

	@PostMapping("/adminlogin")
	public ResponseEntity<?> adminlogin(@RequestParam("email") String email,
			@RequestParam("password") String password) {
		try {
			// First authenticate the user
			Authentication authentication = authenticationManager
					.authenticate(new UsernamePasswordAuthenticationToken(email, password));

			CustomUserDetails userDetails = (CustomUserDetails) authentication.getPrincipal();
			User user = userDetails.getUser();

			// Check for ADMIN role first before proceeding with token generation
			if (!user.getRole().equals("ADMIN")) {
				return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Unauthorized: Admin access required");
			} else if (!user.getStatus().equals("ACTIVE")) {
				return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Unauthorized: NO MORE ACCESS!");
			}

			// If user is admin, proceed with token generation
			String uEmail = userDetails.getUsername();

			// Remove old refresh token if exists
			RefreshToken oldRefreshToken = refreshTokenRepository.findByUserEmail(uEmail);
			if (oldRefreshToken != null) {
				refreshTokenRepository.delete(oldRefreshToken);
			}

			// Generate new tokens
			String accessToken = jwtUtil.generateAccessToken(user);
			String refreshToken = jwtUtil.generateRefreshToken(user);

			// Save new refresh token
			RefreshToken refreshTokenEntity = new RefreshToken();
			refreshTokenEntity.setUser(user);
			refreshTokenEntity.setToken(refreshToken);
			refreshTokenEntity.setExpiryDate(LocalDateTime.now().plusWeeks(2));
			refreshTokenRepository.save(refreshTokenEntity);

			return ResponseEntity.ok(new AuthResponse(accessToken, refreshToken));

		} catch (BadCredentialsException e) {
			return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid email or password");
		}
	}
	
	
	@PostMapping("/clientlogin")
	public ResponseEntity<?> clientlogin(@RequestParam("email") String email,
	                                     @RequestParam("password") String password) {
	    try {
	        // ✅ Use clientAuthenticationManager — hits Client table
	        Authentication authentication = clientAuthenticationManager
	                .authenticate(new UsernamePasswordAuthenticationToken(email, password));

	        ClientCustomUserDetails userDetails = (ClientCustomUserDetails) authentication.getPrincipal();
	        Client client = userDetails.getUser();

	        String accessToken = jwtUtil.generateAccessToken(client);

	        return ResponseEntity.ok(new AuthResponse(accessToken, ""));
	    } catch (BadCredentialsException e) {
	        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid email or password");
	    }
	}


	

}
