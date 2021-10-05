require(rFIA)
states<-c('AL','AZ','AR','CA','CO','CT','DE','FL','GA','ID','IL','IN','IA','KS','KY','LA','ME','MD','MA','MI','MN','MS','MO','MT','NE','NV','NH','NJ','NM','NY','NC','ND','OH','OK','OR','PA','RI','SC','SD','TN','TX','UT','VT','VA','WA','WV','WI','WY')
# 
# FIA<-getFIA(dir="~/Downloads/",states = states,nCores = 4, load=F)
# 
#   
# FIA<-readFIA('~/Downloads/FIADB', inMemory = F)
# FIA_mr<-clipFIA(FIA)
# volume<-volume(db=FIA_mr, bySpecies=T, volType="gross", totals=T,variance=F,grpBy=c(STATECD,COUNTYCD), nCores=4) # update for the output of parallel::detectCores() on your machine
# saveRDS(volume, file="volume_2021.rds")
volume<-readRDS('volume_2021.rds')
require(dplyr)
require(tidyr)
volume$STATECD<-sprintf("%02d",as.numeric(volume$STATECD))
volume$COUNTYCD<-sprintf("%03d",as.numeric(volume$COUNTYCD))
volume$FIPS<-paste0(volume$STATECD,volume$COUNTYCD)
forestland<-volume%>%group_by(FIPS)%>%summarize_at('AREA_TOTAL', min)
write.csv(forestland, file="updated_forestland.csv", row.names=F)
FIA_vol<-volume%>%group_by(FIPS, SCIENTIFIC_NAME)%>%summarize_at('BOLE_CF_TOTAL', sum)
FIA_vol<-spread(FIA_vol,value=BOLE_CF_TOTAL, key=SCIENTIFIC_NAME)
write.csv(FIA_vol, file="updated_treevol.csv", row.names=F)
FIA_tot<-volume%>%group_by(FIPS)%>%summarize_at('BOLE_CF_TOTAL', sum)
FIA_dens<-FIA_tot%>%mutate(TreeDen=BOLE_CF_TOTAL/forestland$AREA_TOTAL)
write.csv(FIA_dens, file="FIA_treeden.csv", row.names=F)
