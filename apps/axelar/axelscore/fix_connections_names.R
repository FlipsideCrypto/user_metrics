library(stringr)

all.files <- list.files("www")

to.fix <- all.files[which(substr(all.files, 1, 5) == "conne")]

for(i in to.fix) {
  
  new.name <- str_replace(i, "connections_", "")
  file.rename(paste0("www/", i), paste0("www/", new.name))
  
}

cat(paste(str_replace(to.fix, "connections_", ""), collapse = "\n"))

