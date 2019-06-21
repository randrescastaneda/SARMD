/*****************************************************************************************************
******************************************************************************************************
**                                                                                                  **
**                                   SOUTH ASIA MICRO DATABASE                                      **
**                                                                                                  **
** COUNTRY			Afghanistan
** COUNTRY ISO CODE	AFG
** YEAR				2011
** SURVEY NAME		National Risk and Vulnerability Assessment 2011-2012
** SURVEY AGENCY	Central Statistics Organization
** RESPONSIBLE		Triana Yentzen
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
	local input "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\AFG\AFG_2007_NRVA\AFG_2007_NRVA_v01_M"
	local output "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\AFG\AFG_2007_NRVA\AFG_2007_NRVA_v01_M_v03_A_SARMD"

** LOG FILE
	log using "`output'\Doc\Technical\AFG_2007_NRVA_v01_M_v03_A_SARMD.log",replace


/*****************************************************************************************************
*                                                                                                    *
                                   * ASSEMBLE DATABASE
*                                                                                                    *
*****************************************************************************************************/


** DATABASE ASSEMBLENT

	* PREPARE DATASETS

	global data  = "`input'\Data\Stata"  

	tempfile Area_Name_modified
	use "$data\Area_Name.dta", clear 
	sort cid 
	save `Area_Name_modified', replace 

	tempfile S1_modified
	use "$data\S1.dta", clear 
	sort hhid hhmemid 
	save `S1_modified', replace 

	tempfile S6_modified
	use "$data\S6.dta", clear 
	sort hhid hhmemid 
	save `S6_modified', replace 

	tempfile S7_modified
	use "$data\S7.dta", clear 
	sort hhid hhmemid 
	save `S7_modified', replace 

	tempfile S8_modified
	use "$data\S8.dta", clear 
	sort hhid 
	save `S8_modified', replace 

	tempfile S9A_modified
	use "$data\S9A.dta", clear 
	sort hhid hhmemid 
	save `S9A_modified', replace 

	tempfile S9B_modified
	use "$data\S9B.dta", clear 
	sort hhid hhmemid 
	save `S9B_modified', replace 

	tempfile S20B_modified
	use "$data\S20B.dta", clear 
	sort hhid hhmemid 
	save `S20B_modified', replace 

	tempfile CM4_modified
	use "$data\CM4.dta", clear 
	sort cid 
	save `CM4_modified.dta', replace 

	tempfile S2A_modified
	use "$data\S2A.dta", clear 
	sort hhid 
	save `S2A_modified', replace 

	tempfile S2B_modified
	use "$data\S2B.dta", clear 
	sort hhid 
	save `S2B_modified', replace 

	tempfile poverty_modified
	use "$data\poverty2007.dta", clear 
	sort hhid 
	ren hhsize hhsize_nat
	save `poverty_modified', replace 
	
	/*
	tempfile pov_cons_modified
	use "$data\pov_cons.dta", clear 
	sort hhid 
	save `pov_cons_modified', replace 
	*/

	* COMBINE DATASETS

	use `S1_modified', clear 

	sort cid 
	merge cid using `Area_Name_modified'
	tab _merge 
	drop if _merge == 2 
	drop _merge 

	order cid provincec provincen districtc hhid hhmemid districtn villagec villagen subnahia Block_No qrt urk kuchic ///
	 urbrur targetm clustern Province_Name_Dari District_Name_Dari Village_Name_Dari pcenter nohhs ProvDari area_weight 

	foreach x in S6_modified S7_modified S9A_modified S9B_modified{
	sort hhid hhmemid
	merge 1:1 hhid hhmemid using ``x''
	tab _merge
	drop if _merge==2
	drop _merge	
	}

	foreach x in S8_modified S2A_modified S2B_modified poverty_modified{
	sort hhid hhmemid
	merge m:1 hhid using ``x''
	tab _merge
	drop if _merge==2
	drop _merge	
	}

	sort cid 
	merge cid using `CM4_modified'
	tab _merge 
	drop if _merge == 2 
	drop _merge 

	sort hhid hhmemid

/*****************************************************************************************************
*                                                                                                    *
                                   * STANDARD SURVEY MODULE
*                                                                                                    *
*****************************************************************************************************/
	
	
** COUNTRY

*<_countrycode_>
	gen str4 countrycode="AFG"	
	label var countrycode "Country code"
*</_countrycode_> 

** YEAR
*<_year_> 
	gen int year=2007
	label var year "Year of survey"
*</_year_>
 
 
** SURVEY NAME 
*<_survey_>
	gen str survey="NRVA"
	label var survey "Survey Acronym"
*</_survey_>

	
** INTERVIEW YEAR
*<_int_year_> 
	gen byte int_year=.
	label var int_year "Year of the interview"
*</_int_year_> 

** INTERVIEW MONTH
*<_int_month_> 
	gen byte int_month=targetm
	la de lblint_month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label value int_month lblint_month
	label var int_month "Month of the interview"
*</_int_month_> 

** HOUSEHOLD IDENTIFICATION NUMBER
*<_idh_>
	gen double idh = hhid
	format idh %16.0f
	tostring idh, replace
	label var idh "Household id"
*</_idh_> 

** INDIVIDUAL IDENTIFICATION NUMBER
*<_idp_>
	egen idp=concat(hhid hhmemid), punct(-)
	label var idp "Individual id"
*</_idp_>

** HOUSEHOLD WEIGHTS
*<_wgt_>
	gen double wgt=hh_weight
	label var wgt "Household sampling weight"
*</_wgt_>


** STRATA
*<_strata_>
	gen strata=stratum
	label var strata "Strata"
*</_strata_>


** PSU
*<_psu_>
	gen psu=cid
	label var psu "Primary sampling units"
*</_psu_>


** MASTER VERSION
*<_vermast_>
	gen vermast="01"
	label var vermast "Master Version"
*</_vermast_>
	
	
** ALTERATION VERSION
*<_veralt_>
	gen veralt="02"
	label var veralt "Alteration Version"
*</_veralt_>	

/*****************************************************************************************************
*                                                                                                    *
                                   HOUSEHOLD CHARACTERISTICS MODULE
*                                                                                                    *
*****************************************************************************************************/


** LOCATION (URBAN/RURAL)
*<_urban_>

	** Urban rural variable according to CSO's definition
	** There are 26 cluster of settled HH where "urbrur" is missing
	** Identify using " Block_No", the value always be 0 in rural area
	replace urbrur = 1 if  Block_No!=0 & Block_No!=.
	replace urbrur = 0 if  Block_No==0
	gen byte urban=urbrur
	label var urban "Urban/Rural"
	la de lblurban 1 "Urban" 0 "Rural"
	label values urban lblurban
*</_urban_>


**REGIONAL AREAS

** REGIONAL AREA 1 DIGIT ADMN LEVEL
*<_subnatid1_>
	gen byte subnatid1=region
	la de lblsubnatid1 1 "Central" 2 "South" 3 "East" 4 "Northeast" 5 "North" 6 "West" 7 "Southwest" 8 "West-Central"
	label var subnatid1 "Region at 1 digit (ADMN1)"
	label values subnatid1 lblsubnatid1
*</_subnatid1_>


** REGIONAL AREA 2 DIGIT ADMN LEVEL
*<_subnatid2_>
	gen byte subnatid2=provincec
	la de lblsubnatid2 1 "Kabul" 2 "Kapisa" 3 "Parwan" 4 "Wardak" 5 "Logar" 6 "Ghazni" 7 "Paktika" 8 "Paktya" 9 "Khost" 10 "Nangarhar" 11 "Kunarha" 12 "Laghman" 13 "Nuristan" 14 "Badakhshan" 15 "Takhar" 16 "Baghlan" 17 "Kunduz" 18 "Samangan" 19 "Balkh" 20 "Jawzjan" 21 "Sar-I-Poul" 22 "Faryab" 23 "Badghis" 24 "Hirat" 25 "Farah" 26 "Nimroz" 27 "Helmand" 28 "Kandahar" 29 "Zabul" 30 "Uruzgan" 31 "Ghor" 32 "Bamyan" 33 "Panjsher" 34 "Daikindi"
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
	gen byte ownhouse=.
	replace ownhouse=1 if inlist(q_2_9,1,2,3,4,5)
	replace ownhouse=0 if inlist(q_2_9,6,7,8,9,10)
	label var ownhouse "House ownership"
	la de lblownhouse 0 "No" 1 "Yes"
	label values ownhouse lblownhouse
*</_ownhouse_>

** WATER PUBLIC CONNECTION
*<_water_>
	gen byte water=.
	replace water=4 if q_2_31a==1 | q_2_31b==1 | q_2_31g==1
	replace water=1 if (q_2_31i==1 | q_2_31j==1 | q_2_31k==1) & water==.
	replace water=3 if (q_2_31c==1 | q_2_31e==1 | q_2_31f==1 | q_2_31h==1) & water==.
	replace water=2 if q_2_31d==1 & water==.
	replace water=7 if (q_2_31s==1 | q_2_31t==1) & water==.
	replace water=9 if (q_2_31l==1 | q_2_31m==1 | q_2_31o==1 | q_2_31p==1 | q_2_31q==1 | q_2_31u==1) & water==.
	replace water=5 if q_2_31r==1 & water==.
	replace water=6 if q_2_31n==1 & water==.
	recode water (2 3 4 5 6 7 9 = 0)
	label var water "Water main source"
	la de lblwater 0 "No" 1 "Yes"
	label values water lblwater
*</_water_>

** ELECTRICITY PUBLIC CONNECTION
*<_electricity_>

	recode q_2_22 (1/3=0)(4=1)(5=0)(6/9=0), gen(electricity)
	label var electricity "Electricity main source"
	la de lblelectricity 0 "No" 1 "Yes"
	label values electricity lblelectricity
*</_electricity_>

** TOILET PUBLIC CONNECTION
*<_toilet_>

	 recode q_2_26 (1=0)(2 3=0)(4 5=0)(6=1)(7=0), gen(toilet)
	label var toilet "Toilet facility"
	la de lbltoilet 0 "No" 1 "Yes"
	label values toilet lbltoilet
*</_toilet_>


** LAND PHONE
*<_landphone_>

	gen byte landphone=.
	label var landphone "Phone availability"
	la de lbllandphone 0 "No" 1 "Yes"
	label values landphone lbllandphone
*</_landphone_>


** CEL PHONE
*<_cellphone_>

	gen byte cellphone=.
	label var cellphone "Cell phone"
	la de lblcellphone 0 "No" 1 "Yes"
	label values cellphone lblcellphone
*</_cellphone_>


** COMPUTER
*<_computer_>
	gen byte computer=.
	label var computer "Computer availability"
	la de lblcomputer 0 "No" 1 "Yes"
	label values computer lblcomputer
*</_computer_>


** INTERNET
	gen byte internet=.
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
	replace z=0 if q_1_1==15
	egen byte hsize=sum(z), by(idh)
	la var hsize "Household size"
*</_hsize_>


** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
*<_relationharm_>
	gen byte relationharm=q_1_1 
	recode relationharm (17 = 3) (7 16 =4) (4 5 6 7 8 9 10 11 12 13 14 18= 5) (15=6)
	label var relationharm "Relationship to the head of household"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Non-relatives"

	gen head=relationharm==1
	bys hhid: egen heads=total(head)

	replace q_1_1=14 if heads!=1 & hhmemid>1 & hhmemid!=. & q_1_1==1
	replace relationharm=5 if heads!=1 & q_1_1==1

	replace q_1_1=1 if heads==0
	replace relationharm=1 if heads==0
	drop head heads
	
	label values relationharm  lblrelationharm
*</_relationharm_>

** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
*<_relationcs_>
	gen byte relationcs=q_1_1
	la var relationcs "Relationship to the head of household country/region specific"
	label define lblrelationcs 1 "Household Head" 2 "Husband/Wife" 3 "Son/Daughter" 4 "Son-in-law/Daughter-in-law" 5 "Grandchild" 6 "Nephew/Niece" 7 "Father/Mother" 8 "Father-in-law/Mother-in-law" 9 "Grandfather/Grandmother" 10 "Brother/Sister" 11 "Brother-in-law/Sister-in-law" 12 "Uncle/Aunt" 13 "Amboq" 14 "Other relatives" 15 "Unrelated male/female" 16 "Stepfather/stepmother" 17 "Stepdaughter/Stepson" 18 "Step-sister/step-brother"
	label values relationcs lblrelationcs
*</_relationcs_>


** GENDER
*<_male_>
	gen byte male=q_1_2
	recode male (2=0)
	label var male "Sex of household member"
	la de lblmale 1 "Male" 0 "Female"
	label values male lblmale
*</_male_>

	
** AGE
*<_age_>
	gen byte age=q_1_3
	label var age "Age of individual"
*</_age_>

	
** SOCIAL GROUP
*<_soc_>
	gen byte soc=.
	label var soc "Social group"
	la de lblsoc 1 ""
	label values soc lblsoc
*</_soc_>

	
** MARITAL STATUS
*<_marital_>
	gen byte marital=q_1_4
	recode marital (4 5 = 2) (3=5) (2=4)
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
	gen byte ed_mod_age=6
	label var ed_mod_age "Education module application age"
	*** recode to missing the education variables for individuals who should not have respondend to these questions
	replace q_6_2 = . if  age < 6 
	replace q_6_3 = . if  age < 6 
	replace q_6_4 = . if  age < 6 
	replace q_6_5_l = . if  age < 6 
	replace q_6_5_y = . if  age < 6 
	replace q_6_6 = . if  age < 6 
	replace q_6_8 = . if  age < 6 |  age > 18 
	replace q_6_9 = . if  age < 6 |  age > 18 
	replace q_6_10 = . if  age < 6 |  age > 18 
	replace q_6_11_1 = . if  age < 6 |  age > 18 
	replace q_6_11_2 = . if  age < 6 |  age > 18 
*</_ed_mod_age_>


** CURRENTLY AT SCHOOL
*<_atschool_>
	gen byte atschool=q_6_8
	recode atschool (2=0)
	replace atschool = 0 if q_6_3 == 2
	replace atschool = . if age < 6
	replace atschool = . if age > 18
	label var atschool "Attending school"
	la de lblatschool 0 "No" 1 "Yes"
	label values atschool  lblatschool
*</_atschool_>


** CAN READ AND WRITE
*<_literacy_>
	gen byte literacy=q_6_2
	recode literacy (2=0)
	replace literacy = 1 if q_6_5_l >= 2 & q_6_5_l <.
	label var literacy "Can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy
*</_literacy_>


** YEARS OF EDUCATION COMPLETED
*<_educy_>
	gen  educy = . 
	*** assign a zero to those who never attended school ***
	replace  educy = 0 if q_6_3 == 2 

	* calculate years based on highest level and years attended or attending ***
	replace  educy = 0 + q_6_5_y if q_6_5_l == 1 
	replace  educy = 6 + q_6_5_y if q_6_5_l == 2 
	replace  educy = 9 + q_6_5_y if q_6_5_l == 3 
	replace  educy = 12 + q_6_5_y if q_6_5_l == 4 
	replace  educy = 12 + q_6_5_y if q_6_5_l == 5 
	replace  educy = 16 + q_6_5_y if q_6_5_l == 6 

	*** subtract one year for those who are currently attending school ***
	replace  educy =  educy - 1 if q_6_8 == 1 

	*** correct for any negative years ***
	replace  educy = 0 if  educy < 0 

	*** correct for age lower than years of education
	replace educy=. if age<educy & educy!=. & age!=.
	label var educy "Years of education"
*</_educy_>


** EDUCATION LEVEL 4 CATEGORIES
*<_educat4_>
	gen byte educat4=q_6_5_l
	recode educat4 (1 = 2 ) (2 3 =3) (4 5 6 7=4) (0=.)
	replace educat4=1 if q_6_3 == 2 
	label var educat4 "Level of education 4 categories"
	label define lbleducat4 1 "No education" 2 "Primary (complete or incomplete)" ///
	3 "Secondary (complete or incomplete)" 4 "Tertiary (complete or incomplete)"
	label values educat4 lbleducat4
*</_educat4_>



** EDUCATION LEVEL 5 CATEGORIES
*<_educat5_>
	gen educat5=.
	replace educat5=1 if educat4==1
	replace educat5=2 if q_6_5_l==1 & q_6_5_y<6 &q_6_5_y!=.
	replace educat5=3 if (q_6_5_l==1 & q_6_5_y==6 ) | q_6_5_l==2 | (q_6_5_l==3 & q_6_5_y<3 & q_6_5_y!=.)
	replace educat5=4 if q_6_5_l==3 & q_6_5_y==3
	replace educat5=5 if q_6_5_l>3 & q_6_5_l!=.
	label define lbleducat5 1 "No education" 2 "Primary incomplete" ///
	3 "Primary complete but secondary incomplete" 4 "Secondary complete" ///
	5 "Some tertiary/post-secondary"
	label values educat5 lbleducat5
*</_educat5_>

	la var educat5 "Level of education 5 categories"

** EDUCATION LEVEL 7 CATEGORIES
*<_educat7_>
	gen educat7=.
	replace educat7=1 if educat4==1
	replace educat7=2 if q_6_5_l==1 & q_6_5_y<6 &q_6_5_y!=.
	replace educat7=3 if (q_6_5_l==1 & q_6_5_y==6 ) 
	replace educat7=4 if q_6_5_l==2 | (q_6_5_l==3 & q_6_5_y<3 & q_6_5_y!=.)
	replace educat7=5 if q_6_5_l==3 & q_6_5_y==3
	replace educat7=6 if q_6_5_l==4
	replace educat7=7 if q_6_5_l>4 & q_6_5_l<7
	la var educat7 "Level of education 7 categories"
	label define lbleducat7 1 "No education" 2 "Primary incomplete" 3 "Primary complete" ///
	4 "Secondary incomplete" 5 "Secondary complete" 6 "Higher than secondary but not university" /// 
	7 "University incomplete or complete" 8 "Other" 9 "Not classified"
	label values educat7 lbleducat7
*</_educat7_>


	
** EVER ATTENDED SCHOOL
*<_everattend_>
	gen byte everattend=q_6_3
	replace everattend = 1 if atschool==1
	recode everattend (2=0)
	replace everattend = . if age < 6
	label var everattend "Ever attended school"
	la de lbleverattend 0 "No" 1 "Yes"
	label values everattend lbleverattend
*</_everattend_>



/*****************************************************************************************************
*                                                                                                    *
                                   LABOR MODULE
*                                                                                                    *
*****************************************************************************************************/


** LABOR MODULE AGE
*<_lb_mod_age_>
 gen byte lb_mod_age=16
	label var lb_mod_age "Labor module application age"

	***recode to missing the income variables for individuals who should not have respondend to these questions
	***child labor is NOT included

	forval i=9/26{
	replace q_9_`i' = . if age < 16 
	}
