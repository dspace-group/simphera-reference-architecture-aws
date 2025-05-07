# Requirements
- Node.js installed
- Reference architecture is deployed with everything enabled


# Run
1. in `.\src\index.ts change` `const clusterid` to var.infrastructurename
1. Run `npm install`
1. Run `npx tsx '.\src\index.ts'`
1. Replace all var.infrstructure with <cluster name>
1. Replace all var.simpheraInstances[*].name with <environment>
1. Replace all arns with resource name
1. Add missing/remove descriptions
1. Add is Mandatory information
1. Align existing AWS cloud