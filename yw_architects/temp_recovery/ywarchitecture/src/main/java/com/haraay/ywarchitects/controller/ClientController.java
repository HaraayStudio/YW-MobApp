package com.haraay.ywarchitects.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.haraay.ywarchitects.dto.ClientBasicDTO;
import com.haraay.ywarchitects.dto.ClientDTO;
import com.haraay.ywarchitects.dto.ClientINEPAGPDTO;
import com.haraay.ywarchitects.model.Client;
import com.haraay.ywarchitects.service.ClientService;
import com.haraay.ywarchitects.util.ResponseStructure;

import java.util.List;

@RestController
@RequestMapping("/api/clients")
public class ClientController {

    
    private final ClientService clientService;
    
    

    public ClientController(ClientService clientService) {
		super();
		this.clientService = clientService;
	}

	@PostMapping("/createclient")
    public ResponseEntity<ResponseStructure<ClientBasicDTO>> createClient(@RequestBody Client client) {
        return clientService.createClient(client);
    }
    
    @GetMapping("/getallclients")
    public ResponseEntity<ResponseStructure<List<ClientBasicDTO>>> getAllClients() {
        return clientService.getAllClients();
    }

    @GetMapping("/getclientbyid/{id}")
    public ResponseEntity<ResponseStructure<ClientDTO>> getClientById(@PathVariable Long id) {
        return clientService.getClientById(id);
    }

    @PutMapping("/updateclient")
    public ResponseEntity<ResponseStructure<ClientDTO>> updateClient(@RequestParam Long id,@RequestBody ClientINEPAGPDTO clientINEPAGPDTO) {
        return clientService.updateClient(id,clientINEPAGPDTO);
    }

    
}
