	
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

	use "X:\Box Sync\19_Community Media Endlines\07_Questionnaires & Data\07_AS\05_data_encrypted\02_survey\03_clean\audio_screening_survey_pilot_output.dta", clear
stop

/* Extract Data ________________________________________________________________*/

	gen id_village_n = substr(id,1,6)
	gen id_resp_n = resp_name 
	gen resp_female = 1 if gender_pull == "Female"
		replace resp_female = 0 if gender_pull == "Male"
		lab def resp_female 0 "Male" 1 "Female"
		lab val resp_female resp_female

/* Keep Certain Variables ______________________________________________________*/


	keep id_* resp_name resp_female 
	
	gen p_id_resp_uid = ""
	gen p_resp_name_new = ""
	gen p_resp_female = .
	

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

	order id_village_n id_resp_uid id_resp_n makesmoney1  p_id_resp_uid p_resp_name_new partner_education partner_makesmoney

	keep  id_village_n id_resp_uid id_resp_n makesmoney1 p_id_resp_uid p_resp_name_new partner_education partner_makesmoney
	
	rename id_village_n villageName
	rename id_resp_uid respondentID
	rename id_resp_n respondentName
	rename p_id_resp_uid partnerID
	rename p_resp_name_new partnerName
	
	sort  villageName   respondentName 
	
	/* Excel export */
	export excel using "${user}/Box Sync/19_Community Media Endlines/02_Project and Survey Management/02 Planning/Training Plan/Training Manual/Spillover/01_Friends/pfm_originalandpartner_pilot.xls" ////
				, firstrow(var) replace


	
