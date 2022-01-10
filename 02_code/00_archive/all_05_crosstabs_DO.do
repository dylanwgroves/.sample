
/* Load Data ____________________________________________________________________*/

cap use "X:/Box Sync/Dissertation - Spotlight/01 Data/06 Final Data/spotlight_survey_all_final.dta", clear
cap use "X:/Box/Dissertation - Spotlight/01 Data/06 Final Data/02_main/spotlight_survey_all_final.dta", clear



/* Get only DO Data ____________________________________________________________*/
*gen id = svy_village_uid
keep svy_* resp_* do_* uid block journo_*
rename do_* *
keep if resp_target == 0 
gen id = svy_village_uid


/* Clean _______________________________________________________________________*/

order start_date_txt svy_village_uid block treat journo_visit current_score gov_score svy_village_n svy_region_n svy_enum resp_target 
sort block treat

bys block: gen block_num = _N

* create dummies 

lab def win -1 "Lose vs Pair" 0 "Tie" 1 "Win vs Pair"
lab def dum 0 "0 or Less" 1 "> 0"


rename gov_score_other gov_score_othgov

foreach type in vc wc bur district mp ministry rc othgov {

	rename gov_score_`type' `type'_score 

}

rename oth_score_other oth_score_othngo
rename oth_score_privatebiz oth_score_prvtbiz

foreach type in ngo prvtbiz othctz othngo {

	rename oth_score_`type' `type'_score

}


foreach type in prob current gov vill oth ///
				vc wc bur district mp ministry rc othgov ///
				ngo prvtbiz othctz othngo {
	
	* Dummy variable
	gen `type'_dum = (`type'_score > 0)
	lab val `type'_dum dum
	
	* Matched-pair winner
	bys block: egen max_`type'_score = max(`type'_score)
	bys block: egen min_`type'_score = min(`type'_score)

	gen `type'_win = 1 if `type'_score == max_`type'_score
		replace `type'_win = -1 if `type'_score == min_`type'_score
		replace `type'_win = 0 if `type'_score == max_`type'_score & `type'_score == min_`type'_score 
		replace `type'_win = . if block_num == 1
	lab val `type'_win win
	
}

lab var journo_heard "Any leader heard news report"
lab var journo_visit "Any leader aware of journo visit"
lab var journo_any "Any leader heard report OR aware of visit"

lab var prob_score "Original Problem Score (0-10)"
lab var prob_dum "Original Problem > 0"
lab var prob_win "Original Problem > Matched-pair"

lab var current_score "Change in Problem (-10-10)"
lab var current_dum "Change in Problem > 0"
lab var current_win "Change in Problem > Matched-pair"

lab var gov_score "Gov Response (0-10)"
lab var gov_dum "Gov Response > 0"
lab var gov_win "Gov Response > Matched-pair"

lab var vill_score "Villager Response (0-10)"
lab var vill_dum "Villager Response > 0"
lab var vill_win "Villager Response > Matched-pair"

lab var oth_score "NGO Response (0-10)"
lab var oth_dum "NGO Response > 0"
lab var oth_win "NGO Response > Matched-pair"


/* First Stage _________________________________________________________________*/

tab journo_visit treat, col
tab journo_heard treat, col
tab journo_any treat, col

/* Report Card Results _________________________________________________________*/

foreach type in prob current gov vill oth ///
				vc wc bur district mp ministry rc othgov ///
				ngo prvtbiz othctz othngo {
				
	foreach var in score dum win {
	
	di "************************************************"
	di "******* VARIABLE TYPE IS `var'_`type' **********"
	di "************************************************"
	
		*tab `type'_`var' treat, col
		*tabstat `type'_`var', by(treat)
		qui regress `type'_`var' treat i.block
		estimates store `type'_`var'
	}
	
	estimates table `type'_score `type'_dum `type'_win, keep(treat) b se p
	estimates clear

}
STOP





stop
/* Current situation ____________________________________________________________

On a scale from -10 (much worse) to 0 (no change) to 10 (totally solved), 
how would you rate the scale of the original problem in the village?

*/

tab prob_score treat, col
tabstat prob_score, by(treat)
qui regress prob_score treat i.block 
estimates store prob_store

stop

* Dummy (greater than 0)
tab prob_dum 

* Matched-pair winner (better than matched pair)
tab prob_win

*replace current_score = 0 if current_score < 0

tab current_score treat, col
bys svy_station: tabstat current_score, by(treat)
reg current_score treat i.block prob_score

tab current_score_dum treat, col
reg current_score_dum treat i.block

tab winner treat, col
reg winner treat i.block




/* where are these -8 and -5 coming from? */

tab vill_score treat, col
tabstat vill_score, by(treat)
reg vill_score treat i.block

tab vill_score_other treat, col
tabstat vill_score_other, by(treat)


tab vill_score_dum treat, col
reg vill_score_dum treat i.block


*government
tab gov_score treat, col
tabstat gov_score, by(treat)
reg gov_score treat i.block prob_score

reg gov_score_dum treat i.block 
	
tab gov_score_other treat, col
tabstat gov_score_other, by(treat)
reg gov_score_other treat i.block

tab gov_winner treat, col
reg gov_winner treat i.block


	estimates table vc wc bur district mp ministry rc other, keep(treat) b se p
	estimates clear
	

*other
tab oth_score treat, col
tabstat oth_score, by(treat)
reg oth_score treat i.block

tab oth_score_other treat, col
tabstat oth_score_other, by(treat)
reg oth_score_other treat i.block


tab oth_score_dum treat, col


foreach type in ngo privatebiz othctz other {

	*tab oth_score_`type' treat, col
	reg oth_score_`type' treat i.block


}




