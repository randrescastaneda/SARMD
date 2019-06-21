/*****************************************************************************************************
******************************************************************************************************
**                                                                                                  **
**                                   SOUTH ASIA MICRO DATABASE                                      **
**                                                                                                  **
** COUNTRY			NEPAL
** COUNTRY ISO CODE	NPL
** YEAR				1995
** SURVEY NAME		NEPAL LIVING STANDARDS SURVEY 1995
** SURVEY AGENCY	CENTRAL BUREAU OF STATISTICS
** RESPONSIBLE		Triana Yentzen
** MODIFIED BY		Julian Eduardo Diaz Gutierrez
** Date				02/12/2016
**                                                                                                  **
******************************************************************************************************
*****************************************************************************************************/

/*****************************************************************************************************
*                                                                                                    *
                                   INITIAL COMMANDS
*                                                                                                    *
*****************************************************************************************************/


** INITIAL COMMANDS
	clear
	cap log close
	set more off
	set mem 500m
	
** DIRECTORY
	local input "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\NPL\NPL_1995_LSS-I\NPL_1995_LSS-I_v01_M"
	local output "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\NPL\NPL_1995_LSS-I\NPL_1995_LSS-I_v01_M_v03_A_SARMD"
	glo pricedata "D:\SOUTH ASIA MICRO DATABASE\CPI\cpi_ppp_sarmd_weighted.dta"
	glo shares "D:\SOUTH ASIA MICRO DATABASE\APPS\DATA CHECK\Food and non-food shares\NPL"
	glo fixlabels "D:\SOUTH ASIA MICRO DATABASE\APPS\DATA CHECK\Label fixing"

** LOG FILE
	log using "`output'\Doc\Technical\NPL_1995_LSS.log",replace
	
/*****************************************************************************************************
*                                                                                                    *
                                   * DATABASE ASSEMBLENT
*                                                                                                    *
*****************************************************************************************************/


* PREPARE DATASETS
	
	use "`input'\Data\Stata\R1_Z01A_HHRoster.dta", clear
	sort WWWHH r1_IDC
	tempfile roster
	save `roster'
	
	use "`input'\Data\Stata\R1_Z11B1_WgEmplmntNAgri.dta", clear
	duplicates drop WWWHH WWW HH r1_activcode, force
	tempfile nagri
	save `nagri'
	
	use "`input'\Data\Stata\R1_Z11B2_WgEmplmntNAgri2.dta", clear
	duplicates drop WWWHH WWW HH r1_activcode, force
	tempfile nagri2
	save `nagri2'
	
	use "`input'\Data\Stata\R1_Z11A1_WgEmplmntAgri.dta", clear
	duplicates drop WWWHH WWW HH r1_activcode, force
	tempfile agri
	save `agri'
	
	use "`input'\Data\Stata\R1_Z11A2_WgEmplmntAgri2.dta", clear
	duplicates drop WWWHH WWW HH r1_activcode, force
	tempfile agri2
	save `agri2'
	
	
	
	use "`input'\Data\Stata\R1_Z01C_Activities.dta", clear
	duplicates drop WWWHH r1_IDC r1_activcode, force
	
	merge m:1 WWWHH  r1_activcode using `nagri2'
	drop if _merge==2
	drop _merge
	
	merge m:1 WWWHH  r1_activcode using `agri2'
	drop if _merge==2
	drop _merge
		
	merge m:1 WWWHH r1_IDC r1_activcode using `nagri'
	drop if _merge==2
	ren _merge mergenonag
	
	merge m:1 WWWHH r1_IDC r1_activcode using `agri'
	drop if _merge==2
	ren _merge mergeag
	*Sort according to importance in time to make difference between first and second job
	gsort WWWHH r1_IDC -r1_12moswrkt -r1_12daypmwr -r1_12hourdwr -r1_7dayswork -r1_7hrperday 
	egen aux=seq(), by( WWWHH r1_IDC)
	egen njobs_aux=count( aux), by( WWWHH r1_IDC)
	ren njobs_aux njobs
	keep if njobs<=2
	reshape wide r1_activcode r1_occupdesc r1_occupcode r1_12moswrkt r1_12daypmwr r1_12hourdwr r1_7dayswork r1_7hrperday r1_workinVDC r1_wrkindstr r1_wrkinurru r1_wgemplagr r1_wgemplnag r1_slemplagr r1_slemplnag r1_na30salar r1_na30trnsp r1_na12bonus r1_na12cloth r1_na12other r1_nataxdedc r1_naprovdfn r1_napension r1_namedcare r1_namumbwrk r1_nacntrtpm r1_agpyycash r1_agpyyink1 r1_agpyyink2 r1_agpyinkvl r1_agpyinkvt r1_aglbloane r1_agothrmem r1_agsharecr r1_agtlivest r1_nagactvit r1_nagacnsco r1_nagindust r1_nagacnsic r1_pcertbasi r1_pddaibasi r1_napdycash r1_napdyink1 r1_napdyink2 r1_napdinkvl r1_napdinkvt mergenonag r1_agactivit r1_agactnsco r1_agactpcra r1_agactpdda r1_agpdycash r1_agpdyink1 r1_agpdyink2 r1_agpdinkvl r1_agpdinkvt mergeag, i(WWWHH r1_IDC) j(aux)
	replace njobs=njobs-1 /*Put njobs in terms of additional jobs*/
