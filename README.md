# Instamart Customer Intelligence & Support Copilot

## Part A – SQL Data Analysis

### 1. Project Overview
This project analyzes Instamart customer, product, and order data using SQL and Python. The objective is to understand customer spending, product pricing, city-wise revenue, and daily revenue trends.

### 2. Database Details
Database: `data/instamart.db`

Tables used:
- `customers` – 1,200 records
- `products` – 40 records
- `orders` – 12,309 records

### 3. SQL Analysis Performed

Seven SQL queries were developed:

1. Identify high-value customers.
2. Analyze city-wise category revenue.
3. Find products priced above the average price.
4. Identify customers without completed orders.
5. Find customers spending above average.
6. Rank customers by spending within each city.
7. Calculate daily and cumulative revenue.

SQL file: `sql/queries.sql`

### 4. Additional Data Analysis

Python and Pandas were used for:
- City-wise revenue analysis.
- Pivot table analysis.
- Outlier detection using IQR.
- Correlation analysis.

### 5. Timestamp Format

The `order_ts` column uses the format:

`YYYY-MM-DD HH:MM:SS`

Daily revenue was calculated using SQLite's `DATE()` function.

### 6. Validation Results

All seven SQL queries executed successfully.

Eight automatic validation checkpoints were completed:

| Validation | Expected Result |
|---|---:|
| Customers | 1,200 |
| Products | 40 |
| Orders | 12,309 |
| High-value customers | 30 |
| Products above average price | 11 |
| Customers without completed orders | 25 |
| Above-average spending customers | 550 |
| Daily revenue records | 183 |

**Final Validation Score: 8/8 PASSED**

### 7. Tools Used
- Python
- SQLite
- SQL
- Pandas
- Jupyter Notebook
- VS Code

### 8. Conclusion
Part A successfully completed the SQL-based analysis of Instamart data. All seven queries executed successfully, and all eight automatic validation checks passed.



 

## Part B – Customer Segments and Lapse Prediction

### 1. Objective
The objective is to identify customer segments using RFM analysis and predict customers who may stop purchasing from Instamart.

### 2. RFM Analysis
RFM stands for:
- Recency – Days since the customer's last completed order.
- Frequency – Number of completed orders.
- Monetary – Total amount spent by the customer.

Total customers analyzed: 1,175.

### 3. Customer Segmentation
Used K-Means clustering with K=4.

Four customer segments:
- Premium Customers
- Occasional Customers
- At-Risk Customers
- Loyal Customers

Premium segment: 138 customers.

PCA explained variance: 85.23% using two components.

### 4. Lapse Prediction
Created a customer cohort of 1,156 customers.

- Lapsed customers: 443
- Not lapsed customers: 713
- Training customers: 924
- Testing customers: 232

### 5. Machine Learning Models

Two models were trained and compared:

| Model | Cross-validation F1 |
|---|---:|
| Logistic Regression | 0.651 |
| Random Forest | 0.684 |

Selected model: Random Forest.

Best parameters:
- max_depth = 5
- min_samples_leaf = 10
- n_estimators = 100

### 6. Final Model Evaluation

- Accuracy: 72%
- Precision: 63%
- Recall: 65.2%
- Test F1 Score: 64.1%

The required test F1 score was 55%. The model successfully exceeded this target.

### 7. Output Files

- `outputs/customer_segments.csv`
- `outputs/lapse_model.joblib`
- `outputs/retention_list.csv`

### 8. Data Leakage Prevention

- Train-test split used stratification.
- Scaler and encoder were fitted within the training pipeline.
- No September orders were used as input features.
- Part A segment labels were not used as model features.

**Limitation:** The retention list is illustrative and not a leakage-free evaluation because Premium status was determined using the full RFM period, including September.

### 9. Conclusion

Part B successfully completed customer segmentation and lapse prediction. The Random Forest model achieved a test F1 score of 0.641, exceeding the required target of 0.55.




## Part C – Support Ticket Classification & Routing

### 1. Project Overview

Part C builds an automated support ticket classification pipeline using a mock LLM. It classifies customer tickets into billing, delivery, technical, and fraud categories and routes them to the appropriate support teams.

### 2. Input Validation

A total of 164 tickets were processed.

- 156 tickets passed validation.
- 4 empty tickets were skipped.
- 4 long tickets were flagged.
- Maximum input limit: 400 estimated tokens.

### 3. PII Redaction

Sensitive information was removed before sending tickets to the LLM.

| Information | Replacements |
|---|---:|
| Email addresses | 55 |
| Phone numbers | 91 |
| Order IDs | 132 |
| Total | 278 |

All three PII patterns were checked after redaction. No matching personal details remained in the ticket text sent to the model.

### 4. Prompt Engineering

Two prompting strategies were tested:

- Zero-shot prompting: Classification instructions without examples.
- Few-shot prompting: Classification instructions with four labelled examples.

Both prompts required JSON-only responses with category and reason fields.

### 5. Retry Handling

A resilient model-calling function was implemented.

