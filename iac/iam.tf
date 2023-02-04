resource "aws_iam_role" "lambda" {
  name = "IGTILambdaRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": "AssumeRole"
    }
  ]
}
EOF

  tags = {
    IES   = "IGTI",
    CURSO = "EDC"
  }

}



resource "aws_iam_policy" "lambda" {
  name        = "IGTIAWSLambdaBasicExecutionRolePolicy"
  path        = "/"
  description = "Provides write permissions to CloudWatch Logs, S3 buckets and EMR Steps"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:*"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticmapreduce:*"
            ],
            "Resource": "*"
        },
        {
          "Action": "iam:PassRole",
          "Resource": ["arn:aws:iam::${var.accountid}:role/EMR_DefaultRole",
                       "arn:aws:iam::${var.accountid}:role/EMR_EC2_DefaultRole"],
          "Effect": "Allow"
        }
    ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "lambda_attach" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda.arn
}

#############
## KINESIS ##
#############

# resource "aws_iam_policy" "firehose" {
#   name        = "IGTIFirehosePolicy"
#   path        = "/"
#   description = "Provides write permissions to CloudWatch Logs and S3"

#   policy = <<EOF
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Effect": "Allow",
#             "Action": [
#                 "logs:CreateLogGroup",
#                 "logs:CreateLogStream",
#                 "logs:PutLogEvents",
#                 "glue:*"
#             ],
#             "Resource": "*"
#         },
#         {
#             "Effect": "Allow",
#             "Action": [
#                 "s3:AbortMultipartUpload",
#                 "s3:GetBucketLocation",
#                 "s3:GetObject",
#                 "s3:GetObjectVersion",
#                 "s3:DeleteObject",
#                 "s3:ListBucket",
#                 "s3:ListBucketMultipartUploads",
#                 "s3:PutObject"
#             ],
#             "Resource": [
#               "${aws_s3_bucket.stream.arn}",
#               "${aws_s3_bucket.stream.arn}/*"
#             ]
#         }
#     ]
# }
# EOF
# }



# resource "aws_iam_role_policy_attachment" "firehose_attach" {
#   role       = aws_iam_role.firehose_role.name
#   policy_arn = aws_iam_policy.firehose.arn
# }


###############
## GLUE ROLE ##
###############

resource "aws_iam_role" "glue_role" {
  name = "IGTIGlueCrawlerRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "glue.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
    IES = "IGTI"
    CURSO = "EDC"
  }

}


resource "aws_iam_policy" "glue_policy" {
  name        = "IGTIAWSGlueServiceRole"
  path        = "/"
  description = "Policy for AWS Glue service role which allows access to related services including EC2, S3, and Cloudwatch Logs"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "glue:*",
                "s3:GetBucketLocation",
                "s3:ListBucket",
                "s3:ListAllMyBuckets",
                "s3:GetBucketAcl",
                "ec2:DescribeVpcEndpoints",
                "ec2:DescribeRouteTables",
                "ec2:CreateNetworkInterface",
                "ec2:DeleteNetworkInterface",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSubnets",
                "ec2:DescribeVpcAttribute",
                "iam:ListRolePolicies",
                "iam:GetRole",
                "iam:GetRolePolicy",
                "cloudwatch:PutMetricData"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:CreateBucket"
            ],
            "Resource": [
                "arn:aws:s3:::aws-glue-*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:*:*:/aws-glue/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateTags",
                "ec2:DeleteTags"
            ],
            "Condition": {
                "ForAllValues:StringEquals": {
                    "aws:TagKeys": [
                        "aws-glue-service-resource"
                    ]
                }
            },
            "Resource": [
                "arn:aws:ec2:*:*:network-interface/*",
                "arn:aws:ec2:*:*:security-group/*",
                "arn:aws:ec2:*:*:instance/*"
            ]
        }
    ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "glue_attach" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.glue_policy.arn
}

resource "aws_iam_role" "EMR_DefaultRole" {
    name = "EMR_DefaultRole"

    assume_role_policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "Service": "elasticmapreduce.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF

}

