# AWS Cloud Spec generation tool
This tool can be used to partially generate AWSCloudSpec.md file from deployed reference architecture and AWS CLI commands.
This script relies on resource tags, more specifically on `clusterid` tag.

## Requirements
- Node.js installed
- Reference architecture is deployed with everything enabled
    - `var.tags` must contain key `clusterid`, with the name of EKS cluster being deployed as a value

## Generate AWS Clous Spec
1. in `.\src\index.ts` change value of `const clusterid` to the value of terraform variable `var.infrastructurename`
1. Run `npm install`
1. Run `npx tsx '.\src\index.ts'`
1. Replace all `var.infrastructurename` with <cluster name>
1. Replace all `var.simpheraInstances[*].name` with <environment>
1. Replace all arns with resource name
1. Based on existing `AWSCloudSpec.md` from previous iteration:
    1. Add missing descriptions
    1. Remove `Description` column where needed
    1. Add values to `Mandatory` column where needed
    1. Remove `Mandatory` column where needed
