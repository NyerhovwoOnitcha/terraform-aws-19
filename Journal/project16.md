Step 1- Networking:
     Create VPC and subnets, Internet gateway, NAT gateway, EIPs, Route table, route table association and routes
Step 2- AWS identity and Access Management:
     Create Assume Role, Create Policy for the role created, attach policy to role,create Instance Profile and interpolate the role.

Step 3- Security Groups

Step 4- Create and Validate Certificate, then create records for tooling and wordpress in route 53

Step 5- Create external LoadBalancer: 
    Create the external load balancer, Create target group for the ext loadbalanceri.e Nginx target group, create listener for this target group. Lastly, create an output.tf file that outputs the `loadbalancer dns name` and `the nginx target group arn`

Step 6- Create Internal Loadbalancer:
    Create the internal loadbalancer to serve the webservers, create the 2 webserver target groups i.e wordpress and tooling, create a listener that defaults traffic to the wordpress, lastly create a listener rule that forwards traffic to the tooling server depending on the header.

Step 7- Create SNS topic for all the autoscaling groups
    First create the SNS topic, then create the `notification` for all autoscaling groups using the `aws_autoscaling_notification resource`. 

Step 8- Create launch template:
    use the random shuffle resource to shuffle the list of AZs
    first create launch template for bastion server, then create autoscaling group for bastion server.

    THEN create launch template and autoscaling group for nginx reverse proxy, attach the autoscaling group of the nginx to the ext. load balancer. Repeat for wordpress and tooling server

Step 9- Create EFS file system.
    first create the `kms key and the kms key alias`, next up is the `EFS`, after which you create the `mount points(2 each in private subnet 1 and 2 respectively)`.

    THEN create the access points, one for the wordpress server and one for tooling server.

Step 10- Create the RDS:
    First create the subnet groups where the databases will be situated i.e subnet 3 and 4(project overview diagram), then create the `RDS`




#----------------------------------------------------------------------------------
## GUI CONFIGURATION STEPS AND SOME SETTINGS CONFIGURED in project 15. To be used as guidance when writing the terraform script of the infrastructure

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



#---------------------------------------------------------------------------------------------------


## Using LOOPS and DATA SOURCES in Fixing the Problem of Multiple Resource Blocks

In this project you will be creating 6 subnets groups, your `subnet.tf` file should reflect this:

```
# Create public subnets1
    resource "aws_subnet" "public1" {
    vpc_id                     = aws_vpc.main.id
    cidr_block                 = "10.0.1.0/24"
    map_public_ip_on_launch    = true
    availability_zone          = "us-east-1"

}

# Create public subnet2
    resource "aws_subnet" "public2" {
    vpc_id                     = aws_vpc.main.id
    cidr_block                 = "10.0.2.0/24"
    map_public_ip_on_launch    = true
    availability_zone          = "us-east-1"
}
```

There are 2 issues with the code block above, the first is the hardcoding of values, the second is issue of multiple resource blocks.

Imagine you want to create multiple resources e.g 50 subnets, that means you will create 50 resource blocks, that is a long process. We can use **Data Sources and Loops" to achieve this.

#### DATA SOURCES
Terraform has a functionality that allows us to pull data which exposes information to us. For example, every region has Availability Zones (AZ). Instead of harcoding the AZs in our code, we will explore the use of Terraform’s Data Sources to fetch information outside of Terraform. In this case, from AWS

Let us fetch Availability zones from AWS:

```
 # Get list of availability zones
data "aws_availability_zones" "available" {
    state = "available"
}
```

The `output` of this resource is a list object that contains a list of available AZs that terraform recieves internally in this format:
["eu-central-1a", "eu-central-1b"]

They are all indexes, the first is index 0, the second is index 1 and so on...........

#### LOOPS
To make use of this `data resource` we will introduce a count argument in the subnet block:

```
 # Create public subnet1
    resource "aws_subnet" "public" { 
        count                   = 2
        vpc_id                  = aws_vpc.main.id
        cidr_block              = "10.10.1.0/24"
        map_public_ip_on_launch = true
        availability_zone       = data.aws_availability_zones.available.names[count.index]

    }
```

Let's explain what is going on here:

- The count argument tells us and terraform that need 2 subnets thus, terraform creates a **Loop** to create 2 subnets.

