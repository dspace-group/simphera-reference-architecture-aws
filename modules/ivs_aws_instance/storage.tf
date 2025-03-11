# resource "aws_s3_bucket" "data_bucket" {
#   bucket = var.dataBucketName
#   tags   = var.tags
# }

# resource "aws_s3_bucket" "rawdata_bucket" {
#   bucket = var.rawDataBucketName
#   tags   = var.tags
# }

# resource "aws_iam_role_policy" "eks_node_s3_access_policy" {
#   for_each = var.nodeRoleNames
#   role     = each.value
#   name     = "s3-access-policy"
#   policy   = <<EOF
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Action": [
#                 "s3:GetEncryptionConfiguration"
#             ],
#             "Effect": "Allow",
#             "Resource": "*"
#         },
#         {
#             "Action": [
#                 "s3:ListBucket"
#             ],
#             "Effect": "Allow",
#             "Resource": [
#                 "${aws_s3_bucket.data_bucket.arn}",
#                 "${aws_s3_bucket.rawdata_bucket.arn}"
#             ]
#         },
#         {
#             "Action": [
#                 "s3:Get*",
#                 "s3:List*",
#                 "s3-object-lambda:Get*",
#                 "s3-object-lambda:List*"
#             ],
#             "Effect": "Allow",
#             "Resource": [
#                 "${aws_s3_bucket.data_bucket.arn}/*",
#                 "${aws_s3_bucket.rawdata_bucket.arn}/*"
#             ]
#         },
#         {
#             "Action": [
#                 "s3:DeleteObject",
#                 "s3:PutObject"
#             ],
#             "Effect": "Allow",
#             "Resource": [
#                 "${aws_s3_bucket.data_bucket.arn}/*",
#                 "${aws_s3_bucket.rawdata_bucket.arn}/*"
#             ]
#         }
#     ]
# }
# EOF
# }