*</_lb_mod_age_>

** LABOR STATUS
*<_lstatus_>
	gen  lstatus = 1 if  inlist(1, q_9_12, q_9_13, q_9_9, q_9_10, q_9_11)  
	replace  lstatus = 1 if q_9_15==1 & mi( lstatus) 
	replace  lstatus = 2 if q_9_16==1 & mi( lstatus)  
	replace  lstatus = 2 if inlist(q_9_17, 6, 7) & mi( lstatus)  
	replace  lstatus = 3 if inlist(q_9_17, 10, 11) & mi( lstatus)  
	replace  lstatus = 4 if mi( lstatus ) & age >=16  
	recode lstatus (4=3)
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non LF"
	label values lstatus lbllstatus
*</_lstatus_>


** EMPLOYMENT STATUS
*<_empstat_>
	gen byte empstat = q_9_19
	recode empstat (1 2 3 = 1)  (6=2) (5=3) (4=4)
	replace empstat=. if lstatus!=1
	label var empstat "Employment status"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee/Family worker" 3 "Employer" 4 "Self-employed" 5 "Other, not classificable"
	label values empstat lblempstat
*</_empstat_>


** SECTOR OF ACTIVITY: PUBLIC - PRIVATE
*<_njobs_>
	gen byte njobs=.
	label var njobs "Number of additional jobs"
