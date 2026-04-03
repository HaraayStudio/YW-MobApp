package com.haraay.ywarchitects.model;


public enum StageName {

    // 🔹 DESIGN PHASE
    CONCEPT_DESIGN,
    FINAL_DRAWINGS,
    
    DOCUMENTATION_STAGE,

    // 🔹 PRE-PERMISSION WORK
    NOC_PREPARATION,
    SURVEY_LAND_RECORDS,

    // 🔹 ⭐ MAIN BUILDING PERMISSION PHASE
    BUILDING_PERMISSION,          // Parent stage for approval workflow

    // 🔹 BUILDING PERMISSION SUB-STAGES
    BUILDING_PERMISSION_INWARD,
    BUILDING_PERMISSION_SCRUTINY,
    BUILDING_PERMISSION_SANCTION,

    // 🔹 POST-SANCTION TECHNICAL APPROVALS
    SETBACK_APPROVAL,
    PLINTH_CHECKING,

    // 🔹 FSI / TDR
    TDR_GENERATION,
    TDR_UTILIZATION,
    
    
    TDR_FSI_STAGE,


    // 🔹 CONSTRUCTION
    CONSTRUCTION_EXECUTION,

    // 🔹 PROJECT COMPLETION
    COMPLETION_PROCESS
}










//package com.haraay.ywarchitects.model;
//
///**
// * ═══════════════════════════════════════════════════════════════════
// * StageName — Top-level (PARENT) stage identifiers
// *
// * Rules:
// *  - Every entry here is a PARENT stage or a standalone stage.
// *  - Stages that have child sub-stages are marked with ★ PARENT.
// *  - Simple stages (no children) are marked with ◆ STANDALONE.
// *  - Child-level names live in their own enum files below.
// * ═══════════════════════════════════════════════════════════════════
// */
//public enum StageName {
//
//    // ─────────────────────────────────────────────────────────────
//    // PHASE 1 — DESIGN
//    // ─────────────────────────────────────────────────────────────
//
//    /** ◆ STANDALONE — Concept drawings, massing, basic floor plans */
//    CONCEPT_DESIGN,
//
//    /** ◆ STANDALONE — Final architectural drawings + legal docs */
//    DETAILED_DESIGN,
//
//    /** ◆ STANDALONE — Final drawings, 7/12 extract, demarcation, POA */
//    DOCUMENTATION,
//
//    // ─────────────────────────────────────────────────────────────
//    // PHASE 2 — NOC & PERMISSIONS
//    // ─────────────────────────────────────────────────────────────
//
//    /**
//     * ★ PARENT — Building Permission NOC Stage.
//     * Children defined in: {@link BuildingPermissionSubStage}
//     *   → WATER_NOC
//     *   → DRAINAGE_NOC
//     *   → GARDEN_NOC
//     *   → FIRE_NOC
//     *   → ELEVATION_HEIGHT_NOC
//     *   → CD_WASTE_NOC
//     */
//    BUILDING_PERMISSION,
//
//    // ─────────────────────────────────────────────────────────────
//    // PHASE 3 — SURVEY & SUBMISSION
//    // ─────────────────────────────────────────────────────────────
//
//    /** ◆ STANDALONE — Demarcation, tree survey, DP Abhipray */
//    SURVEY_AND_LAND_RECORDS,
//
//    /**
//     * ★ PARENT — Inward submission, scrutiny, challan, sanction.
//     * Children defined in: {@link BuildingPermissionScrutinySubStage}
//     *   → INWARD_SUBMISSION
//     *   → ONLINE_INWARD
//     *   → SITE_VISITS
//     *   → PRE_DCR_DRAWING
//     *   → DRAWING_SCRUTINY
//     *   → CHALLAN_AND_PAYMENT
//     *   → DEMAND_SHEET_ENTRY
//     *   → SANCTION_NUMBER_GENERATION
//     *   → SANCTION_COPY_COLLECTION
//     */
//    BUILDING_PERMISSION_SCRUTINY,
//
//    // ─────────────────────────────────────────────────────────────
//    // PHASE 4 — POST-SANCTION APPROVALS
//    // ─────────────────────────────────────────────────────────────
//
//    /** ◆ STANDALONE — Application, sanctioned plan, commencement cert, total station survey */
//    SETBACK_APPROVAL,
//
//    /** ◆ STANDALONE — Application, structural cert, NA order, NOC compliance */
//    PLINTH_CHECKING,
//
//    // ─────────────────────────────────────────────────────────────
//    // PHASE 5 — FSI / TDR
//    // ─────────────────────────────────────────────────────────────
//
//    /**
//     * ★ PARENT — TDR generation and utilization.
//     * Children defined in: {@link TdrSubStage}
//     *   → TDR_GENERATION
//     *   → TDR_UTILIZATION
//     */
//    TDR_FSI,
//
//    // ─────────────────────────────────────────────────────────────
//    // PHASE 6 — CONSTRUCTION
//    // ─────────────────────────────────────────────────────────────
//
//    /** ◆ STANDALONE — Excavation, foundation, superstructure, services, finishing */
//    CONSTRUCTION,
//
//    // ─────────────────────────────────────────────────────────────
//    // PHASE 7 — COMPLETION
//    // ─────────────────────────────────────────────────────────────
//
//    /**
//     * ★ PARENT — Final site inspections, certificates, completion approval.
//     * Children defined in: {@link CompletionSubStage}
//     *   → COMPLETION_APPLICATION
//     *   → SITE_INSPECTIONS
//     *   → STRUCTURAL_STABILITY_CERT
//     *   → FINAL_NOCS
//     *   → SOLAR_CERTIFICATE
//     *   → RAINWATER_HARVESTING_CERT
//     *   → LIFT_NOC
//     *   → STP_CERTIFICATE
//     *   → CONSENT_TO_OPERATE
//     *   → COMPLETION_CERT_APPROVAL
//     *   → FINAL_OUTWARD
//     */
//    COMPLETION_PROCESS;
//
//
//    // ─────────────────────────────────────────────────────────────
//    // HELPERS
//    // ─────────────────────────────────────────────────────────────
//
//    /**
//     * Returns true if this stage is a PARENT (has child sub-stages).
//     */
//    public boolean isParent() {
//        return this == BUILDING_PERMISSION
//            || this == BUILDING_PERMISSION_SCRUTINY
//            || this == TDR_FSI
//            || this == COMPLETION_PROCESS;
//    }
//
//    /**
//     * Returns true if this stage is STANDALONE (no children).
//     */
//    public boolean isStandalone() {
//        return !isParent();
//    }
//
//    /**
//     * Returns the display order for this stage in the project timeline.
//     */
//    public int getDisplayOrder() {
//        return this.ordinal() + 1;
//    }
//}
//
//
//
