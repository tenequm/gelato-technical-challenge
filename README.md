# Gelato technical challenge demo repository

This repository contains the solution for the technical challenge provided by Gelato Network's team. [The text of the challenge can be found here.](./CHALLENGE.md)

List of the accomplished items with comments to them:

1. _Automated deployment of a single source base to multiple environments_
   - Application was deployed to multiple environments with domain names provisioned by [external-dns operator](https://github.com/kubernetes-sigs/external-dns) to simplify management of new environments in the future.
   - [Trunk Based Development](https://trunkbaseddevelopment.com/) was chosen as the branching strategy for the CD pipeline. So that there is one `trunk` branch (`main` git branch in our case) that get's automatically deployed to `dev` environment on every commit/merge into it and after successful tests the same build can be promoted to `prod` environment after getting an approve in the workflow from the defined list reviewers.
2. _Infrastructure as Code_
   - Infrastructure for running the application was defined with Terraform in `ops/terraform` directory of the repository.
   - [Gruntwork's series of articles](https://blog.gruntwork.io/a-comprehensive-guide-to-terraform-b3d32832baca) was used as a base for the code structure of Terraform code for it to be ready for scale. In the real world `live` directory would become a separate repository to store the code of live deployed infrastructure, and every Terraform module would have it's own separate repository for and engineer who would be working with it to be able to utilise module versioning capabilities properly on different environments.
3. _Docker build and push images to a registry of your choice_
   - Docker images where pushed to Github Packages and are stored within the same repository as a code for an application. [Link to docker images.](https://github.com/tenequm/gelato-technical-challenge/pkgs/container/gelato-technical-challenge)
4. Quality gate pipeline
   - GHA pipeline has two jobs that do the linting: `trunk-lint` and `helm-validate`. The first one runs [Trunk](https://trunk.io/) tool as an aggregator for a set of common linters. The second one validate Helm chart to make sure, that it doesn't contain any issues in it's templates that block it from being able to deploy into Kubernetes.
5. _IaC lifecycle & enhanced security_
   - All sensitive data is stored in [AWS SSM Parameter Store](https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-parameter-store.html) and GitHub Actions Secrets.
   - Terraform code hase AWS S3 bucket being configured as a backend to make sure that the state of the infrastructure is stored properly.
6. _Docker Image Promotion strategy_
   - Same image gets promoted to production through the pipeline as the one deployed to dev.
7. _Governance (e.g. Prod deployment approvals)_
   - As you’ll see on the screenshot below - every deploy to `prod` has to be approved.
     ![image](https://media.cleanshot.cloud/media/22198/djhZ6GmobVHugZfRVnF3kyPGmu2uaf2Sy7eRjdF3.jpeg?Expires=1660596639&Signature=Q87Lc46PypDyeSSbOMWIZSC-hsb6wLw7bCx4Y3iXRzsAAAU2oR03GPYa~NS7~HN4pM9Y1RTokHjzJCaeXQ5XzO6IK3td6mC6L~1qigCxyfQVam1ocnLx5y65QMZZNXRF23bONjf~niD4JoB-HpQiV~Et0lETrslHgGV2f8u8DkA7s~PAfarxaQBmXZdqpjw2wMxuBZnNu4EgnDnsyot9QZMUFwsDRqoILFC9FDQsWBmABqRx9Fr8vNVZJymU4p20fckqgGOGFuwnQ-nst7FAHiTxmzn29lEdKGfxU4FbJvGijzDjGCnfdG6FouLGlno3aBsBYWVsBIjdS8L1QVZYGA__&Key-Pair-Id=K269JMAT9ZF4GZ)