*</_njobs_>


** SECTOR OF ACTIVITY: PUBLIC - PRIVATE
*<_ocusec_>
	gen byte ocusec=.
	label var ocusec "Sector of activity"
	la de lblocusec 1 "Public, state owned, NGO, government, army" 2 "Private"
	label values ocusec lblocusec
*</_ocusec_>


** REASONS NOT IN THE LABOR FORCE
*<_nlfreason_>
	gen byte nlfreason=.
	replace nlfreason=1 if q_9_17==1
	replace nlfreason=2 if q_9_17==2
	replace nlfreason=4 if q_9_17==4
	replace nlfreason=3 if q_9_17==3
	replace nlfreason=5 if inlist(q_9_17, 5,6,7,8,9,10,11,12)
	replace nlfreason=. if lstatus!=3
	la de lblnlfreason 1 "Student" 2 "Housewife" 3 "Retired" 4 "Disable" 5 "Other"
	label values nlfreason lblnlfreason
	label var nlfreason "Reason not in the labor force"
*</_nlfreason_>


** UNEMPLOYMENT DURATION: MONTHS LOOKING FOR A JOB
*<_unempldur_l_>
	gen byte unempldur_l=.
	label var unempldur_l "Unemployment duration (months) lower bracket"
*</_unempldur_l_>

