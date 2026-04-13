package com.haraay.ywarchitects.util;

import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import com.haraay.ywarchitects.model.User;

import java.security.Key;
import java.util.Base64;
import java.util.Date;

@Component
public class JwtUtil {
	
    @Value("${jwt.secret}")
    private String jwtSecret;
    
    @Value("${jwt.access-token.expiration}")
    private Long accessTokenExpiration ;
    
    @Value("${jwt.refresh-token.expiration}")
    private Long refreshTokenExpiration ;
    
    public String generateAccessToken(User user) {
        return Jwts.builder()
            .setSubject(user.getEmail()) // Using email as subject
            .claim("role", user.getRole())
            .claim("userId", user.getId())
            .setIssuedAt(new Date())
            .setExpiration(new Date(System.currentTimeMillis() + accessTokenExpiration))
            .signWith(getSigningKey(), SignatureAlgorithm.HS256)
            .compact();
    }
    
    public String generateRefreshToken(User user) {
        return Jwts.builder()
            .setSubject(user.getEmail())
            .claim("userId", user.getId())
           // .claim("deviceInfo", deviceInfo)
            .setIssuedAt(new Date())
            .setExpiration(new Date(System.currentTimeMillis() + refreshTokenExpiration))
            .signWith(getSigningKey(), SignatureAlgorithm.HS256)
            .compact();
    }
    
    private Key getSigningKey() {
        byte[] keyBytes = Base64.getDecoder().decode(jwtSecret);
        return Keys.hmacShaKeyFor(keyBytes);
    }
    
    public String getEmailFromToken(String token) {
        return Jwts.parserBuilder()
            .setSigningKey(getSigningKey())
            .build()
            .parseClaimsJws(token)
            .getBody()
            .getSubject();
    }
    
    public boolean validateToken(String token) {
        try {
            Jwts.parserBuilder()
                .setSigningKey(getSigningKey())
                .build()
                .parseClaimsJws(token);
            return true;
        } catch (Exception e) {
            return false;
        }
    }
}
