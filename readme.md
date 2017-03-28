# About Repository

These are my reports about security and performance monitoring (Using Adam Machanic's sp_WhoIsActive)

For performance reports I have used SQL Server Agent jobs to collect and aggregate data, SSRS for generating reports and [Visual Cron][1] for e-mailing reports every monday on 01:00 for last week.

For security reports I have used only SSRS, reports are manually gathered by security department on demand.

# Installation

## For Performance Reports

Create all the tables then create Agent Jobs. They are collecting sp_WhoIsActive results every minute and aggregate this results every hour. For every hour a new collection table is created and at the beginning of next hour dimension tables are populated using this table and this table is aggregated and dumped into another table. Then the temporary table is dropped. 

To use different pattern for example collect every five minute and aggregate every three hour. You need to change the schedules of agent jobs then you need to change table name computations at [DataAggregation.sql#L5][4], [DataCollection.sql#L7][5], [AgentJobs1_Collection.sql#L45][6], [AgentJobs2_Aggregation.sql#L44][7] accordingly

## For Tables born last week report

Create DDL_Operations table on every database you need this report. Create DDL Trigger on every database you need this report. 

## For Security Reports

This report uses Hosts table in performance reports but you do not need to install anything besides this table. Just add records with Type = DbServer and Environment = PROD. There is no need to do anything else for this reports to run. Just upload rdl files to an SSRS instance. Make necessary onfigurations for connection. 

# Reports

1. Security Reports
* ServerRoles.rdl

Lists server level permissions granted for all users in database server. [Screenshot][2]

* User Permissions

Lists database level permissions granted for all users in databases in a database server [Screenshot][3]

2. Performance reports
* Unwanted login report

This not actually about performance. There are shared users that people used to use, for various reasons we can't delete/disable these accounts. This reports uses aggregated sp_WhoIsActive collections. 

* Tables Born Last Week report

This is not about query performance but about maintenance performance. Our users get used to work in prod environments with an addiction of creating report tables for specific cases. For example a table like ADSL_Report_20150318, there are four years old tables with no usage but every week these tables index maintained, backed up, DBCC checked. 

In meeting people used to say that they are not working as so after my warning but every time i dropped these tables they tend to come back. So I need to pin point the user and table and report it undeniably.

This report uses DDL_Operations table populated by a DDL Trigger on all databases. 

* Server Workload Analysis report

This report is the most usefull report using aggregated sp_WhoIsActive collections. I used different enterprise monitoring systems the tend to report CPU usages, reads, writes and physical reads by only application name parameter in connection strings or program_name column in sys.sessions. I created same report by database, application category, login_name, host. 

* SqlAgentJob Workload Analysis report

This report is very similar to Server Workload Analysis report but it runs only on SqlAgent application category and displays Job Category, Job Name and Step details. 


[1]: http://www.visualcron.com/
[2]: https://github.com/SelmanAY/DbaReports/blob/master/ScreenShots/ServerRoles.rdl.png
[3]: https://github.com/SelmanAY/DbaReports/blob/master/ScreenShots/UserPermissions.rdl.png
[4]: https://github.com/SelmanAY/DbaReports/blob/master/Dba%20Reports%20Scripts/DataAggregation.sql#L5
[5]: https://github.com/SelmanAY/DbaReports/blob/master/Dba%20Reports%20Scripts/DataCollection.sql#L7
[6]: https://github.com/SelmanAY/DbaReports/blob/master/Dba%20Reports%20Scripts/AgentJobs1_Collection.sql#L45
[7]: https://github.com/SelmanAY/DbaReports/blob/master/Dba%20Reports%20Scripts/AgentJobs2_Aggregation.sql#L44