## STEP 1: PROBLEM DEFINITION 
Business context: A pastry shop with five branches across Rwanda serves red velvet, chocolate, cheesecake, and mousse pastries.

Data challenge: The management team wants to know the top-performing pastry type per branch, examine the sales trends, and customers' spending behavior to know the most preferred pastry in order to optimize the business's inventory and come up with appropriate marketing strategies.

Expected outcome: providing a clear report of the top-performing pastry and insights on the targeted customer's preference, which is meant to help the business in making strategic and informed decisions.

## STEP 2: SUCCESS CRITERIA
1. Identify the top 5 best selling pastries in each branch using ranking functions: RANK()
2. Cumulative monthly sales for each branch using windows function: SUM() OVER()
3. Compare one month's sales to the previous month's sales to determine the sales trend using: LAG() LEAD()
4. Segmenting customers into groups based on their total spendings using: NTILE()
5. compute the moving average of 3 month period to clearly see sales trends dynamics using: AVG() OVER()

## STEP 6:
