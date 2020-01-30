# terraform-azure-301
A challenge style training on Terraform where individuals or groups compete to complete the objectives by fixing the code.

Each student group should have:
A username/password to access Azure Portal
A Terraform Enterprise enabled organization in TFC
Azure DevOps environment configured with code from the student folder
A TFC Workspace attached to the ADO code
The code successfully deployed using Terraform 0.11

At the start of the class, the instructor should delete the AKS clusters for everyone.

Students need to:
1) Get application running again
2) Upgrade code to 0.12
3) Modify code to pass sentinel tests
4) Improve/simplify code
5) Create dev/qa/prod environments as part of a pipeline

It's not expected that groups will finish all of these requirements in the time given.

Manual steps to build:
1) Enabling ADO, create project, create repo, create pipeline
2) Service principal created by instructor needs some of the following permissions:
Azure Active Directory Graph (2)
Application.ReadWrite.All
Application
Read and write all applications
Yes
 Granted for HashiCorp Training
User.Read
Delegated
Sign in and read user profile
-
 Granted for HashiCorp Training
Microsoft Graph (4)
Application.ReadWrite.All
Delegated
Read and write all applications
Yes
 Granted for HashiCorp Training
Application.ReadWrite.All
Application
Read and write all applications
Yes
 Granted for HashiCorp Training
User.Read
Delegated
Sign in and read user profile
-
 Granted for HashiCorp Training
User.Read.All
Application
Read all users' full profiles
Yes
 Granted for HashiCorp 

3) Update code in repo with service principal information in azurerm and azuread provider stanzas
