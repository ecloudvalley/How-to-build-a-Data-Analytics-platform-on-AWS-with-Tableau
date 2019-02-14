
# Building a Data Analytics platform on AWS with Tableau
![dataset.jpg](/images/dataset.jpg)<br>
**This lab using IMDb movie dataset**

## Scenario

Various enterprises nowadays face big data problems. Most of them put the effort in data mining, data cleansing, data analytics, or even about machine learning.

AWS plays an important role in big data solution. We provide an end-to-end data solution that leverage different AWS services that including data lake, data catalog, data analytics, and presentation. There are many architectures for the customer to customize their solution. This lab using several services to fulfill data analysis and BI process that includes **S3**, **Glue**, **Athena**.



## Use Case in this Lab
* Dataset: IMDb dataset <br>
* ![imdb_logo.jpg](/images/imdb_logo.jpg)<br>
https://www.imdb.com/interfaces/<br>
The data set of 10000+ most popular movies on IMDB in many years. The data points included are:
Title, Genre, Description, Director, Actors, Year, Runtime, Rating, Votes, Revenue, Metascrore
This use case using IMDb data to analyze some interesting insights of movies or TV episode.




## Lab Architecture
![architecture.png](/images/architecture.png)

As illustrated in the preceding diagram, this is a big data processing in this model:<br><br>
1.&nbsp;&nbsp; 	Upload the IMDb data into the S3 bucket.<br><br>
2.&nbsp;&nbsp; 	Setup Glue data catalog to create Glue table.<br><br>
3.&nbsp;&nbsp; 	Athena runs the query to create target table with Glue data catalog.<br><br>
4.&nbsp;&nbsp; 	Tableau will be configured, connect to Athena, to retrieve data, and show the analytic figure on Tableau dashboard.<br><br>

