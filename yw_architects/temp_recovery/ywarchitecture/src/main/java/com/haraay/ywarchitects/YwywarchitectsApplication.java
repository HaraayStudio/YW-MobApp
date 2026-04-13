 package com.haraay.ywarchitects;

import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.security.crypto.password.PasswordEncoder;

import com.haraay.ywarchitects.model.User;
import com.haraay.ywarchitects.repository.UserRepository;


@SpringBootApplication
public class YwywarchitectsApplication {

	public static void main(String[] args) {
		SpringApplication.run(YwywarchitectsApplication.class, args);
	}
	@Bean
	public CommandLineRunner createDefaultAdmin(UserRepository userRepository, PasswordEncoder passwordEncoder) {
		return args -> {
			// Only create if admin doesn't already exist
			if (userRepository.findByEmail("admin@ywarchitects.com").isEmpty()) {

				User admin = new User();
				admin.setFirstName("Yogesh");
				admin.setLastName("Wakchaure");
				admin.setEmail("admin@ywarchitects.com");
				admin.setPassword(passwordEncoder.encode("admin"));
				admin.setRole("ADMIN");
				admin.setStatus("ACTIVE");
				admin.setPhone(9623901901L);    // placeholder - update as needed
				admin.setJoinDate(java.time.LocalDate.now());

				userRepository.save(admin);

				System.out.println("==== Default admin created: admin@ywarchitects.com ====");
			} else {
				System.out.println("==== Admin already exists, skipping creation. ====");
			}
		};
	}
}




