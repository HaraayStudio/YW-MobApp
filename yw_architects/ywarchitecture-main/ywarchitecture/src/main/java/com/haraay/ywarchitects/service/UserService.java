package com.haraay.ywarchitects.service;

import java.time.LocalDate;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;

import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.multipart.MultipartFile;

import com.haraay.ywarchitects.dto.UserDTO;
import com.haraay.ywarchitects.mapper.ProjectMapper;
import com.haraay.ywarchitects.mapper.UserMapper;
import com.haraay.ywarchitects.dto.ProjectDTO;
import com.haraay.ywarchitects.dto.ProjectLiteDTO;
import com.haraay.ywarchitects.dto.SuccessDTO;
import com.haraay.ywarchitects.exception.InCorrectPassword;
import com.haraay.ywarchitects.exception.ResourceNotFoundException;
import com.haraay.ywarchitects.exception.UserNotFound;
import com.haraay.ywarchitects.model.Client;
import com.haraay.ywarchitects.model.User;
import com.haraay.ywarchitects.repository.UserRepository;
import com.haraay.ywarchitects.util.JwtUtil;
import com.haraay.ywarchitects.util.ResponseStructure;

import jakarta.transaction.Transactional;

@Service
public class UserService {

	@Autowired
	private JwtUtil jwtUtil;

	@Autowired
	private PasswordEncoder passwordEncoder;

	@Autowired
	private UserRepository userRepository;

	@Autowired
	private ResponseStructure<User> userStructure;

	@Autowired
	private ResponseStructure<SuccessDTO> successStructure;

	@Autowired
	private ResponseStructure<UserDTO> userDTOStructure;

	@Autowired
	private UserMapper userMapper;

	@Autowired
	private ProjectMapper projectMapper;;

	@Autowired
	private S3Service s3Service;

	@Autowired
	private ResponseStructure<List<ProjectDTO>> projectDTOListStructure;

	public ResponseEntity<ResponseStructure<UserDTO>> signIn(String email, String password) {
		Optional<User> optionalUser = userRepository.findByEmail(email);
		if (optionalUser.isPresent()) {

			User user = optionalUser.get();

			if (!passwordEncoder.matches(password, user.getPassword()))
				throw new InCorrectPassword("InCorrectPassword");

			userStructure.setMessage("FOUND");
			userStructure.setStatus(HttpStatus.FOUND.value());
			userStructure.setData(user);

			return new ResponseEntity<ResponseStructure<UserDTO>>(userDTOStructure, HttpStatus.FOUND);

		} else
			throw new UserNotFound("UserNotFound");
	}

	public ResponseEntity<ResponseStructure<UserDTO>> createEmployee(User user) {

		user.setStatus("ACTIVE");

		user.setPassword(passwordEncoder.encode(user.getPassword()));

		User savedEmployee = userRepository.save(user);

		ResponseStructure<UserDTO> userStructure = new ResponseStructure<>();
		if (savedEmployee == null) {
			return new ResponseEntity<ResponseStructure<UserDTO>>(userDTOStructure, HttpStatus.INTERNAL_SERVER_ERROR);

		}
		userDTOStructure.setMessage("EMPLOYEE SAVED");
		userDTOStructure.setStatus(HttpStatus.CREATED.value());
		userDTOStructure.setData(userMapper.toDTO(savedEmployee));

		return new ResponseEntity<ResponseStructure<UserDTO>>(userDTOStructure, HttpStatus.OK);

	}

	public ResponseEntity<ResponseStructure<UserDTO>> getEmployeeById(Long id) {
		User user = userRepository.findById(id).orElseThrow(() -> new RuntimeException("User not found"));
		return ResponseEntity.ok(new ResponseStructure<UserDTO>().success(userMapper.toDTO(user), "Employee found"));
	}