/*	gsort WWWHH r1_IDC -r1_12moswrkt -r1_12daypmwr -r1_12hourdwr -r1_7dayswork -r1_7hrperday -r1_7hrperday 
	bys WWWHH r1_IDC: keep if _n==1*/
	tempfile activities
	save `activities'
	
	
	use "`input'\Data\Stata\R1_Z01D_Unemployment.dta", clear
	sort WWWHH r1_IDC
	tempfile unemp
	save `unemp'
	
	use "`input'\Data\Stata\R1_Z07A_Literacy.dta", clear
	sort WWWHH r1_IDC
	tempfile literacy
	save `literacy'
	
	use "`input'\Data\Stata\R1_Z07B_PastEnroll.dta", clear
	sort WWWHH r1_IDC
	tempfile pastenroll
	save `pastenroll'
	
	use "`input'\Data\Stata\R1_Z07C1_CurrEnroll.dta", clear
	sort WWWHH r1_IDC
	tempfile currenroll
	save `currenroll'
	
	use "`input'\Data\Stata\R1_Z02B_HousingXpns.dta", clear
	sort WWWHH
	tempfile property
	save `property'
	
	use "`input'\Data\Stata\R1_Z02C1_UtilsAmenities1.dta", clear
	sort WWWHH
	tempfile amenities1
	save `amenities1'
	
	use "`input'\Data\Stata\R1_Z02C2_UtilsAmenities2.dta", clear
	sort WWWHH
	tempfile amenities2
	save `amenities2'
	
	use "`input'\Data\Stata\R1_Z12A1A_LandOwned", clear
	sort WWWHH
	tempfile landown
	save `landown'
	
	use "`input'\Data\Stata\R1_Z06C_Durables.dta", clear
	drop r1_durbl_yr r1_durbl_hw r1_durbl_vt r1_durbl_vn
	replace r1_durbl_nm=1 if r1_durbl_nm==.
	reshape wide r1_durbl_nm, i( WWWHH) j( r1_durcode)
	sort WWWHH
	tempfile durables
	save `durables'

	use "`input'\Data\Stata\R1_Z12E1B_OwnLivestock2.dta", clear
	drop r1_lvstownrs r1_lvstown12no r1_lvstown12rs r1_lvstsld12no r1_lvstsld12rs r1_lvstbgt12no r1_lvstbgt12rs
	reshape wide r1_lvstownno, i( WWWHH) j( r1_lvestcode)
	sort WWWHH
	tempfile livestock
	save `livestock'

	use  "`input'\Data\Stata\R1_Z00_SurveyInfo.dta", clear
	tempfile inform
	save `inform'
	
	* MERGE DATASETS
	
	use "`input'\Data\Stata\SAS_NPL_1995_96_NLSS1.dta", clear
	ren c1_hhsize c1_hhsize_
	keep WWW WWWHH weight popwt pcexp c1_nompln c1_npcexp c1_hhsize_ c1_poor c1_pindex c1_ra_pcexp
	
	sort WWW
	merge m:1 WWW using "`input'\Data\Stata\sample_hh.dta"
	drop _merge
	
	sort WWWHH
	
	foreach x in property amenities1 amenities2 landown durables livestock inform{
	merge 1:1 WWWHH using ``x''
	drop if _merge==2
	drop _merge
	}
	
	merge 1:m WWWHH using `roster'
	drop if _merge==2
	drop _merge
	
	sort WWWHH r1_IDC
	
	foreach x in activities unemp literacy pastenroll currenroll{
	merge 1:1 WWWHH r1_IDC using ``x''
	drop if _merge==2
	drop _merge
	}
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
	gen int year=1995
	label var year "Survey year"
*</_year_>


** SURVEY NAME 
*<_survey_>
	gen str survey="LSS-I"
	label var survey "Survey Acronym"
*</_survey_>


** INTERVIEW YEAR
*<_int_year_>
	gen byte int_year=.
	label var int_year "Year of the interview"
*</_int_year_>
	
	
** INTERVIEW MONTH
	* S00DINTD phase
	gen int_month=R1_V00_DINTM
	la de lblint_month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label value int_month lblint_month
	label var int_month "Month of the interview"
*</_int_month_>

	
** HOUSEHOLD IDENTIFICATION NUMBER
*<_idh_>
	tostring WWWHH, gen(idh)
	label var idh "Household id"
*</_idh_>

** INDIVIDUAL IDENTIFICATION NUMBER
*<_idp_>

	egen str idp=concat(idh r1_IDC), punct(-)
	tostring idp, replace
	label var idp "Individual id"
*</_idp_>


** HOUSEHOLD WEIGHTS
*<_wgt_>
	gen wgt=weight
	label var wgt "Household sampling weight"
*</_wgt_>


** STRATA
*<_strata_>
	gen strata=stratum
	label var strata "Strata"
*</_strata_>
	
** PSU
*<_psu_>
	gen psu=WWW
	label var psu "Primary sampling units"
*</_psu_>
	
** MASTER VERSION
*<_vermast_>

	gen vermast="01"
	label var vermast "Master Version"
*</_vermast_>
	
	
** ALTERATION VERSION
*<_veralt_>

	gen veralt="03"
	label var veralt "Alteration Version"
*</_veralt_>	
	
/*****************************************************************************************************
*                                                                                                    *
                                   HOUSEHOLD CHARACTERISTICS MODULE
*                                                                                                    *
*****************************************************************************************************/


** LOCATION (URBAN/RURAL)
*<_urban_>
	gen urban=urbrural
	recode urban (2=0)
	label var urban "Urban/Rural"
	la de lblurban 1 "Urban" 0 "Rural"
	label values urban lblurban
*</_urban_>


**MACRO REGIONS
*<_subnatid0_>
	gen subnatid0=region
	label var subnatid0 "Macro regional areas"
	label define lblsubnatid0 1 "Eastern" 2 "Central" 3 "Western" 4 "Mid-west" 5 "Far-west"
	label values subnatid0 lblsubnatid0
*</_subnatid1_>


** REGIONAL AREA 1 DIGIT ADMN LEVEL
*<_subnatid1_>
	gen byte subnatid1=district
	la de lblsubnatid1 1 "Taplejung" 2 "Panchthar" 3 "Ilam" 4 "Jhapa" 5 "Morang" 6 "Sunsari" 7 "Dhankuta" 8 "Tehrathum" 9 "Sankhuwasabha" 10 "Bhojpur" 11 "Solukhumbu" 12 "Okhaldhunga" 13 "Khotang" 14 "Udayapur" 15 "Saptari" 16 "Siraha" 17 "Dhanusha" 18 "Mahottari" 19 "Sarlahi" 20 "Sindhuli" 21 "Ramechhap" 22 "Dolakha" 23 "Sindhupalchok" 24 "Kavrepalanchok" 25 "Lalitpur" 26 "Bhaktapur" 27 "Kathmandu" 28 "Nuwakot" 29 "Rasuwa" 30 "Dhading" 31 "Makwanpur" 32 "Rautahat"  33 "Bara" 34 "Parsa" 35 "Chitwan" 36 "Gorkha" 37 "Lamjung" 38 "Tanahun" 39 "Syangja" 40 "Kaski" 41 "Manang" 42 "Mustang" 43 "Myagdi"44 "Parbat" 45 "Baglung" 46 "Gulmi" 47 "Palpa" 48 "Nawalparasi" 49 "Rupandehi" 50 "Kapilbastu" 51 "Arghakhanchi" 52 "Pyuthan" 53 "Rolpa" 54 "Rukum" 55 "Salyan" 56 "Dang" 57 "Banke" 58 "Bardiya" 59 "Surkhet" 60 "Dailekh" 61 "Jajarkot" 62 "Dolpa" 63 "Jumla" 64 "Kalikot" 65 "Mugu" 66 "Humla" 67 "Bajura" 68 "Bajhang" 69 "Achham"  70 "Doti" 71 "Kailali" 72 "Kanchanpur" 73 "Dandheldhura" 74 "Baitadi" 75 "Darchula"
	label var subnatid1 "Region at 1 digit (ADMN1)"
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
	gen ownhouse= r1_dwelowned
	recode ownhouse (2=0)
	label var ownhouse "House ownership"
	la de lblownhouse 0 "No" 1 "Yes"
	label values ownhouse lblownhouse
*</_ownhouse_>


** TENURE OF DWELLING
*<_tenure_>
   gen tenure=.
   replace tenure=1 if r1_dwelowned==1
   replace tenure=2 if r1_dwelstats==1
   replace tenure=3 if r1_dwelstats!=1 & r1_dwelstats<.
   label var tenure "Tenure of Dwelling"
   la de lbltenure 1 "Owner" 2"Renter" 3"Other"
   la val tenure lbltenure
   note tenure: "NPL 1995" Variable from module 2B has error in codification
*</_tenure_>	


** LANDHOLDING
*<_lanholding_>
   gen landholding=.
   label var landholding "Household owns any land"
   la de lbllandholding 0 "No" 1 "Yes"
   la val landholding lbllandholding
*</_tenure_>	


*ORIGINAL WATER CATEGORIES
*<_water_orig_>
gen water_orig=r1_watersour
la var water_orig "Source of Drinking Water-Original from raw file"
#delimit
la def lblwater_orig 1 "Piped water supply"
					 2 "Covered well/Hand pump"
					 3 "Open well"
					 4 "Other water source";
#delimit cr
la val water_orig lblwater_orig
*</_water_orig_>


*PIPED SOURCE OF WATER
*<_piped_water_>
gen piped_water=.
replace piped_water=1 if r1_watersour==1 & r1_watersour!=.
replace piped_water=0 if piped_water==.
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
replace sar_improved_water=1 if inlist(r1_watersour,1,2)
replace sar_improved_water=0 if inlist(r1_watersour,3,4)
la def lblsar_improved_water 1 "Improved" 0 "Unimproved"
la var sar_improved_water "Improved source of drinking water-using country-specific definitions"
la val sar_improved_water lblsar_improved_water
*</_sar_improved_water_>
  

** ELECTRICITY PUBLIC CONNECTION
*<_electricity_>
	gen byte electricity=r1_lightsrs
	replace electricity=0 if electricity!=1
	label var electricity "Electricity main source"
	la de lblelectricity 0 "No" 1 "Yes"
	label values electricity lblelectricity
	notes electricity: "NPL 1995" The definition used was if household's main source of lighting is electricity
*</_electricity_>

*ORIGINAL TOILET CATEGORIES
*<_toilet_orig_>
gen toilet_orig=r1_toilettyp
la var toilet_orig "Access to sanitation facility-Original from raw file"
#delimit
la def lbltoilet_orig 1 "Household flush (connected to municipal sewer)"
					  2 "Household flush (connected to septic tank)"
					  3 "Household non-flush"
					  4 "Communal latrine"
					  5 "No toilet";
#delimit cr
la val toilet_orig lbltoilet_orig
*</_toilet_orig_>



*SEWAGE TOILET
*<_sewage_toilet_>
gen sewage_toilet=r1_toilettyp
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
replace sar_improved_toilet=1 if inlist(r1_toilettyp,1,2)
replace sar_improved_toilet=0 if inlist(r1_toilettyp,3,4,5)
la def lblsar_improved_toilet 1 "Improved" 0 "Unimproved"
la var sar_improved_toilet "Improved type of sanitation facility-using country-specific definitions"
la val sar_improved_toilet lblsar_improved_toilet
*</_sar_improved_toilet_>

** INTERNET
	gen byte internet= .
	label var internet "Internet connection"
	la de lblinternet 0 "No" 1 "Yes"
	label values internet lblinternet


/*****************************************************************************************************
*                                                                                                    *
                                   DEMOGRAPHIC MODULE
*                                                                                                    *
*****************************************************************************************************/


** HOUSEHOLD SIZE
*<_hsize_>
	gen z=1
	bys idh:egen hsize=sum(z)
	drop wgt
	gen wgt=popwt/hsize
	label var wgt "Household sampling weight"
	*drop if p!=1
*	gen hsize=c1_hhsize
	*gen hsize1=popwt/weight 
	la var hsize "Household size"
*</_hsize_>

**POPULATION WEIGHT
*<_pop_wgt_>
	gen pop_wgt=wgt*hsize
	la var pop_wgt "Population weight"
*</_pop_wgt_>

** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
*<_relationharm_>
	gen byte relationharm=r1_relation
	recode relationharm (5=4) (4 6 7 8 9 0 10 11=5) (12 13 14=6)
	label var relationharm "Relationship to the head of household"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Non-relatives"
	label values relationharm  lblrelationharm
*</_relationharm_>

** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
*<_relationcs_>
	gen byte relationcs=r1_relation
	la var relationcs "Relationship to the head of household country/region specific"
	la define lblrelationcs 1 "Head" 2 "Husband/Wife" 3 "Son/Daughter" 4 "Grandchild" 5 "Father/Mother" 6 "Brother/Sister" 7 "Nephew/Niece" 8 "Son/Daughter-in-law" 9 "Brother/Sister-in-law" 10 "Father/Mother-in-law" 11 "Other family relative" 12 "Servant/servant's relative" 13 "Tenant/tentant's relative" 14 "Other person not related"
	label values relationcs lblrelationcs
*</_relationcs_>


** GENDER
*<_male_>
	gen byte male=r1_sex
	recode male (2=0)
	label var male "Sex of Household Member"
	la de lblmale 1 "Male" 0 "Female"
	label values male lblmale
*</_male_>


** AGE
*<_age_>
	gen byte age=r1_age
	replace age=98 if age>=98
	label var age "Age of individual"
*</_age_>


** SOCIAL GROUP
*<_soc_>
	*gen byte soc=r1_ethncity
	*recode soc 6=5 5=6 8=7 9=8 7=9 14=15 15=14 16/102=15
	gen soc=.
	label var soc "Social group"
	la de lblsoc 1 "Chhetri" 2 "Brahman" 3 "Magar" 4 "Tharu" 5 "Newar" 6  "Tamang" 7 "Kami"  8 "Yadav" 9 "Muslim" 10  "Rai" 11 "Gurung" 12 "Damai" 13 "Limbu" 14 "Sarki" 15 "Other"
	label values soc lblsoc
*</_soc_>


** MARITAL STATUS
*<_marital_>	
	recode r1_martstats (2 3 =4) (5=2)  (4=5) , gen(marital)
	label var marital "Marital status"
	la de lblmarital 1 "Married" 2 "Never Married" 3 "Living Together" 4 "Divorced/separated" 5 "Widowed"
	label values marital lblmarital
*</_marital_>


/*****************************************************************************************************
*                                                                                                    *
                                   EDUCATION MODULE
*                                                                                                    *
*****************************************************************************************************/


** EDUCATION MODULE AGE
*<_ed_mod_age_>
	gen byte ed_mod_age=5
	label var ed_mod_age "Education module application age"
*</_ed_mod_age_>


** CURRENTLY AT SCHOOL
*<_atschool_>
	gen byte atschool=.
	replace atschool=1 if r1_educbckr==3
	replace atschool=0 if r1_educbckr==2 | r1_educbckr==1
	label var atschool "Attending school"
	la de lblatschool 0 "No" 1 "Yes"
	label values atschool  lblatschool
*</_atschool_>


** CAN READ AND WRITE
*<_literacy_>
	gen byte literacy=.
	replace  literacy=1 if  r1_canread==1 & r1_canwrite==1
	replace  literacy=0 if  r1_canread==2 | r1_canwrite==2
	label var literacy "Can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy
*</_literacy_>


** YEARS OF EDUCATION COMPLETED
*<_educy_>
	gen inter_edlevel = r1_attendcls
	replace inter_edlevel = r1_edlevcmpl if inter_edlevel == .
	replace inter_edlevel = 0 if r1_educbckr == 1 & inter_edlevel == .
	recode inter_edlevel (16 17 = .)
	replace inter_edlevel = inter_edlevel -1 if r1_educbckr ==3
	gen byte educy= inter_edlevel
	recode educy (-1 = 0) (13 = 15) (14 15 = 17)
	label var educy "Years of education"
	notes educy: "NPL 1995" There is a substraction of 1 year in the computation of years of schooling for those currently attending
*</_educy_>


** EDUCATION LEVEL 7 CATEGORIES
*<_educat7_>
	recode inter_edlevel  (1/4 = 2) (5/7 = 3) (8/11 = 4) (12=5) (13/15 = 7) (-1 0 = 1), gen(educat7)
	replace educat7=8 if r1_attendcls==16 | r1_edlevcmpl==16
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
	replace everattend=0 if r1_educbckr==1
	replace everattend=1 if r1_educbckr==2 | r1_educbckr==3
	label var everattend "Ever attended school"
	la de lbleverattend 0 "No" 1 "Yes"
	label values everattend lbleverattend
*</_everattend_>


	
	local ed_var "everattend atschool literacy educy educat7 educat5 educat4"
	foreach v in `ed_var'{
	replace `v'=. if( age<ed_mod_age & age!=.)
	}


/*****************************************************************************************************
*                                                                                                    *
                                   LABOR MODULE
*                                                                                                    *
*****************************************************************************************************/

** LABOR MODULE AGE
*<_lb_mod_age_>

 gen byte lb_mod_age=5
	label var lb_mod_age "Labor module application age"
note lb_mod_age: "NPL 1995" Even though the original lower bound is  10, It is kept in 5 to keep comparability with 2003
*</_lb_mod_age_>

** LABOR STATUS
*<_lstatus_>
	gen byte lstatus=.
	replace lstatus=1 if r1_occupcode1>=1 & r1_occupcode1<100
	replace lstatus=3 if r1_occupcode1==97
	replace lstatus=3 if r1_occupcode1==98
	replace lstatus=2 if  r1_undm_lkwr==1 & lstatus!=1
	replace lstatus=3 if r1_undm_lkwr==2
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
	notes lstatus: "NPL 1995" the present definition of unemployment does not take into account availability to work
*</_lstatus_>


** LABOR STATUS 2
*<_lstatus_>
	gen byte lstatus2=.
	replace lstatus2=1 if r1_occupcode2>=1 & r1_occupcode2<100
	replace lstatus2=3 if r1_occupcode2==97
	replace lstatus2=3 if r1_occupcode2==98
	replace lstatus2=2 if  r1_undm_lkwr==1 & lstatus!=1
	replace lstatus2=3 if r1_undm_lkwr==2
	*replace lstatus=2 if r1_undm_avwr==1 & r1_undm_lkwr==2
	label var lstatus2 "Labor status"
	la de lbllstatus2 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus2 lbllstatus2
	notes lstatus: "NPL 1995" the present definition of unemployment does not take into account availability to work
*</_lstatus_>

** LABOR STATUS LAST YEAR
*<_lstatus_year_>
	gen lstatus_year=lstatus
	replace lstatus_year=0 if lstatus>1 & lstatus!=.
	replace lstatus_year=. if age<lb_mod_age & age!=.
	label var lstatus_year "Labor status during last year"
	la de lbllstatus_year 1 "Employed" 0 "Not employed" 
	label values lstatus_year lbllstatus_year
*</_lstatus_year_>

** LABOR STATUS LAST YEAR 2
*<_lstatus_year_>
	gen lstatus_year2=lstatus2
	replace lstatus_year2=0 if lstatus2>1 & lstatus2!=.
	replace lstatus_year2=. if age<lb_mod_age & age!=.
	label var lstatus_year2 "Labor status during last year"
	la de lbllstatus_year2 1 "Employed" 0 "Not employed" 
	label values lstatus_year lbllstatus_year
*</_lstatus_year_>


** EMPLOYMENT STATUS
*<_empstat_>
	gen byte empstat=.
	replace empstat=1 if r1_wgemplagr1==1 | r1_wgemplnag1==1
	replace empstat=4 if r1_slemplagr1==1 | r1_slemplnag1==1
	*replace empstat=3 if EMPTYPE_MAIN==2
	*replace empstat=4 if EMPTYPE_MAIN==3
	replace empstat=. if lstatus==2 | lstatus==3
	label var empstat "Employment status"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed"
	label values empstat lblempstat
*</_empstat_>


** EMPLOYMENT STATUS LAST YEAR
*<_empstat_year_>
	gen empstat_year=.
	replace empstat_year=empstat
	replace empstat_year=. if lstatus_year!=1
	label var empstat_year "Employment status during last year"
	la de lblempstat_year 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_year lblempstat_year
*</_empstat_year_>


** SECTOR OF ACTIVITY: PUBLIC - PRIVATE
*<_njobs_>
	label var njobs "Number of additional jobs"
	*replace njobs=. if lstatus!=1
*</_njobs_>


** NUMBER OF ADDITIONAL JOBS LAST YEAR
*<_njobs_year_>
	gen byte njobs_year=njobs
	*replace njobs_year=. if lstatus_year!=1
	label var njobs_year "Number of additional jobs during last year"
*</_njobs_year_>


** SECTOR OF ACTIVITY: PUBLIC - PRIVATE
*<_ocusec_>
	gen byte ocusec=.
	label var ocusec "Sector of activity"
	la de lblocusec 1 "Public, state owned, government, army, NGO" 2 "Private"
	label values ocusec lblocusec
*</_ocusec_>


** REASONS NOT IN THE LABOR FORCE
*<_nlfreason_>
	gen byte nlfreason=.
	replace nlfreason=1 if r1_undm_whnt==1
	replace nlfreason=2 if r1_undm_whnt==2
	replace nlfreason=3 if r1_undm_whnt==3
	replace nlfreason=5 if r1_undm_whnt==4 | r1_undm_whnt==12
	replace nlfreason=4 if r1_undm_whnt==5
	replace nlfreason=. if nlfreason!=3
	label var nlfreason "Reason not in the labor force"
*</_nlfreason_>
	la de lblnlfreason 1 "Student" 2 "Housewife" 3 "Retired" 4 "Disabled" 5 "Other"
	label values nlfreason lblnlfreason


** UNEMPLOYMENT DURATION: MONTHS LOOKING FOR A JOB
*<_unempldur_l_>
	gen byte unempldur_l=.
	label var unempldur_l "Unemployment duration (months) lower bracket"
*</_unempldur_l_>

*<_unempldur_u_>
	gen byte unempldur_u=.
	label var unempldur_u "Unemployment duration (months) upper bracket"
*</_unempldur_u_>


**ORIGINAL INDUSTRY CLASSIFICATION
*<_industry_orig_>
	gen industry_orig=.
	*replace industry_orig=11 if mergeag1==3

	#delimit
	la def lblindustry_orig
	11	"AGRICULTURE AND HUNTING"
	12	"FORESTRY AND LOGGING"
	13	"FISHING"
	21	"COAL MINING"
	22	"PETROLEUM, GAS PRODUCTION"
	23	"METAL ORE MINING"
	24	"OTHER MINING"
	31	"FOOD, BEVERAGES, TOBACCO"
	32	"TEXTILES, APPAREL, LEATHER"
	33	"WOOD, FURNITURE"
	34	"PAPER/PRINTING/PUBLISHING"
	35	"CHEMICAL/PETROLEUM/PLASTICS"
	36	"OTHER NON-METALLIC"
	37	"BASIC METALLIC"
	38	"FABRICATED METALLIC/MACHINERY "
	39	"HANDICRAFTS AND OTHER"
	41	"ELECTRICITY/GAS/WATER"
	42	"WATER WORKS AND SUPPLIES"
	51	"BUILDING"
	52	"STREETS/HIGHWAYS/BRIDGES"
	53	"IRRIGATION/HYDROELECTRIC"
	54	"SPORTS PROJECTS"
	55	"DOCKS/COMMUNICATIONS"
	56	"SEWERS/WATER MAINS/DRAINS"
	57	"PIPELINES"
	58	"OTHER CONSTRUCTION ACTIVITIES "
	61	"WHOLESALE"
	62	"RETAIL"
	63	"RESTAURANTS/HOTELS"
	71	"TRANSPORT/STORAGE"
	72	"COMMUNICATION"
	81	"FINANCE"
	82	"INSURANCE"
	83	"REAL ESTATE/BUSINESS"
	91	"PUBLIC ADMINISTRATION/DEFENSE "
	92	"SANITARY, ETC"
	93	"SOCIAL, ETC"
	94	"RECREATION/CULTURE"
	95	"PERSONAL/HOUSEHOLD"
	96	"INTERNATIONAL AND OTHER"
	0	"OTHER NON-DEFINED";
	#delimit cr
	la val industry_orig lblindustry_orig
	replace industry_orig=. if lstatus!=1
	la var industry_orig "Original industry code"
*</_industry_orig_>

** INDUSTRY CLASSIFICATION
*<_industry_>
	gen industry=.
	*recode r1_nagacnsic1 (11/13=1) (21/24=2) (31/39=3) (41/42=4) (51/58=5) (61/63=6) (71/72=7) (81/83=8) (91=9) (0 92/99=10) , gen(industry)
	*replace industry=1 if mergeag1==3
	replace industry=. if lstatus==2| lstatus==3
	label var industry "1 digit industry classification"
	la de lblindustry 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industry lblindustry
*</_industry_>

**ORIGINAL OCCUPATION CLASSIFICATION
*<_occup_orig_>
	gen occup_orig=r1_occupcode1
	#delimit
	la def lbloccup_orig
	1	"PHYSICAL SCIENTISTS AND TECHNICIANS"
	2	"ARCHITECTS, ENGINEERS"
	3	"ENGINEERING TECHNICIANS"
	4	"AIRCRAFT AND SHIP OFFICERS"
	5	"LIFE SCIENTISTS AND TECHNICIANS"
	6	"DOCTORS, DENTISTS, ETC"
	7	"MEDICAL, DENTAL, ETC"
	8	"STATISTICIANS, MATHEMATICIANS"
	9	"ECONOMISTS"
	11	"ACCOUNTANTS AND AUDITORS"
	12	"JURISTS"
	13	"TEACHERS"
	14	"RELIGION WORKERS"
	15	"AUTHORS AND WRITERS"
	16	"ARTISTS"
	17	"MUSICIANS AND PERFORMING ARTISTS"
	18	"ATHLETES AND SPORTSMEN"
	19	"OTHER PROFESSIONAL AND TECHNICAL WORKERS"
	20	"LEGISLATIVE AND ADMINISTRATIVE"
	21	"MANAGERS"
	31	"CLERICAL SUPERVISORS"
	32	"TYPISTS AND PUNCH-MACHINE OPERATORS"
	33	"BOOK-KEEPERS, CASHIERS, ETC"
	34	"COMPUTING MACHINE OPERATORS"
	35	"TRANSPORT AND COMMUNICATION SUPERVISORS"
	36	"TRANSPORT CONDUCTORS, GUARDS, ATTENDANTS"
	37	"MAIL DISTRIBUTION CLERKS"
	38	"TELEPHONE AND TELEGRAPH OPERATORS"
	37	"OTHER CLERICAL AND RELATED WORKERS"
	40	"MANAGERS"
	41	"WORKING PROPRIETORS"
	42	"SALES SUPERVISORS AND BUYERS"
	43	"TECHNICAL SALESMEN AND COMMERCIAL TRAVELERS"
	44	"INSURANCE, REAL ESTATE, ETC"
	45	"SALES PERSONNEL AND SHOP ASSISTANTS"
	46	"OTHER SALES WORKERS"
	51	"WORKING PROPRIETORS "
	52	"HOUSEKEEPING & RELATED SERVICES SUPERVISORS"
	53	"COOKS, WAITERS, ETC"
	54	"MAID, VALETS, ETC"
	55	"CARETAKERS, CHARWORKERS, ETC"
	56	"LAUNDRY WORKERS"
	57	"BARBERS AND HAIRDRESSERS "
	58	"PROTECTIVE SERVICE WORKERS "
	59	"OTHER SERVICES WORKERS "
	60	"FARM MANAGERS AND SUPERVISORS "
	61	"FARMERS "
	62	"AGRICULTURAL AND ANIMAL HUSBANDRY WORKERS "
	63	"FORESTRY WORKERS "
	64	"FISHERMEN "
	65	"HUNTERS AND TRAPPERS "
	70	"WORKING PROPRIETORS "
	71	"LABORERS "
	72	"MINERS, QUARRYMEN, ETC"
	73	"METAL PROCESSORS "
	74	"WOOD PREPARATION WORKERS AND PAPER MAKERS "
	75	"CHEMICAL PROCESSORS "
	76	"SPINNERS, WEAVERS, KNITTERS AND DYERS "
	77	"HIDE AND SKIN PROCESSORS "
	78	"FOOD AND BEVERAGE PROCESSORS "
	79	"TOBACCO PRODUCTS WORKERS "
	80	"TAILORS, DRESSMAKERS, UPHOLSTERERS "
	81	"SHOEMAKERS AND LEATHER GOODS MAKERS "
	82	"CABINET MAKERS AND WOODWORKERS "
	83	"STONE CUTTERS AND CARVERS "
	84	"BLACKSMITHS, TOOLMAKERS, ETC"
	85	"MACHINERY FITTERS AND INSTRUMENT MAKERS "
	86	"ELECTRICAL AND ELECTRONICS WORKERS "
	87	"BROADCASTING STATIONS, SOUND EQUIPMENT, ETC"
	88	"PLUMBERS, WELDERS, SHEET METAL WORKERS "
	89	"JEWELRY AND PRECIOUS METAL WORKERS "
	90	"GLASS AND POTTERY WORKERS "
	91	"RUBBER AND PLASTICS PRODUCT MAKERS "
	92	"PAPER AND PAPERBOARD PRODUCT MAKERS "
	96	"OTHER NOT ELSEWHERE CLASSIFIED "
	97	"STUDENT "
	98	"NOT WORKING (HOUSEWIFE, ETC) "
	99	"MILITARY";
	#delimit cr
	la val occup_orig lbloccup_orig
	replace occup_orig=. if lstatus!=1
	la var occup_orig "Original occupation code"
*</_occup_orig_>


** OCCUPATION CLASSIFICATION
*<_occup_>
* HAVE TO FINISH THIS. INCOMPLETE. NEED CODES
	gen occup=r1_occupcode1
	recode occup (1 2 4 6 8 9 11 12 13 14 15 16 17 18 =2) (3 5 7 19 =3) (31/37=4) (40/59=5) (60/65=6) (99=10)
	replace occup=. if r1_occupcode1==97 | r1_occupcode1==98
	replace occup=99 if occup >10 & occup!=.
	replace occup=. if lstatus==2| lstatus==3
	label var occup "1 digit occupational classification"
	la de lbloccup 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup lbloccup
*</_occup_>
	
** FIRM SIZE
*<_firmsize_l_>
	gen byte firmsize_l=.
	label var firmsize_l "Firm size (lower bracket)"
*</_firmsize_l_>

*<_firmsize_u_>

	gen byte firmsize_u=.
	label var firmsize_u "Firm size (upper bracket)"

*</_firmsize_u_>


** HOURS WORKED LAST WEEK
*<_whours_>
	gen whours=r1_7hrperday1*r1_7dayswork1
	replace whours=. if lstatus!=1
	label var whours "Hours of work in last week"
*</_whours_>

** WAGES
*<_wage_>
	*gen double wage=INCOME_MAIN_def if INCOME_MAIN_def>=0 
	gen wage=.
	replace wage=0 if empstat==2
	replace wage=. if lstatus==2  | lstatus==3
	label var wage "Last wage payment"
*</_wage_>

notes _dta: "NPL 1995" Not all sources of wage are included in raw data-sets the survey-specially for aggricultural employment-and variable is created as missing.


** WAGES TIME UNIT
*<_unitwage_>
	gen byte unitwage=.
	label var unitwage "Last wages time unit"
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Quarterly" 7 "Biannual" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage lblunitwage
*</_wageunit_>


** EMPLOYMENT STATUS - SECOND JOB
*<_empstat_2_>
	gen byte empstat_2=.
	replace empstat_2=1 if r1_wgemplagr2==1 | r1_wgemplnag2==1
	replace empstat_2=4 if r1_slemplagr2==1 | r1_slemplnag2==1
	*replace empstat_2=3 if EMPTYPE_MAIN==2
	*replace empstat_2=4 if EMPTYPE_MAIN==3
	replace empstat_2=. if lstatus2==2 | lstatus2==3
	replace empstat_2=. if njobs==0 | njobs==.
	label var empstat_2 "Employment status - second job"
	la de lblempstat_2 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_2 lblempstat_2
*</_empstat_2_>

** EMPLOYMENT STATUS - SECOND JOB LAST YEAR
*<_empstat_2_year_>
	gen byte empstat_2_year=empstat_2
	replace empstat_2_year=. if njobs_year==0 | njobs_year==. | lstatus_year2!=1
	label var empstat_2_year "Employment status - second job"
	la de lblempstat_2_year 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_2_year lblempstat_2
*</_empstat_2_>

** INDUSTRY CLASSIFICATION - SECOND JOB
*<_industry_2_>
	gen industry_2=.
	*recode r1_nagacnsic2 (11/13=1) (21/24=2) (31/39=3) (41/42=4) (51/58=5) (61/63=6) (71/72=7) (81/83=8) (91=9) (0 92/99=10) , gen(industry_2)
	*replace industry_2=1 if mergeag2==3
	*replace industry_2=. if lstatus2==2| lstatus2==3
	*replace industry_2=. if njobs==0 | njobs==.
	label var industry_2 "1 digit industry classification - second job"
	la de lblindustry_2 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industry_2 lblindustry
*<_industry_2_>


**SURVEY SPECIFIC INDUSTRY CLASSIFICATION - SECOND JOB
*<_industry_orig_2_>
	gen industry_orig_2=.
	*gen industry_orig_2=r1_nagacnsic2
	replace industry_orig_2=. if njobs==0 | njobs==. | lstatus2!=1
	label var industry_orig_2 "Original Industry Codes - Second job"
	la de lblindustry_orig_2 1""
	label values industry_orig_2 lblindustry_orig_2
*</_industry_orig_2>


** OCCUPATION CLASSIFICATION - SECOND JOB
*<_occup_2_>
	gen occup_2=r1_occupcode2
	recode occup_2 (1 2 4 6 8 9 11 12 13 14 15 16 17 18 =2) (3 5 7 19 =3) (31/37=4) (40/59=5) (60/65=6) (99=10)
	replace occup_2=. if r1_occupcode2==97 | r1_occupcode2==98
	replace occup_2=99 if occup_2 >10 & occup_2!=.
	replace occup=. if lstatus==2| lstatus2==3
	replace occup_2=. if njobs==0 | njobs==.
	label var occup_2 "1 digit occupational classification - second job"
	la de lbloccup_2 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup_2 lbloccup_2
*</_occup_2_>


** WAGES - SECOND JOB
*<_wage_2_>
	gen double wage_2=.
	replace wage_2=. if njobs==0 | njobs==.
	label var wage_2 "Last wage payment - Second job"
*</_wage_2_>


** WAGES TIME UNIT - SECOND JOB
*<_unitwage_2_>
	gen byte unitwage_2=.
	replace unitwage_2=. if njobs==0 | njobs==.
	label var unitwage_2 "Last wages time unit - Second job"
	la de lblunitwage_2 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Every two months"  5 "Monthly" 6 "Quarterly" 7 "Every six months" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage_2 lblunitwage_2
*</_unitwage_2_>



** CONTRACT
*<_contract_>
	gen byte contract=.
	label var contract "Contract"
	la de lblcontract 0 "Without contract" 1 "With contract"
	label values contract lblcontract
*</_contract_>


** HEALTH INSURANCE
*<_healthins_>
	gen byte healthins=.
	label var healthins "Health insurance"
	la de lblhealthins 0 "Without health insurance" 1 "With health insurance"
	label values healthins lblhealthins
*</_healthins_>


** SOCIAL SECURITY
*<_socialsec_>
	gen byte socialsec=.
	label var socialsec "Social security"
	la de lblsocialsec 1 "With" 0 "Without"
	label values socialsec lblsocialsec
*</_socialsec_>


** UNION MEMBERSHIP

*<_union_>
	gen byte union=.
	label var union "Union membership"
	la de lblunion 0 "No member" 1 "Member"
	label values union lblunion
*</_union_>

	local lb_var "lstatus lstatus_year empstat empstat_year njobs_year ocusec nlfreason unempldur_l unempldur_u industry_orig industry occup_orig occup firmsize_l firmsize_u whours wage unitwage empstat_2 empstat_2_year industry_2 industry_orig_2 occup_2"
	foreach v in `lb_var'{
	di "check `v' only for age>=lb_mod_age"

	replace `v'=. if( age<lb_mod_age & age!=.)
	}

	
/*****************************************************************************************************
*                                                                                                    *
                                   MIGRATION MODULE
*                                                                                                    *
*****************************************************************************************************/


**REGION OF BIRTH JURISDICTION
*<_rbirth_juris_>
	gen byte rbirth_juris=.
	label var rbirth_juris "Region of birth jurisdiction"
	la de lblrbirth_juris 1 "subnatid1" 2 "subnatid2" 3 "subnatid3" 4 "Other country"  9 "Other code"
	label values rbirth_juris lblrbirth_juris
*</_rbirth_juris_>

**REGION OF BIRTH
*<_rbirth_>
	gen byte rbirth=.
	label var rbirth "Region of Birth"
*</_rbirth_>

** REGION OF PREVIOUS RESIDENCE JURISDICTION
*<_rprevious_juris_>
	gen byte rprevious_juris=.
	label var rprevious_juris "Region of previous residence jurisdiction"
	la de lblrprevious_juris 1 "reg01" 2 "reg02" 3 "reg03" 4 "Other country"  9 "Other code"
	label values rprevious_juris lblrprevious_juris
*</_rprevious_juris_>

**REGION OF PREVIOUS RESIDENCE
*<_rprevious_>
	gen byte rprevious=.
	label var rprevious "Region of previous residence"
*</_rprevious_>

** YEAR OF MOST RECENT MOVE
*<_yrmove_>
	gen int yrmove=.
	label var yrmove "Year of most recent move"
*</_yrmove_>
	
	
	
	
/*****************************************************************************************************
*                                                                                                    *
                                            ASSETS 
*                                                                                                    *
*****************************************************************************************************/

** LAND PHONE
*<_landphone_>
	gen byte landphone=r1_telephone
	recode landphone (2=0)
	label var landphone "Household has landphone"
	la de lbllandphone 0 "No" 1 "Yes"
	label values landphone lbllandphone
*</_landphone_>


** CEL PHONE
*<_cellphone_>
	gen cellphone=r1_durbl_nm512>0 & r1_durbl_nm512<.
	label var cellphone "Household has Cell phone"
	la de lblcellphone 0 "No" 1 "Yes"
	label values cellphone lblcellphone
*</_cellphone_>


** COMPUTER
*<_computer_>
	gen byte computer=.
	label var computer "Household has Computer"
	la de lblcomputer 0 "No" 1 "Yes"
	label values computer lblcomputer
*</_computer_>

** RADIO
*<_radio_>
	gen radio=r1_durbl_nm501>0 & r1_durbl_nm501<.
	label var radio "Household has radio"
	la de lblradio 0 "No" 1 "Yes"
	label val radio lblradio
*</_radio_>

** TELEVISION
*<_television_>
	gen television=r1_durbl_nm510>0 & r1_durbl_nm510<.
	label var television "Household has Television"
	la de lbltelevision 0 "No" 1 "Yes"
	label val television lbltelevision
*</_television>

** FAN
*<_fan_>
	gen fan=r1_durbl_nm508>0 & r1_durbl_nm508<.
	label var fan "Household has Fan"
	la de lblfan 0 "No" 1 "Yes"
	label val fan lblfan
*</_fan>

** SEWING MACHINE
*<_sewingmachine_>
	gen sewingmachine=r1_durbl_nm513>0 & r1_durbl_nm513<.
	label var sewingmachine "Household has Sewing machine"
	la de lblsewingmachine 0 "No" 1 "Yes"
	label val sewingmachine lblsewingmachine
*</_sewingmachine>

** WASHING MACHINE
*<_washingmachine_>
	gen washingmachine=r1_durbl_nm507>0 & r1_durbl_nm507<.
	label var washingmachine "Household has Washing machine"
	la de lblwashingmachine 0 "No" 1 "Yes"
	label val washingmachine lblwashingmachine
*</_washingmachine>

** REFRIGERATOR
*<_refrigerator_>
	gen refrigerator=r1_durbl_nm506>0 & r1_durbl_nm506<.
	label var refrigerator "Household has Refrigerator"
	la de lblrefrigerator 0 "No" 1 "Yes"
	label val refrigerator lblrefrigerator
*</_refrigerator>

** LAMP
*<_lamp_>
	gen lamp=.
	label var lamp "Household has Lamp"
	la de lbllamp 0 "No" 1 "Yes"
	label val lamp lbllamp
*</_lamp>

** BYCICLE
*<_bycicle_>
	gen bicycle=r1_durbl_nm503>0 & r1_durbl_nm503<.
	label var bicycle "Household has Bicycle"
	la de lblbycicle 0 "No" 1 "Yes"
	label val bicycle lblbycicle
*</_bycicle>

** MOTORCYCLE
*<_motorcycle_>
	gen motorcycle=r1_durbl_nm504>0 & r1_durbl_nm504<.
	label var motorcycle "Household has Motorcycle"
	la de lblmotorcycle 0 "No" 1 "Yes"
	label val motorcycle lblmotorcycle
*</_motorcycle>

** MOTOR CAR
*<_motorcar_>
	gen motorcar=r1_durbl_nm505>0 & r1_durbl_nm505<.
	label var motorcar "Household has Motor car"
	la de lblmotorcar 0 "No" 1 "Yes"
	label val motorcar lblmotorcar
*</_motorcar>

** COW
*<_cow_>
	gen cow=r1_lvstownno1>0 & r1_lvstownno1<.
	label var cow "Household has Cow"
	la de lblcow 0 "No" 1 "Yes"
	label val cow lblcow
*</_cow>

** BUFFALO
*<_buffalo_>
	gen buffalo=r1_lvstownno2>0 & r1_lvstownno2<.
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
                                   WELFARE MODULE
*                                                                                                    *
*****************************************************************************************************/

** SPATIAL DEFLATOR
*<_spdef_>
	gen spdef=c1_pindex
	la var spdef "Spatial deflator"
*</_spdef_>

** WELFARE
*<_welfare_>
	gen welfare=c1_ra_pcexp/12
	la var welfare "Welfare aggregate"
*</_welfare_>

*<_welfarenom_>
	gen welfarenom=c1_npcexp/12
	la var welfarenom "Welfare aggregate in nominal terms"
*</_welfarenom_>

*<_welfaredef_>
	gen welfaredef=c1_ra_pcexp/12
	la var welfaredef "Welfare aggregate spatially deflated"
*</_welfaredef_>

*<_welfshprosperity_>
	gen welfshprosperity=welfare
	la var welfshprosperity "Welfare aggregate for shared prosperity"
*</_welfshprosperity_>

*<_welfaretype_>
	gen welfaretype="EXP"
	la var welfaretype "Type of welfare measure (income, consumption or expenditure) for welfare, welfarenom, welfaredef"
*</_welfaretype_>

*<_welfareother_>
	gen welfareother=.
	la var welfareother "Welfare Aggregate if different welfare type is used from welfare, welfarenom, welfaredef"
*</_welfareother_>

*<_welfareothertype_>
	gen welfareothertype=""
	la var welfareothertype "Type of welfare measure (income, consumption or expenditure) for welfareother"
*</_welfareothertype_>

*<_welfarenat_>
	gen welfarenat=c1_npcexp/12
	la var welfarenat "Welfare aggregate for national poverty"
*</_welfarenat_>


*QUINTILE, DECILE AND FOOD/NON-FOOD SHARES OF CONSUMPTION AGGREGATE
	levelsof year, loc(y)
	merge m:1 idh using "$shares\\NPL_fnf_`y'", keepusing (food_share nfood_share quintile_cons_aggregate decile_cons_aggregate)
	drop _merge

