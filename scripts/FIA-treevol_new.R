require(rFIA)
require(dplyr)
require(tidyr)
# states<-c('AL','AZ','AR','CA','CO','CT','DE','FL','GA','ID','IL','IN','IA','KS','KY','LA','ME','MD','MA','MI','MN','MS','MO','MT','NE','NV','NH','NJ','NM','NY','NC','ND','OH','OK','OR','PA','RI','SC','SD','TN','TX','UT','VT','VA','WA','WV','WI','WY') #comment these lines out after you finish downloading
# 
# FIA<-getFIA(dir="~/Downloads/",states = states,nCores = 4, load=F) #comment these lines out after you finish downloading

FIA<-readFIA('data/FIADB', inMemory = F)
live_biomass <-biomass(db=FIA, bySpecies=T, bySizeClass=T, totals=T, treeType="live",variance=F,grpBy=c(STATECD,COUNTYCD), nCores=4) 

#reformat columns
live_biomass$STATECD<-sprintf("%02d",as.numeric(live_biomass$STATECD))
live_biomass$COUNTYCD<-sprintf("%03d",as.numeric(live_biomass$COUNTYCD))
live_biomass$FIPS<-paste0(live_biomass$STATECD,live_biomass$COUNTYCD)

#save
saveRDS(live_biomass, file="output/live_biomass.rds")

#read back in
live_biomass<-readRDS('output/live_biomass.rds')

#break into small, medium, large trees
sum_live_small<-live_biomass%>%filter(sizeClass<=6)%>%group_by(FIPS,YEAR, SPCD, COMMON_NAME, SCIENTIFIC_NAME)%>%summarize_at('BIO_TOTAL',sum)

sum_live_med<-live_biomass%>%filter(sizeClass>6 & sizeClass<=12)%>%group_by(FIPS,YEAR, SPCD, COMMON_NAME, SCIENTIFIC_NAME)%>%summarize_at('BIO_TOTAL',sum)# do the same but with size Class >6 and <=12

sum_live_large<-live_biomass%>%filter(sizeClass>12)%>%group_by(FIPS,YEAR, SPCD, COMMON_NAME, SCIENTIFIC_NAME)%>%summarize_at('BIO_TOTAL',sum)# do the same but with size Class >=12 

live_biomass_total<-rbind(sum_live_small, sum_live_med)
live_biomass_total<-rbind(live_biomass_total, sum_live_large)

#save
saveRDS(live_biomass_total, file="output/live_biomass_total.rds")

###Combine with pest data

## pest data where each row should correspond with the forecasts
data2<-read.csv('data/datanorm.csv', stringsAsFactors = FALSE)# pest data from Hudgins et al. 2017
data2<-data2[-c(25,69),] # remove pests with no range in US forests
data2<-data2[-4,]# remove pests with no range in US forests

## pest backcasts, including year pest arrived in each FIPS code
forecasts<-read.csv('data/replace_withpest_distributional_file.csv')


