# SQL_Data-Cleaning
This project focuses on data cleaning and manipulation in SQL. Here is the complete summary of the project:


I started by taking an initial look at the data set by running a SELECT query to view all the records from the dbo.housing_data$ table.

After examining the SaleDate column, I noticed that it had a time stamp after the date, which I wanted to get rid of. To address this, I added a new column named SaleDateConverted to the dbo.housing_data$ table. I then updated this new column with only the date part of the SaleDate using the CONVERT function.

Next, I focused on populating the PropertyAddress column. I first checked if there were any null values in this column using a SELECT query. Upon finding 29 fields with null values, I devised a strategy to fill in these missing addresses. By joining the table with itself on the ParcelID, I was able to identify rows with similar ParcelID values but one of them missing the PropertyAddress. I used this information to update the PropertyAddress column with the corresponding non-null address wherever possible.

To break down the PropertyAddress into individual columns like Address and City, I added two new columns, PropertySplitAddress and PropertySplitCity, to the dbo.housing_data$ table. I then updated these columns by extracting the address and city information from the original PropertyAddress using appropriate string functions.

Similarly, I tackled the OwnerAddress column. I created three new columns, OwnerSplitAddress, OwnerSplitCity, and OwnerSplitState, in the dbo.housing_data$ table. I updated these columns with the extracted address, city, and state, respectively, from the OwnerAddress using the PARSENAME function.

To ensure consistency in the SoldAsVacant column, I used a CASE statement to replace 'Y' with 'Yes' and 'N' with 'No', so that the values are standardized.

To handle duplicate rows, I used a Common Table Expression (CTE) with ROW_NUMBER(). This allowed me to assign row numbers to duplicate rows based on specific columns. I then selected and displayed the duplicate rows.

Finally, I addressed the presence of null values in the table. I generated a dynamic DELETE statement to remove rows with null values in any column of the dbo.housing_data$ table.

In the end, I successfully cleaned and processed the data in the dbo.housing_data$ table, ensuring that there are no more null values and that the data is now clean and ready for further analysis.
