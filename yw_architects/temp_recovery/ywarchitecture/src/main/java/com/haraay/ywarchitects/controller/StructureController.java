package com.haraay.ywarchitects.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;

import org.springframework.web.bind.annotation.RestController;

import com.haraay.ywarchitects.dto.StructureDTO;

import com.haraay.ywarchitects.model.Structure;
import com.haraay.ywarchitects.service.StructureService;
import com.haraay.ywarchitects.util.ResponseStructure;

@RestController
@RequestMapping("/api/structure")
public class StructureController {

	private final StructureService structureService;

	public StructureController(StructureService structureService) {
		super();
		this.structureService = structureService;
	}

	@PostMapping("/createstructure/{projectId}")
	public ResponseEntity<ResponseStructure<StructureDTO>> createStructure(@PathVariable Long projectId,
			@RequestBody Structure structure) {
		return structureService.createStructure(projectId, structure);

	}

}
