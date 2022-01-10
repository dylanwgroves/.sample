	
/* Overview ______________________________________________________________________

Project: Wellspring Tanzania, Audio Screening
Purpose: Analysis Prelimenary Work
Author: dylan groves, dylanwgroves@gmail.com; 
		beatrice montano, bm2955@columbia.edu
Date: 2020/12/23l


	This mostly just subsets the data and does anything else necessary before
	running the analysis
________________________________________________________________________________*/


/* Introduction ________________________________________________________________*/
	
	clear all	
	clear matrix
	clear mata
	set more off
	global c_date = c(current_date)
	
/* Tempfiles ___________________________________________________________________*/	

	tempfile temp_attend

	
/* Load Data ___________________________________________________________________*/	

	use "${data}/03_final_data/pfm_appended_prefix.dta", clear

/* Subset Data _________________________________________________________________*/	
	
	/* Get correct sample */
	keep if sample == "as"
	drop ne_*
	rename as_* *																// Get rid of prefix
	
	
/* Keep Certain Variables ______________________________________________________*/

	keep id_* resp_name resp_female p_id_resp_uid p_resp_name_new p_resp_female
	

/* Identify who to ask makes money question ______________________________*/
	
	gen     makesmoney1 = "-" if resp_female == 0
	gen     partner_makesmoney = "-" if p_resp_female == 0
	
/* Formatting XLS for export ______________________________*/
			
	gen		partner_education = ""
	
	
	local myvar id_resp_n p_resp_name_new
	foreach var of local myvar {
	local fmt: format `var'
	local fmt: subinstr local fmt "%" "%-"
	format `var' `fmt'
	}
	order id_district_n id_village_n id_resp_uid id_resp_n makesmoney1 p_resp_name_new partner_education partner_makesmoney
	keep id_district_n id_village_n id_resp_uid id_resp_n makesmoney1 p_resp_name_new partner_education partner_makesmoney
	
	rename id_district_n districtName
	rename id_village_n villageName
	rename id_resp_uid respondentID
	rename id_resp_n respondentName
	rename p_resp_name_new partnerName
	
	sort districtName villageName   respondentName 
	drop districtName
	
	/* Excel export */
	export excel using "${user}/Box Sync/19_Community Media Endlines/02_Project and Survey Management/02 Planning/Training Plan/Training Manual/Spillover/01_Friends/pfm_friends_background.xls" ////
				, firstrow(var) replace


	
