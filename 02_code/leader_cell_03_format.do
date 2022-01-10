

/* Load Data ____________________________________________________________________*/

cap use "X:/Box Sync/Dissertation - Spotlight/01 Data/05 Mid Data/spotlight_survey_cell_clean.dta", clear

/* Drop Unecessary Variables ___________________________________________________*/
	drop deviceid subscriberid simid devicephonenum username caseid problem_sw
	drop idcheck idcheck_1 idcheck_2 idcheck_3 idcheck_4 idcheck_0 idcheck_region idcheck_district idcheck_ward idcheck_village problemcheck


/* Survey Information __________________________________________________________*/

	rename station_pull svy_station 
	rename village_name_pull svy_village_n 
	rename ward_name_pull svy_ward_n 
	rename district_name_pull svy_district_n 
	rename region_name_pull svy_region_n 
	rename problem svy_problem 
	encode treat_pull, gen(sb_treat)
		recode sb_treat (2 = 1 "Treat")(1 = 0 "Control"), gen(treat) 
	rename enum svy_enum 
	rename enum_name svy_enum_n 
	rename id svy_village_uid
	rename consent svy_consent
	tostring resp_target, gen(resp_target_txt)
	
	gen uid = svy_village_uid + "_" + resp_target_txt
		drop resp_target_txt

/* Respondent Information ______________________________________________________*/	
	
	rename resp_profession_1 resp_job_fish
	rename resp_profession_2 resp_job_fishell	
	rename resp_profession_3 resp_job_boat
	rename resp_profession_4 resp_job_ownag
	rename resp_profession_5 resp_job_ownlivestock
	rename resp_profession_6 resp_job_otherag
	rename resp_profession_7 resp_job_otherlive
	rename resp_profession_8 resp_job_construction
	rename resp_profession_9 resp_job_house
	rename resp_profession_10 resp_job_boda
	rename resp_profession_11 resp_job_smallbiz
	rename resp_profession_12 resp_job_othbiz
	rename resp_profession_13 resp_job_casual
	rename resp_profession_14 resp_job_salariedag
	rename resp_profession_15 resp_job_salariednonag
	rename resp_profession_16 resp_job_pension
	rename resp_profession_17 resp_job_teacher
	rename resp_profession_18 resp_job_doctor
	rename resp_profession_19 resp_job_gov
	rename resp_profession_20 resp_job_unemployed
	rename resp_profession_21 resp_job_carpenter
	rename resp_profession_22 resp_job_witchdoctor
	rename resp_profession__222 resp_job_other
	rename resp_profession__999 resp_job_dk
	rename resp_profession__888 resp_job_refuse

	
/* Problem _____________________________________________________________________*/

	rename prob_water_0 prob_water_noprob
	rename prob_water_1 prob_water_missing
	rename prob_water_2 prob_water_broke
	rename prob_water_3 prob_water_unsafe
	rename prob_water_4	prob_water_distance
	rename prob_water_5 prob_water_expensive
	rename prob_water__222 prob_water_other
	
	rename prob_health_0 prob_health_noprob 
	rename prob_health_1 prob_health_clinic 
	rename prob_health_2 prob_health_watelectric 
	rename prob_health_3 prob_health_personnel
	rename prob_health_4 prob_health_distance
	rename prob_health_5 prob_health_expensive
	rename prob_health__222 prob_health_other 

	rename prob_roads_0 prob_roads_noprob 
	rename prob_roads_1 prob_roads_noroad 
	rename prob_roads_2 prob_roads_damage 
	rename prob_roads_3 prob_roads_flooded 
	rename prob_roads_4 prob_roads_quality 
	rename prob_roads_5 prob_roads_unsafe 
	rename prob_roads__222 prob_roads_other
	
	rename prob_fishing_0 prob_fishing_noprob 
	rename prob_fishing_1 prob_fishing_nosupplies 
	rename prob_fishing_2 prob_fishing_nolaw
	rename prob_fishing_3 prob_fishing_violence 
	rename prob_fishing__222 prob_fishing_other
	
	rename prob_mining_0 prob_mining_noprob 
	rename prob_mining_1 prob_mining_unsafe 
	rename prob_mining_2 prob_mining_equipment 
	rename prob_mining_3 prob_mining_money 
	rename prob_mining_4 prob_mining_govsupport 
	rename prob_mining_5 prob_mining_abuse 
	rename prob_mining__222 prob_mining_other 
	
	rename prob_wildlife_0 prob_wildlife_noprob 
	rename prob_wildlife_1 prob_wildlife_attacks
	rename prob_wildlife_2 prob_wildlife_interference 
	rename prob_wildlife_3 prob_wildlife_land 
	rename prob_wildlife__222 prob_wildlife_other 
	
	rename prob_electricity_0 prob_electricity_noprob 
	rename prob_electricity_1 prob_electricity_none 
	rename prob_electricity_2 prob_electricity_notenough 
	rename prob_electricity_3 prob_electricity_unpredict 
	rename prob_electricity_4 prob_electricity_expensive 
	rename prob_electricity_5 prob_electricity_broken 
	rename prob_electricity__222 prob_electricity_other 

	rename prob_other_0 prob_other_none
	rename prob_other_1 prob_other_water
	rename prob_other_2 prob_other_health
	rename prob_other_3 prob_other_schools
	rename prob_other_4 prob_other_roads
	cap rename prob_other_5 prob_other_electric
	
	egen prob_other_tot = rowtotal(prob_other_water prob_other_health prob_other_schools ///
									prob_other_roads prob_other_electric)

