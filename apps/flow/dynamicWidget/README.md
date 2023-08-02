# Working with the Dynamic Integration

## Getting Started

### 1.  Install Language Dependencies

Before you do anything, you are going to have to install everything that is needed to make our `R` packages work. After running this, you should be able to go open a terminal and type `R` to receive a help response.

```bash
brew install R libgit2 freetype harfbuzz fribidi libtiff  
```

> **Note**
> This is a global install it does not matter where you run this command if you copy-paste the above.* 

> **Important**
> If you are on MacOS, you are likely to have an issue with installing R that can be resolved by running the following in your terminal (again, this is global):
> 
> ```bash
> brew update && brew upgrade
> brew reinstall gcc
> brew reinstall r
> ```

### 2.  Install Repository Project References

This repository does not natively contain all the code for the base applications. This package effectively operates as a 'reference' for other applications to reference in an informal means. To retrieve the active state of a package, in your terminal, run:

```bash
Rscript setup.R
```

Surprisingly, you are going to run this in the root directory if you have not before.

> I am actually not sure what this did but somehow files magically showed up. If it turns out this is doing something different, i'm not surprised, please submit a PR with the real information.
> - **CHANCE**

### 3.  Create a New Package 

Sometimes, you are going to want to add a new project. Because our projects are built in R, you need to run the initial generation with `R` so that you have everything included. With this, we are using `reactR` so that we can use the two together.

> **Important**
> Replace `<package_name>` with the name of your project. This will be used as the name of the directory. For example, for Flow, the Package directory is located at `app/flow/dynamicWidget` this will be referred to as `<package_name>` moving forward.

To open `R` in your terminal run:

```bash
R
```

Now with an `R` process active, we can copy-pasta our code like professionals!

```R
path <- file.path(getwd(), "<package_name>")
usethis::create_package(path)
reactR::scaffoldReactShinyInput(
  "wallet_connect", 
  list(
    "reactstrap" = "^8.9.0"
  )
)
```

With that run, you have created a project! Go ahead and close your R process without saving the image by running:

```R
quit()
```

### 4. Working in a Package

With a project already created (whether you just created it or are updating an existing one) go ahead and install the dependencies in your terminal. First of course, navigate to the 'Package' directory.

```bash
cd <package_name>
```

Finally, you are ready to install the dependencies with yarn in your terminal like:

```bash
yarn install
```

> **Note**
> Unless you have a reason to, do not upgrade the dependencies.

Remember, we are going to build everything and package it up for use in R which means we need to bundle the dependencies used within the `reactR` implementation. 

### 5. Build a Package for Production 

With all your work done, you are ready to build the package and hand it off in a PR. To build the package, we need to run a little more `R` and then we are all set. Still in your terminal while in the `<package_name>` directory run:

```bash
yarn run webpack --mode=development 
R
```

Back in `R`, let's go ahead and bundle everything together with:

```R
devtools::document()
devtools::load_all()
devtools::install()
```

You are almost done, but there is one final step. Build the Package as a `.tar.gz`. To do this, you are going to move remain in R and run:

```R
devtools::build()
```

## Running

Now, we are good developers and will always make sure that everything is nice and running before stepping away with a mash of a PR. To run your Package, still in your same working directory of `<package_name>` navigate to your terminal and run:

```bash
R -e "shiny::runApp('.')"
```

This will spin up the app locally for you where you can acccess it at `http://127.0.0.1:3226`.