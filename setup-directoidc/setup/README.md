# Google Workload Identity Demo

1. identity_pool: a WIF container
1. identity_pool_provider: the AuthN WIF implementation component. Defines the primary attributes necessary for authN, maps expected attributes from the JWT for usage in WIF, sets condition boundaries for admission (`attribute_condition`)
1. service_account: TFC Specifies this (via email), the WIF workflow ultimately impersonates this SA
1. project_iam_member: assigns GCP roles (aka permissions) to the SA in a given project
1. service_account_iam_binding: Once an audience (tfc workspace run) authenticates to the pool, it is evaluated for membership to SA iam bindings. if its claims match the binding, it receives the permission. 

Constrain the pool_provider to an org (and a project if desired) then let the iam_binding constrain to a workspace (or a project instead).

- IAM bindings can only have 1 attribute in the identifier claim (aka the workspace name)
- IAM bindings can have many members, effectively an OR
- Pool provider attribute_condition accepts `&&` to specify many conditions
