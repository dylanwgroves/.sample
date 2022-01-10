

/* Basics ______________________________________________________________________

	Project: Spotlights Tanzania
	Purpose: Import and basic cleaning of village sample
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
	global spotlight "X:\Box Sync\Dissertation - Spotlight"
	
	do "X:/Box Sync/Dissertation - Spotlight/02 Code/spotlight_00_paths.do"
	
	
/* Load Data ___________________________________________________________________*/	

	insheet using "${spotlights_data}/01_raw/spotlights_sample.csv", clear

	
/* Clean _______________________________________________________________________*/

	* Drop if no radio station
	drop if radiostation == ""
	
	* Split Longitude and Latitude
	drop longtitude latitude
	
	split longitude, p(", ")
	drop longitude
	rename longitude1 latitude
	rename longitude2 longitude 
	
	* Clean wrong stuff
	*list longitude if missing(real(longitude)) // Identify
	replace longitude = "36.1724070" if longitude == "36. 1724070"
	replace longitude = "36.3100074" if longitude == "36,3100074"
	replace longitude = "35.6385345" if longitude == "35. 6385345"
	replace longitude = "35.7284158" if longitude == "357284158"
	replace longitude = "35.9650678" if longitude == "359650678"
	destring longitude, replace


	*list latitude if missing(real(latitude)) // Identify
	replace latitude = "" if latitude == "NIL"
	destring latitude, replace
	sort latitude
	
	* Split Longitude and Latitude
	split longitude_capital, p(", ")
	drop longitude_capital
	rename longitude_capital1 latitude_capital
	rename longitude_capital2 longitude_capital
	
	* Radio Station
	replace radiostation = "Dodoma FM" if radiostation == "Dodoma Fm"
	rename radiostation station_n 
	encode station_n, gen(station_c)
	gen station_uid = station_c

	* Region
	replace region = "Dodoma" if region == "Dodoma "
	replace region = "Geita" if region == "Geita "
	rename region region_n 
	gen region_c = station_c
	gen region_uid = region_c
		
	* District
	replace district = "Chamwino" if district == "Chamwino "
	replace district = "Malinyi" if district == "Mallinyi"
	replace district = "Mkinga" if district == "Mkinga "
	replace district = "Mtwara" if district == "Mtwara MJINI"
	replace district = "Siha" if district == "Siha "
	rename district district_n
	
	gen rand_d = runiform()
	bysort station_c (district_n) : gen dum = 1 if _n == 1
	bysort station_c (district_n) : replace dum = 1 if district_n[_n-1] != district_n
	bysort station_c (district_n) : gen district_c = sum(dum)
	
	egen district_uid = concat(station_c district_c), p(_)

	* Ward
	gen rand_w = runiform()
	rename ward ward_n
	sort station_c district_c rand_w
	bys station_c district_c: gen ward_c = _n
	
	egen ward_uid = concat(district_uid ward_c), p(_)

	
	* Village
	gen rand_v = runiform()
	rename village village_n
	gen village_c = ward_c // All wards have only one village_c
	
	gen village_uid = ward_uid
	
	* Treatment
	gen treat = .
	replace treat = 0 if treatmentassignment == "Control"
	replace treat = 1 if treatmentassignment == "Treatment"
	lab def treat 0 "Control" 1 "Treatment"
	lab val treat treat
	drop treatmentassignment
	
	* Specific Block
	egen block_uid = concat(station_uid block), p(_)
	
	* Population
	foreach var in male female households {
		tostring `var', replace
		replace `var' = subinstr(`var',",","",.)
		destring `var', gen(vill_pop`var')
	}
		gen vill_popmale_ln = ln(vill_popmale)
		gen vill_popfemale_ln = ln(vill_popfemale)
		gen vill_pophh_ln = ln(vill_pophouseholds)
	
	* new villages
	rename new vill_new
		replace vill_new = 0 if vill_new != 1

	* Problem
	rename problem problem_specific
	
	gen problem = ""
		replace problem = "Health" if problem_specific == "Health"
		replace problem = "Education" if problem_specific == "School" | problem_specific == "Education"
		replace problem = "Water" if problem_specific == "Water"
		replace problem = "Transport" if problem_specific == "Infrastructure"
		replace problem = "Other" if 	problem_specific == "Fishing" | ///
										problem_specific == "Mining" | ///
										problem_specific == "Police" | ///
										problem_specific == "Toilets" | ///
										problem_specific == "Wildlife"
											
	label define problem 1 "Water" 2 "Health" 3 "Education" 4 "Transport" 5 "Other"
	encode problem, gen(problem_general) label(problem)
	drop problem

	
	tab problem_general, gen(problem_)
		rename problem_1 problem_education
		rename problem_2 problem_health
		rename problem_3 problem_other
		rename problem_4 problem_transport
		rename problem_5 problem_water
		
		
	* Politics
	encode diwanipart, gen(ward_party_diw_15)
		drop diwanipart
		
		gen ward_ccm_diw_15 = (ward_party_diw_15 == 1)
			replace ward_ccm_diw_15 = . if ward_party_diw_15 == .
		
	encode mpparty, gen(dist_party_mp_15)
		label values dist_party_mp_15 ward_party_diw_15
		
		gen dist_ccm_mp_15 = (dist_party_mp_15 == 1)
			replace dist_ccm_mp_15 = . if dist_party_mp_15 == .
	
	foreach var of varlist president mp diwani {
		replace `var' = subinstr(`var', "%", "",.) 
		replace `var' = "." if `var' == "NIL"
	}
	
	destring diwani, gen(ward_ccmvote_diw_15) percent
	destring president, gen(dist_ccmvote_prez_15) percent
	destring mp, gen(dist_ccmvote_mp_15) percent
	drop diwani president mp
	
	foreach var of varlist ward_ccmvote_diw_15 dist_ccmvote_prez_15 dist_ccmvote_mp_15 {
		replace `var' = `var'/100
	}
	
	* Implementation
	gen implement_broadcast = 1 if status == "Aired"
		replace implement_broadcast = 1 if status != "Aired"
		drop status
		
	* Drop
	drop 	success	followup howfartogo transpotproposed proposedcost ///
			responsefromcallstothevillage notes talktodistrictlevel textmessages ///
			pictures websitepost problemnotes presidentccm mpparty ///
			politicalpartyofdawani politicalpartyofmwinyikiti ccmvote population ///
			male female households dum neemasupdates
			
	* Create Unique ID
	gen svy_village_uid = id
	
/* Export ______________________________________________________________________*/

	save "${spotlights_data}/03_final/spotlights_sample_clean.dta", replace

	export excel using "${spotlights_data}/03_final/spotlight_sample_clean.xlsx", ///
						firstrow(variables) nolabel replace