*<_unempldur_u_>
	gen byte unempldur_u=.
	label var unempldur_u "Unemployment duration (months) upper bracket"
*</_unempldur_u_>

** INDUSTRY CLASSIFICATION
*<_industry_>
	gen byte industry=q_9_18
	recode  industry (3 = 5) (4 = 5) (5 = 3) (6 = 7) (7 = 6) (8 = 6) (9 = 10) (11 = 10) (12 = 9)
	replace industry=. if lstatus!=1
	label var industry "1 digit industry classification"
	la de lblindustry 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industry lblindustry
*</_industry_>


** OCCUPATION CLASSIFICATION
*<_occup_>
	gen byte occup=.
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
	gen whours = (q_9_24 * q_9_23)/4.2 
	replace whours = . if lstatus != 1
	replace whours  = 96 if whours  > 96 & whours < .
	replace whours = . if whours  > 168
	label var whours "Hours of work in last week"
*</_whours_>


** WAGES
*<_wage_>
	gen double wage=q_9_21
	replace wage=. if lstatus!=1
	replace wage=0 if empstat==2
	label var wage "Last wage payment"
*</_wage_>


** WAGES TIME UNIT
*<_unitwage_>
	gen byte unitwage=1
	replace unitwage=. if lstatus!=1 & empstat!=1
	replace unitwage=. if wage==.
	label var unitwage "Last wages time unit"
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Quarterly" 7 "Biannual" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage lblunitwage
*</_wageunit_>


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


