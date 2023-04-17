## setup:

1.  Install R and dependencies

```
brew install R
brew install libgit2 
brew install freetype
brew install harfbuzz fribidi
brew install libtiff  
```


2.  Install required packages by running

 ```
 Rscript setup.R
 ```

3.  in the terminal create an R project with react?

```
~ R
> path <- file.path(getwd(), "flowAttestR")
> usethis::create_package(path)
> reactR::scaffoldReactShinyInput(
  "wallet_connect", 
  list(
    "reactstrap" = "^8.9.0"
  )
)
> quit()
Save workspace image? [y/n/c]: n
yarn install

```
## "exporting"

R doesn't call it that but that's what we're doing

```

cd <my library to export>
yarn run webpack --mode=development 
R
devtools::document()
devtools::load_all()
-or-
devtools::install()
```


## Running

```
cd <this directory>
 R -e "shiny::runApp('.')"
```
