# Metals Analysis Application - ICP Mass Spectrometry Data

This Shiny application is designed to simplify the analysis of ICP mass spectrometry data by classifying samples and controls, converting units, and presenting results in an organized manner. It is tailored for use at the **Complejo Hospitalario de Vigo** and processes `.csv` files exported from ICP-MS equipment.

## Features

- **Sample Classification**: Automatically identifies and categorizes internal controls, external controls, urine, whole blood, and serum samples.
- **Unit Conversion**: Adjusts measurement units (e.g., µg/L to ppm or µg/dL) based on sample type.
- **Interactive Tables**: Displays results in a clear and dynamic format for easy analysis.
- **Automated Adjustments**: Applies specific rules to modify data according to sample types and conditions.

## Application Link

You can access the application online via this link:  
[Metals Analysis Application - Complejo Hospitalario de Vigo](https://vtj3ex-marta0bello.shinyapps.io/METALESVIGO/)

## How to Use

1. **Upload a File**: Click the **"Select a CSV File"** button and upload a `.csv` file exported from your ICP-MS equipment. Ensure the file uses a semicolon (`;`) as the delimiter.
2. **View Results**: The app organizes data into the following categories:
   - **Internal Controls** (`UM`, `MQ`, `WB`)
   - **External Controls** (`CEXT`)
   - **Urine Samples** (`0997`)
   - **Whole Blood Samples** (`0280`)
   - **Serum Samples** (`0804`)
3. **Analyze the Data**: The processed data is displayed in categorized tables, with units and values adjusted according to the predefined rules.

## Data Processing Rules

### Internal Controls (`UM`, `MQ`, `WB`)
- **MQ Samples**: Copper and Zinc values are divided by 10.  
- **WB Samples**:
  - Lead values are divided by 10.
  - Copper and Zinc values are hidden.  
- **MQ Samples**: Lead values are hidden.

### External Controls (`CEXT`)
- For samples containing `OR`, Zinc values are converted to ppm (divided by 1000).  
- For samples containing `WB`, Copper and Zinc values are hidden.  
- Lead values are hidden for samples containing `S` (except those containing `OR`).  

### Urine Samples (`0997`)
- Zinc values are converted to ppm (divided by 1000).  

### Whole Blood Samples (`0280`)
- Lead values are converted to µg/dL (divided by 10).  

### Serum Samples (`0804`)
- Copper and Zinc values are converted to µg/dL (divided by 10).  

## CSV File Format

The input file must adhere to the following structure:
- Use a semicolon (`;`) as the delimiter.
- Contain at least 13 columns.
- Include sample data starting from the third row.

## Requirements

- **R Version**: 4.0.0 or later  
- **R Packages**:
  - `shiny`
  - `shinythemes`

## Running the Application Locally

To run the application locally, follow these steps:

1. Install R and RStudio on your computer.
2. Install the required R packages by running:
   ```R
   install.packages("shiny")
   install.packages("shinythemes")
3. Save the application script (app.R) to a folder on your system.
4. Open RStudio, navigate to the folder containing app.R, and execute:
shiny::runApp("app.R")
