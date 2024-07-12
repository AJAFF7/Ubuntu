#"""An AWS Python Pulumi program"""

#import pulumi
#from pulumi_aws import s3

# Create an AWS resource (S3 Bucket)
#bucket = s3.Bucket('my-bucket')

# Export the name of the bucket
#pulumi.export('bucket_name', bucket.id)



import pulumi
from pulumi_aws import s3, ec2

# Create an AWS resource (S3 Bucket)
bucket = s3.Bucket('my-bucket')

# Export the name of the bucket
pulumi.export('bucket_name', bucket.id)

# Create a security group for the EC2 instance
sg = ec2.SecurityGroup('instance-sg', description="security group for web servers")

# Define ingress rules for SSH and HTTP
allow_ssh = ec2.SecurityGroupRule("AllowSSH", type="ingress", from_port=22, to_port=22, protocol="tcp", cidr_blocks=["0.0.0.0/0"], security_group_id=sg.id)
allow_http = ec2.SecurityGroupRule("AllowHTTP", type="ingress", from_port=80, to_port=80, protocol="tcp", cidr_blocks=["0.0.0.0/0"], security_group_id=sg.id)

# Define egress rule allowing all traffic
allow_all = ec2.SecurityGroupRule("AllowAll", type="egress", from_port=0, to_port=0, protocol="-1", cidr_blocks=["0.0.0.0/0"], security_group_id=sg.id)

# Create an EC2 instance
ec2_instance = ec2.Instance('server_ubuntu',  # Unique instance name
                            ami="ami-023adaba598e661ac",
                            instance_type="t2.micro",
                            key_name="AJAFF-EC2",
                            vpc_security_group_ids=[sg.id],
                            tags={"name": 'web'})

# Export the public IP address of the EC2 instance
pulumi.export('public_ip', ec2_instance.public_ip)

