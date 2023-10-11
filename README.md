# seQura Backend Coding Challenge
## Table of Contents
1. Introduction
2. Setup and Running the Solution
3. Technical Choices
4. Tradeoffs and Assumptions
5. Remaining Tasks

## Introduction
This repository contains the solution to the seQura backend coding challenge. The challenge involves automating the calculation of merchants' disbursements payouts and seQura commissions for existing and new orders based on specific requirements.

## Setup and Running the Solution
To set up and run the solution:
1. Clone this repository to your local machine.
2. Navigate to the project directory.
3. Run docker build 
> `docker-compose build`
4. Create the database
> docker-compose run web bundle exec rake db:create
5. Execute migrations
> docker-compose run web bundle exec rake db:migrate
6. Import the dummy data with a rake task
> docker-compose run web bundle exec rake import:data
*Take care with this import, the full import process takes at least 10m, If you prefer to test the app, change the route into the rake tast from ./db/original_data/ to ./db/dev_data/*
7. After the procces, run
> docker-compose up
8. visit http://localhost:3000 to ensure the rails app is working

### Some docker basic commands 
- How to login into the shell
> docker-compose run web bash
- How to login into the ruby console
> docker-compose run web bundle exec rails c
- How to run an independant instance of sidekiq
> docker-compose run worker bundle exec sidekiq -e development -C config/sidekiq.yml
- How to runt the rspec suite tests
> docker-compose run web bundle exec rspec
- How to run services from the console
> docker-compose run web bundle exec rails c

### Sidekiq
Visit [http://localhost:3000/sidekiq](http://localhost:3000/sidekiq) to run the worker jobs. 
There are some workers to run daily, weekly, and reporting jobs. 
These jobs are configured to run on specific dates, but you can run them individually when needed.

I created a new job to populate all the monthly fees from `live_on` to the last completed month from today. **MonthlyDisbursementJob**

In the MonthlyDisbursementService there are 3 methods
1. Calculate the last month fee
2. Calculate all months from merchant.live_on till today or last month
3. Calculate all months for an specific merchant

- Run a service from Rails console
> docker-compose run web bundle exec rails c

- Daily Disbursement for All merchants
> DailyDisbursementService.new.perform 

- Weekly Disbursement for All merchants
> WeeklyDisbursementService.new.perform 

- Single merchant daily and weekly (Single merchant with disbursement type determined by the database, supporting both daily and weekly disbursements)
> DisbursementCalculatorService.new(Merchant).calculate_and_create_disbursements

- Run last monthly fee for a especific merchant
> MonthlyDisbursementService.new(date, merchant)

- Run All months fee from live_on to today for a especific merchant
> MonthlyDisbursementService.new(merchant).all_months

- Run All months fee from live_on date to today to all merchants
> MonthlyDisbursementService.new.all_months_all_merchants

- Run Yearly Export Manually
> YearlyExportService.new.yearly_data

To run this entire process in the background, I schedule jobs for specific dates and times.
- DailyDisbursementJob. It is launched every morning at 9:00
- WeeklyDisbursementJob. It is launched every morning at 9:00
- MonthlyDisbursementJob  It is launched every month at 9:00 ("In any case, the system is intelligent, and if it detects that an order is the first of the month, it calculates the monthly fee automatically.")
-YearlyReportingJob. It is launched every year on 1st of January

** Fix Possible problems with database permissions **
- docker-compose exec db bash
- mysql -u root -p
- Insert the root password

> GRANT ALL PRIVILEGES ON development.* TO 'the_user'@'%';
> GRANT ALL PRIVILEGES ON test.* TO 'the_user'@'%';

> FLUSH PRIVILEGES;

Alternatively, you can use the *init.sql* file stored in the root folder if you prefer.

## Technical Choices
### Language and Framework
The solution is implemented using Ruby on Rails. Ruby on Rails provides a robust framework for building web applications and interacting with databases.

### Database
MySQL is used as the database to store merchant and order data. MySQL is a powerful relational database.

### CSV Parsing
The CSV data is parsed using the built-in CSV library in Ruby, which simplifies the process of reading data from CSV files.

### Background Job
For handling periodic tasks, such as daily disbursements, a background job is scheduled using a task runner or a background job processing system (e.g., Sidekiq,).

## Tradeoffs and Assumptions
1.  **Batch Processing:** Due to the potentially large number of merchants, batch processing is not explicitly implemented in the provided solution. For handling large datasets efficiently, a batch processing mechanism could be introduced using tools like Sidekiq or implementing custom batch processing logic.

2.  **Data Structure:** The data structure for storing disbursements and other related information is designed to meet the specific requirements of the challenge. Depending on the overall system architecture and requirements, the data structure may be further optimized or normalized.

3.  **Commission Calculation:** The commission calculation assumes a straightforward percentage-based fee calculation. If more complex fee structures are introduced, the calculation logic may need adjustment.

## Remaining Tasks
1.  **Testing:** While the solution includes some basic tests, a comprehensive test suite covering edge cases and potential issues is recommended for a production-ready application.
2.  **Error Handling:** Additional error handling and logging mechanisms can be implemented to improve system resilience and provide detailed error messages in case of failures.
3.  **Scalability:** The solution may need further optimization for scalability, especially if the dataset grows significantly. This could involve database indexing, query optimizations, and distributed processing.
4.  **Security:** Implement security best practices, such as input validation and sanitization, to prevent potential security vulnerabilities.

## Reporting tool
This report provides a summary of all processed orders after launching the report_tool!
[Report](https://imgur.com/a/DinE0YS)

## Conclusion
The seQura backend coding challenge is implemented as a Ruby on Rails application, providing a foundation for automating the calculation of disbursements and commissions for merchants. The provided solution aims to meet the specified requirements; however, there are some areas that may need further optimization and refinement, pending discussion with the rest of the engineering team.

### Remaining Optimizations
1.  **Worker Scalability:** The current solution assumes a straightforward execution of tasks without explicit consideration for worker scalability. Depending on the size of the dataset and the frequency of tasks, it may be beneficial to explore options for optimizing worker performance and scaling the processing infrastructure.
2.  **Batch Processing:** To handle large datasets efficiently, especially when dealing with a substantial number of merchants, implementing batch processing logic can be considered. This would involve processing data in smaller, manageable batches to prevent potential bottlenecks.
3.  **Infrastructure Sizing:** As the application scales, considerations for infrastructure sizing and resource allocation become crucial. Collaborating with the infrastructure and operations team to determine optimal server sizes, database configurations, and potential load balancing strategies is essential.
4.  **Monitoring and Logging:** Implementing robust monitoring and logging mechanisms will aid in identifying performance bottlenecks, errors, and potential issues. This includes integrating with tools for real-time monitoring and logging to ensure the health and stability of the system.
5.  **Security Audits:** Perform thorough security audits to identify and address potential vulnerabilities. Ensure that input validation and sanitization are in place to prevent common security risks.

### Collaboration with the Team
The remaining optimizations mentioned above should be discussed and planned collaboratively with the rest of the engineering team. Engaging in discussions about infrastructure, worker optimization, and overall system scalability will contribute to a well-rounded and performant solution.

The solution provided here serves as a starting point and can be iteratively improved based on feedback, team discussions, and evolving project requirements.

## Personal Reflection and Request for Feedback
I thoroughly enjoyed working on the seQura Backend Coding Challenge. Over the course of approximately 6-7 hours spread across daily 3-hour sessions, I delved into the challenges of automating the calculation of merchant payouts and seQura commissions.

While I am satisfied with the outcome, I acknowledge there are areas for improvement, especially in terms of performance and more comprehensive testing. In hindsight, I realize there are opportunities to optimize system performance and strengthen the test suite to address edge cases and special scenarios.

I want to highlight that, given the time constraint, I did my best to deliver a functional solution. However, I am aware that there is always room for improvement and continuous learning.

If possible, I would greatly appreciate any feedback you can provide. Whether you identify areas for improvement, point out critical errors, or suggest alternative approaches, I am open to learning and improving.

Thank you again for this opportunity. I look forward to the feedback from your team and any suggestions you may have for my professional development.

Have a great day!
Adán
---
Adán González
adangrx@gmail.com
+34 692 817 071