list.of.packages <- c("data.table","dotenv", "dplyr","httr")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
lapply(list.of.packages, require, character.only=T)
rm(list.of.packages,new.packages)

# Note: You will need to create your own account at https://developer.iatistandard.org/ and create a .env file.

# setwd("C:/git/iati-budgets")
#load_dot_env()
api_key = Sys.getenv("PA_TOKEN")

results_list = list()
results_index = 1

# Setup dummy `docs` to get our `while` loop started. The loop will automatically stop when
# it reaches the end because it finds the last page by looking for a result with less than 1000
docs = rep(0, 1000)

#### Marker query ####

start_num = 0
api_url_base = paste0(
  "https://api.iatistandard.org/datastore/budget/select?",
  "q=budget_period_start_iso_date:[2021-01-01T00:00:00Z TO *]",
  #"AND reporting_org_ref:(\"GB-GOv-1\")", # Can include a specific reporter if wanted.
  "&",
  "fl=budget_* iati_identifier reporting_org_ref &wt=json&",
  "sort=iati_identifier asc&",
  "rows=1000&start="
)
while(length(docs)==1000){
  if (nchar(api_key)==32){print("got into loop with api key")}else{print("no api")}
  Sys.sleep(1)
  #message(start_num)
  req = GET(
    URLencode(paste0(api_url_base, format(start_num, scientific=F))),
    add_headers(`Ocp-Apim-Subscription-Key` = api_key)
  )
  res = content(req)
  docs = res$response$docs
  
  filename = paste0("budgets-",Sys.Date())
  for (index in c((start_num+1):(start_num+1000))){
  if ((index-start_num)<=length(docs)){
  results_list[[index]] = docs[[index-start_num]]
  }
  }
  start_num = start_num + 1000
  message(length(docs))
}


save(results_list, file=paste0(filename,".RDa"))

# We now have a dataset of iati-identifiers with their budget information for all budgets 2021 onwards.