- Each time terraform goes into this loop to create a subnet the subnet must be created in the retrieved AZ from the list gotten from the **Data Resource**. Each loop need the index number to determine what AZ the subnet will be created. That is why we have `data.aws_availability_zones.available.names[count.index]` as the value for availability_zone. When the first loop runs, the first index will be 0, therefore the AZ will be eu-central-1a. The pattern will repeat for the second loop.\

**But we still have a problem, if we run our configuration like this the first loop will run just fine but the second loop will fail because 2 subnets can't have the same `CIDR_BLOCK`. This is a problem because our `cidr_block` is hardcoded.**

#### Make CIDR_BLOCK Dynamic

We will introduce a function **cidrsubnet()**  to achieve this, this function takes 3 parameters i.e cidrsubnet(prefix, newbits, netnum):

- The prefix parameter also known as the `VPC_CIDER` must be given in CIDR notation, same as for VPC.

- The newbits parameter is the number of additional bits with which to extend the prefix/cider. For this specific example the vpc cider is 16 i.e 10.0.0.0/16, thus if given a prefix ending with /16 and a newbits value of 4, the resulting subnet address will have length /20. We want our resulting subnet address to have a lenght of /24 thus our newbuts value will be 8.

- The netnum parameter is a whole number that can be represented as a binary integer with no more than newbits binary digits, which will be used to populate the additional bits added to the prefix. **In Layman terms the netnum is the whole number we want to create, if you check the address of the 2 subnets we wish to create in the beginning they are 10.0.1.0/24 and 10.0.2.0/24, 1 and 2 are the netnum**

This is how we use the cidrsubnet() function to dynamically allocate cidr block.

Our configuration now becomes:

```
# Create public subnet1
    resource "aws_subnet" "public" { 
        count                   = 2
        vpc_id                  = aws_vpc.main.id
        cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
        map_public_ip_on_launch = true
        availability_zone       = data.aws_availability_zones.available.names[count.index]

    }
```

You can experiment how this works by entering the terraform console and keep changing the figures to see the output.


- On the terminal, run $terraform console
- type cidrsubnet("10.0.0.0/16", 4, 1)
- Hit enter
- See the output
- Keep change the numbers and see what happens.
- To get out of the console, type exit

#### Removing Hardcoded Count Value

The `count value = 2` is hardcoded in our configuration, we need a way to dynamically provide the value based on some input. Since the data resource returns all the AZs within a region, it makes sense to count the number of AZs returned and pass that number to the count argument.

We can do this using the **length() function** this function determines the length of a given list, map, or string. we can use this function in the `data resource` as it's output is a list, doing so will return the number of AZs available. 

Update the configuration:

```
# Create public subnet1
    resource "aws_subnet" "public" { 
        count                   = length(data.aws_availability_zones.available.names)
        vpc_id                  = aws_vpc.main.id
        cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
        map_public_ip_on_launch = true
        availability_zone       = data.aws_availability_zones.available.names[count.index]

    }
```

This configuration will work but does not actually achieve what we want, we want to create 2 subnets but, if the length function returns 4 as the number of available subnets then terraform will go into a loop 4x and create 4 subnets. 

How do we fix this?

- Declare a variable to store the desired number of public subnets, and set the default value

```
variable "preferred_number_of_public_subnets" {
  default = 2
}
```

- Next, update the count argument with a condition. Terraform needs to check first if there is a desired number of subnets. Otherwise, use the data returned by the lenght function. See how that is presented below.

```
# Create public subnets
resource "aws_subnet" "public" {
  count  = var.preferred_number_of_public_subnets == null ? length(data.aws_availability_zones.available.names) : var.preferred_number_of_public_subnets   
  vpc_id = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 4 , count.index)
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]

}
```

This configuration achieves our aim of avoiding multiple resource blocks and adhering to best practices by not hardcodind values

Let's break down the condition:

- The first part `var.preferred_number_of_public_subnets == null` checks if the value of the variable is set to null or has some value defined.

- The second part `? and length(data.aws_availability_zones.available.names)` means, if the first part is true, then use this. In other words, if preferred number of public subnets is null (Or not known) then set the value to the data returned by length function.

- The third part `: and var.preferred_number_of_public_subnets` means, if the first condition is false, i.e preferred number of public
 subnets is not null then set the value to whatever is definied in var.preferred_number_of_public_subnets




