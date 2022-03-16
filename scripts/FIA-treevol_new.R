require(rFIA)
require(dplyr)
require(tidyr)
# states<-c('AL','AZ','AR','CA','CO','CT','DE','FL','GA','ID','IL','IN','IA','KS','KY','LA','ME','MD','MA','MI','MN','MS','MO','MT','NE','NV','NH','NJ','NM','NY','NC','ND','OH','OK','OR','PA','RI','SC','SD','TN','TX','UT','VT','VA','WA','WV','WI','WY') #comment these lines out after you finish downloading
# 
# FIA<-getFIA(dir="~/Downloads/",states = states,nCores = 4, load=F) #comment these lines out after you finish downloading

FIA<-readFIA('~/Downloads/FIADB', inMemory = F)
live_biomass <-biomass(db=FIA, bySpecies=T, bySizeClass=T, totals=T, treeType="live",variance=F,grpBy=c(STATECD,COUNTYCD), nCores=4) 
live_biomass$STATECD<-sprintf("%02d",as.numeric(live_biomass$STATECD))
live_biomass$COUNTYCD<-sprintf("%03d",as.numeric(live_biomass$COUNTYCD))
live_biomass$FIPS<-paste0(live_biomass$STATECD,live_biomass$COUNTYCD)
saveRDS(live_biomass, file="output/live_biomass.rds")
live_biomass<-readRDS('/output/live_biomass.rds')
sum_live_small<-live_biomass%>%filter(sizeClass<=6)%>%group_by(FIPS,YEAR, SPCD, COMMON_NAME, SCIENTIFIC_NAME)%>%summarize_at('BIO_TOTAL',sum)
sum_live_med<-live_biomass%>%filter(sizeClass>6 & sizeClass<=12)%>%group_by(FIPS,YEAR, SPCD, COMMON_NAME, SCIENTIFIC_NAME)%>%summarize_at('BIO_TOTAL',sum)# do the same but with size Class >6 and <=12
sum_live_large<-live_biomass%>%filter(sizeClass>12)%>%group_by(FIPS,YEAR, SPCD, COMMON_NAME, SCIENTIFIC_NAME)%>%summarize_at('BIO_TOTAL',sum)# do the same but with size Class >=12 
live_biomass_total<-rbind(sum_live_small, sum_live_med)
live_biomass_total<-rbind(live_biomass_total, sum_live_large)
saveRDS(live_biomass_total, file="live_biomass_total.rds")

# ash<-subset(sum_live_large, SCIENTIFIC_NAME=="Fraxinus pennsylvanica")
# boxplot(ash$BIO_TOTAL~ash$YEAR)
# m<-lm(sum_live_small$BIO_TOTAL~sum_live_small$YEAR+sum_live_small$SCIENTIFIC_NAME)
###think about how to add columns to the data frame that tell us about when each pest arrived to that county.

##county data with grid cells and county IDs
countydata<-read.csv('~/Desktop/OneDrive - McGill University/GitHub/UStreedamage/data/countydata_march.csv', stringsAsFactors = FALSE) 
colnames(countydata)
##squareID column gives ID of grid cell, FIPS.C.5 gives FIPS code


##grid cell IDs (3372 rows should match the 3372 row indices in the pest data)
grid_data<-read.csv('~/Desktop/OneDrive - McGill University/GitHub/UStreedamage/data/countydatanorm_march.csv', stringsAsFactors = FALSE) 
colnames(grid_data)
#ID column should match the squareID column 

## pest data where each row should correspond with the forecasts
data2<-read.csv('~/Desktop/OneDrive - McGill University/GitHub/UStreedamage/data/datanorm.csv', stringsAsFactors = FALSE)# pest data from Hudgins et al. 2017
data2<-data2[-c(25,69),] # remove pests with no range in US forests
data2<-data2[-4,]# remove pests with no range in US forests

## pest forecasts as a list where each list element (accessed with [[]]) is the 5-year timestep forecast of the pest up to 2050. Each column is a set of row indices of the grid cells newly invaded in that period. 
forecasts<-readRDS('~/Desktop/OneDrive - McGill University/GitHub/UStreedamage/output/new_presences.RDS')
eab_forecast<-forecasts[[1]]
#for instance eab_forecast[,10] is the row indices of the grid cells invaded 2040-2045

## add steps to transform forecasts for each species into years of invasion in each grid cell

### add steps to transform tree data into proportion of living biomass by year
## match up with your tree data by FIPS codes, joining the tree data to countydata by FIPS codes
#merge(df1, df2 by="FIPS") #to do this both data frames need to have the same column named FIPS, so you would need to change the name of FIPS.C.5
## using countydata%>%group_by(squareID)%>%summarize_if(is.numeric, min)


##could then convert different grid cell/pest combinations to 'number of years since pest x arrived'