	public ResponseEntity<ResponseStructure<UserDTO>> updateEmployee(Long id, User updatedData) {
		User user = userRepository.findById(id).orElseThrow(() -> new RuntimeException("User not found"));
		user.setFirstName(updatedData.getFirstName());
		user.setSecondName(updatedData.getSecondName());
		user.setLastName(updatedData.getLastName());

		user.setEmail(updatedData.getEmail());
		user.setPhone(updatedData.getPhone());

//		user.setStatus(updatedData.getStatus());	
		user.setRole(updatedData.getRole());

		user.setGender(updatedData.getGender());
		user.setBirthDate(updatedData.getBirthDate());
		user.setBloodGroup(updatedData.getBloodGroup());

		user.setAdharNumber(updatedData.getAdharNumber());
		user.setPanNumber(updatedData.getPanNumber());

		user.setJoinDate(updatedData.getJoinDate());
		user.setLeaveDate(updatedData.getLeaveDate());

		User updatedEmployee;
		try {
			updatedEmployee = userRepository.save(user);
		} catch (Exception e) {
			userDTOStructure.setMessage("DUPLICATE  DATA FOR EMPLOYEE ,EMAIL/PHONE");
			userDTOStructure.setStatus(HttpStatus.INTERNAL_SERVER_ERROR.value());
			userDTOStructure.setData(null);

			return new ResponseEntity<ResponseStructure<UserDTO>>(userDTOStructure, HttpStatus.INTERNAL_SERVER_ERROR);

		}

		if (updatedEmployee == null) {
			userDTOStructure.setMessage("DUPLICATE  DATA FOR EMPLOYEE ,EMAIL/PHONE");
			userDTOStructure.setStatus(HttpStatus.INTERNAL_SERVER_ERROR.value());
			userDTOStructure.setData(null);

			return new ResponseEntity<ResponseStructure<UserDTO>>(userDTOStructure, HttpStatus.INTERNAL_SERVER_ERROR);
		}

		UserDTO dto = userMapper.toDTO(updatedEmployee);

		userDTOStructure.setMessage("EMPLOYEE UPDATED");
		userDTOStructure.setStatus(HttpStatus.OK.value());
		userDTOStructure.setData(dto);

		return new ResponseEntity<ResponseStructure<UserDTO>>(userDTOStructure, HttpStatus.OK);

	}

	@Transactional
	public ResponseEntity<ResponseStructure<String>> softDeleteEmployee(Long id) {
		Optional<User> userOpt = userRepository.findById(id);
		if (userOpt.isEmpty()) {
			return ResponseEntity.status(HttpStatus.NOT_FOUND)
					.body(new ResponseStructure<String>().error("Employee not found", "Not Found"));
		}

		User user = userOpt.get();
		user.setStatus("INACTIVE");
		user.setLeaveDate(LocalDate.now());
		userRepository.save(user);

		return ResponseEntity
				.ok(new ResponseStructure<String>().success("Employee marked as inactive", "Soft Deleted"));
	}

	public ResponseEntity<ResponseStructure<List<UserDTO>>> getAllEmployees() {

		List<UserDTO> employees = userMapper.toUserDTOList(userRepository.findAllEmployeesDesc());

		return ResponseEntity.ok(new ResponseStructure<List<UserDTO>>().success(employees, "All employees fetched"));
	}

	public ResponseEntity<ResponseStructure<UserDTO>> getEmployeeData(String token) {
		String jwtToken = token.replace("Bearer ", "");
		String email = jwtUtil.getEmailFromToken(jwtToken);
		Optional<User> optionalUser = userRepository.findByEmail(email);

		if (optionalUser.isEmpty()) {

			userDTOStructure.setMessage(" EMPLOYEE'S ID IS NOT FOUND");
			userDTOStructure.setStatus(HttpStatus.NOT_FOUND.value());
			userDTOStructure.setData(null);

			return new ResponseEntity<ResponseStructure<UserDTO>>(userDTOStructure, HttpStatus.NOT_FOUND);
		}

		User databaseEmployee = optionalUser.get();

		userDTOStructure.setMessage(" EMPLOYEE FOUND");
		userDTOStructure.setStatus(HttpStatus.FOUND.value());
		userDTOStructure.setData(userMapper.toDTO(databaseEmployee));

		return new ResponseEntity<ResponseStructure<UserDTO>>(userDTOStructure, HttpStatus.FOUND);
	}