- Maximum retries: 3 per ticket.
- Exponential backoff with random jitter.
- Temporary errors were logged with ticket ID, retry number, and wait time.
- 19 transient errors occurred in each full run and were successfully recovered.

### 6. Response Validation

LLM responses were validated using two methods:

- Valid JSON responses were classified as `classified_json`.
- Responses containing exactly one allowed category keyword were classified as `classified_keyword`.
- Invalid responses were flagged as `flagged_invalid_output` and sent for human review.

### 7. Zero-Shot vs Few-Shot Comparison

| Metric | Zero-shot | Few-shot |
|---|---:|---:|
| Classified tickets | 147 | 147 |
| Accuracy | 85.71% | 100% |
| Total tokens | 10,024 | 18,136 |
| Tokens per classified ticket | 68.19 | 123.37 |

Few-shot prompting improved classification accuracy by 14.29 percentage points. However, it used approximately 80.9% more tokens. This demonstrates the trade-off between classification quality and token cost.

### 8. Token Budget Demonstration

A zero-shot budget demonstration was performed with a 6,000-token budget.

- Actual tokens used: 6,044.
- Classified JSON: 82.
- Classified keyword: 7.
- Invalid output: 5.
- Budget exhausted: 62 tickets.

Once the budget was reached, remaining tickets were routed for human review without additional model calls.

### 9. Customer-Based Routing

Tickets were routed using classification results and customer segments.

| Condition | Route | Priority |
|---|---|---|
| Empty, long, invalid or budget exhausted | human_review | NORMAL |
| Fraud category | security_team | HIGH |
| Premium customer | premium_desk | HIGH |
| Other valid tickets | support_queue | NORMAL |

Final routing distribution:

| Route | Tickets |
|---|---:|
| support_queue | 102 |
| security_team | 34 |
| premium_desk | 11 |
| human_review | 17 |

### 10. Output Files

- `outputs/triage_results.csv` – Final classification and routing results for all 164 tickets.
- `outputs/triage_budget_demo.csv` – Results of the token budget demonstration.

The final results file contains eight columns:
ticket_id, customer_id, status, category, segment_name, priority, route, tokens_used.

### 11. Final Validation

All 10 automatic validation checks passed, including ticket counts, classification status counts, routing, output columns, and CSV file existence.

### 12. Conclusion

Part C successfully implemented a privacy-aware and resilient support ticket classification pipeline. Few-shot prompting achieved 100% accuracy among successfully classified tickets. Invalid outputs and tickets requiring additional attention were routed to human review, while fraud and premium customers received specialized routing.





## Part D – Policy RAG and Refund Agent

### 1. Policy RAG Assistant
- Loaded five policy documents: refund, delivery, payment, privacy, and escalation.
- Split the documents into 40-word chunks with 10-word overlap.
- Created 15 policy chunks.
- Implemented keyword-based retrieval with stopword removal and a minimum relevance score.
- Used the retrieved policy context to answer customer questions.
- Evaluated the assistant using 14 questions: 12 in-scope and 2 out-of-scope.
- All 14 expected policy facts were identified, and the assistant abstained when the answer was outside the available policies.

Evaluation output: `outputs/rag_evaluation.csv`

### 2. Refund Agent
Implemented five tools:
- `get_order` – retrieves order details.
- `search_policy` – searches the policy documents.
- `calculate_refund` – calculates the eligible refund.
- `issue_refund` – records an approved refund.
- `escalate_to_human` – sends cases for human approval.

The agent follows a ReAct-style process: it reasons about the request, calls the required tools, observes their results, and produces a final response.

Safety measures include tool-result handling, a maximum of six agent steps, and a fallback response when the step limit is reached.

### 3. Agent Evaluation
- Tested all seven supplied refund scenarios.
- Covered successful refunds, denied refunds, escalation, missing orders, and loop fallback.
- Result: **7 out of 7 scenarios passed.**

Evaluation output: `outputs/agent_evaluation.csv`

### 4. Part D Deliverables
- `outputs/rag_evaluation.csv`
- `outputs/agent_evaluation.csv`

Part D implementation and evaluation completed.

## Reproduce

1. Clone this repository:
   `git clone https://github.com/nilaarchu7/instamart-customer-copilot.git`

2. Open the project folder.

3. Create and activate a Python virtual environment.

4. Install the required packages:
   `pip install -r requirements.txt`

5. Open `notebooks/01_python_setup.ipynb` in VS Code or Jupyter Notebook.

6. Run the notebook cells in order to reproduce the project workflow.

The notebook contains the implementation for Parts A, B, C, and D. The supporting Python files are `generate_data.py`, `mock_llm.py`, and `src/validate.py`.

## Limitations and Next Steps

- The project uses generated sample data and is not connected to live Instamart customer systems.
- The LLM functionality uses a mock LLM for demonstration and evaluation.
- The RAG implementation uses keyword-based retrieval rather than production-grade vector search.
- The machine learning results are based on the available sample dataset and may differ with real-world data.
- Future improvements could include real-time data integration, vector-based retrieval, production LLM integration, and continuous model evaluation.