resource "aws_iam_policy" "AmazonElasticMapReduceRole" {

    name        = "AmazonElasticMapReduceRole"
    path        = "/"
    description = "This policy is on a deprecation path. See documentation for guidance: https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-managed-iam-policies.html. Default policy for the Amazon Elastic MapReduce service role."

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Resource": "*",
            "Action": [
                "ec2:AuthorizeSecurityGroupEgress",
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:CancelSpotInstanceRequests",
                "ec2:CreateFleet",
                "ec2:CreateLaunchTemplate",
                "ec2:CreateNetworkInterface",
                "ec2:CreateSecurityGroup",
                "ec2:CreateTags",
                "ec2:DeleteLaunchTemplate",
                "ec2:DeleteNetworkInterface",
                "ec2:DeleteSecurityGroup",
                "ec2:DeleteTags",
                "ec2:DescribeAvailabilityZones",
                "ec2:DescribeAccountAttributes",
                "ec2:DescribeDhcpOptions",
                "ec2:DescribeImages",
                "ec2:DescribeInstanceStatus",
                "ec2:DescribeInstances",
                "ec2:DescribeKeyPairs",
                "ec2:DescribeLaunchTemplates",
                "ec2:DescribeNetworkAcls",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DescribePrefixLists",
                "ec2:DescribeRouteTables",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSpotInstanceRequests",
                "ec2:DescribeSpotPriceHistory",
                "ec2:DescribeSubnets",
                "ec2:DescribeTags",
                "ec2:DescribeVpcAttribute",
                "ec2:DescribeVpcEndpoints",
                "ec2:DescribeVpcEndpointServices",
                "ec2:DescribeVpcs",
                "ec2:DetachNetworkInterface",
                "ec2:ModifyImageAttribute",
                "ec2:ModifyInstanceAttribute",
                "ec2:RequestSpotInstances",
                "ec2:RevokeSecurityGroupEgress",
                "ec2:RunInstances",
                "ec2:TerminateInstances",
                "ec2:DeleteVolume",
                "ec2:DescribeVolumeStatus",
                "ec2:DescribeVolumes",
                "ec2:DetachVolume",
                "iam:GetRole",
                "iam:GetRolePolicy",
                "iam:ListInstanceProfiles",
                "iam:ListRolePolicies",
                "iam:PassRole",
                "s3:CreateBucket",
                "s3:Get*",
                "s3:List*",
                "sdb:BatchPutAttributes",
                "sdb:Select",
                "sqs:CreateQueue",
                "sqs:Delete*",
                "sqs:GetQueue*",
                "sqs:PurgeQueue",
                "sqs:ReceiveMessage",
                "cloudwatch:PutMetricAlarm",
                "cloudwatch:DescribeAlarms",
                "cloudwatch:DeleteAlarms",
                "application-autoscaling:RegisterScalableTarget",
                "application-autoscaling:DeregisterScalableTarget",
                "application-autoscaling:PutScalingPolicy",
                "application-autoscaling:DeleteScalingPolicy",
                "application-autoscaling:Describe*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": "iam:CreateServiceLinkedRole",
            "Resource": "arn:aws:iam::*:role/aws-service-role/spot.amazonaws.com/AWSServiceRoleForEC2Spot*",
            "Condition": {
                "StringLike": {
                    "iam:AWSServiceName": "spot.amazonaws.com"
                }
            }
        }
    ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "EMR_DefaultRole_attach" {
  role       = aws_iam_role.EMR_DefaultRole.name
  policy_arn = aws_iam_policy.AmazonElasticMapReduceRole.arn
}

resource "aws_iam_role" "EMR_EC2_DefaultRole" {
    name = "EMR_EC2_DefaultRole"

    path = "/"

    assume_role_policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF

}

resource "aws_iam_policy" "AmazonElasticMapReduceforEC2Role" {

    name        = "AmazonElasticMapReduceforEC2Role"
    path        = "/"
    description = "AmazonElasticMapReduceforEC2Role"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Resource": "*",
            "Action": [
                "cloudwatch:*",
                "dynamodb:*",
                "ec2:Describe*",
                "elasticmapreduce:Describe*",
                "elasticmapreduce:ListBootstrapActions",
                "elasticmapreduce:ListClusters",
                "elasticmapreduce:ListInstanceGroups",
                "elasticmapreduce:ListInstances",
                "elasticmapreduce:ListSteps",
                "kinesis:CreateStream",
                "kinesis:DeleteStream",
                "kinesis:DescribeStream",
                "kinesis:GetRecords",
                "kinesis:GetShardIterator",
                "kinesis:MergeShards",
                "kinesis:PutRecord",
                "kinesis:SplitShard",
                "rds:Describe*",
                "s3:*",
                "sdb:*",
                "sns:*",
                "sqs:*",
                "glue:CreateDatabase",
                "glue:UpdateDatabase",
                "glue:DeleteDatabase",
                "glue:GetDatabase",
                "glue:GetDatabases",
                "glue:CreateTable",
                "glue:UpdateTable",
                "glue:DeleteTable",
                "glue:GetTable",
                "glue:GetTables",
                "glue:GetTableVersions",
                "glue:CreatePartition",
                "glue:BatchCreatePartition",
                "glue:UpdatePartition",
                "glue:DeletePartition",
                "glue:BatchDeletePartition",
                "glue:GetPartition",
                "glue:GetPartitions",
                "glue:BatchGetPartition",
                "glue:CreateUserDefinedFunction",
                "glue:UpdateUserDefinedFunction",
                "glue:DeleteUserDefinedFunction",
                "glue:GetUserDefinedFunction",
                "glue:GetUserDefinedFunctions"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "EMR_EC2_DefaultRole_attach" {
  role       = aws_iam_role.EMR_EC2_DefaultRole.name
  policy_arn = aws_iam_policy.AmazonElasticMapReduceforEC2Role.arn
}

# resource "aws_iam_role" "SLRole_AWSServiceRoleForEMRCleanup" {
#     name = "AWSServiceRoleForEMRCleanup"

#     assume_role_policy = <<EOF
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Effect": "Allow",
#             "Principal": {
#                 "Service": "elasticmapreduce.amazonaws.com"
#             },
#             "Action": "sts:AssumeRole"
#         }
#     ]
# }
# EOF

# }

# resource "aws_iam_policy" "AmazonEMRCleanupPolicy" {

#     name        = "AmazonEMRCleanupPolicy"
#     path        = "/aws-service-role/elasticmapreduce.amazonaws.com/"
#     description = "AmazonEMRCleanupPolicy"

#   policy = <<EOF
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Effect": "Allow",
#             "Resource": "*",
#             "Action": [
#                 "ec2:DescribeInstances",
#                 "ec2:DescribeLaunchTemplates",
#                 "ec2:DescribeSpotInstanceRequests",
#                 "ec2:DeleteLaunchTemplate",
#                 "ec2:ModifyInstanceAttribute",
#                 "ec2:TerminateInstances",
#                 "ec2:CancelSpotInstanceRequests",
#                 "ec2:DeleteNetworkInterface",
#                 "ec2:DescribeInstanceAttribute",
#                 "ec2:DescribeVolumeStatus",
#                 "ec2:DescribeVolumes",
#                 "ec2:DetachVolume",
#                 "ec2:DeleteVolume",
#                 "ec2:DescribePlacementGroups",
#                 "ec2:DeletePlacementGroup"
#             ]
#         }
#     ]
# }
# EOF
# }

# resource "aws_iam_role_policy_attachment" "AWSServiceRoleForEMRCleanup_attach" {
#   role       = aws_iam_role.SLRole_AWSServiceRoleForEMRCleanup.name
#   policy_arn = aws_iam_policy.AmazonEMRCleanupPolicy.arn
# }

# resource "aws_iam_role" "EMR_AutoScaling_DefaultRole" {
#     name = "EMR_AutoScaling_DefaultRole"

#     assume_role_policy = <<EOF
# {
#     "Version": "2008-10-17",
#     "Statement": [
#         {
#             "Sid": "",
#             "Effect": "Allow",
#             "Principal": {
#                 "Service": [
#                     "elasticmapreduce.amazonaws.com",
#                     "application-autoscaling.amazonaws.com"
#                 ]
#             },
#             "Action": "sts:AssumeRole"
#         }
#     ]
# }
# EOF

# }

# resource "aws_iam_policy" "AmazonElasticMapReduceforAutoScalingRole" {

#     name        = "AmazonElasticMapReduceforAutoScalingRole"
#     path        = "/"
#     description = "Amazon Elastic MapReduce for Auto Scaling. Role to allow Auto Scaling to add and remove instances from your EMR cluster."

#   policy = <<EOF
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Action": [
#                 "cloudwatch:DescribeAlarms",
#                 "elasticmapreduce:ListInstanceGroups",
#                 "elasticmapreduce:ModifyInstanceGroups"
#             ],
#             "Effect": "Allow",
#             "Resource": "*"
#         }
#     ]
# }
# EOF
# }

# resource "aws_iam_role_policy_attachment" "EMR_AutoScaling_DefaultRole_attach" {
#   role       = aws_iam_role.EMR_AutoScaling_DefaultRole.name
#   policy_arn = aws_iam_policy.AmazonElasticMapReduceforAutoScalingRole.arn
# }

# resource "aws_iam_service_linked_role" "emr" {
#   aws_service_name = "elasticmapreduce.amazonaws.com"
# }

resource "aws_iam_instance_profile" "emr_profile" {
    name = aws_iam_role.EMR_EC2_DefaultRole.name
    role = aws_iam_role.EMR_EC2_DefaultRole.name
}

resource "aws_iam_service_linked_role" "emr" {
  aws_service_name = "elasticmapreduce.amazonaws.com"
}