	public ResponseEntity<ResponseStructure<UserDTO>> updateMyProfile(String token, User employee) {
		String jwtToken = token.replace("Bearer ", "");
		String email = jwtUtil.getEmailFromToken(jwtToken);
		Optional<User> optionalUser = userRepository.findByEmail(email);

		if (optionalUser.isEmpty()) {

			userDTOStructure.setMessage(" EMPLOYEE'S ID IS NOT FOUND");
			userDTOStructure.setStatus(HttpStatus.NOT_FOUND.value());
			userDTOStructure.setData(null);

			return new ResponseEntity<ResponseStructure<UserDTO>>(userDTOStructure, HttpStatus.NOT_FOUND);
		}

		User databaseEmployee = optionalUser.get();
		databaseEmployee.setFirstName(employee.getFirstName());
		databaseEmployee.setSecondName(employee.getSecondName());
		databaseEmployee.setLastName(employee.getLastName());
		databaseEmployee.setPhone(employee.getPhone());
		
		databaseEmployee.setBirthDate(employee.getBirthDate());
		databaseEmployee.setGender(employee.getGender());
		databaseEmployee.setBloodGroup(employee.getBloodGroup());
		
		//adhar pan 23-03
		databaseEmployee.setAdharNumber(employee.getAdharNumber());
		databaseEmployee.setPanNumber(employee.getPanNumber());

//		yw given email cant be changed
//		databaseEmployee.setEmail(employee.getEmail());
		
		return ResponseEntity.ok(new ResponseStructure<UserDTO>()
				.success(userMapper.toDTO(userRepository.save(databaseEmployee)), "Employee updated"));
	}

	public ResponseEntity<ResponseStructure<List<UserDTO>>> getallinactiveemployees() {
		List<User> inactiveUsers = userRepository.findAllInactiveEmployees();
		List<UserDTO> dtos = inactiveUsers.stream().map(userMapper::toDTO) // or however you map to DTO
				.toList();
		return ResponseEntity
				.ok(new ResponseStructure<List<UserDTO>>().success(dtos, "All InACtive Employees Fetched"));

	}

	public ResponseEntity<ResponseStructure<String>> activeemployee(Long id) {
		Optional<User> userOpt = userRepository.findById(id);
		if (userOpt.isEmpty()) {
			return ResponseEntity.status(HttpStatus.NOT_FOUND)
					.body(new ResponseStructure<String>().error("Employee not found", "Not Found"));
		}

		User user = userOpt.get();
		user.setStatus("ACTIVE");
		user.setLeaveDate(null);
		userRepository.save(user);

		return ResponseEntity.ok(new ResponseStructure<String>().success("Employee marked as Active", "Soft Active"));
	}

	// ADD THIS METHOD IN YOUR UserService.java

