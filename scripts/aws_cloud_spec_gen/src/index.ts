import YAML from 'yaml'
import { execSync } from "child_process"
import * as fs from 'fs';

const clusterid = ""


const builtin_roles = [
    "AmazonSSMRoleForAutomationAssumeQuickSetup",
    "AmazonSSMRoleForInstancesQuickSetup",
    "AWSServiceRoleForAmazonEKS",
    "AWSServiceRoleForAmazonEKSForFargate",
    "AWSServiceRoleForAmazonEKSNodegroup",
    "AWSServiceRoleForAmazonSSM",
    "AWSServiceRoleForAPIGateway",
    "AWSServiceRoleForAutoScaling",
    "AWSServiceRoleForEC2Spot",
    "AWSServiceRoleForECS",
    "AWSServiceRoleForElasticLoadBalancing",
    "AWSServiceRoleForGlobalAccelerator",
    "AWSServiceRoleForNetworkFirewall",
    "AWSServiceRoleForOrganizations",
    "AWSServiceRoleForRDS",
    "AWSServiceRoleForServiceQuotas",
    "AWSServiceRoleForSupport",
    "AWSServiceRoleForTrustedAdvisor"
]

const execute = (cmd: string) => {
    return JSON.parse(execSync(cmd).toString())
}


const index_value = (arn: string) => {
    let splits = arn.split(":")

    let subtype = splits[5]

    if (subtype.indexOf("/") > 0) {

        subtype = subtype.substring(0, subtype.indexOf("/"))
    }
    if (splits[2] === "s3") {
        return "s3"
    }
    return splits[2] + ":" + subtype
}
const vpcid = execute(`aws ec2 describe-vpcs --filters "Name=tag:Name,Values=${clusterid}-vpc" --query "Vpcs[].VpcId"`)[0]

class Category {
    name = ""
    icon = ""
    path = ""
    services = new Array<Service>()
}

class Service {
    name = ""
    icon = ""
    parent = new Category()
    resources = new Array<ResourceType>()
}

class ResourceType {
    name: string = ""
    icon: string | null = null
    parent = new Service()
    arn = ""
    type = "normal"
    source: string | null = null
    instances = new Array<Instance>()
}

class Instance {
    name: string = ""
    arn: string = ""
    constructor(name: string, arn: string) {
        this.name = name
        this.arn = arn
    }
}

const structure = YAML.parse(fs.readFileSync("structure.yaml").toString())
const arn_index = new Map<string, ResourceType>()
const categories = new Array<Category>()

for (let category of structure) {
    let category_ = new Category()
    category_.name = category.name
    category_.icon = category.path + "/" + category.icon
    category_.path = category.path

    for (let service of category.services) {
        let service_ = new Service()
        service_.parent = category_
        service_.name = service.name
        service_.icon = category.path + "/" + service.icon

        for (let resource of service.resources) {
            let resource_ = new ResourceType()
            resource_.name = resource.name
            resource_.icon = resource.icon ? category.path + "/" + resource.icon : null
            resource_.arn = resource.arn
            resource_.type = resource.type ? resource.type : "normal"
            resource_.source = resource.source ? resource.source : null
            service_.resources.push(resource_)
            arn_index.set(resource_.arn, resource_)
        }
        category_.services.push(service_)
    }
    categories.push(category_)

}