/* Government Response _________________________________________________________

Lusekelo says 4_1 and 4_2 need to update government response

NOTE THAT ON 12/1 the problem_other_5 was roads, not electricity. Now it is set to problem_other_4

*/

	* Problem solved
	rename govresp_actions_water_1 govresp_water_wp
	rename govresp_actions_water_2 govresp_water_pipes
	rename govresp_actions_water_3 govresp_water_containers
	rename govresp_actions_water_4 govresp_water_fix
	rename govresp_actions_water_5 govresp_water_catchment
	rename govresp_actions_water_6 govresp_water_othwat
	rename govresp_actions_water__222 govresp_water_other
	rename govresp_actions_water__999 govresp_waterdk
	
	egen govresp_water_tot = rowtotal(govresp_water_wp govresp_water_pipes ///
										govresp_water_containers govresp_water_fix ///
										govresp_water_catchment govresp_water_othwat ///
										govresp_water_other)
		
	gen govresp_water_pct = govresp_water_tot/7

	
	rename govresp_actions_health_1 govresp_health_newclinic
	rename govresp_actions_health_2 govresp_health_watelectric
	rename govresp_actions_health_3 govresp_health_money
	rename govresp_actions_health_4 govresp_health_supplies
	rename govresp_actions_health_5 govresp_health_personnel
	rename govresp_actions_health_6 govresp_health_transport
	rename govresp_actions_health_0 govresp_health_none
	rename govresp_actions_health__222 govresp_healthoth
	rename govresp_actions_health__999 govresp_healthdk

	egen govresp_health_tot = rowtotal(govresp_health_newclinic govresp_health_watelectric ///
										govresp_health_money govresp_health_supplies ///
										govresp_health_personnel govresp_health_transport ///
										govresp_healthoth)
	
	gen govresp_health_pct = govresp_health_tot/7
	
	rename govresp_actions_roads_1 govresp_roads_newroad
	rename govresp_actions_roads_2 govresp_roads_smallrepair
	rename govresp_actions_roads_3 govresp_roads_fullrepair
	rename govresp_actions_roads_0 govresp_roads_none
	rename govresp_actions_roads__222 govresp_roads_other
	rename govresp_actions_roads__999 govresp_roadsdk
	
	replace govresp_roads_smallrepair = 1 if govresp_roads_fullrepair == 1
	
	egen govresp_roads_tot = rowtotal(govresp_roads_newroad govresp_roads_smallrepair ///
										govresp_roads_fullrepair govresp_roads_other)
	
	gen govresp_roads_pct = govresp_roads_tot/4
										
	rename govresp_actions_school_1 govresp_school_newschool
	rename govresp_actions_school_2 govresp_school_facilities
	rename govresp_actions_school_3 govresp_school_money
	rename govresp_actions_school_4 govresp_school_supplies
	rename govresp_actions_school_5 govresp_school_personnel
	rename govresp_actions_school_6 govresp_school_transport
	rename govresp_actions_school_0 govresp_school_none
	rename govresp_actions_school__222 govresp_school_other
	rename govresp_actions_school__999 govresp_schooldk
	
	egen govresp_school_tot = rowtotal(govresp_school_newschool govresp_school_facilities ///
										govresp_school_money govresp_school_supplies ///
										govresp_school_personnel govresp_school_transport govresp_school_other)	
										
										
	gen govresp_school_pct = govresp_school_tot/7

	rename govresp_actions_fishing_1 govresp_fishing_patrols
	rename govresp_actions_fishing_2 govresp_fishing_resources
	rename govresp_actions_fishing_3 govresp_fishing_equipment
	rename govresp_actions_fishing_4 govresp_fishing_criminals
	rename govresp_actions_fishing_5 govresp_fishing_police
	rename govresp_actions_fishing__222 govresp_fishing_other
	rename govresp_actions_fishing__999 govresp_fishingdk
	
	egen govresp_fishing_tot = rowtotal(govresp_fishing_patrols govresp_fishing_resources ///
										govresp_fishing_equipment govresp_fishing_criminals ///
										govresp_fishing_police govresp_fishing_other)
										
	gen govresp_fishing_pct = govresp_fishing_tot/6
	
	rename govresp_actions_electricity_1 govresp_electric_everywhere
	rename govresp_actions_electricity_2 govresp_electric_some
	rename govresp_actions_electricity_3 govresp_electric_newequipment
	rename govresp_actions_electricity_4 govresp_electric_fixequip
	rename govresp_actions_electricity_5 govresp_electric_loweredcost
	rename govresp_actions_electricity_0 govresp_electric_none
	rename govresp_actions_electricity__999 govresp_electricdk
	rename govresp_actions_electricity__222 govresp_electric_other
	
	egen govresp_electricity_tot = rowtotal(govresp_electric_everywhere govresp_electric_some ///
			govresp_electric_newequipment govresp_electric_fixequip ///
			govresp_electric_loweredcost govresp_electric_other)
			
	gen govresp_electricity_pct = govresp_electricity_tot/6
	
	rename govresp_actions_mining_1 govresp_mining_resources
	rename govresp_actions_mining_2 govresp_mining_supplies
	rename govresp_actions_mining_3 govresp_mining_training
	rename govresp_actions_mining_4 govresp_mining_regulations
	rename govresp_actions_mining_5 govresp_mining_economic
	rename govresp_actions_mining_0 govresp_mining_none
	rename govresp_actions_mining__999 govresp_miningdk
	rename govresp_actions_mining__222 govresp_mining_other
	
	egen govresp_mining_tot = rowtotal(govresp_mining_resources govresp_mining_supplies ///
			govresp_mining_training govresp_mining_regulations ///
			govresp_mining_economic govresp_mining_other)
			
	gen govresp_mining_pct = govresp_mining_tot/6

	rename govresp_actions_wildlife_1 govresp_wildlife_resolved
	rename govresp_actions_wildlife_2 govresp_wildlife_money
	rename govresp_actions_wildlife_3 govresp_wildlife_inkind
	rename govresp_actions_wildlife_4 govresp_wildlife_interference
	rename govresp_actions_wildlife_5 govresp_wildlife_spoke
	rename govresp_actions_wildlife_0 govresp_wildlife_none
	rename govresp_actions_wildlife__999 govresp_wildlifedk
	rename govresp_actions_wildlife__222 govresp_wildlife_other
	
	egen govresp_wildlife_tot = rowtotal(govresp_wildlife_resolved govresp_wildlife_money ///
			govresp_wildlife_inkind govresp_wildlife_interference ///
			govresp_wildlife_spoke govresp_wildlife_other)
	
	gen govresp_wildlife_pct = govresp_wildlife_tot/6
						
