/*****************************************************************************************************
******************************************************************************************************
**                                                                                                  **
**                                   SOUTH ASIA MICRO DATABASE                                      **
**                                                                                                  **
** COUNTRY			NEPAL
** COUNTRY ISO CODE	NPL
** YEAR				2015
** SURVEY NAME		Nepal Annual Household Survey 2015-2016
** SURVEY AGENCY	Central Bureau of Statistics
** RESPONSIBLE		Francisco Javier Parada Gomez Urquiza
** MODIFIED BY		
** Date				12/11/2018
**                                                                                                  **
******************************************************************************************************
*****************************************************************************************************/

/*****************************************************************************************************
*                                                                                                    *
                                   INITIAL COMMANDS
*                                                                                                    *
*****************************************************************************************************/


** INITIAL COMMANDS
	cap log close 
	clear
	set more off
	set mem 800m


** DIRECTORY
	local input "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\NPL\NPL_2015_AHS\NPL_2015_AHS_v01_M"
	local output "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\NPL\NPL_2015_AHS\NPL_2015_AHS_v01_M_v01_A_SARMD"
	glo pricedata "D:\SOUTH ASIA MICRO DATABASE\CPI\cpi_ppp_sarmd_weighted.dta"
	glo shares "D:\SOUTH ASIA MICRO DATABASE\APPS\DATA CHECK\Food and non-food shares\NPL"
	glo fixlabels "D:\SOUTH ASIA MICRO DATABASE\APPS\DATA CHECK\Label fixing"

	
** LOG FILE
	log using "`output'\Doc\Technical\NPL_2015_AHS_v01_M_v01_A_SARMD.log",replace
	
	
/*****************************************************************************************************
*                                                                                                    *
                                   * ASSEMBLE DATABASE
*                                                                                                    *
*****************************************************************************************************/


** DATABASE ASSEMBLEMENT

