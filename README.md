# terraforrm-aws
Create an AWS account and IAM role with the requisite  administrative role and programmatic access 
then issue on the command prompt 
aws configure --profile terradorm-user 
to crosscheck issue command in your command prompt type:


$ aws sts get-caller-identity --profile terradorm-user 


to find a suitable image for ec2 creation and provisioning 


$ aws ec2 describe-images --region ap-south-1 --filters "Name=owner-alias,Values=amazon" "Name=name,Values=ubuntu*" --query "Images[].[ImageId,Name]" --output table --profile terradorm-user


then, finally, within the current GitHub folder try

$ terraform init 

$ terraform validate
 
$ terraform apply -auto-approve

$  terraform destroy -auto-approve

 
