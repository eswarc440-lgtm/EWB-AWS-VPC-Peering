# Export your EXISTING AWS Console infrastructure as code

The Terraform files in this repository are reconstructed examples. For a closer record of the **actual** live console configuration, use the AWS **CloudFormation IaC Generator**.

## AWS Console-only steps

1. Sign in to the AWS Management Console and select **US East (N. Virginia), `us-east-1`** (the Region used by the tested lab).
2. Search for **CloudFormation** and open it.
3. In the CloudFormation sidebar, select **IaC generator**.
4. Choose **Start a new scan**. A targeted scan is possible; choose resource types relevant to this project (VPC, subnet, Internet gateway, route table, security group, EC2 instances and VPC peering), when supported. Alternatively scan all resources if permitted.
5. After the scan finishes, choose **Create template** → **Start from a new template**.
6. Give it a name such as `aws-vpc-peering-existing-lab`, then **select only the project resources** you recognize. Add relevant related resources when appropriate.
7. Create the template. Review any warnings, unsupported resources, parameter values and hard-coded IDs.
8. **Download the generated YAML or JSON CloudFormation template**.
9. Review/redact any identifying or sensitive metadata before committing a copy as `cloudformation/existing-lab-generated.yaml` (create this directory when you have the export).
10. Upload the template to GitHub with the other project files.

**This does not change or redeploy live VPC resources.** Generating a template is separate from CloudFormation resource import, stack creation or Terraform import. Do **not** select "Create stack", "Import resources" or "Deploy" solely to make a GitHub portfolio.

## Limitations

- IaC generator supports supported CloudFormation/Cloud Control resources, not necessarily every AWS setting; check resource support and generated output.
- Reconcile missing SG rules, route associations, EC2 settings, public IP behavior and SSH key references against your AWS Console screenshots.
- Do not upload a downloaded SSH private key, API key, access key, Terraform state, AWS account identifiers or security-sensitive values unless you have deliberately reviewed them.
- Do not pretend an exported template was automatically deployed using IaC. The original implementation was **manual**.

Sources:
- https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/generate-IaC.html
- https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/iac-generator-start-resource-scan.html
- https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/iac-generator-create-template-from-scanned-resources.html