	public ResponseEntity<ResponseStructure<?>> updateMyProfileImage(String token, MultipartFile profileImage) {

		// ── 1. Extract email from JWT token ──────────────────────────
		String jwtToken = token.replace("Bearer ", "");
		String email = jwtUtil.getEmailFromToken(jwtToken);

		// ── 2. Find user ──────────────────────────────────────────────
		User user = userRepository.findByEmail(email)
				.orElseThrow(() -> new IllegalArgumentException("User not found with email: " + email));

		// ── 3. Validate file ──────────────────────────────────────────
		if (profileImage == null || profileImage.isEmpty()) {
			throw new IllegalArgumentException("Profile image cannot be empty");
		}

		// Validate file type (only images allowed)
		String contentType = profileImage.getContentType();
		if (contentType == null || !contentType.startsWith("image/")) {
			throw new IllegalArgumentException("Only image files are allowed (jpg, png, jpeg, etc.)");
		}

		// ── 4. Delete old image from S3 if exists ─────────────────────
		if (user.getProfileImage() != null && !user.getProfileImage().isBlank()) {
			try {
				s3Service.deleteFileByUrl(user.getProfileImage()); // replace with your S3 delete method
			} catch (Exception e) {
				// log but don't fail if old image delete fails
				System.out.println("Warning: Could not delete old profile image: " + e.getMessage());
			}
		}

		// ── 5. Upload new image to S3 ─────────────────────────────────
		String imageUrl = s3Service.uploadProfileImage(profileImage, user.getFirstName()); // replace with your S3
																							// upload method

		// ── 6. Update user profileImage field ────────────────────────
		user.setProfileImage(imageUrl);
		userRepository.save(user);

		// ── 7. Return response ────────────────────────────────────────
		ResponseStructure<String> response = new ResponseStructure<>();
		response.setStatus(HttpStatus.OK.value());
		response.setMessage("Profile image updated successfully");
		response.setData(imageUrl);

		return ResponseEntity.ok(response);
	}

	public ResponseEntity<ResponseStructure<List<ProjectDTO>>> getmyprojects(String token, int page, int size) {
		String jwtToken = token.replace("Bearer ", "");
		String email = jwtUtil.getEmailFromToken(jwtToken);
		Optional<User> optionalUser = userRepository.findByEmail(email);

		if (optionalUser.isEmpty()) {

			projectDTOListStructure.setMessage(" EMPLOYEE'S ID IS NOT FOUND");
			projectDTOListStructure.setStatus(HttpStatus.NOT_FOUND.value());
			projectDTOListStructure.setData(null);

			return new ResponseEntity<ResponseStructure<List<ProjectDTO>>>(projectDTOListStructure,
					HttpStatus.NOT_FOUND);
		}

		User databaseEmployee = optionalUser.get();

		projectDTOListStructure.setMessage(" EMPLOYEE FOUND");
		projectDTOListStructure.setStatus(HttpStatus.FOUND.value());
		projectDTOListStructure.setData(projectMapper.toDTOList(databaseEmployee.getProjects()));

		return new ResponseEntity<ResponseStructure<List<ProjectDTO>>>(projectDTOListStructure, HttpStatus.FOUND);
	}
	
	public ResponseEntity<ResponseStructure<SuccessDTO>> updateMyPassword(String token, String oldPassword,
			String newPassword) {

		String jwtToken = token.replace("Bearer ", "");
		String email = jwtUtil.getEmailFromToken(jwtToken);

		User user = userRepository.findByEmail(email)
				.orElseThrow(() -> new ResourceNotFoundException("User not found"));

		// 1. Verify old password
		if (!passwordEncoder.matches(oldPassword, user.getPassword())) {
			throw new IllegalArgumentException("Old password is incorrect");
		}
		// 2. Validate new password
		if (newPassword == null || newPassword.isBlank()) {
			throw new IllegalArgumentException("New password cannot be empty");
		}

		// 3. Guard: new password must not be same as old
		if (newPassword != null && !newPassword.isBlank() && newPassword.isEmpty()
				&& passwordEncoder.matches(newPassword, user.getPassword())) {
			throw new IllegalArgumentException("New password must be different from old password");
		}

		// 3. Update password
		user.setPassword(passwordEncoder.encode(newPassword));
		userRepository.save(user);

		ResponseStructure<SuccessDTO> response = new ResponseStructure<>();
		response.setStatus(HttpStatus.OK.value());
		response.setMessage("Password updated successfully");
		response.setData(null);

		return ResponseEntity.ok(response);
	}


}
