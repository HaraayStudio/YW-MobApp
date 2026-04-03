package com.haraay.ywarchitects.website.dto;

public class ProjectSizeDTO {

    private String plotArea;
    private String builtUpArea;
    private String towerFloors;
    private String commercialFloors;

    public ProjectSizeDTO() {}

    public ProjectSizeDTO(String plotArea, String builtUpArea,
                          String towerFloors, String commercialFloors) {
        this.plotArea         = plotArea;
        this.builtUpArea      = builtUpArea;
        this.towerFloors      = towerFloors;
        this.commercialFloors = commercialFloors;
    }

    public String getPlotArea() { return plotArea; }
    public void setPlotArea(String plotArea) { this.plotArea = plotArea; }

    public String getBuiltUpArea() { return builtUpArea; }
    public void setBuiltUpArea(String builtUpArea) { this.builtUpArea = builtUpArea; }

    public String getTowerFloors() { return towerFloors; }
    public void setTowerFloors(String towerFloors) { this.towerFloors = towerFloors; }

    public String getCommercialFloors() { return commercialFloors; }
    public void setCommercialFloors(String commercialFloors) { this.commercialFloors = commercialFloors; }
}