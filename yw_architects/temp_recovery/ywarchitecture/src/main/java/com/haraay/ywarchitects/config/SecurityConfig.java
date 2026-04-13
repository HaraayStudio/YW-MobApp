package com.haraay.ywarchitects.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.security.web.session.SessionManagementFilter;

import org.springframework.web.filter.CorsFilter;

import com.haraay.ywarchitects.service.otherservices.CustomUserDetailsService;
import com.haraay.ywarchitects.util.JwtAuthenticationFilter;

@Configuration
@EnableWebSecurity
public class SecurityConfig {
	@Autowired
	private CustomUserDetailsService userDetailsService;

	@Autowired
	private JwtAuthenticationFilter jwtAuthFilter;

	@Autowired
	private CorsFilter corsFilter;

	// Role constants for clarity
	private static final String ADMIN = "ADMIN";
	private static final String CO_FOUNDER = "CO_FOUNDER";
	private static final String SR_ARCHITECT = "SR_ARCHITECT";
	private static final String JR_ARCHITECT = "JR_ARCHITECT";
	private static final String SR_ENGINEER = "SR_ENGINEER";
	private static final String DRAFTSMAN = "DRAFTSMAN";
	private static final String LIAISON_MGR = "LIAISON_MANAGER";
	private static final String LIAISON_OFF = "LIAISON_OFFICER";
	private static final String LIAISON_ASST = "LIAISON_ASSISTANT";
	private static final String HR = "HR";

	// ----------------------------------------------------------------
	// Role Access Matrix (from spec)
	// ----------------------------------------------------------------
	// ADMIN / CO_FOUNDER → Everything
	// SR_ARCHITECT → Projects, Pre/Post Sales, Clients, some Reports
	// JR_ARCHITECT → Manage Projects, All PostSales, Clients, Stage-wise Report
	// SR_ENGINEER → Manage Projects, Stage-wise Report only
	// DRAFTSMAN → Dashboard only
	// LIAISON_* → Pre Sales + Manage Clients
	// HR → HR section only
	// ----------------------------------------------------------------

	@Bean
	public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
		http.addFilterBefore(corsFilter, SessionManagementFilter.class).csrf(csrf -> csrf.disable())
				.authorizeHttpRequests(auth -> auth

						// ── Public endpoints ──────────────────────────────────────
						.requestMatchers("/api/auth/**").permitAll().requestMatchers("/ws-notifications/**").permitAll()
						.requestMatchers("/api/rera/**").hasAnyRole(ADMIN, CO_FOUNDER, SR_ARCHITECT, JR_ARCHITECT, SR_ENGINEER, DRAFTSMAN, LIAISON_MGR,
								LIAISON_OFF, LIAISON_ASST, HR)

						// ── Employee endpoints ────────────────────────────────────
						// Any authenticated user can fetch their own data / update profile
						.requestMatchers("/api/employees/getemployeedata")
						.hasAnyRole(ADMIN, CO_FOUNDER, SR_ARCHITECT, JR_ARCHITECT, SR_ENGINEER, DRAFTSMAN, LIAISON_MGR,
								LIAISON_OFF, LIAISON_ASST, HR)

						.requestMatchers("/api/employees/updatemyprofile")
						.hasAnyRole(ADMIN, CO_FOUNDER, SR_ARCHITECT, JR_ARCHITECT, SR_ENGINEER, DRAFTSMAN, LIAISON_MGR,
								LIAISON_OFF, LIAISON_ASST, HR)

						// Full employee management → ADMIN, CO_FOUNDER only
						.requestMatchers("/api/employees/**").hasAnyRole(ADMIN, CO_FOUNDER, SR_ARCHITECT, JR_ARCHITECT, SR_ENGINEER, DRAFTSMAN, LIAISON_MGR,
								LIAISON_OFF, LIAISON_ASST, HR)

						// ── Client endpoints ──────────────────────────────────────
						// Architects + Liaison roles manage clients
						.requestMatchers("/api/clients/**")
						.hasAnyRole(ADMIN, CO_FOUNDER, SR_ARCHITECT, JR_ARCHITECT, SR_ENGINEER, DRAFTSMAN, LIAISON_MGR,
								LIAISON_OFF, LIAISON_ASST, HR)

						// ── Pre-Sales ─────────────────────────────────────────────
						// SR_ARCHITECT + Liaison roles handle pre-sales
						.requestMatchers("/api/presales/**")
						.hasAnyRole(ADMIN, CO_FOUNDER, SR_ARCHITECT, JR_ARCHITECT, SR_ENGINEER, DRAFTSMAN, LIAISON_MGR,
								LIAISON_OFF, LIAISON_ASST, HR)

						// ── Post-Sales ────────────────────────────────────────────
						// Create: SR_ARCHITECT, JR_ARCHITECT and above
						.requestMatchers("/api/postsales/createpostsales")
						.hasAnyRole(ADMIN, CO_FOUNDER, SR_ARCHITECT, JR_ARCHITECT, SR_ENGINEER, DRAFTSMAN, LIAISON_MGR,
								LIAISON_OFF, LIAISON_ASST, HR)

						// All post-sales: JR_ARCHITECT and above
						.requestMatchers("/api/postsales/**").hasAnyRole(ADMIN, CO_FOUNDER, SR_ARCHITECT, JR_ARCHITECT, SR_ENGINEER, DRAFTSMAN, LIAISON_MGR,
								LIAISON_OFF, LIAISON_ASST, HR)

						// ── Projects ──────────────────────────────────────────────
						// SR_ENGINEER, JR_ARCHITECT+ can manage projects
						.requestMatchers("/api/projects/**")
						.hasAnyRole(ADMIN, CO_FOUNDER, SR_ARCHITECT, JR_ARCHITECT, SR_ENGINEER, DRAFTSMAN, LIAISON_MGR,
								LIAISON_OFF, LIAISON_ASST, HR)

						// ── Site Visits ───────────────────────────────────────────
						// Field visits tied to projects — same access as projects
						.requestMatchers("/api/site-visits/**")
						.hasAnyRole(ADMIN, CO_FOUNDER, SR_ARCHITECT, JR_ARCHITECT, SR_ENGINEER, DRAFTSMAN, LIAISON_MGR,
								LIAISON_OFF, LIAISON_ASST, HR)

						// ── Structure ─────────────────────────────────────────────
						// Stage/structure data — architects + engineers
						.requestMatchers("/api/structure/**")
						.hasAnyRole(ADMIN, CO_FOUNDER, SR_ARCHITECT, JR_ARCHITECT, SR_ENGINEER, DRAFTSMAN, LIAISON_MGR,
								LIAISON_OFF, LIAISON_ASST, HR)

						// ── Catch-all ─────────────────────────────────────────────
						.anyRequest().authenticated())
				.sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
				.addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class);

		return http.build();
	}

	@Bean
	public PasswordEncoder passwordEncoder() {
		return new BCryptPasswordEncoder();
	}

	@Bean
	public AuthenticationManager authenticationManager(AuthenticationConfiguration config) throws Exception {
		return config.getAuthenticationManager();
	}

}
