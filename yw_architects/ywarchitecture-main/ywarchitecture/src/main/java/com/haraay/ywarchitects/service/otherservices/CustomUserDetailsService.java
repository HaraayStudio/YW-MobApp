package com.haraay.ywarchitects.service.otherservices;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import com.haraay.ywarchitects.exception.UserNotFound;
import com.haraay.ywarchitects.model.User;
import com.haraay.ywarchitects.repository.UserRepository;
import com.haraay.ywarchitects.util.CustomUserDetails;



@Service
public class CustomUserDetailsService implements UserDetailsService {
    @Autowired
    private UserRepository userRepository;
    
    @Override
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
        User user = userRepository.findByEmail(email)
            .orElseThrow(() -> new UserNotFound("User not found with email: " + email));
        return new CustomUserDetails(user);
    }
}
