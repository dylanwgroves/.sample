

/* Basics ______________________________________________________________________

	Project: Spotlight Tanzania
	Purpose: Import and basic cleaning of village sample
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
	
/* Load Data ___________________________________________________________________*/	

	use "$spotlight/01 Data/06 Final Data/spotlight_master_clean.dta", clear
	
/* Randomize ___________________________________________________________________*/

	set seed 1956 
	
	gen rand1 = .
	gen rand2 = .
	gen rank = .

	replace rand1 = runiform()
	replace rand2 = runiform()
	
	sort block_uid rand1 rand2 
	bys block_uid : replace rank = _n
	
	gen treat_`i' = .
		replace treat_`i' = 1 if rank == 1
		replace treat_`i' = 0 if rank == 2

	keep village_uid block_uid treat* 
	
	
/* Export ______________________________________________________________________*/

	save "${spotlight}/01 Data/06 Final Data/spotlight_ri.dta", replace