const resources = execute(`aws resourcegroupstaggingapi get-resources --tag-filters Key=clusterid,Values=${clusterid}`)
for (let resource of resources.ResourceTagMappingList) {
    let original_arn = resource.ResourceARN
    let indexed_arn = index_value(original_arn)
    let resource_ = arn_index.get(indexed_arn)
    if (resource_) {
        let name = resource.Tags.filter(item => item.Key === "Name").map(item => item.Value)
        resource_.instances.push(new Instance(name, original_arn))
    }
}
const security_groups = execute(`aws ec2 describe-security-groups --filters Name=vpc-id,Values=${vpcid}`)
const sg_buffer = new Array<string>()
sg_buffer.push(`<table>`)
sg_buffer.push(`<tr><th>Group name</th><th>Group description</th><th>Direction</th><th>Protocol</th><th>Port range</th><th>Rule description</th></tr>`)
for (let sg of security_groups.SecurityGroups) {
    let description = sg.Description
    let groupname = sg.GroupName
    if (sg.Tags) {
        for (let tag in sg.Tags) {
            let item = sg.Tags[tag]
            if (item.Key == "Name") {
                groupname = item.Value
                break
            }
        }
    }
    else {
        console.log("error: " + groupname)
    }

    let rowspan = 0
    let sg_buffer_ = new Array<string>()
    let first = true
    for (let ippermission of sg.IpPermissions) {
        let portrange = ""
        if (ippermission.FromPort) {

            let fromport = ippermission.FromPort
            let toport = ippermission.ToPort
            if (fromport != toport) {
                portrange = fromport + " - " + toport
            }
            else {
                portrange = fromport
            }
        }
        else {
            portrange = "All"
        }

        let ipprotocol = ippermission.IpProtocol == "-1" ? "All" : ippermission.IpProtocol

        for (let range of ippermission.IpRanges) {

            let ruledescription = range.Description || ""
            rowspan++
            if (first) {
                sg_buffer_.push(`<tr><td rowspan="%d">${groupname}</td><td rowspan="%d">${description}</td>`)
                first = false
            }
            else {
                sg_buffer_.push(`<tr>`)
            }
            sg_buffer_.push(`<td>inbound</td><td>${ipprotocol}</td><td>${portrange}</td><td>${ruledescription}</td></tr>`)
        }

        for (let range of ippermission.UserIdGroupPairs) {

            let ruledescription = range.Description || ""
            rowspan++
            if (first) {
                sg_buffer_.push(`<tr><td rowspan="%d">${groupname}</td><td rowspan="%d">${description}</td>`)
                first = false
            }
            else {
                sg_buffer_.push(`<tr>`)
            }
            sg_buffer_.push(`<td>inbound</td><td>${ipprotocol}</td><td>${portrange}</td><td>${ruledescription}</td></tr>`)
        }
    }

    for (let ippermission of sg.IpPermissionsEgress) {
        let portrange = ""
        if (ippermission.FromPort) {

            let fromport = ippermission.FromPort
            let toport = ippermission.ToPort
            if (fromport != toport) {
                portrange = fromport + " - " + toport
            }
            else {
                portrange = fromport
            }
        }
        else {
            portrange = "All"
        }

        let fromport = ippermission.FromPort
        let ipprotocol = ippermission.IpProtocol == "-1" ? "All" : ippermission.IpProtocol

        for (let range of ippermission.IpRanges) {
            let ruledescription = range.Description || ""
            rowspan++

            if (first) {
                sg_buffer_.push(`<tr><td rowspan="%d">${groupname}</td><td rowspan="%d">${description}</td>`)
                first = false
            }
            else {
                sg_buffer_.push(`<tr>`)
            }
            sg_buffer_.push(`<td>outbound</td><td>${ipprotocol}</td><td>${portrange}</td><td>${ruledescription}</td></tr>`)
        }
        for (let range of ippermission.UserIdGroupPairs) {
            let ruledescription = range.Description || ""
            rowspan++
            if (first) {
                sg_buffer_.push(`<tr><td rowspan="%d">${groupname}</td><td rowspan="%d">${description}</td>`)
                first = false
            }
            else {
                sg_buffer_.push(`<tr>`)
            }
            sg_buffer_.push(`<td>inbound</td><td>${ipprotocol}</td><td>${portrange}</td><td>${ruledescription}</td></tr>`)
        }
    }
    sg_buffer.push(sg_buffer_.join("").replace(/%d/g, rowspan + ""))
}
sg_buffer.push(`</table>`)

const buffer = new Array<string>()
const prefix = "https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/"

