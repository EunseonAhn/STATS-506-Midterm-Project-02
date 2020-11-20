* STATA Script for Midterm group project
* Stats506, F20
* Group2: EunSeon Ahn, Tianshi Wang, Yanyu Long
* 
*	Visualization of COVID-19 Data:
*		1) Marginal plot
*		2) Bubble plot
*
* Author: EunSeon Ahn, Yanyu Long, Tianshi Wang 
* Updated: November 20, 2020

// 79: ------------------------------------------------------------------------

// Set up ---------------------------------------------------------------------
version 16.0

// Directories ----------------------------------------------------------------
cd "E:\git\Stats506_midterm_project\STATA\"  //For local directory accesss


// Plot1 (Marginal Plot) ------------------------------------------------------

// data prep ------------------------------------------------------------------
import delimited "..\Data\Race Data Entry - CRDT.csv", ///
  stringcols(1) numericcols(3/28) clear

keep if date == "20201101"
keep state *white *black *latinx *asian

reshape long cases_ deaths_, i(state) j(race) string
rename cases_ cases
rename deaths_ deaths

// turn race into a ordered factor
gen race_int = 1
replace race_int = 2 if race == "black"
replace race_int = 3 if race == "latinx"
replace race_int = 4 if race == "asian"

label define race_label 1 "White" 2 "Black" 3 "LatinX" 4 "Asian"
label values race_int race_label 
drop race
rename race_int race

save race_plot_data, replace

// Creating marginal plots using 'grc1leg' ------------------------------------
// Note: grc1leg is the same as `graph combine` except that it displays
// a single common legend for all of the combined graphs.

// Todo: Uncomment the following line to install grc1leg
// net install grc1leg, from(http://www.stata.com/users/vwiggins/)

use race_plot_data, clear
drop if cases == . | deaths == .
separate deaths, by(race) veryshortlabel

// version 1: top+right margin -------------------------------------
// note: 
// (1) run the code chunk (from 'local alpha' to 'twoway histogram cases')
// at once to make sure the local variables can be used by all three plots
// (2) the opacity settings (e.g. `mcolor(red%30)`) are only available in 
// STATA15 or above. For STATA14 or below, try using hollow circles instead 
// of solid ones by adding the option `msymbol(Oh)`.

// create the main plot
local alpha %30
local xscale_opt xscale(range(0 415000)) 
local yscale_opt yscale(range(0 10500))

local scatter_opt mcolor(red`alpha' blue`alpha' green`alpha' purple`alpha')
scatter deaths? cases, `scatter_opt' ///
  `xscale_opt' `yscale_opt' ///
  legend(subtitle("Race") position(9) cols(1) region(style(none))) ///
  ytitle("Deaths") xtitle("Cases") xlabel(, grid) ///
  saving(yx_tr, replace)

// create the two marginal histograms
local hist_opt color(navy%30) bin(30)
twoway histogram deaths, `hist_opt' fraction ///
  `yscale_opt' ysca(alt) horiz fxsize(25) ///
  ytitle("") xlabel(, nogrid) ///
  saving(hy_tr, replace)
twoway histogram cases, `hist_opt' fraction ///
  `xscale_opt' xsca(alt) fysize(25) ///
  xtitle("") xlabel(, grid) ylabel(, nogrid) ///
  saving(hx_tr, replace)

// group the three plots together
local graph_title = "Total confirmed COVID-19 deaths vs. cases, " + ///
                    "U.S. States (11/01/20)"
grc1leg hx_tr.gph yx_tr.gph hy_tr.gph, ///
  colfirst hole(3) imargin(0 0 0 0) ///
  title("`graph_title'", size(medium)) ///
  legendfrom(yx_tr.gph) position(9)

// graph export stata-marginplot-tr.png, replace

// remove the intermediate files from disk
erase hx_tr.gph
erase yx_tr.gph
erase hy_tr.gph

// version 2: bottom+left margin -------------------------------------
// note: run the code chunk (from 'local alpha' to 'twoway histogram cases')
// at once to make sure the local variables can be used by all three plots

// create the main plot
local alpha %30
local xscale_opt xscale(range(0 415000)) 
local yscale_opt yscale(range(0 10500))

local scatter_opt mcolor(red`alpha' blue`alpha' green`alpha' purple`alpha')
scatter deaths? cases, `scatter_opt' ///
  `xscale_opt' `yscale_opt' ///
  legend(subtitle("Race") position(3) cols(1) region(style(none))) ///
  ytitle("Deaths") xtitle("Cases") ///
  xlabel(, grid) ysca(alt) xsca(alt) /// 
  saving(yx_bl, replace)

// create the two marginal histograms
local hist_opt color(navy%30) bin(30)
twoway histogram deaths, `hist_opt' fraction ///
  `yscale_opt' xsca(alt reverse) horiz fxsize(25) ///
  ytitle("") xlabel(, nogrid) ///
  saving(hy_bl, replace)
twoway histogram cases, `hist_opt' fraction ///
  `xscale_opt' ysca(alt reverse) fysize(25) ///
  xtitle("") xlabel(, grid) ylabel(, nogrid) ///
  saving(hx_bl, replace)

// group the three plots together
local graph_title = "Total confirmed COVID-19 deaths vs. cases, " + ///
                    "U.S. States (11/01/20)"
grc1leg hy_bl.gph yx_bl.gph hx_bl.gph, ///
  hole(3) imargin(0 0 0 0) ///
  title("`graph_title'", size(medium)) ///
  legendfrom(yx_bl.gph) position(3)

// graph export stata-marginplot-bl.png, replace

// remove the intermediate files from disk
erase hy_bl.gph
erase yx_bl.gph
erase hx_bl.gph

// 79: ------------------------------------------------------------------------

// Plot2 (Bubble Plot) --------------------------------------------------------
// data prep ------------------------------------------------------------------
import delimited "..\Data\owid-covid-data.csv", clear

// keep only relevant variables & data points
keep if date == "2020-10-20"
keep iso_code continent total_deaths_per_million ///
     stringency_index human_development_index
drop if continent == "" //drop international world data points

// Drop data pt. if either of the index measures are missing
drop if stringency_index ==. | ///
        human_development_index==. | ///
		    total_deaths_per_million ==.

save covid_plot_data, replace

// Creating bubble plot using 'scatter' ---------------------------------------
use covid_plot_data, clear

// categorize the human_development_index into six groups by continents
separate human_development_index, by(continent) veryshortlabel

local vars human_development_index? stringency_index ///
      [aw = total_deaths_per_million]
local symbol O // solid circles
local size .75 // make all points smaller (75% of the original size)
local alpha %30
local options xscale(range(0 80)) yscale(range(0.32 1)) ///
			mcolor(red`alpha' blue`alpha' green`alpha' ///
			       purple`alpha' orange`alpha' yellow`alpha') ///
			msymbol(`symbol' `symbol' `symbol' `symbol' `symbol' `symbol') ///
			msize(`size' `size' `size' `size' `size' `size')
local graph_title = ("Total # of Deaths Across Gov. Stringency Index " + ///
                     "and Human Development Index")
scatter `vars', `options' ///
  legend(subtitle("Continent") position(3) cols(1) ///
	       region(style(none))) ///
  title("`graph_title'", size(*.7)) ///
  ytitle("Human Development Index") xtitle("Government Stringency Index") ///
  yscale(titlegap(3)) // enlarge the gap between y-axis title and ticks
                      // to avoid overlap

// graph export stata-bubbleplot.png, replace

// 79: ------------------------------------------------------------------------
