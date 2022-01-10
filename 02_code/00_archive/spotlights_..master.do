
/* Basics ______________________________________________________________________

	Project: Wellspring Tanzania, Audio Screening
	Purpose: Master
	Author: dylan groves, dylanwgroves@gmail.com
	Date: 2021/04/26
________________________________________________________________________________*/


/* Introduction ________________________________________________________________*/
	
	clear all	
	clear matrix
	clear mata
	set more off
	global c_date = c(current_date)
	set seed 1956

/* Paths and master ____________________________________________________________*/	

	foreach user in  "X:" "/Users/BeatriceMontano" "/Users/Bardia" {
					capture cd "`user'"
					if _rc == 0 macro def path `user'
				}
	local dir `c(pwd)'
	global user `dir'
	display "${user}"

	cap assert "$`{globals_set}'" == "yes"
	if _rc!=0 {   
		do "${user}/Documents/pfm_.master/00_setup/pfm_paths_master.do"	
		}
	else { 
		di "Globals have already been set."
	}

	do "${code}/pfm_.master/pfm_master.do"

/* AS prelim ___________________________________________________________________*/

	do "${code}/pfm_audioscreening_efm/02_indices/pfm_as_indices_covars.do"
	do "${code}/pfm_audioscreening_efm/pfm_as_prelim.do"

/* Balance _____________________________________________________________________*/

	do "${code}/pfm_audioscreening_efm/pfm_as_balance.do"
	
/* Analysis ____________________________________________________________________*/

	do "${code}/pfm_audioscreening_efm/pfm_as_analysis.do"
	
/* Tables ______________________________________________________________________*/

	texdoc do "${code}/pfm_audioscreening_efm/pfm_as_tables_balance_short.texdoc"
	
	texdoc do "${code}/pfm_audioscreening_efm/pfm_as_tables_descriptives_em.texdoc"
	
	texdoc do "${code}/pfm_audioscreening_efm/pfm_as_tables_results_fm_em_mid.texdoc"
	texdoc do "${code}/pfm_audioscreening_efm/pfm_as_tables_results_fm_em.texdoc"
	
	texdoc do "${code}/pfm_audioscreening_efm/pfm_as_tables_results_norm_mid.texdoc"
	texdoc do "${code}/pfm_audioscreening_efm/pfm_as_tables_results_norm.texdoc"

	texdoc do "${code}/pfm_audioscreening_efm/pfm_as_tables_results_report_mid.texdoc"
	texdoc do "${code}/pfm_audioscreening_efm/pfm_as_tables_results_report.texdoc"
	
	texdoc do "${code}/pfm_audioscreening_efm/pfm_as_tables_results_priority_mid.texdoc"
	texdoc do "${code}/pfm_audioscreening_efm/pfm_as_tables_results_priority.texdoc"
		
	texdoc do "${code}/pfm_audioscreening_efm/pfm_as_tables_results_ipvlong_ge_mid.texdoc"
	texdoc do "${code}/pfm_audioscreening_efm/pfm_as_tables_results_ipvlong_ge.texdoc"
	
	/* HetFX 
	texdoc do "${code}/pfm_audioscreening_efm/pfm_as_04_tables_04_results_hetfx_fm_mid.texdoc"
	texdoc do "${code}/pfm_audioscreening_efm/pfm_as_04_tables_04_results_hetfx_fm.texdoc"
	*/
	
	/* Appendix */
	texdoc do "${code}/pfm_audioscreening_efm/pfm_as_tables_results_attendanceattrition.texdoc"
	texdoc do "${code}/pfm_audioscreening_efm/pfm_as_tables_balance.texdoc"

	texdoc do "${code}/pfm_audioscreening_efm/pfm_as_tables_appendix_attitudes.texdoc"
	texdoc do "${code}/pfm_audioscreening_efm/pfm_as_tables_appendix_norms.texdoc"
	texdoc do "${code}/pfm_audioscreening_efm/pfm_as_tables_appendix_priority.texdoc"
	texdoc do "${code}/pfm_audioscreening_efm/pfm_as_tables_appendix_reporting.texdoc"
	texdoc do "${code}/pfm_audioscreening_efm/pfm_as_tables_appendix_ge.texdoc"
	texdoc do "${code}/pfm_audioscreening_efm/pfm_as_tables_appendix_ipv.texdoc"
	
	
	