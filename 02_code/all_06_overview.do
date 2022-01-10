

/* Load Data ____________________________________________________________________*/

cap use "X:/Box Sync/Dissertation - Spotlight/01 Data/06 Final Data/spotlight_survey_all_final.dta", clear
*cap use "X:/Box/Dissertation - Spotlight/01 Data/06 Final Data/02_main/spotlight_survey_all_final.dta", clear

/* Enumerators _________________________________________________________________*/

global date_txt "13dec2021"   // <------- YOU MUST SET THE APPROPRIATE DATE
global date td(13122021) // <------- YOU MUST SET THE APPROPRIATE DATE

cap local dailyhfc_file "X:\Box Sync\Dissertation - Spotlight\01 Data\10_Survey Checks\spotlights_checks_all"
cap local backcheck_file "X:\Box Sync\Dissertation - Spotlight\01 Data\10_Survey Checks\spotlights_backchecks_all"

tostring svy_village_uid, gen(sb_uid)
replace uid = sb_uid if merge_cases == 1

* Count total number of surveys collected
	preserve
		egen count = count(uid)
		egen count_svy = count(uid) if resp_target != 0
		egen count_vc = count(uid) if resp_target == 1
		egen count_vcm = count(uid) if resp_target == 2
		egen count_veo = count(uid) if resp_target == 3
		egen count_do = count(uid) if resp_target == 0 
		
		foreach type in svy vc vcm veo do {
			egen max_count_`type' = max(count_`type')
			replace count_`type' = max_count_`type'
			drop max_count_`type'
		}
		
		gen rank = _n
		sort uid
		keep if rank == 1
		keep startdate count count*
		export excel using "`dailyhfc_file'", sheet("total complete") firstrow(variables) sheetreplace
	restore
	
* Count number of surveys by village
	preserve
		bysort svy_village_n: egen count = count(uid)
		bysort svy_village_n: egen count_svy = count(uid) if resp_target != 0
		bysort svy_village_n: egen count_vc = count(uid) if resp_target == 1
		bysort svy_village_n: egen count_vcm = count(uid) if resp_target == 2
		bysort svy_village_n: egen count_veo = count(uid) if resp_target == 3
		bysort svy_village_n: egen count_do = count(uid) if resp_target == 0

		foreach type in svy vc vcm veo do {
			if _N == 0 continue
			egen max_count_`type' = max(count_`type'), by(svy_village_n)
			replace count_`type' = max_count_`type'
			drop max_count_`type'
		}
		duplicates drop svy_village_uid, force
		keep svy_village_uid block svy_village_n svy_ward_n svy_district_n svy_region_n svy_enum count count_*
		sort svy_village_uid
		export excel using "`dailyhfc_file'", sheet("surveys per village") firstrow(variables) sheetreplace
	restore

	
* Count number of survey collected by each FO
	preserve
		bysort svy_enum: egen count = count(uid)
		bysort svy_enum: egen count_svy = count(uid) if resp_target != 0
		bysort svy_enum: egen count_vc = count(uid) if resp_target == 1
		bysort svy_enum: egen count_vcm = count(uid) if resp_target == 2
		bysort svy_enum: egen count_veo = count(uid) if resp_target == 3
		bysort svy_enum: egen count_do = count(uid) if resp_target == 0

		foreach type in svy vc vcm veo do {
			egen max_count_`type' = max(count_`type'), by(svy_enum)
			replace count_`type' = max_count_`type'
			drop max_count_`type'
		}
		duplicates drop svy_enum, force
		sort svy_enum
		keep svy_enum  count count_*
		sort svy_enum
		export excel using "`dailyhfc_file'", sheet("surveys per FO") firstrow(variables) sheetreplace
	restore

	
* Duplicate uid
	preserve
		sort uid
		duplicates tag uid, gen(dup_uid)
		keep if dup_uid > 0 
		keep uid startdate svy_village_uid svy_enum dup_uid
		cap export excel using "`dailyhfc_file'", sheet("duplicates") firstrow(variables) sheetreplace
   restore
   
* List survey length	
	preserve 
		gen too_short=1 if survey_length < 25
		gen too_long=1 if survey_length > 120
		keep submissiondate uid svy_village_n resp_target svy_enum svy_village_n survey_length too_short too_long 
		sort uid	
		export excel using "`dailyhfc_file'", sheet("survey length") firstrow(variables) sheetreplace
	restore
	
   
*Check answers coded as"other" & comments FROM SURVEY
	preserve
		local other resp_profession_oth govresp_actions_other govres_oth_oth_txt visits_other_name effort_citizens_oth_oth ///
					aware_supportjourno_txt
		keep submissiondate svy_enum uid resp_target svy_village_uid `other'
		sort uid
		export excel using "`dailyhfc_file'", sheet("SVY_txt") firstrow(varlabels) sheetreplace
   restore
   
     
*Check answers coded as"other" & comments from DO
	preserve
		keep if resp_target == 0 
		keep svy_* resp_* do_*
		rename do_* *
		local other prob_overview_text vill_overview_text gov_overview_text oth_overview_text
		keep submissiondate svy_enum resp_target svy_village_uid `other'
		sort svy_village_uid
		export excel using "`dailyhfc_file'", sheet("DO_txt") firstrow(varlabels) sheetreplace
   restore
   
   
*Overall comments
	preserve
		local other comments
		keep submissiondate svy_enum uid resp_target svy_village_uid `other'
		sort uid
		export excel using "`dailyhfc_file'", sheet("comments") firstrow(varlabels) sheetreplace
   restore
   
   
* Support Journalist Why 
	preserve
		local other aware_supportjourno aware_supportjourno_txt
		keep submissiondate svy_enum uid resp_target svy_village_uid `other'
		sort uid
		export excel using "`dailyhfc_file'", sheet("support_journo") firstrow(varlabels) sheetreplace
	restore




   
   
