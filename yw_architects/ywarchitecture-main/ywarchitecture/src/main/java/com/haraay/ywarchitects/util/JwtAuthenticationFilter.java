package com.haraay.ywarchitects.util;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import com.haraay.ywarchitects.service.otherservices.ClientUserDetailsService;
import com.haraay.ywarchitects.service.otherservices.CustomUserDetailsService;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {
	@Autowired
	private JwtUtil jwtUtil;

	@Autowired
	private CustomUserDetailsService userDetailsService;

	@Autowired
	private ClientUserDetailsService clientUserDetailsService;

//    @Override
//    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, 
//            FilterChain filterChain) throws ServletException, IOException {
//        String authHeader = request.getHeader("Authorization");
//        
//        if (authHeader != null && authHeader.startsWith("Bearer ")) {
//            String jwt = authHeader.substring(7);
//            try {
//                String email = jwtUtil.getEmailFromToken(jwt);
//                UserDetails userDetails = userDetailsService.loadUserByUsername(email);
//                
//                if (jwtUtil.validateToken(jwt)) {
//                    UsernamePasswordAuthenticationToken authentication = 
//                        new UsernamePasswordAuthenticationToken(
//                            userDetails, null, userDetails.getAuthorities());
//                    SecurityContextHolder.getContext().setAuthentication(authentication);
//                }
//            } catch (Exception e) {
//                // Token validation failed
//            }
//        }
//        filterChain.doFilter(request, response);
//    }

	@Override
	protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
			throws ServletException, IOException {

		String authHeader = request.getHeader("Authorization");

		if (authHeader != null && authHeader.startsWith("Bearer ")) {
			String jwt = authHeader.substring(7);
			try {
				if (jwtUtil.validateToken(jwt) && SecurityContextHolder.getContext().getAuthentication() == null) {

					String email = jwtUtil.getEmailFromToken(jwt);
					String role = jwtUtil.getRoleFromToken(jwt); // ← read role from JWT

					UserDetails userDetails = loadUserDetailsByRole(email, role);

					if (userDetails != null) {
						UsernamePasswordAuthenticationToken authentication = new UsernamePasswordAuthenticationToken(
								userDetails, null, userDetails.getAuthorities());

						authentication.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));

						SecurityContextHolder.getContext().setAuthentication(authentication);
					}
				}
			} catch (Exception e) {
				// Token validation failed — continue without authentication
			}
		}

		filterChain.doFilter(request, response);
	}

	/**
	 * Route to correct UserDetailsService based on role in JWT.
	 */
	private UserDetails loadUserDetailsByRole(String email, String role) {
		if (role == null)
			return null;

		if (role.toUpperCase().equalsIgnoreCase("CLIENT")) {
			return clientUserDetailsService.loadUserByUsername(email);
		} else {
			return userDetailsService.loadUserByUsername(email);
		}

	}
}