/*****************************************************************************************************
*                                                                                                    *
                                   NATIONAL POVERTY
*                                                                                                    *
*****************************************************************************************************/

	
** POVERTY LINE (NATIONAL)
*<_pline_nat_>
	gen pline_nat=c1_nompln/12
	label variable pline_nat "Poverty Line (National)"
*</_pline_nat_>


** HEADCOUNT RATIO (NATIONAL)
*<_poor_nat_>
	gen poor_nat=welfarenat<pline_nat if welfarenat!=.
	la var poor_nat "People below Poverty Line (National)"
	la define poor_nat 0 "Not-Poor" 1 "Poor"
	la values poor_nat poor_nat
*</_poor_nat_>


/*****************************************************************************************************
*                                                                                                    *
                                   INTERNATIONAL POVERTY
*                                                                                                    *
*****************************************************************************************************/


	local year=2011
	
** USE SARMD CPI AND PPP
*<_cpi_>
	capture drop _merge
	gen urb=.
	merge m:1 countrycode year urb using "$pricedata", ///
	keepusing(countrycode year urb syear cpi`year'_w ppp`year')
	drop urb
	drop if _merge==2
	drop _merge
	
	
** CPI VARIABLE
	ren cpi`year'_w cpi
	label variable cpi "CPI (Base `year'=1)"
*</_cpi_>
	
	
** PPP VARIABLE
*<_ppp_>
	ren ppp`year' 	ppp
	label variable ppp "PPP `year'"
*</_ppp_>

	
** CPI PERIOD
*<_cpiperiod_>
	gen cpiperiod=syear
	label var cpiperiod "Periodicity of CPI (year, year&month, year&quarter, weighted)"
*</_cpiperiod_>	
	
** POVERTY LINE (POVCALNET)
*<_pline_int_>
	gen pline_int=1.90*cpi*ppp*365/12
	label variable pline_int "Poverty Line (Povcalnet)"
*</_pline_int_>
	
	
** HEADCOUNT RATIO (POVCALNET)
*<_poor_int_>
	gen poor_int=welfare<pline_int & welfare!=.
	la var poor_int "People below Poverty Line (Povcalnet)"
	la define poor_int 0 "Not Poor" 1 "Poor"
	la values poor_int poor_int
*</_poor_int_>


/*****************************************************************************************************
*                                                                                                    *
                                   FINAL STEPS
*                                                                                                    *
*****************************************************************************************************/
** KEEP VARIABLES - ALL
	do "$fixlabels\fixlabels", nostop

	keep countrycode year survey idh idp wgt pop_wgt strata psu vermast veralt urban int_month int_year subnatid0  ///
		subnatid1 subnatid2 subnatid3 ownhouse landholding tenure water_orig piped_water water_jmp sar_improved_water  electricity toilet_orig sewage_toilet toilet_jmp sar_improved_toilet  landphone cellphone ///
	     computer internet hsize relationharm relationcs male age soc marital ed_mod_age everattend ///
	     atschool electricity literacy educy educat4 educat5 educat7 lb_mod_age lstatus lstatus_year empstat empstat_year njobs njobs_year ///
	     ocusec nlfreason unempldur_l unempldur_u industry_orig industry occup_orig occup firmsize_l firmsize_u whours wage ///
		  unitwage empstat_2 empstat_2_year industry_2 industry_orig_2 occup_2 wage_2 unitwage_2 contract healthins socialsec union rbirth_juris rbirth rprevious_juris rprevious yrmove ///
		 landphone cellphone computer radio television fan sewingmachine washingmachine refrigerator lamp bicycle motorcycle motorcar cow buffalo chicken  ///
		 pline_nat pline_int poor_nat poor_int spdef cpi ppp cpiperiod welfare welfshprosperity welfarenom food_share nfood_share quintile_cons_aggregate decile_cons_aggregate welfaredef welfarenat welfareother welfaretype welfareothertype  
		 
** ORDER VARIABLES

	order countrycode year survey idh idp wgt pop_wgt strata psu vermast veralt urban int_month int_year subnatid0 ///
		subnatid1 subnatid2 subnatid3 ownhouse landholding tenure water_orig piped_water water_jmp sar_improved_water electricity toilet_orig sewage_toilet toilet_jmp sar_improved_toilet  landphone cellphone ///
	     computer internet hsize relationharm relationcs male age soc marital ed_mod_age everattend ///
	     atschool electricity literacy educy educat4 educat5 educat7 lb_mod_age lstatus lstatus_year empstat empstat_year njobs njobs_year ///
	     ocusec nlfreason unempldur_l unempldur_u industry_orig industry occup_orig occup firmsize_l firmsize_u whours wage ///
		  unitwage empstat_2 empstat_2_year industry_2 industry_orig_2 occup_2 wage_2 unitwage_2 contract healthins socialsec union rbirth_juris rbirth rprevious_juris rprevious yrmove ///
		 landphone cellphone computer radio television fan sewingmachine washingmachine refrigerator lamp bicycle motorcycle motorcar cow buffalo chicken  ///
		 pline_nat pline_int poor_nat poor_int spdef cpi ppp cpiperiod welfare welfshprosperity welfarenom food_share nfood_share quintile_cons_aggregate decile_cons_aggregate welfaredef welfarenat welfareother welfaretype welfareothertype  
	compress

** DELETE MISSING VARIABLES

	local keep ""
	qui levelsof countrycode, local(cty)
	foreach var of varlist urban - welfareother {
	qui sum `var'
	scalar sclrc = r(mean)
	if sclrc==. {
	     display as txt "Variable " as result "`var'" as txt " for countrycode " as result `cty' as txt " contains all missing values -" as error " Variable Deleted"
	}
	else {
	     local keep `keep' `var'
	}
	}
	
	foreach w in welfare welfareother{
	qui su `w'
	if r(N)==0{
	drop `w'type
}
}
	keep countrycode year survey idh idp wgt pop_wgt strata psu vermast veralt `keep' *type

	compress
	
	saveold "`output'\Data\Harmonized\NPL_1995_LSS-I_v01_M_v03_A_SARMD-FULL_IND.dta", replace version(12)
	saveold "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\__REGIONAL\Individual Files\NPL_1995_LSS-I_v01_M_v03_A_SARMD-FULL_IND.dta", replace version(12)
	
	notes
	
	log close


