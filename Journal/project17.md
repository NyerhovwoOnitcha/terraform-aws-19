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




 