	
/* Overview ______________________________________________________________________

Project: Wellspring Tanzania, Audio Screening
Purpose: Sampling Sheets for Mobilizers to mobilize friends
Author: beatrice montano, bm2955@columbia.edu
Date: 2020/01/21

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

	use "X:\Box Sync\19_Community Media Endlines\07_Questionnaires & Data\07_AS\05_data_encrypted\02_survey\03_clean\audio_screening_survey_pilot_master.dta", clear


/* Extract Data ________________________________________________________________*/

	gen id_village_n = substr(id,1,6)
	gen id_resp_n = resp_name 
	

/* Keep Certain Variables ______________________________________________________*/


	*keep id_* resp_name comsample*
	
	gen id_district_n = ""
	gen p_resp_name_new = ""


/* Select Closes Friend (Remove if Family Member) ______________________________
			
	gen     relationship1_family = 0
	replace relationship1_family = 1 if 	comsample_1_rltn == 1  | comsample_1_rltn == 2  | ///
											comsample_1_rltn == 3  |  ///
											 comsample_1_rltn == 12 | ///
											comsample_1_rltn == 16 | comsample_1_rltn == 17 | comsample_1_rltn == 18
	
	gen relationship2_family = 0 
	replace relationship2_family = 1 if 	comsample_2_rltn == 1  | comsample_2_rltn == 2  | ///
											comsample_2_rltn == 3  |  ///
											 comsample_2_rltn == 12 | ///
											comsample_2_rltn == 16 | comsample_2_rltn == 17 | comsample_2_rltn == 18

	gen name1 = comsample_1_name 
	replace name1 = "" if relationship1_family == 1 
	
	gen relationship1 = comsample_1_rltn
	replace relationship1 = . if relationship1_family == 1 
	lab val relationship1 s33q2_r
	
	gen name2 = comsample_2_name
	replace name2 =  "" if relationship2_family == 1 

	gen relationship2 = comsample_2_rltn
	replace relationship2 = . if relationship2_family == 1 
	lab val relationship2 s33q2_r

	replace name1 = name2 if name1=="" & name2!=""
	replace relationship1 = relationship2 if name1 == name2
	replace name2 = "" if name1 == name2
	replace relationship2 = . if name2==""

/* Generate list of Original + Partner + Friends (maybe eligible) ______________*/
	
	decode relationship1, gen(relationship_1)
	decode relationship2, gen(relationship_2)

	replace relationship_1 = "A person who lives nearby" if relationship_1 == "A person who lives nearbye"
	replace relationship_2 = "A person who lives nearby" if relationship_2 == "A person who lives nearbye"

	local myvar id_village_n id_resp_n name1 relationship_1  name2  relationship_2
	foreach var of local myvar {
	local fmt: format `var'
	local fmt: subinstr local fmt "%" "%-"
	format `var' `fmt'
	}

	drop relationship1
	rename relationship_1 relationship1
	drop relationship2
	rename relationship_2 relationship2
	rename id_district_n districtName
	rename id_village_n villageName
	rename id_resp_uid respondentID
	rename id_resp_n respondentName
	rename p_resp_name_new partnerName

	replace relationship1 = "Friends" if relationship1 == "A friend you spend your free time with"
	replace relationship2 = "Friends" if relationship2 == "A friend you spend your free time with"
	
	replace relationship1 = "Neighbor" if relationship1 == "A person who lives nearby"
	replace relationship2 = "Neighbor" if relationship2 == "A person who lives nearby"

	replace relationship1 = "Friend of prayer" if relationship1 == "A friend you go to church/mosque with"	
	replace relationship2 = "Friend of prayer" if relationship2 == "A friend you go to church/mosque with"
	
	replace relationship1 = "Community leader" if relationship1 == "Your community leader"	
	replace relationship2 = "Community leader" if relationship2 == "Your community leader"	
	
	sort districtName villageName respondentID respondentName 

	/* Save overall list */
	preserve
	
	order districtName villageName respondentID respondentName partnerName name1 relationship1 name2 relationship2
	keep  villageName respondentID respondentName partnerName name1 relationship1 name2 relationship2
	
	stop
	rename name1 friend1 
	rename name2 friend2
	
	export excel using ///
				"${user}/Box Sync/19_Community Media Endlines/02_Project and Survey Management/02 Planning/Training Plan/Training Manual/Spillover/01_Friends/pfm_friends_list1_pilot.xls" ///
				, firstrow(var) replace
	
	restore
*/	
/* Generate list of Respondents + empty columns for eligibility criteria _______*/
	
	replace village_id = subinstr(village_id, "-", "_",.)


	order  village_id resp_id id_resp_n
	keep   village_id resp_id id_resp_n
	
	sort village_id resp_id id_resp_n
	sort village_id resp_id id_resp_n
	
	gen note = ""
	
	/* Save conditions list */
	export excel using ///
			     "${user}/Box Sync/19_Community Media Endlines/02_Project and Survey Management/02 Planning/Training Plan/Training Manual/Spillover/01_Friends/pfm_friends_list2_pilot2.xls" ///
				 , firstrow(var) replace


	
