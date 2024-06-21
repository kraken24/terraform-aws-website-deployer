**Deploy your personal website in 5 mins for just €20 / year**
=============================

## Goal

This repository deploys a secure website on AWS using Terraform and GitHub Actions. And the best part, it costs less than €20 per year.

## Requirements

The following variable values need to be set in your github repository secrets:
* `TF_VERSION` : The version of terraform to be used. I am using 1.8.5
* `BACKEND_BUCKET_NAME` : The name of AWS S3 bucket to store terraform backend
* `BACKEND_BUCKET_REGION` : The AWS region where the bucket for terraform backend is created
* `AWS_ACM_REGION` : The AWS region to provision SSL Certificates. This region should always be **us-east-1**
* `DOMAIN_BUCKET_NAME` : The name of AWS S3 bucket to store your website files. I would recommend to keep it same as your domain name.
* `DOMAIN_BUCKET_REGION` : The AWS region where the domain bucket should be created. 
* `ROUTE53_DOMAIN_NAME` : The domain name you purchased for your website.
* `ROUTE53_HOSTED_ZONE_ID` : The hosted zone id created by route 53 for your domain.
* `ROUTE53_RECORD_TTL` : The time-to-life (TTL) for your website files. 
* `AWS_ACCESS_KEY_ID` : The access key for your IAM User.
* `AWS_SECRET_ACCESS_KEY` : The secret access key for your IAM User.
* `AWS_REGION` : The default AWS region. I would recommend it to be same as the region where you create your bucket for storing website files.

## Architecture
![alt text](images/website_architecture.png)

## Limitations

1. The User has to take some trouble to setup AWS and GitHub accounts. I have included the steps below.
2. Currently the pipeline only supports domains hosted in route 53. If your domain is hosted somewhere else like in Squarespace or Azure, then you have to make necessary changes to the terraform deployment files.
3. The pipeline only supports AWS deployment. I will setup Azure & GCP deployment pipelines at a later stage.

## Cost Break-Up

There are two types of costs involved in this project:
1. **One-time Costs (Optional)**: This is the cost of purchasing the website template. There are abundant free website templates available online, so depending on your needs you can either download free templates or purchase online.

    My personal favourite is [theme forest](https://themeforest.net/) website templates. They have a wide variety of website templates. You can also download free word press templates from [HTML5 UP](https://html5up.net).

2. **Infrastructure Costs**: This refers to the cost of using AWS Services. The total cost also depends on which domain name you purchase and how large is the size of the AWS S3 bucket. Below is the detailed breakdown of the infrastructure costs for deploying a portfolio website:

| AWS Service           | Cost (per year)   | Remarks                                            |
|-----------------------|-------------------|----------------------------------------------------|
| Registrar             | € 12.00           | Cost of domain renewal                             |
| Route 53              | € 6.00            | Cost of hosting the domain                         |
| AWS S3                | € 0.20            | Cost of storing website files (HTML / CSS)         |
| Cloud Front           | € 0.00            | Content delivery services from AWS                 |
| Certificate Manager   | € 0.00            | SSL Certificate for the website                    |
| **Total**             | **€ 18.20**       | **Total cost per year**                            |


## Pre-Requisites

This repository has four parts. I have explained each part below, so feel free to skip to whichever part you don't know about.
* ☁️ AWS Account Setup: An AWS account to deploy your website.
* 🐙 GitHub Account Setup: A GitHub account to store your website files and maintain a history of changes.
* 🛠️ Terraform configuration in `terraform` folder: This is the main configuration file for deploying the website on AWS. You do not have to change anything here as long as the secrets are stored properly on GitHub :)
* 🌐 Website files in `my_website` folder: Store all the required website files in this folder.

#### AWS Setup

1. Create a AWS Account and an IAM User to deploy the cloud infrastructure. Link to create an IAM User can be found [here](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html).
2. For your IAM User, generate access key and secret access key. **Save them in a safe place.**
    1. Go to security credentials tab
    ![alt text](images/image.png)
    2. Scroll down and click on create access key
    ![alt text](images/image-1.png)
3. Buy a domain name from AWS [Route53](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/registrar-tld-list.html). It will automatically create a Route53 hosted zone. You will require the `hosted_zone_id` and `domain_name` for the next steps.
![alt text](images/image-2.png)
4. Create AWS S3 bucket for storing terraform backend state securely. Here two values are very important, the bucket name and the AWS region where this bucket is stored. We will assign these values to `BACKEND_BUCKET_NAME` and `BACKEND_BUCKET_REGION` in github. Select the region closest to your geographical location.
    1. Select AWS region from drop-down
    ![alt text](images/image-4.png)
    2. Click Create bucket and assign a very unique bucket name. You could use `tfstate.<domain-name>` as bucket name.
    ![alt text](images/image-3.png)
    3. Enable bucket versioning and create the bucket.

#### GitHub Setup

1. Create a GitHub account to store the website files.
2. Fork this [Repository](https://github.com/kraken24/personal-website-with-terraform) from GitHub and clone it locally.

3. In the settings tab, go to `Secrets and variables` tab, click on `Actions` and add secrets.
![alt text](images/image-5.png)
4. Add secret `Name`: `Secret`value as follows:

| Name                       | Secret                       | Remarks                                             |
|----------------------------|------------------------------|----------------------------------------------------|
| `TF_VERSION`               | 1.8.5                        | The version of terraform to be used.    |
| `BACKEND_BUCKET_NAME`      | tfstate.your-domain-name     | The name of AWS S3 bucket to store terraform backend          |
| `BACKEND_BUCKET_REGION`    | eu-central-1                 | The AWS region where the bucket for terraform backend is created  |
| `AWS_ACM_REGION`           | us-east-1                    | The AWS region to provision SSL Certificates. This region should always be **`us-east-1`** |
| `DOMAIN_BUCKET_NAME`       | your-domain-name             | The name of AWS S3 bucket to store your website files. I would recommend it to be same as your domain name.  |
| `DOMAIN_BUCKET_REGION`     | eu-central-1                 | The AWS region where the domain bucket should be created.          |
| `ROUTE53_DOMAIN_NAME`      | your-domain-name             | The domain name you purchased for your website.         |
| `ROUTE53_HOSTED_ZONE_ID`   | your-route53-hosted-zone-id  | The hosted zone id created by route 53 for your domain.          |
| `ROUTE53_RECORD_TTL`       | 600                          | The time-to-life (TTL) for your website files.                  |
| `AWS_ACCESS_KEY_ID`        | access-key                   | The access key for your IAM User.                             |
| `AWS_SECRET_ACCESS_KEY`    | secret-access-key            | The secret access key for your IAM User.                      |
| `AWS_REGION`               | eu-central-1                 | The default AWS region. I would recommend it to be same as the region where you create your bucket for storing website files.  |

#### Website Files

1. Download the website template files of your choices from a wide range of online websites. My recommendations are:
    * [Paid Interactive Websites](https://themeforest.net/)
    * [Free HTML5 Websites](https://html5up.net/)
2. Update the downloaded website files with your personal information.
3. Upload all files into `my_website` folder.
4. As soon as the files are uploaded into the `my_website` folder, github will automatically update the files on AWS S3 bucket. You can check the progress in the actions tab of github

**Contributing**

If you'd like to contribute to this project, please feel free to open a pull request. Or if you have suggestions, feel free to write to me at `kraken2404@gmail.com`.

**License**

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

**Acknowledgments**

I hope this README provides a helpful overview of how to deploy and manage this personal portfolio website using AWS, Terraform, and GitHub Actions.
