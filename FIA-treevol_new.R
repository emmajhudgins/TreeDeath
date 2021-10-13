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
ash<-subset(sum_live_small, SCIENTIFIC_NAME=="Fraxinus pennsylvanica")
boxplot(ash$BIO_TOTAL~ash$YEAR)
m<-lm(sum_live_small$BIO_TOTAL~sum_live_small$YEAR+sum_live_small$SCIENTIFIC_NAME)
sum_live_med<-# do the same but with size Class >6 and <=12
sum_live_large<-# do the same but with size Class >=12 
live_biomass_total<-rbind(sum_live_small, sum_live_med)
live_biomass_total<-rbind(live_biomass_total, sum_live_large)
saveRDS(live_biomass_total, file="live_biomass_total.rds")


###think about how to add columns to the data frame that tell us about when each pest arrived to that county.