egen govresp_actions_pct = rowmax(govresp_wildlife_pct govresp_mining_pct govresp_electricity_pct govresp_fishing_pct govresp_roads_pct govresp_health_pct govresp_water_pct)

	gen govresp_solved_long = .
		replace govresp_solved_long = 3 if govresp_solved_yes == 1
		replace govresp_solved_long = 2 if govresp_solved_yes == 0
		replace govresp_solved_long = 1 if govresp_solved_no == 0 
		replace govresp_solved_long = 0 if govresp_solved_no == 1 
		
	lab def govresp_solved_long 0 "No, Never" 1 "No, Not yet" 2 "Yes, partly" 3 "Yes, completely"
	lab val govresp_solved_long govresp_solved_long
		
	* Responsibility
	clonevar govresp_who = govresp_solved_yes_resp 
		replace govresp_who = govresp_solved_no_resp if govresp_who == . 

	
	* Other issues
	rename govresp_oth_wat* govresp_other*

	rename govresp_other_0 govresp_other_none
	rename govresp_other_1 govresp_other_water
	rename govresp_other_2 govresp_other_health
	rename govresp_other_3 govresp_other_schools
	rename govresp_other_4 govresp_other_roads
	cap rename govresp_other_5 govresp_other_electric
	
	egen govresp_other_tot = rowtotal(govresp_other_water govresp_other_health govresp_other_schools ///
									  govresp_other_roads govresp_other_electric)
									  

			