/*****************************************************************************************************
*                                                                                                    *
                                   WELFARE MODULE
*                                                                                                    *
*****************************************************************************************************/

** SPATIAL DEFLATOR
*<_spdef_>
	gen spdef=.
	la var spdef "Spatial deflator"
*</_spdef_>

** WELFARE
*<_welfare_>
	sum pline [w=hh_weight]  /*no need to restrict the sample as all data for all provinces were used for the pline estimation*/
	gen PLN_ps=`r(mean)'
	gen def_ps=pline/PLN_ps
	gen welfare=(pexadj_t/def_ps)*12
	replace welfare=. if pov_sample==0
	la var welfare "Welfare aggregate"

*</_welfare_>

*<_welfarenom_>
	gen welfarenom=pexnom_t*12
	replace welfarenom=. if pov_sample==0
	replace welfarenom=. if welfare==.
	la var welfarenom "Welfare aggregate in nominal terms"
*</_welfarenom_>

*<_welfaredef_>
	gen welfaredef=welfare
	replace welfaredef=. if pov_sample==0
	la var welfaredef "Welfare aggregate spatially deflated"
*</_welfaredef_>

*<_welfshprosperity_>
	gen welfshprosperity=welfare
	replace welfshprosperity=. if pov_sample==0
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
	gen welfarenat=welfare
	replace welfarenat=. if pov_sample==0
	la var welfarenat "Welfare aggregate for national poverty"
*</_welfarenat_>


/*****************************************************************************************************
*                                                                                                    *
                                   NATIONAL POVERTY
*                                                                                                    *
*****************************************************************************************************/

** POVERTY LINE (NATIONAL)
*<_pline_nat_>
	sum pline [w=hh_weight]  /*no need to restrict the sample as all data for all provinces were used for the pline estimation*/
	gen pline_nat=`r(mean)'
	label variable pline_nat "Poverty Line (National)"
