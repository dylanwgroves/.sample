

/* Basics ______________________________________________________________________

	Project: Spotlight Tanzania
	Purpose: Import and basic cleaning of radios sample
	Author: dylan groves, dylanwgroves@gmail.com
	Date Created: 2021/08/01
	Date Edited: 2021/08
________________________________________________________________________________*/


/* Introduction ________________________________________________________________*/
	
	clear all	
	clear matrix
	clear mata
	set more off
	global c_date = c(current_date)
	global spotlight "X:\Box Sync\Dissertation - Spotlight"
	
	
/* Load Data ___________________________________________________________________*/	

	insheet using "${spotlights_data}/01_raw/spotlights_radios.csv", clear

	
/* Keep Selected Radios ________________________________________________________*/

	keep if wns == 1
	

/* Clean _______________________________________________________________________*/

	split latitude, p(", ")
	drop latitude
	destring latitude1, gen(latitude)
	destring latitude2, gen(longitude)
	drop latitude1 latitude2
	
	keep station region district city latitude longitude
	
/* Export ______________________________________________________________________*/

	save "${spotlights_data}/03_final/spotlights_radios_clean.dta", replace
	
	export excel using "${spotlights_data}/03_final/spotlights_radios_clean.xlsx", ///
						firstrow(variables) nolabel replace

	export delimited using "${spotlights_data}/03_final/spotlights_radios_clean.csv", ///
							nolabel replace

