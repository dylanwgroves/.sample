
/* Basics ______________________________________________________________________

	Project: Spotlights
	Purpose: Master
	Author: dylan groves, dylanwgroves@gmail.com
	Date: 2022/01/2020
________________________________________________________________________________*/


/* Introduction ________________________________________________________________*/
	
	clear all	
	clear matrix
	clear mata
	set more off
	global c_date = c(current_date)
	set seed 1956

/* Paths and master ____________________________________________________________*/	

	do "${code}/pfm_.master/00_setup/pfm_paths_master.do"
	do "${code}/pfm_.master/pfm_master.do"

	
/* Prelim ______________________________________________________________________*/

	do "${spotlight_code}/spotlight_01_import_sample.do"

	
/* Balance _____________________________________________________________________*/

	do "${spotlight_code}/spillover_analysis_balance.do"
	
	
/* Analysis ____________________________________________________________________*/

	do "${code}/pfm_spill/pfm_spill_03_analysis.do"
	
/* Tables ______________________________________________________________________*/

	*texdoc do "${code}/pfm_spillovers/pfm_spill_tables_01_balance.texdoc"
	
	* Balance
	texdoc do "${spotlight_code}/spotlight_tables_balance.texdoc"
	

		
	
	
	