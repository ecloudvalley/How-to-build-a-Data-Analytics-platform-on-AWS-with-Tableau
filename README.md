
# How to build a Data Analytics platform on AWS with Tableau
![dataset.jpg](/images/dataset.jpg)<br>
**This lab using IMDb movie dataset**

## Scenario

Various enterprises nowadays face big data problems. Most of them put the effort in data mining, data cleansing, data analytics, or even about machine learning.

AWS plays an important role in big data solution. We provide an end-to-end data solution that leverage different AWS services that including data lake, data catalog, data analytics, and presentation. There are many architectures for the customer to customize their solution. This lab using several services to fulfill data analysis and BI process that includes **S3**, **Glue**, **Athena**.



## Use Case in this Lab
* Dataset: IMDb dataset <br>
* ![imdb_logo.svg](/images/imdb_logo.svg)<br>
https://www.imdb.com/interfaces/<br>
With the large growth of YouTube, it plays an important role of video service. The large company also use it to determine their ads strategies and marketing plans.
This use case using trending YouTube video data to analyze which video channel or video type are suitable for advertising. In addition, YouTubers can make themselves more popular by analyzing the trending videos of YouTube. We use AWS Glue to do serverless ETL job and analyze those big data automatically with BI tool that integrate with AWS Athena or AWS Redshift Spectrum.




## Lab Architecture
![architecture.png](/images/architecture.png)

As illustrated in the preceding diagram, this is a big data processing in this model:<br><br>
* 1.&nbsp;&nbsp; 	Upload the IMDb data into the S3 bucket.<br><br>
* 2.&nbsp;&nbsp; 	Setup Glue data catalog to create Glue table.<br><br>
* 3.&nbsp;&nbsp; 	Athena runs the query to create target table with Glue data catalog.<br><br>
* 4.&nbsp;&nbsp; 	Tableau will be configured, connect to Athena, to retrieve data, and show the analytic figure on Tableau dashboard.<br><br>

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


## Prerequisites
1.	Sign-in a AWS account, and make sure you have select **Singapore** region<br>
2.	Make sure your account have permission to create IAM role for following services: **S3, Glue, Athena**<br>
3.	Make sure you have created the **Access key** and **Secret access key** that have **Athena** fully permission to connect to Tableau
4.	Download **this repository** and unzip, ensure that **data** folder including two files:<br>
**title.basic.tsv**, **title.rating.tsv**<br>
5.  You need to download **Tableau Desktop** on your laptop.<br>
Click below link to download <br>
https://www.tableau.com/support/releases <br>
Note that download the latest version (2018.3.2 for this example) <br>
Make sure that you have license to use Tableau <br>
https://www.tableau.com/pricing <br>


<!-- ![learnflow.png](/images/learnflow.png)<br> -->

## Lab tutorial


### Create following IAM roles

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





### Create S3 bucket to store data

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
 -  Select file **title.basics.tsv** then click **Upload.**.<br><br>
 ![s3-3.png](/images/s3-3.png)<br>
 -  Click **Create folder** to create another folder named **ratings** as the same way in **1.6**<br><br>
  ![s3-4.png](/images/s3-4.png)<br>
 -  In **ratings** folder Click **Upload** and choose **Add files.**.<br><br>
 -  Select file **title.ratings.tsv** then click **Upload.**<br><br>
  ![s3-5.png](/images/s3-5.png)<br>
 -  Now **“[your name]-imdb-dataset”** bucket the folder will show as below <br>
 ![s3-6.png](/images/s3-6.png)<br>
 -  For another bucket, click **Create bucket** again and enter the bucket name **“[your name]-athena-table” (e.g., samuel-athena-table)** and ensure that the bucket name is unique so that you can create.<br>
 ![s3-7.png](/images/s3-7.png)<br>
 -  Click **Create**.<br><br>
 -  Make sure that your S3 buckets contain those two buckets<br><br>
![s3-8.png](/images/s3-8.png)<br>



### Setup data catalog in AWS Glue

Create database, tables, crawlers, jobs in Glue<br><br>
* 	On the **Services** menu, click **AWS Glue**.<br><br>
* 	In the console, choose **Add database**. In the **Database name**, type **imdb-data**, and choose **Create**.<br><br>
![glue-1.png](/images/glue-1.png)<br>
* 	Choose **Crawlers** in the navigation pane, choose **Add crawler**. Add type Crawler name **basics-crawler**, and choose **Next**.<br><br>
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


Now you successfully to setup AWS Glue data catalog and create Glue table with IMDb data


### Analyze the data with Athena

Athena can query the data in an easy way with data catalog of Glue<br><br>
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

* **rating_with_info** table will be used in Tableau to create different views



### Visualize data with Tableau

The following steps will show you how to integrate Athena with Tableau.<br><br>
* 	First you need to download Tableau Desktop on your laptop.<br>
* In this step assume you have installed Tableau Desktop.<br>
* 	Open Tableau you will see this screen (Tableau Desktop for example)<br>
![tableau1.png](/images/tableau1.png)<br>
* 	To connect to Athena, click **Amazon Athena** in navigation pane left side <br><br>
![tableau2.png](/images/tableau2.png)<br>
* 	Enter **“athena.us-ap-southeast-1.amazonaws.com”** in **Server**<br><br>
* 	Enter **port** for 443<br><br>
* 	Enter Staging Directory for your **Athena query result S3 bucket**<br><br>
Go to Athena console and click **Settings** to get the staging directory path<br><br>
![athena-4.png](/images/athena-4.png)<br>
![athena-5.png](/images/athena-5.png)<br><br>
* 	Enter **Access Key ID** and **Secret Access Key** then click **sign in**<br><br>
![tableau3.png](/images/tableau3.png)<br>
* 	Select **AwsDataCatalog** in **Catalog** and select **my-data** in **database**<br><br>
* 	Drag the table you want to make the chart for<br><br>
![tableau4.png](/images/tableau4.png)<br><br>
![tableau5.png](/images/tableau5.png)<br><br>
1.11. 	Click **New Worksheet** icon below then you can start making your chart to do BI
![tableau6.png](/images/tableau6.png)<br><br>
![tableau7.png](/images/tableau7.png)<br><br>
![tableau8.png](/images/tableau8.png)<br><br>

## Appendix
