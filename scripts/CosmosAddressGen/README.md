# Cosmos Address Generator


## Setup

`npm install`

## Usage

1.  Open `generateIBCAddress.js` and locate: 

```
/*
 *
 * Set Filename here!
 * 
 */
const fileName = "test.csv";
```

(It's at the top of the file)

2.  update the variable `fileName` to be the name of your CSV file.

3.  Ensure the CSV file does not have `"` around each address, and each address is on a new line.  Following CSV format, the first line of the file will be skipped so make sure there is a header line.

4.  Run `node generateIBCAddress.js`

5.  The output will be `addresses.json`