* PREPARE DATASETS

	use "`input'\Data\Stata\ahsweight7273.dta", clear
	qui compress
	tempfile weights
	save `weights'		
	
	use "`input'\Data\Stata\S00_rc.dta", clear
	qui compress
	tempfile cover
	save `cover'	

	use "`input'\Data\Stata\S01_rc.dta", clear
	ren idcode1 idc
	sort psu hhno idc
	qui compress
	tempfile roster
	save `roster'
	
	use "`input'\Data\Stata\S02_rc.dta", clear
	sort psu hhno
	qui compress
	tempfile housing
	save `housing'
	
	use "`input'\Data\Stata\S03_rc.dta", clear
	keep if foodcode==300
	qui compress
	tempfile food
	save `food'	
	
	use "`input'\Data\Stata\S04a_rc.dta", clear
	keep if nonfoodcode==4100
	qui compress
	tempfile non_food
	save `non_food'
	
	use "`input'\Data\Stata\S04b_rc.dta", clear
	qui compress
	tempfile production
	save `production'	
	
	use "`input'\Data\Stata\S04c_rc.dta", clear
	gen itc2=durable_name
	replace itc2=strtoname(itc2)
	replace itc2=substr(itc2, 1,15)
	drop durable_code durable_name
	reshape wide yesno durable_num received_how yearsago purchase_price current_value, i(psu hhno hhid) j( itc2 ) string
	sum yesno* durable_num* received* yearsago* purchase_price* current_value*, sep(24)
	qui compress
	tempfile durables
	save `durables'	

	use "`input'\Data\Stata\psu_information7273.dta", clear
	
	* MERGE DATASETS AT HOUSEHOLD LEVEL
	use `cover', clear
	merge m:1 psu using `weights'
	drop _merge
	merge 1:1 psu hhno using `housing'
	drop _merge
	merge 1:1 hhid using `durables'
	drop _merge
	merge 1:1 hhid using `food'
	drop _merge
	merge 1:1 hhid using `non_food'
	drop _merge
	qui compress
	tempfile households
	save `households'
	
	* MERGE DATASETS AT INDIVIDUAL LEVEL
	use `roster', clear
	merge m:1 hhid using `households'
	
	rename psu xhpsu 
	rename hhno xhnum
	
	/*****************************************************************************************************
*                                                                                                    *
                                   * STANDARD SURVEY MODULE
*                                                                                                    *
*****************************************************************************************************/

	
** COUNTRY
*<_countrycode_>
	gen str4 countrycode="NPL"
	label var countrycode "Country name"
*</_countrycode_>

** YEAR
*<_year_>
	gen int year=2015
	label var year "Survey year"
*</_year_>


** SURVEY NAME 
*<_survey_>
	gen str survey="AHS-IV"
	label var survey "Survey Acronym"
*</_survey_>


** INTERVIEW YEAR
*<_int_year_>
	gen ye=year(int_yr)
	rename ye int_year
	label var int_year "Year of the interview"
*</_int_year_>
	
	
** INTERVIEW MONTH
	gen int_month=month(int_mon)
	la de lblint_month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label value int_month lblint_month
	label var int_month "Month of the interview"
*</_int_month_>
	
** FIELD WORK***
*<_fieldwork_> 
	gen fieldwork=ym(int_yr, int_month)
	format %tm fieldwork
	la var fieldwork "Date of fieldwork"
*<_/fieldwork_> 


** HOUSEHOLD IDENTIFICATION NUMBER
*<_idh_>
	egen str idh= concat(xhpsu xhnum), punct(-)
	label var idh "Household id"
*</_idh_>


** INDIVIDUAL IDENTIFICATION NUMBER
*<_idp_>
	egen str idp= concat(idh idc), punct(-)
	label var idp "Individual id"
*</_idp_>


** HOUSEHOLD WEIGHTS
*<_wgt_>
	gen double wgt=wt_hh_adj
	replace wgt=0 if wgt==.
	label var wgt "Household sampling weight"
*</_wgt_>


** STRATA
*<_strata_>
	gen strata=urbrur
	recode strata (2=0)
	label var strata "Strata"
	la de lblstrata 1 "Urban" 0 "Rural"
	label values strata lblstrata
*</_strata_>


** PSU
*<_psu_>
	gen psu=xhpsu
	label var psu "Primary sampling units"
*</_psu_>

	
** MASTER VERSION
*<_vermast_>
	gen vermast="01"
	label var vermast "Master Version"
*</_vermast_>
	
	
** ALTERATION VERSION
*<_veralt_>
	gen veralt="01"
	label var veralt "Alteration Version"
*</_veralt_>	
	
/*****************************************************************************************************
*                                                                                                    *
                                   HOUSEHOLD CHARACTERISTICS MODULE
*                                                                                                    *
*****************************************************************************************************/


** LOCATION (URBAN/RURAL)
*<_urban_>
	gen urban=urbrur
	recode urban (2=0)
	label var urban "Urban/Rural"
	la de lblurban 1 "Urban" 0 "Rural"
	label values urban lblurban
*</_urban_>


** MACRO REGIONS
*<_subnatid0_>
	gen region=.
	replace region=1 if dist==1
	replace region=1 if dist==2
	replace region=1 if dist==3
	replace region=1 if dist==4
	replace region=1 if dist==5
	replace region=1 if dist==6
	replace region=1 if dist==7
	replace region=1 if dist==8
	replace region=1 if dist==9
	replace region=1 if dist==10
	replace region=1 if dist==11
	replace region=1 if dist==12
	replace region=1 if dist==13
	replace region=1 if dist==14
	replace region=1 if dist==15
	replace region=1 if dist==16
	replace region=2 if dist==17
	replace region=2 if dist==18
	replace region=2 if dist==19
	replace region=2 if dist==20
	replace region=2 if dist==21
	replace region=2 if dist==22
	replace region=2 if dist==23
	replace region=2 if dist==24
	replace region=2 if dist==25
	replace region=2 if dist==26
	replace region=2 if dist==27
	replace region=2 if dist==28
	replace region=2 if dist==29
	replace region=2 if dist==30
	replace region=2 if dist==31
	replace region=2 if dist==32
	replace region=2 if dist==33
	replace region=2 if dist==34
	replace region=2 if dist==35
	replace region=3 if dist==36
	replace region=3 if dist==37
	replace region=3 if dist==38
	replace region=3 if dist==39
	replace region=3 if dist==40
	replace region=3 if dist==43
	replace region=3 if dist==44
	replace region=3 if dist==45
	replace region=3 if dist==46
	replace region=3 if dist==47
	replace region=3 if dist==48
	replace region=3 if dist==49
	replace region=3 if dist==50
	replace region=3 if dist==51
	replace region=4 if dist==52
	replace region=4 if dist==53
	replace region=4 if dist==54
	replace region=4 if dist==55
	replace region=4 if dist==56
	replace region=4 if dist==57
	replace region=4 if dist==58
	replace region=4 if dist==59
	replace region=4 if dist==60
	replace region=4 if dist==61
	replace region=4 if dist==63
	replace region=4 if dist==64
	replace region=4 if dist==65
	replace region=5 if dist==67
	replace region=5 if dist==68
	replace region=5 if dist==69
	replace region=5 if dist==70
	replace region=5 if dist==71
	replace region=5 if dist==72
	replace region=5 if dist==73
	replace region=5 if dist==74
	replace region=5 if dist==75

	gen byte subnatid0=region
	la de lblsubnatid0 1 "Eastern" 2 "Central" 3 "Western" 4 "Mid-west" 5 "Far-west"
	label var subnatid0 "Macro regional areas"
	label values subnatid0 lblsubnatid0
*</_subnatid0_> */

** REGIONAL AREA 1 DIGIT ADMN LEVEL
*<_subnatid1_>
	gen byte subnatid1=dist
	la de lblsubnatid1 1 "Taplejung" 2 "Panchthar" 3 "Ilam" 4 "Jhapa" 5 "Morang" 6 "Sunsari" 7 "Dhankuta" 8 "Tehrathum" 9 "Sankhuwasabha" 10 "Bhojpur" 11 "Solukhumbu" 12 "Okhaldhunga" 13 "Khotang" 14 "Udayapur" 15 "Saptari" 16 "Siraha" 17 "Dhanusha" 18 "Mahottari" 19 "Sarlahi" 20 "Sindhuli" 21 "Ramechhap" 22 "Dolakha" 23 "Sindhupalchok" 24 "Kabhrepalanchok" 25 "Lalitpur" 26 "Bhaktapur" 27 "Kathmandu" 28 "Nuwakot" 29 "Rasuwa" 30 "Dhading" 31 "Makwanpur" 32 "Rautahat"  33 "Bara" 34 "Parsa" 35 "Chitwan" 36 "Gorkha" 37 "Lamjung" 38 "Tanahun" 39 "Syangja" 40 "Kaski" 41 "Manang" 42 "Mustang" 43 "Myagdi"44 "Parbat" 45 "Baglung" 46 "Gulmi" 47 "Palpa" 48 "Nawalparasi" 49 "Rupandehi" 50 "Kapilbastu" 51 "Arghakhanchi" 52 "Pyuthan" 53 "Rolpa" 54 "Rukum" 55 "Salyan" 56 "Dang" 57 "Banke" 58 "Bardiya" 59 "Surkhet" 60 "Dailekh" 61 "Jajarkot" 62 "Dolpa" 63 "Jumla" 64 "Kalikot" 65 "Mugu" 66 "Humla" 67 "Bajura" 68 "Bajhang" 69 "Achham"  70 "Doti" 71 "Kailali" 72 "Kanchanpur" 73 "Dandheldhura" 74 "Baitadi" 75 "Darchula"
	label var subnatid1 "Region at 2 digit (ADMN2)"
	label values subnatid1 lblsubnatid1
*</_subnatid1_>


** REGIONAL AREA 2 DIGIT ADMN LEVEL
*<_subnatid2_>
	gen byte subnatid2=.
	label var subnatid2 "Region at 2 digit (ADMN2)"
	label values subnatid2 lblsubnatid2
*</_subnatid2_>


** REGIONAL AREA 3 DIGIT ADMN LEVEL
*<_subnatid3_>
	gen byte subnatid3=.
	label var subnatid3 "Region at 3 digit (ADMN3)"
	label values subnatid3 lblsubnatid3
*</_subnatid3_>

** HOUSE OWNERSHIP
*<_ownhouse_>
	gen byte ownhouse=is_ownhouse
	recode ownhouse (2=0) (1=1)
	label var ownhouse "House ownership"
	la de lblownhouse 0 "No" 1 "Yes"
	label values ownhouse lblownhouse
*</_ownhouse_>

** TENURE OF DWELLING
*<_tenure_>
   gen tenure=.
   replace tenure=1 if is_ownhouse==1
   replace tenure=2 if  use_condition==1
   replace tenure=3 if use_condition!=1 & use_condition<.
   label var tenure "Tenure of Dwelling"
   la de lbltenure 1 "Owner" 2"Renter" 3"Other"
   la val tenure lbltenure
*</_tenure_>	

/** LANDHOLDING
*<_lanholding_>
   gen landholding=.
   label var landholding "Household owns any land"
   la de lbllandholding 0 "No" 1 "Yes"
   la val landholding lbllandholding
*</_tenure_>*/


*ORIGINAL WATER CATEGORIES
*<_water_orig_>
	gen water_orig=source_water
	la var water_orig "Source of Drinking Water-Original from raw file"
	#delimit
	la def lblwater_orig 1 "Piped water supply"
						 2 "Covered well"
						 3 "Hand pump/tubewell"
						 4 "Open well"
						 5 "Spring water"
						 6 "River"
						 7 "Other source";
	#delimit cr
	la val water_orig lblwater_orig
*</_water_orig_>


** PIPED SOURCE OF WATER
*<_piped_water_>
gen piped_water=has_pipe
recode piped_water (1=1)(2=0)
la var piped_water "Household has access to piped water"
la def lblpiped_water 1 "Yes" 0 "No"
la val piped_water lblpiped_water
*</_piped_water_>


**INTERNATIONAL WATER COMPARISON (Joint Monitoring Program)
*<_water_jmp_>
gen water_jmp=.
label var water_jmp "Source of drinking water-using Joint Monitoring Program categories"
#delimit
la de lblwater_jmp 1 "Piped into dwelling" 	
				   2 "Piped into compound, yard or plot" 
				   3 "Public tap / standpipe" 
				   4 "Tubewell, Borehole" 
				   5 "Protected well"
				   6 "Unprotected well"
				   7 "Protected spring"
				   8 "Unprotected spring"
				   9 "Rain water"
				   10 "Tanker-truck or other vendor"
				   11 "Cart with small tank / drum"
				   12 "Surface water (river, stream, dam, lake, pond)"
				   13 "Bottled water"
				   14 "Other";
#delimit cr
la values  water_jmp lblwater_jmp
*</_water_jmp_>


*SAR improved source of drinking water
*<_sar_improved_water_>
	gen sar_improved_water=.
	replace sar_improved_water=1 if inlist(source_water,1,2,3)
	replace sar_improved_water=0 if inlist(source_water,4,5,6,7 )
	la def lblsar_improved_water 1 "Improved" 0 "Unimproved"
	la var sar_improved_water "Improved source of drinking water-using country-specific definitions"
	la val sar_improved_water lblsar_improved_water
*</_sar_improved_water_>


** WATER SOURCE
*<_water_source_>
	gen water_source=.
	replace water_source=1 if source_water==1
	replace water_source=5 if source_water==2
	replace water_source=4 if source_water==3
	replace water_source=10 if source_water==4
	replace water_source=5 if source_water==5
	replace water_source=9 if source_water==6
	replace water_source=14 if source_water==7
	#delimit
		la de lblwater_source 1 "Piped water into dwelling" 	
							  2 "Piped water to yard/plot" 
							  3 "Public tap or standpipe" 
							  4 "Tubewell or borehole" 
							  5 "Protected dug well"
							  6 "Protected spring"
							  7 "Bottled water"
							  8 "Rainwater"
							  9 "Unprotected spring"
							  10 "Unprotected dug well"
							  11 "Cart with small tank/drum"
							  12 "Tanker-truck"
							  13 "Surface water"
								14 "Other";
		#delimit cr
		la val water_source lblwater_source
		la var water_source "Sources of drinking water"
*</_water_source_>

	
** SAR IMPROVED SOURCE OF DRINKING WATER
*<_improved_water_>
	gen improved_water=.
	replace improved_water=1 if inrange(water_source,1,8)
	replace improved_water=0 if inrange(water_source,9,14) // Asuming other is not improved water source
	la def lblimproved_water 1 "Improved" 0 "Unimproved"
	la val improved_water lblimproved_water
	la var improved_water "Improved access to drinking water"
*</_improved_water_>



** PIPED SOURCE OF WATER ACCESS
*<_pipedwater_acc_>
	gen pipedwater_acc=0 if inrange(source_water,2,11) // Asuming other is not piped water
	replace pipedwater_acc=3 if inlist(source_water,1)
	#delimit 
	la def lblpipedwater_acc	0 "No"
								1 "Yes, in premise"
								2 "Yes, but not in premise"
								3 "Yes, unstated whether in or outside premise";
	#delimit cr
	la val pipedwater_acc lblpipedwater_acc
	la var pipedwater_acc "Household has access to piped water"
*</_pipedwater_acc_>

	
** WATER TYPE VARIABLE USED IN THE SURVEY
*<_watertype_quest_>
	gen watertype_quest=1
	#delimit
	la def lblwaterquest_type	1 "Drinking water"
								2 "General water"
								3 "Both"
								4 "Others";
	#delimit cr
	la val watertype_quest lblwaterquest_type
	la var watertype_quest "Type of water questions used in the survey"
*</_watertype_quest_>


** ELECTRICITY
*<_electricity_>
gen electricity=source_light
recode electricity (1=1)(2 3 4 5=0)
la var electricity "Household has access to electricity"
la def lblelectricity 1 "Yes" 0 "No"
la val electricity lblelectricity
*</_piped_water_>


** ORIGINAL TOILET CATEGORIES
*<_toilet_orig_>
gen toilet_orig=type_toilet
la var toilet_orig "Access to sanitation facility-Original from raw file"
la def lbltoilet_orig 1 "Household flush (connected to municipal sewer)" 2 "Household flush (connected to septic tank)"  3 "Household non-flush"	  4 "Communal latrine"5 "No toilet"
la val toilet_orig lbltoilet_orig
*</_toilet_orig_>

		  
*SEWAGE TOILET
*<_sewage_toilet_>
	gen sewage_toilet= type_toilet
	replace sewage_toilet=0 if sewage_toilet!=1
	la var sewage_toilet "Household has access to sewage toilet"
	la def lblsewage_toilet 1 "Yes" 0 "No"
	la val sewage_toilet lblsewage_toilet
*</_sewage_toilet_>


**INTERNATIONAL SANITATION COMPARISON (Joint Monitoring Program)
*<_toilet_jmp_>
	gen toilet_jmp=.
	label var toilet_jmp "Access to sanitation facility-using Joint Monitoring Program categories"
	#delimit 
	la def lbltoilet_jmp 1 "Flush to piped sewer  system"
						2 "Flush to septic tank"
						3 "Flush to pit latrine"
						4 "Flush to somewhere else"
						5 "Flush, don't know where"
						6 "Ventilated improved pit latrine"
						7 "Pit latrine with slab"
						8 "Pit latrine without slab/open pit"
						9 "Composting toilet"
						10 "Bucket toilet"
						11 "Hanging toilet/hanging latrine"
						12 "No facility/bush/field"
						13 "Other";
	#delimit cr
	la val toilet_jmp lbltoilet_jmp
*</_toilet_jmp_>


*SAR improved type of toilet
*<_sar_improved_toilet_>
	gen sar_improved_toilet=.
	replace sar_improved_toilet=1 if inlist(type_toilet,1,2)
	replace sar_improved_toilet=0 if inlist(type_toilet,3,4,5)
	la def lblsar_improved_toilet 1 "Improved" 0 "Unimproved"
	la var sar_improved_toilet "Improved type of sanitation facility-using country-specific definitions"
	la val sar_improved_toilet lblsar_improved_toilet
*</_sar_improved_toilet_>


** ORIGINAL SANITATION CATEGORIES 
*<_sanitation_original_>
	clonevar j= type_toilet
	#delimit
	la def lblsanitation_original   1 "Household flush (connected to municipal sewer)"
									2 "Household flush (connected to septic tank)"
									3 "Household non-flush"
									4 "Communal latrine"
									5 "No toilet";
	#delimit cr
	la val j lblsanitation_original
	decode j, gen(sanitation_original)
	drop j
	la var sanitation_original "Access to sanitation facility-Original from raw file"
*</_sanitation_original_>


	** SANITATION SOURCE
	*<_sanitation_source_>
		gen sanitation_source=.
		replace sanitation_source=2 if  type_toilet==1
		replace sanitation_source=3 if  type_toilet==2
		replace sanitation_source=14 if type_toilet==3
		replace sanitation_source=14 if type_toilet==4
		replace sanitation_source=13 if type_toilet==5
		#delimit
		la def lblsanitation_source	1	"A flush toilet"
									2	"A piped sewer system"
									3	"A septic tank"
									4	"Pit latrine"
									5	"Ventilated improved pit latrine (VIP)"
									6	"Pit latrine with slab"
									7	"Composting toilet"
									8	"Special case"
									9	"A flush/pour flush to elsewhere"
									10	"A pit latrine without slab"
									11	"Bucket"
									12	"Hanging toilet or hanging latrine"
									13	"No facilities or bush or field"
									14	"Other";
		#delimit cr
		la val sanitation_source lblsanitation_source
		la var sanitation_source "Sources of sanitation facilities"
	*</_sanitation_source_>

	
	** SAR IMPROVED SANITATION 
	*<_improved_sanitation_>
		gen improved_sanitation=.
		replace improved_sanitation=1 if inlist(sanitation_source,1,2,3,4,5,6,7,8)
		replace improved_sanitation=0 if inlist(sanitation_source,9,10,11,12,13,14)
		la def lblimproved_sanitation 1 "Improved" 0 "Unimproved"
		la val improved_sanitation lblimproved_sanitation
		la var improved_sanitation "Improved type of sanitation facility-using country-specific definitions"
	*</_improved_sanitation_>
	

	** ACCESS TO FLUSH TOILET
	*<_toilet_acc_>
		gen toilet_acc=3 if improved_sanitation==1
		replace toilet_acc=0 if improved_sanitation==0 
		#delimit 
		la def lbltoilet_acc		0 "No"
									1 "Yes, in premise"
									2 "Yes, but not in premise"
									3 "Yes, unstated whether in or outside premise";
		#delimit cr
		la val toilet_acc lbltoilet_acc
		la var toilet_acc "Household has access to flushed toilet"
	*</_toilet_acc_>

	
** INTERNET
*<_internet_>
	gen byte internet=email_internet
	recode internet (2=0)
	label var internet "Internet connection"
	la de lblinternet 0 "No" 1 "Yes"
	label values internet lblinternet
*</_internet_>


/*****************************************************************************************************
*                                                                                                    *
                                   DEMOGRAPHIC MODULE
*                                                                                                    *
*****************************************************************************************************/


** HOUSEHOLD SIZE
*<_hsize_>
	gen hsize=totmemb
	la var hsize "Household size"
	
*</_hsize_>

**POPULATION WEIGHT
*<_pop_wgt_>
	gen pop_wgt=wgt*hsize
	la var pop_wgt "Population weight"
*</_pop_wgt_>


** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
*<_relationharm_>
	gen byte relationharm=rel_hhh
	recode relationharm (1=1) (2=2) (3 4=3) (5 6=4) (7 8 10=5) (9 =6)
	replace relationharm=5 if  rel_hhh==3 & sex==2
	replace relationharm=5 if  rel_hhh==4 & sex==1
	label var relationharm "Relationship to the head of household"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Non-relatives"
	label values relationharm  lblrelationharm
*</_relationharm_>

** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
*<_relationcs_>
	gen byte relationcs=rel_hhh
	la var relationcs "Relationship to the head of household country/region specific"
	la define lblrelationcs 1 "Head" 2 "Husband/Wife" 3 "Son/Daughter-in-law " 4 "Daughter/Son-in-law" 5 "Father/Mother" 6 "Father-in-law/Mother-in-law" 7 "Brother/Brother-in-law/Sister/Sister-in-law" 8 "Grandchildren" 9 "Household worker" 10 "Other"
	label values relationcs lblrelationcs
*</_relationcs_>


** GENDER
*<_male_>
	gen byte male=sex
	recode male (2=0)
	label var male "Sex of Household Member"
	la de lblmale 1 "Male" 0 "Female"
	label values male lblmale
*</_male_>


** AGE
*<_age_>
	*gen byte age=v01_03
	replace age=98 if age>=98
	label var age "Age of individual"
*</_age_>


** SOCIAL GROUP
*<_soc_>
	/*gen byte soc=v01_08
	replace soc=17 if soc>16 & soc!=.
	recode soc 6=5 5=6 8=7 9=8 7=9 15=14 14=15 16=15 17=15
	label var soc "Social group"
	la de lblsoc 1 "Chhetri" 2 "Brahman" 3 "Magar" 4 "Tharu" 5 "Newar" 6  "Tamang" 7 "Kami"  8 "Yadav" 9 "Muslim" 10  "Rai" 11 "Gurung" 12 "Damai" 13 "Limbu" 14 "Sarki" 15 "Other"
	label values soc lblsoc*/
*</_soc_>


** MARITAL STATUS
*<_marital_>
	gen byte marital=.
	label var marital "Marital status"
	la de lblmarital 1 "Married" 2 "Never Married" 3 "Living Together" 4 "Divorced/separated" 5 "Widowed"
	label values marital lblmarital
*</_marital_>*/

/*****************************************************************************************************
*                                                                                                    *
                                   EDUCATION MODULE
*                                                                                                    *
*****************************************************************************************************/

** EDUCATION MODULE AGE
*<_ed_mod_age_>
	gen byte ed_mod_age=5
	label var ed_mod_age "Education module application age"
	note ed_mod_age: "NPL 2015" The minimum age of application for the education module is 5 years old
*</_ed_mod_age_>

** CURRENTLY AT SCHOOL
*<_atschool_>
	gen byte atschool=.
	replace atschool=1 if school_attend==3
	replace atschool=0 if school_attend==1 | school_attend==2 | school_attend==4
	label var atschool "Attending school"
	la de lblatschool 0 "No" 1 "Yes"
	label values atschool  lblatschool
	note atschool: "NPL 2015" Currently attending school 
*</_atschool_>

** CAN READ AND WRITE
*<_literacy_>
	gen byte literacy=.
	replace  literacy=1 if  can_read==1 & can_write==1
	replace  literacy=0 if  can_read==2 | can_write==2
	label var literacy "Can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy
	note atschool: "NPL 2015" Can both read and write a letter
*</_literacy_>

** YEARS OF EDUCATION COMPLETED
*<_educy_>
	gen inter_edlevel = grade_comp
	replace inter_edlevel = inter_edlevel -1 if school_attend ==3
	gen byte educy= inter_edlevel
	recode educy (-1 = 0) (13 = 15) (14 15 = 17)
	label var educy "Years of education"
	notes educy: "NPL 2015" There is a substraction of 1 year in the computation of years of schooling for those currently attending
*</_educy_>

** EDUCATION LEVEL 7 CATEGORIES
*<_educat7_>
	recode inter_edlevel  (1/4 = 2) (5/7 = 3) (8/11 = 4) (12=5) (13/15 = 7) (-1 0 = 1), gen(educat7)
	label define lbleducat7 1 "No education" 2 "Primary incomplete" 3 "Primary complete" ///
	4 "Secondary incomplete" 5 "Secondary complete" 6 "Higher than secondary but not university" /// 
	7 "University incomplete or complete" 8 "Other" 9 "Not classified"
	label values educat7 lbleducat7
	la var educat7 "Level of education 7 categories"
*</_educat7_>

** EDUCATION LEVEL 5 CATEGORIES
*<_educat5_>
	gen educat5=.
	replace educat5=1 if educat7==1
	replace educat5=2 if educat7==2
	replace educat5=3 if educat7==3 | educat7==4
	replace educat5=4 if educat7==5
	replace educat5=5 if educat7==6 | educat7==7
	label define lbleducat5 1 "No education" 2 "Primary incomplete" ///
	3 "Primary complete but secondary incomplete" 4 "Secondary complete" ///
	5 "Some tertiary/post-secondary"
	label values educat5 lbleducat5
	la var educat5 "Level of education 5 categories"
*</_educat5_>

** EDUCATION LEVEL 4 CATEGORIES
*<_educat4_>
	gen byte educat4=.
	replace educat4=1 if educat7==1 
	replace educat4=2 if educat7==2 | educat7==3
	replace educat4=3 if educat7==4 | educat7==5
	replace educat4=4 if educat7==6 | educat7==7
	label var educat4 "Level of education 4 categories"
	label define lbleducat4 1 "No education" 2 "Primary (complete or incomplete)" ///
	3 "Secondary (complete or incomplete)" 4 "Tertiary (complete or incomplete)"
	label values educat4 lbleducat4
*</_educat4_>

** EVER ATTENDED SCHOOL
*<_everattend_>
	gen byte everattend=.
	replace everattend=0 if  school_attend==1
	replace everattend=1 if  school_attend==2 |  school_attend==3
	label var everattend "Ever attended school"
	la de lbleverattend 0 "No" 1 "Yes"
	label values everattend lbleverattend
*</_everattend_>

local ed_var "everattend atschool literacy educy educat7 educat5 educat4"
	foreach v in `ed_var'{
	replace `v'=. if (age<ed_mod_age & age!=.)
	}

/*****************************************************************************************************
*                                                                                                    *
                                            ASSETS 
*                                                                                                    *
*****************************************************************************************************/

** LAND PHONE
*<_landphone_>
	gen byte landphone= landline
	recode landphone (2=0)
	label var landphone "Household has landphone"
	la de lbllandphone 0 "No" 1 "Yes"
	label values landphone lbllandphone
	note landphone: "NPL 2015" Variable is defined as hh having telephone
*</_landphone_>


** CEL PHONE
*<_cellphone_>
	gen byte cellphone=mobile
	recode cellphone (2=0)
	label var cellphone "Household has Cellphone"
	la de lblcellphone 0 "No" 1 "Yes"
	label values cellphone lblcellphone
	note cellphone: "NPL 2015" Variable is defined as hh having mobile phone
*</_cellphone_>

** COMPUTER
*<_computer_>
	gen byte computer=yesnoComputer_Printe
	recode computer (2=0)(1=1)
	label var computer "Household has computer"
	la de lblcomputer 0 "No" 1 "Yes"
	label values computer lblcomputer
	note computer: "NPL 2015" Variable is defined as hh having computer/printer	
*</_computer_>

** RADIO
*<_radio_>
	gen byte radio=yesnoRadio_tape_CD_o
	recode radio (2=0)(1=1)
	label var radio "Household has radio"
	la de lblradio 0 "No" 1 "Yes"
	label val radio lblradio
	note computer: "NPL 2015" Variable is defined as hh having Radio/ tape/CD player/DVD Player	
*</_radio_>

** TELEVISION
*<_television_>
	gen byte television=yesnoTelevision
	recode television (2=0)(1=1)
	label var television "Household has Television"
	la de lbltelevision 0 "No" 1 "Yes"
	label val television lbltelevision
	note television: "NPL 2015" Variable is defined as hh having T.V. 
*</_television>

** FAN
*<_fan_>
	gen byte fan=yesnoElectric_fan
	recode fan (2=0)(1=1)
	label var fan "Household has Fan"
	la de lblfan 0 "No" 1 "Yes"
	label val fan lblfan
	note fan: "NPL 2015" Variable is defined as hh having electric fan
*</_fan>

** SEWING MACHINE
*<_sewingmachine_>
	gen byte sewingmachine=yesnoTailoring_machi
	recode sewingmachine (2=0)(1=1) 
	label var sewingmachine "Household has Sewing machine"
	la de lblsewingmachine 0 "No" 1 "Yes"
	label val sewingmachine lblsewingmachine
	note sewingmachine: "NPL 2015" Variable is defined as hh having sewing machine
*</_sewingmachine>

** WASHING MACHINE
*<_washingmachine_>
	gen byte washingmachine=yesnoWashing_machine
	recode washingmachine (2=0)(1=1) 
	label var washingmachine "Household has Washing machine"
	la de lblwashingmachine 0 "No" 1 "Yes"
	label val washingmachine lblwashingmachine
	note sewingmachine: "NPL 2015" Variable is defined as hh having washing machine
*</_washingmachine>

** REFRIGERATOR
*<_refrigerator_>
	gen byte refrigerator=yesnoRefrigerator
	recode refrigerator (2=0)(1=1) 
	label var refrigerator "Household has Refrigerator"
	la de lblrefrigerator 0 "No" 1 "Yes"
	label val refrigerator lblrefrigerator
	note refrigerator: "NPL 2015" Variable is defined as hh having refrigerator
*</_refrigerator>

** LAMP
*<_lamp_>
	gen lamp=.
	label var lamp "Household has Lamp"
	la de lbllamp 0 "No" 1 "Yes"
	label val lamp lbllamp
*</_lamp>*

** BYCICLE
*<_bycicle_>
	gen byte bicycle=yesnoBicycle
	recode bicycle (2=0)(1=1) 
	label var bicycle "Household has Bicycle"
	la de lblbycicle 0 "No" 1 "Yes"
	label val bicycle lblbycicle
	note bicycle: "NPL 2015" Variable is defined as hh having refrigerator
*</_bycicle>

** MOTORCYCLE
*<_motorcycle_>
	gen byte motorcycle=yesnoMotorcycle_Scoo
	recode motorcycle (2=0)(1=1) 
	label var motorcycle "Household has Motorcycle"
	la de lblmotorcycle 0 "No" 1 "Yes"
	label val motorcycle lblmotorcycle
	note motorcycle: "NPL 2015" Variable is defined as hh having motorcycle
*</_motorcycle>

** MOTOR CAR
*<_motorcar_>
	gen byte motorcar=yesnoMotorcar
	recode motorcar (2=0)(1=1) 
	label var motorcar "Household has Motor car"
	la de lblmotorcar 0 "No" 1 "Yes"
	label val motorcar lblmotorcar
	note motorcar: "NPL 2015" Variable is defined as hh having motorcar
*</_motorcar>

** COW
*<_cow_>
	gen cow=.
	label var cow "Household has Cow"
	la de lblcow 0 "No" 1 "Yes"
	label val cow lblcow
*</_cow>

** BUFFALO
*<_buffalo_>
	gen buffalo=.
	label var buffalo "Household has Buffalo"
	la de lblbuffalo 0 "No" 1 "Yes"
	label val buffalo lblbuffalo
*</_buffalo>

** CHICKEN
*<_chicken_>
	gen chicken=.
	label var chicken "Household has Chicken"
	la de lblchicken 0 "No" 1 "Yes"
	label val chicken lblchicken
*</_chicken>

/*****************************************************************************************************
*                                                                                                    *
                                   FINAL STEPS
*                                                                                                    *
*****************************************************************************************************/
** KEEP VARIABLES - ALL
	do "$fixlabels\fixlabels", nostop

	keep countrycode year survey idh idp wgt pop_wgt strata psu vermast veralt urban int_month int_year fieldwork subnatid0  ///
		subnatid1 subnatid2 subnatid3 ownhouse  tenure water_orig piped_water water_jmp sar_improved_water  electricity toilet_orig sewage_toilet toilet_jmp sar_improved_toilet  landphone cellphone ///
		water_orig water_source improved_water pipedwater_acc watertype_quest sanitation_original sanitation_source improved_sanitation toilet_acc ///
	     computer internet hsize relationharm relationcs male age  marital ed_mod_age everattend ///
	     atschool electricity literacy educy educat4 educat5 educat7 ///
		 landphone cellphone computer radio television fan sewingmachine washingmachine refrigerator lamp bicycle motorcycle motorcar cow buffalo chicken  
		 
		 
** ORDER VARIABLES

	order countrycode year survey idh idp wgt pop_wgt strata psu vermast veralt urban int_month int_year fieldwork subnatid0 ///
		subnatid1 subnatid2 subnatid3 ownhouse  tenure water_orig piped_water water_jmp sar_improved_water water_orig ///
		water_source improved_water pipedwater_acc watertype_quest electricity toilet_orig sewage_toilet toilet_jmp sar_improved_toilet ///
		sanitation_original sanitation_source improved_sanitation toilet_acc landphone cellphone ///
	     computer internet hsize relationharm relationcs male age  marital ed_mod_age everattend ///
	     atschool electricity literacy educy educat4 educat5 educat7 ///
		 landphone cellphone computer radio television fan sewingmachine washingmac refrigerator lamp bicycle motorcycle motorcar cow buffalo chicken
	
	compress

** DELETE MISSING VARIABLES

	glo keep=""
	qui levelsof countrycode, local(cty)
	
	foreach var of varlist countrycode - chicken {
		capture assert mi(`var')
		if !_rc {
		
			 display as txt "Variable " as result "`var'" as txt " for countrycode " as result `cty' as txt " contains all missing values -" as error " Variable Deleted"
			 
		}
		else {
		
			 glo keep = "$keep"+" "+"`var'"
			 
		}
	}
	

	keep countrycode year survey idh idp wgt pop_wgt strata psu vermast veralt ${keep} 
	
	
	
	
	compress

	saveold "`output'\Data\Harmonized\NPL_2015_AHS_v01_M_v01_A_SARMD_IND.dta", replace version(12)
	saveold "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\__REGIONAL\Individual Files\NPL_2015_AHS_v01_M_v01_A_SARMD_IND.dta", replace version(12)
	notes

	log close

******************************  END OF DO-FILE  *****************************************************/


	
	
