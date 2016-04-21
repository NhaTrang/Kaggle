##
## Kaggle World Rankning Analysis
##

#Load libraries
library(ggplot2)

#Read data
input_dir = "input/"
cwurData = read.csv(paste0(input_dir, "cwurData.csv")) #CWUR rating
#ed_attain_sup = read.csv(paste0(input_dir, "educational_attainment_supplementary_data.csv")) #Population schooling
#ed_expen_sup = read.csv(paste0(input_dir, "education_expenditure_supplementary_data.csv")) #Funding for schools
school_country = read.csv(paste0(input_dir, "school_and_country_table.csv")) #Country/School table
shanghai = read.csv(paste0(input_dir, "shanghaiData.csv")) #Shanghai rating
times = read.csv(paste0(input_dir, "timesData.csv")) #Times rating

#Fix some of the names for the shanghai scores
school_country = rbind(school_country, data.frame(school_name = "University of California, San Francisco", country = "United States of America"))
shanghai$university_name[shanghai$university_name == "University of California-Berkeley"] = "University of California, Berkeley"

#Merge the shanghai data to get countries
##Lost datasets due to naming issues with school_country, as well as not in dataset
shanghai = merge(shanghai, school_country, by.x = "university_name", by.y = "school_name")

#shanghai is more raw research base
##40% based on research, +30% for having nobel laureatesa and awarded people
#times seems to be biased non english colleges
##32% based on research impact, ~+10%  research monies and papers
#cwur saudi arabia made one
##25% on quality of staff(awards,etc), 5% pub, 5% influ, 5% cit, 5% patent

#1
#ghetto see if yamanaka paper and 2012 nobel did anything to enrolllment or whatever
#2006
#Assocaited with UCSF and Kyoto dai
#2012 got nobel

##
## Investigate the ratings of both Kyoto and UCSF in regards to Yamanaka's first paper on iPS cells and nobel prize
##

#Subset out data pertaining to UCSF and Kyoto Dai
kyoto_ucsf.shang = shanghai[shanghai$university_name == "University of California, San Francisco" | 
                        shanghai$university_name == "Kyoto University",]
kyoto_ucsf.cwur = cwurData[cwurData$institution == "University of California, San Francisco" | 
                             cwurData$institution == "Kyoto University",]
kyoto_ucsf.times = times[times$university_name == "University of California, San Francisco" | 
                             times$university_name == "Kyoto University",]

#Sort based on institute and year
kyoto_ucsf.shang = kyoto_ucsf.shang[order(kyoto_ucsf.shang$university_name,kyoto_ucsf.shang$year),]
kyoto_ucsf.cwur = kyoto_ucsf.cwur[order(kyoto_ucsf.cwur$institution, kyoto_ucsf.cwur$year),]
kyoto_ucsf.times = kyoto_ucsf.times[order(kyoto_ucsf.times$university_name, kyoto_ucsf.times$year),]
  
#Look at the times rating for Kyoto University

#3
#maybe checkout the impact of research after crispr paper 2012-2013