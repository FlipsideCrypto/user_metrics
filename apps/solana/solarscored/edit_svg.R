library(stringr)
setwd("~/user_metrics/apps/solana/solarscored")

# read in the svg text
svg.text <- readLines("wheelpart.svg")

# split into parts on the layer opening tag
split.at.1 <- "Layer_"
sgv.text.split <- strsplit(svg.text, split = split.at.1, fixed = TRUE)[[1]]


# grab the layer with the slices
# you have to know which one it is
# we're looking for layer 1
center.slices <- sgv.text.split[which(substr(sgv.text.split, 1, 1) == "1")]
center.slices <- '<g id="Layer_1"><path class="cls-7" d="M421.63,216.81c51.13,0,99.47,23.28,131.35,63.25l-47.29,37.71c-20.4-25.58-51.34-40.48-84.06-40.48v-60.48Z"/><path class="cls-9" d="M552.98,280.07c31.88,39.97,43.82,92.29,32.44,142.13l-58.96-13.46c7.28-31.9-.36-65.38-20.76-90.96l47.29-37.71Z"/><path class="cls-17" d="M585.42,422.19c-11.38,49.84-44.83,91.8-90.9,113.98l-26.24-54.49c29.48-14.2,50.89-41.05,58.17-72.95l58.96,13.46Z"/><path class="cls-5" d="M494.52,536.17c-46.06,22.18-99.72,22.18-145.78,0l26.24-54.49c29.48,14.2,63.82,14.2,93.3,0l26.24,54.49Z"/><path class="cls-11" d="M348.74,536.17c-46.06-22.18-79.52-64.13-90.9-113.98l58.96-13.46c7.28,31.9,28.69,58.75,58.17,72.95l-26.24,54.49Z"/><path class="cls-13" d="M257.84,422.19c-11.38-49.84,.56-102.16,32.44-142.13l47.29,37.71c-20.4,25.58-28.04,59.06-20.76,90.96l-58.96,13.46Z"/><path class="cls-15" d="M290.28,280.07c31.88-39.97,80.22-63.25,131.35-63.25v60.48c-32.72,0-63.66,14.9-84.06,40.48l-47.29-37.71Z"/><path class="cls-7" d="M421.63,156.33c69.53,0,135.28,31.66,178.63,86.03l-47.29,37.71c-31.88-39.97-80.22-63.25-131.35-63.25v-60.48Z"/><path class="cls-9" d="M600.27,242.36c43.35,54.36,59.59,125.51,44.12,193.3l-58.96-13.46c11.38-49.84-.56-102.16-32.44-142.13l47.29-37.71Z"/><path class="cls-17" d="M644.38,435.65c-15.47,67.79-60.97,124.84-123.62,155.01l-26.24-54.49c46.06-22.18,79.52-64.13,90.9-113.98l58.96,13.46Z"/><path class="cls-5" d="M520.77,590.66c-62.65,30.17-135.62,30.17-198.27,0l26.24-54.49c46.06,22.18,99.72,22.18,145.78,0l26.24,54.49Z"/><path class="cls-11" d="M322.5,590.66c-62.65-30.17-108.15-87.22-123.62-155.01l58.96-13.46c11.38,49.84,44.83,91.8,90.9,113.98l-26.24,54.49Z"/><path class="cls-13" d="M198.88,435.65c-15.47-67.79,.77-138.93,44.12-193.3l47.29,37.71c-31.88,39.97-43.82,92.29-32.44,142.13l-58.96,13.46Z"/><path class="cls-15" d="M243,242.36c43.35-54.36,109.1-86.03,178.63-86.03v60.48c-51.13,0-99.47,23.28-131.35,63.25l-47.29-37.71Z"/><path class="cls-7" d="M421.63,95.85c87.94,0,171.09,40.04,225.92,108.8l-47.29,37.71c-43.35-54.36-109.1-86.03-178.63-86.03v-60.48Z"/><path class="cls-9" d="M647.55,204.65c54.83,68.75,75.37,158.73,55.8,244.46l-58.96-13.46c15.47-67.79-.77-138.93-44.12-193.3l47.29-37.71Z"/><path class="cls-17" d="M703.35,449.11c-19.57,85.73-77.11,157.89-156.34,196.04l-26.24-54.49c62.65-30.17,108.15-87.22,123.62-155.01l58.96,13.46Z"/><path class="cls-5" d="M547.01,645.16c-79.23,38.15-171.52,38.15-250.75,0l26.24-54.49c62.65,30.17,135.62,30.17,198.27,0l26.24,54.49Z"/><path class="cls-11" d="M296.26,645.16c-79.23-38.15-136.77-110.31-156.34-196.04l58.96-13.46c15.47,67.79,60.97,124.84,123.62,155.01l-26.24,54.49Z"/><path class="cls-13" d="M139.92,449.11c-19.57-85.73,.97-175.71,55.8-244.46l47.29,37.71c-43.35,54.36-59.59,125.51-44.12,193.3l-58.96,13.46Z"/><path class="cls-15" d="M195.71,204.65c54.83-68.75,137.98-108.8,225.92-108.8v60.48c-69.53,0-135.28,31.66-178.63,86.03l-47.29-37.71Z"/></g>'

split.at.2 <- "path"

block.orders <- c("nfts", "governance", "variety", "staking", "longevity", "bridging", "activity")
wheel.colors <- c("#30CFCF", "#A682EE", "#23D1BA", "#9764E8", "#3EAFE0", "#8880E5", "#26D994")

editing <- str_split(center.slices, "path")[[1]]

intro.bit <- editing[1]

editing <- editing[2:22]

# insert class name to each slice shape
edited <- sapply(1:21, function(i) {
  
  #class name:
  cat.name <- block.orders[ifelse(i %% 7 == 0, 7, i %% 7)]
  class.name <- paste0(cat.name, ceiling((i)/7))
  
  str_replace( editing[i], "cls-(.*?) ", paste0(class.name, "\" "))
  
})

edited.slices <- paste(c(intro.bit, edited), collapse = split.at.2)

# add this to the top section with the css
new.header <- str_replace(string = sgv.text.split[1],
                          pattern = "<style>.",
                          replacement = paste0("<style>",
                                               paste(".", paste0(rep(block.orders, each = 3), 1:3), "{fill:",
                                                     rep(wheel.colors, each = 3),
                                                     ";opacity:%s;}", sep = "", collapse = ""),
                                               ".")
                          )

edited.svg <- paste(c(new.header, 
                    sgv.text.split[which(substr(sgv.text.split, 1, 1) == "3")], 
                    edited.slices, 
                    sgv.text.split[which(substr(sgv.text.split, 1, 1) == "2")], 
                    sgv.text.split[which(substr(sgv.text.split, 1, 1) == "5")]), 
                    collapse = split.at.1)

writeLines(edited.svg, con = "wheel.svg")

# 1 slices
# 2 text 
# 3 border
# 5 icon

substr(sgv.text.split, 1, 1)



