<h1 align="center">Deploy Banking Flask application using a Jenkins agent<h1> 


# Deployment 5.1
October 13, 2023

By: Andrew Mullen

## Purpose:

Demonstrating the ability to deploy a Banking Flask application to EC2 instances using a Jenkins agent while also practicing creating infrastructure for Jenkins and Flask applications with the Guincorn web server and SQLite database

## Steps:

### 1. Create a new key pair in AWS, save the .pem file on your computer, and attach the new private key to all your instances.
   - We will need the new keys when we configure our Jenkins Agent.

### 2. Create a VPC with Terraform and the VPC MUST have only the components listed: 1 VPC, 2 AZ's, 2 Public Subnets, 3 EC2's (The application instances should be in their own subnet), 1 Route Table, Security Group Ports: 8080, 8000, 22
   - This process gives us practice using Terraform to create our AWS infrastructure using resource blocks.  Here is the link to the main.tf file [HERE](https://github.com/andmulLABS01/Deployment_5.1AM/blob/main/main.tf)
   - Also we will utilize Git to continue gaining experience in the day-to-day operations of a DevOps engineer.
   - We will also use Jenkins Agents to deploy the Banking Flask application on the application instances
   - Use git commands to clone the Kura Deployment 5.1 repository to the local instance and push it to the new repository
   
#### 2a. Clone the Kura repository to our Jenkins instance and push it to the new repository
	- Create a new repository on GitHub
	- Clone the Kura Deployment 5.1 repository to the local instance
		- Clone using `git clone` command and the URL of the repository
			- This will copy the files to the local instance 
		- Enter the following to gain access to GitHub repository
			- `git config --global user.name username`
			- `git config --global user.email email@address`
		- Next, you will push the files from the local instance to the new repository (Done from the local instance via the command line)
			- `git push`
			- enter GitHub username
			- enter personal token (GitHub requires this as it is more secure)

### 3. For the Jenkins instance follow the instructions below: D5.1_Jenkins_EC2
   - Install required packages
```
- software-properties-common, sudo add-apt-repository -y ppa:deadsnakes/ppa, python3.7, python3.7-venv}
- Install the following plugin: “Pipeline Keep Running Step”
```

###	4. On the other 2 instances, install the following: D5.1_AppServer1_EC2; D5.1_AppServer2_EC2
- Install the following:
```
 {default-jre, software-properties-common, sudo add-apt-repository -y ppa:deadsnakes/ppa, python3.7, python3.7-venv}
```

### 5. Make a Jenkins agent on the second instance
- This is the step where we will configure and then utilize a Jenkins Agent to deploy the Banking application.
- Follow the steps in this link to create a Jenkins agent: [link](https://scribehow.com/shared/Step-by-step_Guide_Creating_an_Agent_in_Jenkins__xeyUT01pSAiWXC3qN42q5w)
		
### 6. Create a Jenkins multibranch pipeline and run the Jenkinsfile

- Jenkins is the main tool used in this deployment for pulling the program from the GitHub repository, and then building and testing the files to be deployed to instances.
- Creating a multibranch pipeline allows implementing different Jenkinsfiles for different branches of the same project.
- A Jenkinsfile is used by Jenkins to list out the steps to be taken in the deployment pipeline.
- A Jenkins agent is a machine or container that connects to a Jenkins controller and executes tasks when directed by the controller. 

- Steps in the Jenkinsfile are as follows:
  - Build
    - The environment is built to see if the application can run.
  - Test
    - Unit test is performed to test specific functions in the application.
  - Clean
	- Uses the Jenkins Agent to run the script that stops gunicorn process.
  - Deploy
    - Uses the Jenkins Agent to deploy the application by installing the required files and running gunicorn. 	


### 7. Check the application!!
	- Here is the screenshot of the application. [HERE](https://github.com/andmulLABS01/Deployment_5.1AM/blob/main/1st_instance.PNG)
	
### 8. Now figure out how to deploy the application on the third instance	

- In order to deploy the application to the third instance we will need to configure another agent, the same way as we did before, calling the node name `awsDeploy2` and modifying/adding another Jenkinsfile (Jenkinsfilev1).

#### 8a. Branch, update, and merge Jenkinsfile into the main branch
	- Create a new branch in your repository
		- `git branch newbranchName`
	- Switch to the new branch and create Jenkinsfilev1
		- `git switch newbranchName`
    - `touch Jenkinsfilev1`
    - `nano Jenkinsfilev1`
		- Update Jenkinsfilev1 with the new agent label in the Clean and Deploy stages with agent `{label 'awsDeploy2'}`
	- After modifying the Jenkinsfile commit the changes
		- `git add "filename"`
		- `git commit -m "message"`
	- Merge the changes into the main branch
		- `git switch main`
		- `git merge second main`
	- Push the updates to your repository
		- `git push`
		
#### 8b. Modify the pipeline to use Jenkinsfilev1 and check the application on 3rd instance
- Here is the screenshot of the application on the 3rd instance. [HERE](https://github.com/andmulLABS01/Deployment_5.1AM/blob/main/2nd_instance.PNG)

### 9. What should be added to the infrastructure to make the application more available to users?

- I believe that we could add an application load balancer to balance traffic between the two application servers to make the application more available to users.

### 10. What is the purpose of a Jenkins agent?

- From a security, performance, and best practice perspective, it is much better to use an agent to do all of your work.
- It also allows you to run multiple functions across several different nodes.


## System Diagram:

To view the diagram of the system design/deployment pipeline, click [HERE](https://github.com/andmulLABS01/Deployment_5.1AM/blob/main/Deployment_5-1.drawio.png)

## Issues/Troubleshooting:

Trouble understanding how to create and install agents on remote servers.

Resolution Steps:
- Read the documentation and used ChatGPT to break down the documentation into a format that I could understand.


## Conclusion:

As stated in previous documentation this deployment was improved by automating the setup of infrastructure by using Terraform.  
However, additional improvements can be made by changing how we utilize the Jenkins Agents.  For example, we could have created two agents and modified the Jenkinsfile to utilize one for testing and one for deployment of the application.  We can also utilize ChatGPT to assist with error messages and ask to explain options in Jenkinsfile. Utilizing prompts such as:

- You are a Jenkins pipeline expert
- Check the Jenkinsfile for errors
- Please explain the error, including the method to fix the error, and provide a link to documentation. 
