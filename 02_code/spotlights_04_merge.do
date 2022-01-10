

tempfile dirobs
tempfile master
tempfile data


/* Here ________________________________________________________________________*/

use "X:/Box Sync/Dissertation - Spotlight/01 Data/05 Mid Data/spotlight_survey_all_format.dta", clear 


/* In-person Leader Surveys ____________________________________________________*/

append using "X:/Box Sync/Dissertation - Spotlight/01 Data/05 Mid Data/spotlight_survey_leader_old_format.dta", force


/* DO __________________________________________________________________________*/

append using "X:/Box Sync/Dissertation - Spotlight/01 Data/05 Mid Data/spotlight_survey_DO_format.dta", force 
lab def resp_target 0 "Direct Observation", modify
destring svy_village_uid, replace
save `dirobs', replace


/* Original ____________________________________________________________________*/

import excel "X:\Box Sync\Dissertation - Spotlight\01 Data\04 Raw Data\spotlight_cases.xlsx", sheet("Episodes") firstrow clear
drop if village_uid == 0
rename village_uid svy_village_uid
rename village_n svy_village_n 
rename station_n svy_station
rename ward_n svy_ward_n 
rename district_n svy_district_n
rename region_n svy_region_n 
drop treat
merge 1:n svy_village_uid using `dirobs', gen(merge_cases)

	
* Create update measure for direct observation
egen journo_visit = max(visits_any_journo), by(svy_village_uid)
lab def yesno 1 "Yes" 0 "No"
lab val journo_visit yesno

egen journo_heard = max(aware_listen), by(svy_village_uid)
lab val journo_visit yesno

egen aware_either = rowmax(journo_heard journo_visit)
egen journo_any = max(aware_either), by(svy_village_uid)
lab val journo_any yesno

gen journo_likely_vc = aware_journolikely if resp_target == 1
egen journo_likely = max(journo_likely_vc), by(svy_village_uid)
lab val journo_likely aware_journolikely

tab visits_any_journo treat if resp_target == 1, col
tab aware_listen treat if resp_target == 1, col
tab aware_either treat if resp_target == 1, col

* Create matched pairs
encode svy_station, gen(svy_station_c)
rename block sb_block 
tostring svy_station_c, gen(sb_svy_station)

replace sb_block = sb_svy_station + "_" + sb_block
encode sb_block, gen(block)
drop sb_block



* Save dta
save `data', replace


/* Master ______________________________________________________________________*/

use "${spotlights_data}/03_final/spotlights_sample_clean.dta", clear
	drop block
	merge 1:n svy_village_uid using `data', gen(_merge_master)


/* Save ________________________________________________________________________*/

save "${spotlights_data}/03_final/spotlights_survey_all_final.dta", replace

	