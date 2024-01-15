## Tagging

We will be updating our infrastructure with tags. We will be using the merge() function to achieve this.

```
tags = merge(
    var.tags,
    {
      Name = "Name of the resource"
    },
  )
```
Basically it says merge what we have on `var.tags` with `Name= "Name of the resource`

Update the variables.tf as seen below:

```
variable "tags" {
  description = "A mapping of tags to assign to all resources."
  type        = map(string)
  default     = {}
}
```

#### Tagging the Private and Public subnets

```
 # Create public subnet1
    resource "aws_subnet" "public" { 
        count                   = 2
        vpc_id                  = aws_vpc.main.id
        cidr_block              = "10.10.1.0/24"
        map_public_ip_on_launch = true
        availability_zone       = data.aws_availability_zones.available.names[count.index]


  tags = merge{
    var.tags,
    {
      Name = format("%s-PublicSubnet-%s", var.name, count.index)
	  },	
}
}
```

- The `format` helps us dynamically generate a unique name for the function properly
- The first `%s` is like declaring a variable in this case `var.name`
- The second `%s` declares `count.index`
- The resulting tag will be `var.name-PublicSubnet-count.index`

UPDATE the `variables.tf file`:

```
variable "tags"{
	type = map(string)
	default = {}
}
```

```
variable "name"{
	type = string
	default = "ACS"
}
```

UPDATE the `terraform.tfvars` file:

```
tags = {
	owner-Email = "papi@papi.io"
	Managed-By = "Terraform"
	Billing-Accoount = "123456789"
}
```

## Subnet Association
 To explain our configuration for subnet association, let's see the code:

 ```
 # create private route table
resource "aws_route_table" "private-rtb" {
  vpc_id = aws_vpc.main.id



  tags = merge(
    var.tags,
    {
        Name = format("%s-Private-Route-Table", var.name)
    },
  )
}

# associate all private subnets to the private route table
resource "aws_route_table_association" "private-subnets-assoc" {
  count          = length(aws_subnet.private[*].id)
  subnet_id      = element(aws_subnet.private[*].id, count.index)
  route_table_id = aws_route_table.private-rtb.id
}
 ```

We are dealing with multiple resource blocks, we wish to associate 4 private subnets to the the private route table. The skeletal code for this task is:
```
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.foo.id
  route_table_id = aws_route_table.bar.id
}
```

Since we want to achieve this using a block of resource instead of 4 blocks, we can the **count argument** with the **length function**, this tells terraform to determine the length of private subnet ids, i.e `length(aws_subnet.private[*].id)`, this will return a list that will be counted and terraform goes into a **loop** to create the resource 4x.

Basically: 
- `count          = length(aws_subnet.private[*].id)`: tells terraform it will be going to a loop 4x.

- subnet_id      = element(aws_subnet.private[*].id, count.index): This tells teraform that for every time it goes into the loop i.e for every count, take an element from the list of private subnets and associate it to the private-rtb


## IAM Roles
Remember that a role is just like a container that holds some policies, such that  whatever resources assume that role it can perform the actions defined by those policies. Policies can be attached to a user or a role, a user is an identity, like a person, a role is assumed by resources e.g ec2, fargate, etc.4

We want to give our instance access to some specific resources that it normally will not have access to. The way we do this is by:

- ### First we create an **Assume Role**. It allows an entity to assume the role we create and the permissions attached to the role
   - Assume Role uses Security Token Service (STS) API that returns a set of temporary security credentials that you can use to access AWS resources that you might not normally have access to.

```
resource "aws_iam_role" "ec2_instance_role" {
name = "ec2_instance_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = merge(
    var.tags,
    {
      Name = "aws assume role"
    },
  )
}

```

- ### Create an IAM policy for the Role created
  - we Define the required policy/permission for the role.

```
resource "aws_iam_policy" "policy" {
  name        = "ec2_instance_policy"
  description = "A test policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]

  })

  tags = merge(
    var.tags,
    {
      Name =  "aws assume policy"
    },
  )

}

```

- ### Attach the Policy to the Role

```
 resource "aws_iam_role_policy_attachment" "test-attach" {
        role       = aws_iam_role.ec2_instance_role.name
        policy_arn = aws_iam_policy.policy.arn
    }
    
```

- ### Create and instance Profile and Interpolate the IAM role to it

```
resource "aws_iam_instance_profile" "ip" {
        name = "aws_instance_profile_test"
        role =  aws_iam_role.ec2_instance_role.name
    }
    
```

- **Prepare AMI for bastion, nginx reverse proxy, wordpress webserver and tooling webserver.**
  - we logged into each server and made some installations before creating the AMIs. For the nginx reverse proxy it was a self signed certificate and both webservers it was a self signed certificate. There are different procedures for self signed certificates for apache and nginx servers, since the webservers are going to use apache thus the procedure was different.

### Before creating the auto-scaling group we first create a **Target Group > Launch Template and Load Balancer**


- **We created target groups for nginx servers, wordpress servers and tooling servers. Settings include:** `1.53.35`
  - protocol, healthchecks (/healthstatus) 

- **Next is the load balancer. Settings include:**
  - internete facing
  - listener protocol
  - AZs: must specify subnets from at least 2 AZs
  - certificate
  - security groups
  - routing to target groups, here you select the wordpress as default target and configure a listner rule for tooling target later. `2.01.50`
  - healthchecks = (/healthstatus)

- **Next is the launch template** `2.04.46`

** KEY FEATURE OF LAUNCH TEMPLATE IS `THE USER DATA and AMI`, we already prepared the AMI's for the bastion, nginx and webservers in project 15., but we will learn how to use packer in the next project
 
settings for launch template include:
  - AMI
  - instance type
  - key pair
  - subnet
  - security group
  - assign public ip or not
  - userdata

- **Next is the auto scaling group:** `2.25.21`
settings include:
  - launch template
  - VPC and subnets
  - loadbalancer: attach to loadbalancer yes or no
  - healthchecks: (tick `ELB`), 300secs grace period
  - Desired, minimum and maximum capacity
  - scaling policies: metric type(average cpu utilization), target value(90)
  - Notifications: create an SNS topic,



- **Creating a kms key:** `1.06.07`
settings include:
  - symmetric or asymmetric (tick symmetric)
  - alias
  - key administrator
  - key policy

- **Next is the RDS :** `1.08.00`
First creata a subnet group: settings include:
  - VPC
  - AZ ans subnets. In this case our RDS will be in the private subnet 3 and 4 so remember that. i.e 10.0.5.0/24 and 10.0.6.0/24

Create Database next, settings include:
  - engine type
  - engine version
  - template: (free tier)
  - DB instance identifier
  - username and password
  - storage type = general purpose SSD
  - ALLOCATED STORAGE = 20GB
  - enable storage autoscaling
  - maximum storage threshold = 1000GiB
  - VPC and SUBNET GROUP
  - public access = In this case, No.
  - security group
  - select any of the AZ
  - database auth option = password auth
  - initial DB name = test
  - 
- **Next is the File system:** `59.47`
settings include:
  - VPC
  - availability and durability =  choose Regional and not One Zone
  - Add mount targets: specify private subnet 1 and 2 where the webservers are as the mount targets so they can mount to the filesystem.
  - security group
  - Access points: create 2 access points for tooling and wordpress webserver. settings include:
    -  root directory = /wordpress and /tooling
    - Posix user:user ID = 0, Group ID = 0, leave secondary Group IDs blank
    - Root ID creation permissions:  owner user id = 0, owner group id = 0, POSIX permission to directory path = 0755

- **efs access point mount command:** `2.17.40`


 