for (let category of categories) {
    buffer.push(`\n# <a name="Category_${category.name}"></a> ![${category.name}](${prefix}${category.icon}) ${category.name}`)

    for (let service of category.services) {
        buffer.push(`\n## <a name="Service_${service.name}"></a> ![${service.name}](${prefix}${service.icon}) ${service.name}`)

        for (let resource of service.resources) {

            let rbuffer = new Array<string>()
            if (resource.type === "normal") {
                rbuffer.push(`\n### <a name="Resource_${resource.name}"></a>`)
                if (resource.icon != null) {
                    rbuffer.push(`![${resource.name}](${prefix}${resource.icon}) `)
                }
                rbuffer.push(resource.name)
            }
            else {
                rbuffer.push(`\n### ${resource.name}`)
            }

            buffer.push(rbuffer.join(""))
            if (resource.type === "normal") {


                if (resource.name === "Security group") {
                    buffer.push(sg_buffer.join("\n"))
                }
                else {
                    if (resource.instances.length > 0) {
                        buffer.push("| Name | Description | Mandatory? |")
                        buffer.push("| ---- | ----------- | ---------- |")

                    }

                    for (let instance of resource.instances) {
                        if (instance.name.length > 0) {
                            buffer.push(`| ${instance.name} | tbd | tbd |`)
                        }
                        else {
                            buffer.push(`| ${instance.arn} | tbd | tbd |`)
                        }
                    }
                }

            }
            else {
                const requirement = fs.readFileSync(`static/${resource.source}`).toString()
                buffer.push(requirement)
            }
        }
    }
}

const policies = new Set<string>()
const roles = execute("aws iam list-roles")

buffer.push("\n# ![Security, Identity, & Compliance](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/SecurityIdentityCompliance/SecurityIdentityCompliance.png) Security, Identity, & Compliance")
const buffer_roles = []
buffer_roles.push("\n## ![AWS Identity and Access Management](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/SecurityIdentityCompliance/IdentityandAccessManagement.png) AWS Identity and Access Management")
buffer_roles.push("\n### ![Role](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/SecurityIdentityCompliance/IdentityAccessManagementRole.png) Role")

buffer_roles.push("| Role name | Description | Policies  |")
buffer_roles.push("| --------- | ----------- | --------- |")


for (let role of roles.Roles) {

    let rolename = role.RoleName + ""

    if (!builtin_roles.includes(rolename)) {
        role = execute(`aws iam get-role --role-name ${rolename}`)

        if (role.Role.Tags && role.Role.Tags) {

            let match = role.Role.Tags.find((element: any) => element.Key == "clusterid" && element.Value == clusterid)

            let description = role.Role.Description || ""
            description = description.replace("\n", "")
            let policy_refs = []
            if (match) {


                let attachedpolicies = execute(`aws iam list-attached-role-policies --role-name ${rolename}`)

                for (let policy of attachedpolicies.AttachedPolicies) {
                    let item = `<li>[${policy.PolicyName}](#${policy.PolicyName})</li>`
                    policy_refs.push(item)
                    policies.add(policy.PolicyArn)
                }

                let rolepolicies = execute(`aws iam list-role-policies --role-name ${rolename}`)
                for (let policy of rolepolicies.PolicyNames) {

                    let item = `<li>${policy}</li>`
                    policy_refs.push(item)

                }

                let policies_str = `<ul>${policy_refs.join("")}</ul>`

                buffer_roles.push(`|${rolename}|${description}|${policies_str}|`)
            }
        }
        else {
            console.log(`Role ${rolename} is not tagged with clusterid=${clusterid}.`)
        }
    }
    else {
        console.log(`Role ${rolename} is ignored.`)
    }
}


const buffer_policies = []
buffer_policies.push("\n### ![Policies](https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/main/dist/SecurityIdentityCompliance/IdentityAccessManagementPermissions.png) Policies")
buffer_policies.push("| Policy name | Description | Managed By |")
buffer_policies.push("| ----------- | ----------- | ---------- | ")

policies.forEach(arn_ => {
    let arn = arn_ + ""
    let policy = execute(`aws iam get-policy --policy-arn ${arn}`)
    let anchor = `<a name="${policy.Policy.PolicyName}"></a>`
    let description = policy.Policy.Description || ""
    description = description.replace("\n", "")
    let name = arn.startsWith("arn:aws:iam::aws:policy/") ? `[${policy.Policy.PolicyName}](https://raw.githubusercontent.com/SummitRoute/aws_managed_policies/master/policies/${policy.Policy.PolicyName})` : `[${policy.Policy.PolicyName}](./)`
    name = anchor + name
    let type = arn.startsWith("arn:aws:iam::aws:policy/") ? "AWS" : "Customer"
    buffer_policies.push(`|${name}|${description}|${type}|`)
})


Array.prototype.push.apply(buffer, buffer_roles)
Array.prototype.push.apply(buffer, buffer_policies)

fs.writeFileSync(`AWSCloudSpec.md`, buffer.join("\n"))
