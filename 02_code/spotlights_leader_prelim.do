
/* Load Data ____________________________________________________________________*/

use "X:/Box Sync/Dissertation - Spotlight/01 Data/06 Final Data/spotlight_survey_all_final.dta", clear // FOR DYLAN 
*use "X:/Box/Dissertation - Spotlight/01 Data/06 Final Data/02_main/spotlight_survey_all_final.dta", clear // FOR NEEMA

gen id = svy_village_uid

drop if svy_village_uid == 92

encode svy_station, gen(svy_station_uid)
gen cluster = svy_village_uid


/* Drop Direct Observation __________________________________________________________*/

drop if resp_target == 0
drop do_*


/* Merge RI ____________________________________________________________________*/

	merge n:1 id using "${spotlights_data}/03_final/spotlights_ri.dta", gen(_merge_ri)

	
/* Save ________________________________________________________________________*/

	save "${spotlights_data}/03_final/spotlights_leader_analysis.dta", replace
	
stop


/* First Stage _________________________________________________________________*/

tab journo_visit treat, col
tab journo_heard treat, col
tab journo_any treat, col
tab aware_journolikely treat, col
reg aware_journolikely treat i.block, cluster(cluster)

stop



stop
/* Core Results _________________________________________________________________*/

bys resp_target: tab govresp_solved treat, col

tab govresp_solved_long  treat, col
stop
recode govresp_solved_long (1 = 0)(2 = 1)(3 = 2)
reg govresp_solved_long treat i.block if resp_target != 1, cluster(cluster)

bys govresp_solved: tab govresp_who treat, col

tab  govresp_actions_pct treat if resp_target == 1, col


* meets
tab meet_any treat, col
reg meet_any treat i.block, cluster(svy_village_uid)

replace meet_number = . if meet_number == -999
reg meet_number treat i.block, cluster(svy_village_uid)

tab meet_number treat, col
	tabstat meet_number, by(treat)
tab meet_citizens treat, col
	tabstat meet_citizens, by(treat)

	
stop	
*
foreach var of varlist visits_any_* {
	tab `var' treat, col
}



reg effort_citizens treat i.block, cluster(cluster)
replace effort_citizens_prop = 0 if effort_citizens == 0
reg effort_citizens_prop treat i.block, cluster(cluster)

foreach var of varlist finance_any_govnone finance_any_ministry {

	replace `var' = 0 if finance_any_gov == 0
	tab `var' treat, col

}

foreach var of varlist finance_any_citizens finance_any_ngos finance_any_gov {
	tab `var' treat, col
	reg `var' treat i.block, cluster(cluster)
}

foreach var of varlist pressure_wc_none pressure_wc_citizens pressure_wc_vc pressure_wc_veo pressure_wc_wc pressure_wc_weo pressure_wc_mp pressure_wc_ngo pressure_wc_dcded pressure_wc_do pressure_wc_ministry pressure_wc_ccm pressure_wc_private pressure_wc_dk pressure_wc_rc pressure_wc_party pressure_wc_other {

	replace `var' = 0 if pressure_who_wc == 0 
	tab `var' treat, col
}


foreach var of varlist pressure_vc_none pressure_vc_citizens pressure_vc_vc pressure_vc_veo pressure_vc_vc pressure_vc_weo pressure_vc_mp pressure_vc_ngo pressure_vc_dcded pressure_vc_do pressure_vc_ministry pressure_vc_ccm pressure_vc_private pressure_vc_dk pressure_vc_rc pressure_vc_party pressure_vc_other {

	replace `var' = 0 if pressure_who_vc == 0 
	tab `var' treat, col
}


foreach var of varlist pressure_mp_none pressure_mp_citizens pressure_mp_vc pressure_mp_veo pressure_mp_wc pressure_mp_weo pressure_mp_mp pressure_mp_ngo pressure_mp_dcded pressure_mp_do pressure_mp_ministry pressure_mp_ccm pressure_mp_private {

	replace `var' = 0 if pressure_who_mp == 0 
	tab `var' treat, col
}


}

foreach var of varlist effort_* {
	tab `var' treat, col
}

* other
tab govresp_other_tot treat, col


bys svy_enum: tab govresp_solved_long treat, col



foreach var of varlist pressure_who_citizens pressure_who_vc pressure_who_veo pressure_who_wc pressure_who_weo pressure_who_mp pressure_who_ngo pressure_who_dcded pressure_who_do pressure_who_ministry pressure_who_party pressure_who_private {

	tab `var' treat, col

}