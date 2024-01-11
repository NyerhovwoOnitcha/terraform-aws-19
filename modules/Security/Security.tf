locals {
  security_group = {
    ext-alb-sg = {
        name = "ext-alb-sg"
        description = "ext_loadbalancer SG"
        
    }

    bastion-SG = {
        name = "bastion-SG"
        description = "bastion server SG"
    }

    nginx-SG ={
        name = "nginx-SG"
        description = " nginx reverse proxy SG"
    }

    int-ALB-SG = {
        name = "int-ALB-SG"
        description = "internal_LB SG"
    }

    webservers-SG = {
        name = "webservers-SG"
        description = "webservers-SG"
    }

    datalayer-SG = {
        name = "datalayer-SG"
        description = "datalayer-SG"
    }
  }
}