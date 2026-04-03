package com.haraay.ywarchitects.service.otherservices;

import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import com.haraay.ywarchitects.model.Client;
import com.haraay.ywarchitects.repository.ClientRepository;
import com.haraay.ywarchitects.util.ClientCustomUserDetails;

@Service("clientUserDetailsService")
public class ClientUserDetailsService implements UserDetailsService {

	@Autowired
	private ClientRepository clientRepository;

	@Override
	public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
		Optional<Client> client = clientRepository.findByEmail(email);
		if (client == null) {
			throw new UsernameNotFoundException("Client not found with email: " + email);
		}
		return new ClientCustomUserDetails(client.get());
	}
}