/* Meetings ____________________________________________________________________*/			
	

	replace meet_number = 0 if meet_any == 0
	replace meet_citizens = 0 if meet_any == 0

	
/* Government Visits ___________________________________________________________*/			
	
	rename visits_all_0 visits_any_none
	rename visits_all_1 visits_any_wc 
	rename visits_all_2 visits_any_weo 
	rename visits_all_3 visits_any_dc 
	rename visits_all_4 visits_any_mp 
	rename visits_all_5 visits_any_ngo 
	rename visits_all_6 visits_any_ministry 
	rename visits_all_7 visits_any_party 
	rename visits_all_8 visits_any_journo 

		
/* Financial Contributions _____________________________________________________*/

	rename finance_short_0 finance_any_none
	rename finance_short_1 finance_any_citizens
	rename finance_short_2 finance_any_ngos
	rename finance_short_3 finance_any_gov

	
	rename finance_gov_who__999 finance_any_govdk
	rename finance_gov_who_7 finance_any_ministry 
	rename finance_gov_who_5 finance_any_mp 
	rename finance_gov_who_4 finance_any_district 
	rename finance_gov_who_3 finance_any_ward 
	rename finance_gov_who_2 finance_any_vill 
	rename finance_gov_who_0 finance_any_govnone
	
	rename finance_other_prob_* finance_gov_oth_* 

	foreach type in gov citizens ngos {
	
		rename finance_`type'_oth_0 finance_`type'_oth_none
		rename finance_`type'_oth_1 finance_`type'_oth_water
		rename finance_`type'_oth_2 finance_`type'_oth_health
		rename finance_`type'_oth_3 finance_`type'_oth_schools
		rename finance_`type'_oth_4 finance_`type'_oth_roads
		rename finance_`type'_oth_5 finance_`type'_oth_electric
		rename finance_`type'_oth__222 finance_`type'_oth_other
		rename finance_`type'_oth__888 finance_`type'_oth_dk
	
	}


/* Effort ______________________________________________________________________*/

	rename effort_citizens_oth_0 effort_citizens_oth_none
	rename effort_citizens_oth_1 effort_citizens_oth_water
	rename effort_citizens_oth_2 effort_citizens_oth_health
	rename effort_citizens_oth_3 effort_citizens_oth_schools
	rename effort_citizens_oth_4 effort_citizens_oth_roads
	cap rename effort_citizens_oth_5 effort_citizens_oth_electric
	
/* Media Awareness _____________________________________________________________*/
	
	gen aware_supportjourno_txt = aware_supportjourno_yes 
		replace aware_supportjourno_txt = aware_supportjourno_no 
		
	drop aware_supportjourno_yes 
	drop aware_supportjourno_no
	
