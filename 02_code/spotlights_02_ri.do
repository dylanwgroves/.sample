

/* Basics ______________________________________________________________________

	Project: Spotlights Tanzania
	Purpose: Randomization Inference fro Village Sample
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
	
	do "X:/Box Sync/Dissertation - Spotlight/02 Code/spotlight_00_paths.do"

	
/* Load Data ___________________________________________________________________*/	

	use "${spotlights_data}/03_final/spotlights_sample_clean.dta", clear
	
/* Randomize ___________________________________________________________________*/

	gen rand1 = .
	gen rand2 = .
	gen rank = .
	
	forval i = 1/3000 {
	
		set seed `i'
		
		replace rand1 = runiform()
		replace rand2 = runiform()
		
		sort rand1 rand2 
		bys block_uid : replace rank = _n
		
		gen treat_`i' = .
			replace treat_`i' = 1 if rank == 1
			replace treat_`i' = 0 if rank == 2
			
	}

	keep id village_uid block_uid treat* 
	
	
/* Export ______________________________________________________________________*/

	save "${spotlights_data}/03_final/spotlights_ri.dta", replace