*</_pline_nat_>

	
** HEADCOUNT RATIO (NATIONAL)
*<_poor_nat_>
	gen poor_nat=(welfare/12)<pline_nat & welfare!=.
	la var poor_nat "People below Poverty Line (National)"
	la define poor_nat 0 "Not Poor" 1 "Poor"
	la values poor_nat poor_nat
	replace poor_nat=. if pov_sample==0
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
	merge m:1 countrycode year urb using "D:\SOUTH ASIA MICRO DATABASE\CPI and PPP\cpi_ppp_sarmd_weighted.dta", ///
	keepusing(countrycode year urb syear cpi`year'_w ppp`year')
	drop urb
	drop if _merge!=3
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
	replace poor_int=. if pov_sample==0
*</_poor_int_>


qui su ppp
if r(mean)==0{
replace pline_int=.
replace poor_int=.
}
	
	stop
/*****************************************************************************************************
*                                                                                                    *
                                   FINAL STEPS
*                                                                                                    *
*****************************************************************************************************/


** KEEP VARIABLES - ALL

	keep countrycode year survey idh idp wgt strata psu vermast veralt urban int_month int_year  ///
		subnatid1 subnatid2 subnatid3 ownhouse water electricity toilet landphone cellphone ///
	     computer internet hsize relationharm relationcs male age soc marital ed_mod_age everattend ///
	     atschool electricity literacy educy educat4 educat5 educat7 lb_mod_age lstatus empstat njobs ///
	     ocusec nlfreason unempldur_l unempldur_u industry occup firmsize_l firmsize_u whours wage ///
		 unitwage contract healthins socialsec union pline_nat pline_int poor_nat poor_int spdef cpi ppp ///
		 cpiperiod welfare welfarenom welfaredef welfarenat welfareother welfaretype welfareothertype

** ORDER VARIABLES

	order countrycode year survey idh idp wgt strata psu vermast veralt urban int_month int_year  ///
			subnatid1 subnatid2 subnatid3 ownhouse water electricity toilet landphone cellphone ///
	      computer internet hsize relationharm relationcs male age soc marital ed_mod_age everattend ///
	      atschool electricity literacy educy educat4 educat5 educat7 lb_mod_age lstatus empstat njobs ///
	      ocusec nlfreason unempldur_l unempldur_u industry occup firmsize_l firmsize_u whours wage ///
		 unitwage contract healthins socialsec union pline_nat pline_int poor_nat poor_int spdef cpi ppp ///
		 cpiperiod welfare welfarenom welfaredef welfarenat welfareother welfaretype welfareothertype
	
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
	keep countrycode year survey idh idp wgt strata psu vermast veralt `keep' *type
	compress

	saveold "`output'\Data\Harmonized\AFG_2007_NRVA_v01_M_v03_A_SARMD.dta", replace version(12)
	saveold "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\__REGIONAL\Individual Files\AFG_2007_NRVA_v01_M_v03_A_SARMD.dta", replace version(12)

	log close


















******************************  END OF DO-FILE  *****************************************************/
