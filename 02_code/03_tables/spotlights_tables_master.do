
/* Basics ______________________________________________________________________

	Project: Spotlights
	Purpose: Master
	Author: dylan groves, dylanwgroves@gmail.com
	Date Created: 2021/08/01
	Date Edited: 2022/01/04
________________________________________________________________________________*/


/* Introduction ________________________________________________________________*/
	
	clear all	
	clear matrix
	clear mata
	set more off
	global c_date = c(current_date)
	set seed 1956

/* Set Globals _________________________________________________________*/

	foreach user in  "X:" {
					capture cd "`user'"
					if _rc == 0 macro def path `user'
				}
	local dir `c(pwd)'
	global user `dir'
	display "${user}"	
	
/* Tables ______________________________________________________________________*/

	texdoc do "${spotlights_code}/03_tables/spotlights_tables_balance.texdoc"
	
	texdoc do "${spotlights_code}/03_tables/spotlights_tables_firststage.texdoc"
	
	
	
	texdoc do "${spotlights_code}/03_tables/spotlights_tables_current.texdoc"


	
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
	
	
	