*********************************************************************************************************************************	
******RENAME COMPARABLE VARIABLES AND SAVE THEM IN _SARMD. UNCOMPARABLE VARIALBES ACROSS TIME SHOULD BE FOUND IN _SARMD-FULL*****
*********************************************************************************************************************************

loc var cellphone pline_nat pline_int poor_nat poor_int spdef cpi ppp cpiperiod welfare welfarenom welfaredef welfarenat welfareother welfshprosperity ///
 welfareothertype industry_orig industry industry_2 industry_orig_2 lb_mod_age lstatus lstatus_year empstat empstat_year njobs ///
 njobs_year nlfreason occup_orig occup whours empstat_2 empstat_2_year occup_2 piped_water water_jmp sar_improved_water food_share nfood_share quintile_cons_aggregate decile_cons_aggregate
 
foreach i of loc var{

cap sum `i'

	if _rc==0{
	loc a: var label `i'
	la var `i' "`a'-old non-comparable version"
	cap rename `i' `i'_v2
	}
	else if _rc==111{
	dis as error "Variable `i' does not exist in data-base"
	}
	
}	
	note _dta: "NPL 1995" Variables NAMED with "v2" are those not compatible with latest round (2010). ///
 These include the existing information from the particular survey, but the iformation should be used for comparability purposes  

	saveold "`output'\Data\Harmonized\NPL_1995_LSS-I_v01_M_v03_A_SARMD_IND.dta", replace version(12)
	saveold "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\__REGIONAL\Individual Files\NPL_1995_LSS-I_v01_M_v03_A_SARMD_IND.dta", replace version(12)



******************************  END OF DO-FILE  *****************************************************/

