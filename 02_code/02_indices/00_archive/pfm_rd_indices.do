

/* Basics ______________________________________________________________________

	Project: Wellspring Tanzania, Radio Distribution Globals
	Purpose: Analysis - Set Globals
	Author: dylan groves, dylanwgroves@gmail.com
	Date: 2020/12/23
________________________________________________________________________________*/


/* Define Globals and globals ___________________________________________________*/
	#d ;
		
		global takeup		/* Takeup */
							rd_receive
							rd_stillhave
							radio_ever
							radio_listen
							radio_listen_hrs
							;
							
		global pint			/* Political Interest */
							ptixpart_interest
							radio_locleader 
							radio_natleader 
							;
							
		global healthknow 	/* Health Knowledge */
							resp_ppe
							healthknow_notradmed 
							healthknow_nowitchcraft 
							healthknow_vaccines 
							healthknow_vaccines_imp 
							;
							
		global gender		/* Gender Equality */
							ge_index 
							ge_work 
							ge_leadership 
							ge_business 
							ge_school
							;
							
		global ipv 			ipv_rej_disobey 
							ipv_norm_rej 
							ipv_report
							;
							
		global fm 			fm_reject
							fm_reject_long
							;
							
		global em 			em_reject_index
							em_reject_religion_dum 
							em_reject_noschool_dum 
							em_reject_pregnant_dum 
							em_reject_money_dum 
							em_record_reject
							em_record_shareany
							em_report
							em_norm_reject_dum
							;
							
		global prej_nbr		/* Prejudice */
							prej_yesnbr_index
							prej_yesnbr_aids 
							prej_yesnbr_homo 
							prej_yesnbr_alcoholic 
							prej_yesnbr_unmarried 
							;
							
		global prej_marry 	prej_kidmarry_index
							prej_kidmarry_nottribe 
							prej_kidmarry_notrelig 
							prej_kidmarry_nottz
							prej_kidmarry_notrural 
							;
							
		global prej_thermo 	prej_thermo_city 
							prej_thermo_chinese 
							prej_thermo_kenyan 
							prej_thermo_out_rel 
							prej_thermo_out_eth
							;
							
		global values	 	/* Values */
							values_tzortribe_dum
							values_urbangood 
							resp_urbanvisit
							resp_religiosity
							;
							
		global ppref	   	/* Political Preferences */
							values_dontquestion
							ptixknow_trustnat 
							ptixknow_trustloc
							ptixknow_trustrel
							ptixpref_global_approve
							ptixpref_respnat
							ptixpref_resploc
							ptixpref_respcom
							;
							
		global ppart 		/* Political Participation */
							ptixpart_villmeet
							ptixpart_collact
							ptixpart_vote
							;
							
		global wpp 			wpp_attitude_dum 
							wpp_norm_dum 
							wpp_behavior 
							;
							
		global hivknow		hivknow_index 
							hivknow_arv_survive 
							hivknow_arv_nospread 
							hivknow_transmit 
							;
							
		global hivdisclose	hivdisclose_index 
							hivdisclose_fam 
							hivdisclose_friend 
							hivdisclose_cowork 
							hivdisclose_nosecret 
							;
							
		global hivstigma 	hivstigma_index 
							hivstigma_notfired 
							hivstigma_yesbus 
							hivstigma_notfired_norm 
							;
		/* Covariates */	
		global cov_always	i.id_village_uid_c									// For partner
							i.block_rd
							;					
		
		
		/* Lasso Covariates */
		global cov_lasso	resp_age resp_female resp_muslim b_resp_standard7 b_resp_married 
							b_resp_religiosity b_resp_literate b_resp_lang_swahili 
							b_resp_numhh b_resp_numkid b_resp_numolder b_resp_numyounger b_resp_numadult 
							b_ge_index b_ge_raisekids b_ge_earning b_ge_leadership b_ge_noprefboy 
							b_fm_reject 
							b_ipv_rej_disobey b_ipv_norm_rej
							b_radio_any
							b_values_likechange b_values_techgood 
							b_values_elders b_values_respectauthority
							b_asset_cell b_asset_tv b_asset_radio_num
							;
							
		#d cr