/* Pressure ____________________________________________________________________*/

	rename pressure_who_0 pressure_who_none
	rename pressure_who_1 pressure_who_citizens
	rename pressure_who_2 pressure_who_vc 
	rename pressure_who_3 pressure_who_veo 
	rename pressure_who_4 pressure_who_wc 
	rename pressure_who_5 pressure_who_weo
	rename pressure_who_6 pressure_who_mp
	rename pressure_who_7 pressure_who_ngo 
	rename pressure_who_8 pressure_who_dcded
	rename pressure_who_9 pressure_who_do 
	rename pressure_who_11 pressure_who_ministry 
	rename pressure_who_12 pressure_who_party
	rename pressure_who_13 pressure_who_private 
	rename pressure_who__222 pressure_who_other	 
	rename pressure_who__999 pressure_who_dk 
	
	rename pressure_vill_0 pressure_vill_none
	rename pressure_vill_1 pressure_vill_citizens
	rename pressure_vill_2 pressure_vill_vc 
	rename pressure_vill_3 pressure_vill_veo 
	rename pressure_vill_4 pressure_vill_wc 
	rename pressure_vill_5 pressure_vill_weo
	rename pressure_vill_6 pressure_vill_mp
	rename pressure_vill_7 pressure_vill_ngo 
	rename pressure_vill_8 pressure_vill_dcded
	rename pressure_vill_9 pressure_vill_do 
	rename pressure_vill_11 pressure_vill_ministry 
	rename pressure_vill_12 pressure_vill_ccm 
	rename pressure_vill_13 pressure_vill_private 
	rename pressure_vill__999 pressure_vill_dk 	
	
	rename pressure_vc_0 pressure_vc_none
	rename pressure_vc_1 pressure_vc_citizens
	rename pressure_vc_2 pressure_vc_vc 
	rename pressure_vc_3 pressure_vc_veo 
	rename pressure_vc_4 pressure_vc_wc 
	rename pressure_vc_5 pressure_vc_weo
	rename pressure_vc_6 pressure_vc_mp
	rename pressure_vc_7 pressure_vc_ngo 
	rename pressure_vc_8 pressure_vc_dcded
	rename pressure_vc_9 pressure_vc_do 
	rename pressure_vc_11 pressure_vc_ministry 
	rename pressure_vc_12 pressure_vc_ccm 
	rename pressure_vc_13 pressure_vc_private 
	rename pressure_vc__999 pressure_vc_dk 	
	
	rename pressure_wc_0 pressure_wc_none
	rename pressure_wc_1 pressure_wc_citizens
	rename pressure_wc_2 pressure_wc_vc 
	rename pressure_wc_3 pressure_wc_veo 
	rename pressure_wc_4 pressure_wc_wc 
	rename pressure_wc_5 pressure_wc_weo
	rename pressure_wc_6 pressure_wc_mp
	rename pressure_wc_7 pressure_wc_ngo 
	rename pressure_wc_8 pressure_wc_dcded
	rename pressure_wc_9 pressure_wc_do 
	rename pressure_wc_11 pressure_wc_ministry 
	rename pressure_wc_12 pressure_wc_ccm 
	rename pressure_wc_13 pressure_wc_private 
	rename pressure_wc__999 pressure_wc_dk 	
	
	rename pressure_mp_0 pressure_mp_none
	rename pressure_mp_1 pressure_mp_citizens
	rename pressure_mp_2 pressure_mp_vc 
	rename pressure_mp_3 pressure_mp_veo 
	rename pressure_mp_4 pressure_mp_wc 
	rename pressure_mp_5 pressure_mp_weo
	rename pressure_mp_6 pressure_mp_mp
	rename pressure_mp_7 pressure_mp_ngo 
	rename pressure_mp_8 pressure_mp_dcded
	rename pressure_mp_9 pressure_mp_do 
	rename pressure_mp_11 pressure_mp_ministry 
	rename pressure_mp_12 pressure_mp_ccm 
	rename pressure_mp_13 pressure_mp_private 
	rename pressure_mp__999 pressure_mp_dk 	
	
	foreach var of varlist pressure_mp_* {
		replace `var' = 0 if pressure_who_mp == 0
	}

	
/* Conclusion __________________________________________________________________*/
	



/* Save ________________________________________________________________________*/
save "X:/Box Sync/Dissertation - Spotlight/01 Data/05 Mid Data/spotlight_survey_all_format.dta", replace 







