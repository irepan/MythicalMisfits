# Tiempo Development Practical Exercise

### Modern application infrastructure

![mysfits-welcome](mysfits-screenshot.png)


The Mythical Mysfits website serves it's static content from Amazon S3 with Amazon CloudFront, provides a microservice API backend deployed as a container through AWS Fargate on Amazon ECS, stores data in a managed NoSQL database provided by Amazon DynamoDB, with authentication and authorization for the application enabled through AWS API Gateway/Network Load Balancer or Application Load balancer and it's integration with Amazon Cognito.  
You will be creating and deploying the required infrastructure to support this application on an Infrastructure as Code approach using Cloudformation.

### Application Architecture

![Application Architecture](architecture.png)


### Expected Outputs

* Cloudformation templates inside the `infrastructure` directory
* Script to automatically create/update infrastructure and deploy the web application different layer:
* * Deploy Database structure and data
* * Deploy Backend Microservice infrastructure and service
* * Replace variables or placeholders in front end source
* * Deploy Front end static website
* Update this readme or present a PDF explaining the architectual decisions, how the layers communicate, etc. Explain your solution.