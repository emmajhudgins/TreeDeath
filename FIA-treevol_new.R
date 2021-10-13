require(rFIA)
require(dplyr)
require(tidyr)
states<-c('AL','AZ','AR','CA','CO','CT','DE','FL','GA','ID','IL','IN','IA','KS','KY','LA','ME','MD','MA','MI','MN','MS','MO','MT','NE','NV','NH','NJ','NM','NY','NC','ND','OH','OK','OR','PA','RI','SC','SD','TN','TX','UT','VT','VA','WA','WV','WI','WY') #comment these lines out after you finish downloading

FIA<-getFIA(dir="~/Downloads/",states = states,nCores = 4, load=F) #comment these lines out after you finish downloading

FIA<-readFIA('~/Downloads/FIADB', inMemory = F)
live_biomass <-biomass(db=FIA, bySpecies=T, bySizeClass=T, totals=T, treeType="live",variance=F,grpBy=c(STATECD,COUNTYCD), nCores=4) 
live_biomass$STATECD<-sprintf("%02d",as.numeric(live_biomass$STATECD))
live_biomass$COUNTYCD<-sprintf("%03d",as.numeric(live_biomass$COUNTYCD))
live_biomass$FIPS<-paste0(live_biomass$STATECD,live_biomass$COUNTYCD)
saveRDS(live_biomass, file="live_biomass.rds")
sum_live_small<-live_biomass%>%filter(sizeClass<=6)%>%group_by(FIPS,YEAR, SPCD, COMMON_NAME, SCIENTIFIC_NAME)%>%summarize_at('BIO_TOTAL',sum)
sum_live_med<-# do the same but with size Class >6 and <=12
sum_live_large<-# do the same but with size Class >=12 
live_biomass_total<-rbind(sum_live_small, sum_live_med)
live_biomass_total<-rbind(live_biomass_total, sum_live_large)
saveRDS(live_biomass_total, file="live_biomass_total.rds")


dead_biomass <-biomass(db=FIA, bySpecies=T, bySizeClass=T, totals=T, treeType="dead",variance=F,grpBy=c(STATECD,COUNTYCD), nCores=4) 
dead_biomass$STATECD<-sprintf("%02d",as.numeric(dead_biomass$STATECD))
dead_biomass$COUNTYCD<-sprintf("%03d",as.numeric(dead_biomass$COUNTYCD))
dead_biomass$FIPS<-paste0(dead_biomass$STATECD,dead_biomass$COUNTYCD)
saveRDS(dead_biomass, file="dead_biomass.rds")


###repeat same size class grouping as above for dead biomass