## Amazon S3 introduction
What is Amazon S3?
Amazon Simple Storage Service (Amazon S3) is an object storage service that offers industry-leading scalability, data availability, security, and performance. This means customers of all sizes and industries can use it to store and protect any amount of data for a range of use cases, such as websites, mobile applications, backup and restore, archive, enterprise applications, IoT devices, and big data analytics. Amazon S3 provides easy-to-use management features so you can organize your data and configure finely-tuned access controls to meet your specific business, organizational, and compliance requirements. Amazon S3 is designed for 99.999999999% (11 9's) of durability, and stores data for millions of applications for companies all around the world.

## AWS Glue introduction
What is AWS Glue?
AWS Glue is a fully managed data catalog and ETL (extract, transform, and load) service that simplifies and automates the difficult and time-consuming tasks of data discovery, conversion, and job scheduling. AWS Glue crawls your data sources and constructs a data catalog using pre-built classifiers for popular data formats and data types, including CSV, Apache Parquet, JSON, and more. It is significantly reducing the time and effort that it takes to derive business insights quickly from an Amazon S3 data lake by discovering the structure and form of your data. Also automatically crawls your Amazon S3 data, identifies data formats, and then suggests schemas for use with other AWS analytic services.

## Amazon Athena introduction
What is Amazon Athena?
Amazon Athena is an interactive query service that makes it easy to analyze data in Amazon S3 using standard SQL. Athena is serverless, so there is no infrastructure to manage, and you pay only for the queries that you run.
Athena is easy to use. Simply point to your data in Amazon S3, define the schema, and start querying using standard SQL. Most results are delivered within seconds. With Athena, there’s no need for complex ETL jobs to prepare your data for analysis. This makes it easy for anyone with SQL skills to quickly analyze large-scale datasets.
Athena is out-of-the-box integrated with AWS Glue Data Catalog, allowing you to create a unified metadata repository across various services, crawl data sources to discover schemas and populate your Catalog with new and modified table and partition definitions, and maintain schema versioning. You can also use Glue’s fully-managed ETL capabilities to transform data or convert it into columnar formats to optimize cost and improve performance.

### The workshop’s region will be in ‘Singapore’


## Step 0 - Prerequisites
1. Sign-in a AWS account, and make sure you have select **Singapore** region<br>
2. Make sure your account have permission to create IAM role for following services: **S3, Glue, Athena**<br>
3. Make sure you have created the **Access key** and **Secret access key** that have **Athena** fully permission to connect to Tableau
4. Download **this repository** and unzip, ensure that **data** folder including two files:<br>
**title.basic.tsv**, **title.rating.tsv**<br>
5. Download **Tableau Desktop** on your laptop.<br>
Click below link to download <br>
https://www.tableau.com/support/releases <br>
Note that download the latest version (2018.3.2 for this example) <br>
Make sure that you have license to use Tableau <br>
https://www.tableau.com/pricing <br>
6. Setup AWS Athena Driver for Tableau Desktop <br>
If Java is not already installed on your Mac, download and install the latest Java version from https://www.java.com/en/download. <br>
Download the JDBC driver (.jar file) from the Amazon Athena User Guide on Amazon's website. <br>
https://docs.aws.amazon.com/athena/latest/ug/connect-with-jdbc.html <br>
For Mac, Copy the downloaded .jar file to the /Library/JDBC directory. You might have to create the JDBC directory if it doesn't already exist. <br>
For Windows, Move the downloaded .jar file to C:\Program Files\Tableau\Drivers.


<!-- ![learnflow.png](/images/learnflow.png)<br> -->

## Step 1 - AWS environment setup
First of all, login to AWS console <br>
https://console.aws.amazon.com/console/home

### Create Access key and Secret access key on AWS
-   To create a new secret access key for your root account, use the  [security credentials page](https://console.aws.amazon.com/iam/home?#security_credential). Expand the  **Access Keys** section, and then click  **Create New Root Key**.
-   To create a new secret access key for an IAM user, open the  [IAM console](https://console.aws.amazon.com/iam/home?region=ap-southeast-1#home). Click  **Users**  in the  **Details**  pane, click the appropriate IAM user, and then click  **Create Access Key**  on the  **Security Credentials** tab.
- Download the newly created credentials (**csv file**), when prompted to do so in the key creation wizard

## Setp 2 - Create IAM roles for Glue service

* 	On the **service** menu, click **IAM**.<br>
* 	In the navigation pane, choose **Roles**.<br>
* 	Click **Create role**.<br>
* 	For role type, choose **AWS Service**, find and choose **Glue**, and choose **Next: Permissions**.<br>
* 	On the **Attach permissions policy** page, search and choose **AmazonS3FullAccess, AWSGlueServiceRole**, and choose **Next: Tags** then click **Next: Review**.<br>
* 	On the **Review** page, enter the following detail: <br>
**Role name: AWSGlueServiceRoleDefault**<br>
* 	Click **Create role**.<br>
* 	Choose **Roles** page, select the role **AWSGlueServiceDefault** you just created.<br>

* 	Now confirm you have policies as below figure.<br>
![iam1.png](/images/iam1.png)<br>
Figure1: IAM role policies<br><br><br>
You successfully create the role that allow AWS Glue get access to S3.<br>


## Setp 3 - Create S3 bucket for data lake and staging 

 - In this step we create below two S3 buckets

	- *The bucket stores the data that contain IMDb data and allow Glue crawler to crawl the data* <br>
	- *The bucket stores the data from Athena query and provide the path for creating table in Athena*<br>
 - 	On the service menu, click **S3**.<br><br>
 -  Click **Create bucket**.<br><br>
 -  Enter the **Bucket name “[your name]-imdb-dataset” (e.g., samuel-imdb-dataset)** and ensure that the bucket name is unique so that you can create.<br><br>
 ![s3-1.png](/images/s3-1.png)<br>
 -  Click **Create**.<br><br>
 -  Click **“[your name]-imdb-dataset”** bucket<br><br>
 - Click **Create folder** and enter the name **basics** then click **save**<br><br>
 ![s3-2.png](/images/s3-2.png)<br>
 -  In **basics** folder Click **Upload** and choose **Add files.**<br><br>
 -  Select file **title.basics.tsv** then click **Upload**.<br><br>
 ![s3-3.png](/images/s3-3.png)<br>
 -  Click **Create folder** to create another folder named **ratings** as the same way in **1.6**<br><br>
  ![s3-4.png](/images/s3-4.png)<br>
 -  In **ratings** folder Click **Upload** and choose **Add files**.<br><br>
 -  Select file **title.ratings.tsv** then click **Upload.**<br><br>
  ![s3-5.png](/images/s3-5.png)<br>
 -  Now **“[your name]-imdb-dataset”** bucket the folder will show as below <br>
 ![s3-6.png](/images/s3-6.png)<br>
 -  For another bucket, click **Create bucket** again and enter the bucket name **“[your name]-athena-table” (e.g., samuel-athena-table)** and ensure that the bucket name is unique so that you can create.<br>
 ![s3-7.png](/images/s3-7.png)<br>
 -  Click **Create**.<br><br>
 -  Make sure that your S3 buckets contain those two buckets<br><br>
![s3-8.png](/images/s3-8.png)<br><br>



## Step 4 - Setup AWS Glue data catalog

Create database, tables, crawlers, in Glue Data Catalog<br><br>
* 	On the **Services** menu, click **AWS Glue**.<br><br>
* 	In the console, choose **Add database**. In the **Database name**, type **imdb-data**, and choose **Create**.<br><br>
![glue-1.png](/images/glue-1.png)<br>
* 	Choose **Crawlers** in the navigation pane, choose **Add crawler**. Enter the Crawler name **basics-crawler**, and choose **Next**.<br><br>
![glue-2.png](/images/glue-2.png)<br>
* 	On the **Add a data store** page, choose **S3** as data store.<br><br>
* 	Select **Specified path in my account**.<br><br>
* 	Select **basics** folder in the bucket that you have created **[your name]-imdb-dataset**, and choose **Next**.<br>
![glue-3.png](/images/glue-3.png)<br>
* 	On **Add another data store** page, choose **No**, and choose **Next**.<br><br>
* 	Select **Choose an existing IAM role**, and choose the role **AWSGlueServiceRoleDefault** you just created in the drop-down list, and choose **Next**.<br><br>
* 	For **Frequency**, choose **Run on demand**, and choose **Next**.<br><br>
* 	For **Database**, choose **imdb-data**, and choose **Next**.<br><br>
* 	Review the steps, and choose **Finish**.<br><br>
* 	The crawler is ready to run. Choose **Run it now**.<br>
Now the **basics-crawler** is crawling the data in basics folder in S3 bucket.

* 	When the crawler has finished, two table has been added. Choose **Tables** in the left navigation pane, and then choose **basics** to confirmed.<br><br>
![glue-4.png](/images/glue-4.png)<br>
You can get the table information such as S3 location<br>
![glue-5.png](/images/glue-5.png)<br>
You can also get the table schema<br>
![glue-6.png](/images/glue-6.png)<br>




Now you need to add another ratings table so let's create another crawler<br><br>

* 	In the navigation pane, choose **Add crawler**. Add type Crawler name **“ratings-crawler”** and choose **Next**.<br><br>
![glue-7.png](/images/glue-7.png)<br>
* 	On the **Add a data store** page, choose **S3** as data store.<br><br>
* 	Select **Specified path in my account**.<br><br>
* 	Select **ratings** folder in the bucket that you have created **[your name]-imdb-dataset**, and choose **Next**.<br>
![glue-8.png](/images/glue-8.png)<br>
* 	On **Add another data store** page, choose **No**, and choose **Next**.<br><br>
* 	Select **Choose an existing IAM role**, and choose the role **AWSGlueServiceRoleDefault** you just created in the drop-down list, and choose **Next**.<br><br>
* 	For **Frequency**, choose **Run on demand**, and choose **Next**.<br><br>
* 	For **Database**, choose **imdb-data**, and choose **Next**.<br><br>
* 	Review the steps, and choose **Finish**.<br><br>
* 	The crawler is ready to run. Choose **Run it now**.<br>
* 	After the crawler has finished, there is a new table **ratings** in the **imdb-data** database:<br><br>
![glue-9.png](/images/glue-9.png)<br>
![glue-10.png](/images/glue-10.png)<br>
![glue-11.png](/images/glue-11.png)<br>


Now you successfully to setup AWS Glue data catalog and create Glue table with IMDb data<br><br>


## Step 5 - Ad Hoc query in with AWS Athena

Athena can query the data in an easy way with Glue Data Catalog<br><br>
* 	On the **Services** menu, click **Athena**.<br><br>
* 	On the **Query Editor** tab, choose the database **imdb-data**.<br><br>
![athena-1.png](/images/athena-1.png)<br>

* 	Query the data, paste below standard SQL in the blank:<br>
**remember to replace external_location with your S3 bucket name**

		create table rating_with_info with(
		format='PARQUET',
		external_location='s3://[your name]-athena-table/result/')
		as (
		select basics.*, averagerating, numvotes from basics
		left join ratings
		on basics.tconst = ratings.tconst where ratings.averagerating is not null and basics.startyear is not null)

* 	Click **Run Query** and Athena will query data as the below screen<br>
![athena-2.png](/images/athena-2.png)<br>
The query will take about 10 seconds to run<br>
* 	When the query finished you will find that a new table name **"rating_with_info"** in the Tables list.<br>
![athena-3.png](/images/athena-3.png)<br>

* **rating_with_info** table will be used in Tableau to create different views<br>
* You can also preview **rating_with_info** table to explore the data<br>
![athena-6.png](/images/athena-6.png)<br><br>


## Step 6 - Setup Tableau desktop connection to Athena

The following steps will show you how to use Tableau to create the views with Athena table.<br><br>
* 	First you need to download Tableau Desktop on your laptop.<br>
* In this step assume you have installed Tableau Desktop.<br>
* 	Open Tableau Desktop you will see this screen<br>
![tableau-1.png](/images/tableau-1.png)<br>
* 	To connect to Athena, click **Amazon Athena** in navigation pane left side <br><br>
![tableau-2.png](/images/tableau-2.png)<br>
* 	Enter **"athena.ap-southeast-1.amazonaws.com"** in **Server**<br><br>
* 	Enter **port** for 443<br><br>
* 	Enter Staging Directory for your **Athena query result S3 bucket**<br><br>
Go to Athena console and click **Settings** to get the staging directory path<br><br>
![athena-4.png](/images/athena-4.png)<br>
![athena-5.png](/images/athena-5.png)<br><br>
* 	Enter **Access Key ID** and **Secret Access Key** which you have created on AWS (**you can view these two items in credential csv**) then click **sign in**<br><br>
![tableau-3.png](/images/tableau-3.png)<br>
* 	Select **AwsDataCatalog** in **Catalog** and select **imdb-data** in **database**<br><br>
![tableau-4.png](/images/tableau-4.png)<br><br>
* 	Drag the table you want to use<br><br>
![tableau-5.png](/images/tableau-5.png)<br><br>
In this lab we use **rating_with_info**<br>


## Step 7 - Visualize data with Tableau

* First, we need to create a **Calculated Field** for column **Startyear** to convert integer format into Date format<br>
* Click **Create Calculated Field** on column **Startyear**<br>
![tableau-6.png](/images/tableau-6.png)<br><br>
* Type the field name **YYYY**<br>
* Enter below function in the calculated blank<br>
* `DATE(LEFT(STR([Startyear]), 4) + "-01-01")`<br>
![tableau-7.png](/images/tableau-7.png)<br><br>
* Click **OK** and you will find a new field named **YYYY** in the data<br>
![tableau-8.png](/images/tableau-8.png)<br><br>

After creating a date type field to display the year feature, we can start to create some views to visualize the data<br>

* Click **Sheet1** below<br>
![tableau-9.png](/images/tableau-9.png)<br><br>
![tableau-10.png](/images/tableau-10.png)<br><br>

### View_1: we focus on the relationship between year and average rating

* Drag the Dimension **YYYY** to **Columns** blank<br>
![tableau-11.png](/images/tableau-11.png)<br><br>
* Drag the Measures **Averagerating** to **Rows** blank<br>
![tableau-12.png](/images/tableau-12.png)<br><br>
* Click the **Averagerating** and change the Measure to **Average**<br>
![tableau-13.png](/images/tableau-13.png)<br><br>
![tableau-14.png](/images/tableau-14.png)<br><br>
* Click **Show Me** at the right and select the line chart (For lines (continuous) try)<br>
![tableau-15.png](/images/tableau-15.png)<br><br>
* Click **YYYY** and select **Show Filter**<br>
![tableau-16.png](/images/tableau-16.png)<br><br>
* The result view will show as below<br>
![tableau-17.png](/images/tableau-17.png)<br><br>
* You can change the sheet name or the line color just a few clicks <br><br>
![tableau-19.png](/images/tableau-19.png)<br><br>
You can drag the filter bar to explore the AVG(rating) within years<br>
![tableau-18.gif](/images/tableau-18.gif)<br><br>

### View_2: we can observe the rating variation of each title type (e.g. movie, short, tvseries, tvepisode, video, etc) among years
* Open a new worksheet<br>
![tableau-20.png](/images/tableau-20.png)<br><br>
* Drag the Dimension **Titletype** to **Columns** blank<br>
![tableau-21.png](/images/tableau-21.png)<br><br>
* Drag the Dimension **YYYY** to **Columns** blank<br>
![tableau-22.png](/images/tableau-22.png)<br><br>
* Drag the Measures **Averagerating** to **Rows** blank<br>
![tableau-23.png](/images/tableau-23.png)<br><br>
* Click the **Averagerating** and change the Measure to **Average**<br>
![tableau-24.png](/images/tableau-24.png)<br><br>
* Click **Show Me** at the right and select the line chart (For lines (continuous) try)<br>
![tableau-25.png](/images/tableau-25.png)<br><br>
The result view will show as below, you can click **Show Filter** on **Titletype** to select which type to view at the right side<br>
![tableau-26.png](/images/tableau-26.png)<br><br>
![tableau-27.png](/images/tableau-27.png)<br><br>
You will find that the average rating of tvMiniSeries is increasing in recent years<br>
![tableau-28.png](/images/tableau-28.png)<br><br>


## Clean Resources
* Delete all the resources you have created in the lab including:<br>
* AWS Glue (Glue tables, Glue crawlers, Glue database), Amazon S3 (S3 buckets), **Your Access Key**<br>

## Conclusion
You have learned:<br>
* How to set up the Glue Data catalog integrates with the S3 data lake<br>
* How to analyze the data in Glue table with Athena<br>
* How to use Tableau Desktop to visualize the data in Athena<br>

## Appendix
