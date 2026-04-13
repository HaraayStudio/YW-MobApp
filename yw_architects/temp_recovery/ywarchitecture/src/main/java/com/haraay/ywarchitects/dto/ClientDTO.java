package com.haraay.ywarchitects.dto;


import java.util.ArrayList;
import java.util.List;

public class ClientDTO {

	private Long id;
	private String name;
	private String email;
	private Long phone;
	private String address;
	private String GSTCertificate;
	private String PAN;

	// relations
	private List<PreSalesDTO> preSales = new ArrayList<>();
	private List<PostSalesDTO> postSales = new ArrayList<>();

	public ClientDTO() {
	}

	// ================= GETTERS & SETTERS =================

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

	public List<PreSalesDTO> getPreSales() {
		return preSales;
	}

	public void setPreSales(List<PreSalesDTO> preSales) {
		this.preSales = preSales;
	}

	public List<PostSalesDTO> getPostSales() {
		return postSales;
	}

	public void setPostSales(List<PostSalesDTO> postSales) {
		this.postSales = postSales;
	}

}
