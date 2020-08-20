log using AppliedEconometrics_final, replace
*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*
* Does Airbnb contribute to no-fault evictions in the San-Francisco area?"*
*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*

clear all
set more off

/* import data */
cd "C:\Users\NMTRAN\Documents\Documents\Airbnb"
import excel "C:\Users\NMTRAN\Documents\Documents\Copy_ of_monthly_data_with_spatial_lag.xlsx", firstrow clear
gen listing_lag_1=listings_rate[_n-1]
drop extracted_month_year adjacent_1 adjacent_2 adjacent_3 adjacent_4 adjacent_5 adjacent_6 percap_inc listings_rate_help

/* Set up panel data */
xtset ZipCode Date
/* Summary statistics for panel data*/
xtsum
/*Export as publication-ready table*/
/* Summary of the main statistics*/
fsum *
outreg2 using summary_total.doc, replace sum(log)
/*Summary of all statistics*/
fsum 
outreg2 using summary_short.doc, replace sum(log) keep(Airbnb_listings Evictions instrument_home instrument_rent_gap Occupation_Airbnb rent_gap percp_inc_monthly total_population)

/* Regressions*/
/*Hausman test for the Basic Model*/
 xtreg evictions_rate listing_lag_1 Occupation_Airbnb rent_gap percp_inc_monthly total_population  unemp housing_units owner_occ median_rooms male median_age black native_american_alaska asian pacific other hispanic,fe
estimates store fixed
xtreg evictions_rate listing_lag_1 Occupation_Airbnb rent_gap percp_inc_monthly total_population  unemp housing_units owner_occ median_rooms male median_age black native_american_alaska asian pacific other hispanic,re
estimates store random
hausman fixed random
/*Hausman test for the Main Model*/

/*Main model*/
eststo: xtivreg2 evictions_rate (listing_lag_1 = instrument_home)  Occupation_Airbnb rent_gap percp_inc_monthly total_population,fe endog(listing_lag_1)

/*Rent_gap as an instrument*/
eststo: xtivreg2 evictions_rate (listing_lag_1 = instrument_rent_gap)  Occupation_Airbnb rent_gap percp_inc_monthly total_population,fe endog(listing_lag_1)
/*Compare both instuments*/
eststo: xtivreg2 evictions_rate (listing_lag_1= instrument_home instrument_rent_gap)  Occupation_Airbnb rent_gap percp_inc_monthly total_population,fe endog(listing_lag_1)
/* Main model without IV*/
eststo: xtreg evictions_rate listing_lag_1 Occupation_Airbnb rent_gap percp_inc_monthly total_population,fe
/*Export results*/
esttab using table1.rtf,  starlevels(* 0.10 ** 0.05 *** 0.001) sca("widstat Weak Ident." "sargan Sargan"  "exexog Instruments  ") mtitles( "Adjacent home value" "Adjacent rent gap" " Two instruments"" Baseline model" ) replace
!table1.rtf

/*Main model with all covariates*/
 xtreg evictions_rate listing_lag_1 Occupation_Airbnb rent_gap percp_inc_monthly total_population  unemp housing_units owner_occ median_rooms male median_age black native_american_alaska asian pacific other hispanic,fe
est sto m1
 esttab m1 using baseline.rtf, starlevels(* 0.10 ** 0.05 *** 0.001)  mtitles(  "Baseline model with all covariates") replace
!baseline.rtf

log close
translate Final_report.smcl Final_report.pdf, replace
