package com.haraay.ywarchitects.model;

import java.util.ArrayList;
import java.util.List;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.OneToMany;

@Entity
public class Client {
	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	private String name;
	private String email;
	private Long phone;
	private String address;

	@JsonProperty("GSTCertificate")
	private String GSTCertificate;

	@JsonProperty("PAN")
	private String PAN;

	@OneToMany(mappedBy = "client", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
	@JsonIgnoreProperties("client")
	private List<PreSales> preSales = new ArrayList<>();

	@OneToMany(mappedBy = "client", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
	@JsonIgnoreProperties("client")
	private List<PostSales> postSales = new ArrayList<>();

	private String password;

	private String role;

	public Client() {

	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getEmail() {
		return email;
	}

	public void setEmail(String email) {
		this.email = email;
	}

	public Long getPhone() {
		return phone;
	}

	public void setPhone(Long phone) {
		this.phone = phone;
	}

	public String getAddress() {
		return address;
	}

	public void setAddress(String address) {
		this.address = address;
	}

	public String getGSTCertificate() {
		return GSTCertificate;
	}

	public void setGSTCertificate(String gSTCertificate) {
		GSTCertificate = gSTCertificate;
	}

	public String getPAN() {
		return PAN;
	}

	public void setPAN(String pAN) {
		PAN = pAN;
	}

	public List<PreSales> getPreSales() {
		return preSales;
	}

	public void setPreSales(List<PreSales> preSales) {
		this.preSales = preSales;
	}

	public List<PostSales> getPostSales() {
		return postSales;
	}

	public void setPostSales(List<PostSales> postSales) {
		this.postSales = postSales;
	}

	public String getPassword() {
		return password;
	}

	public void setPassword(String password) {
		this.password = password;
	}

	public String getRole() {
		return role;
	}

	public void setRole(String role) {
		this.role = role;
	}

}
