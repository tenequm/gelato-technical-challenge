## Scenario
BlockNvision Network is a Web 3.0 gaming startup. Their idea is to partner up with Activision to enhance the Call of Duty game series to be blockchain compatible enabling players to pay in any crypto currency to receive in-game rewards.

Their objective is to become the proxy between the blockchain and the COD servers by providing and managing all the relevant infrastructure to monitor on chain events and push computed data towards the Activision infrastructure.

As this idea is in a MVP phase, the team decided to prioritise the backend service (the listener) development first. The listener is a NodeJS application that listens on just one blockchain via an RPC provider, it scrapes the relevant data, processes and pushes it back to a local database for later use. The MVP is focusing on three blockchains, therefore the team needs to be able to deploy three applications at the same time using the same source code but different environment variables.

The DevOps engineers need to create a seamless flow to allow developers to freely deploy listener services to a cloud provider supporting Docker/Kubernetes.

The diagram below shows the final result that the BlockNvision team is presenting to Activision for their sales pitch.

![diagram1](https://media.cleanshot.cloud/media/22198/sJtmoonUF8TSRpCY8yWkYaTq46iSuGTkim9r9xaB.jpeg?Expires=1660594878&Signature=lpgzCEyKIaMkNs6i3CdAGDJ7BfLUImmuBFowpHT0mEP2Cx4wg6vkHuFmQQ7F5F3Ksj2hwJXfIMkIbitWsbhCG18ry53KToH7lcF~FLKO3G46poFybbf-jl6McEV1VPnkHxVhvEm2Nla8I8O2u-Mn860-6dOB-eUBhGTHs-yIZ8BasH--UIqn2QpruYWZQFxGVxSYYEekvFl0gi8wzlf8JUg0gXCa87ciauito0rm2POU8PLmevYdEunkGJS75sBDPkp50E3kW4pYFy7dNhPkioeskKdZ5tioTKcoHv-HA~eggUG6HJQw7DVKjbVWwLe0A9z~0b0cgXVt5rxajNfa7g__&Key-Pair-Id=K269JMAT9ZF4GZ)

## The challenge

Create a CI/CD pipeline that allows a developer to deploy a single application to a specific cloud environment by creating the necessary infrastructure first. Simulate a go-to-production workflow from a dev to production environment via different branches, PRs, or similar where dev in this case can be a Goerli enabled listener while production will be using Mainnet, BSC.

The solution should be developer-friendly also for less DevOps skilled developers. Example workflow:

![diagram2](https://media.cleanshot.cloud/media/22198/yDtpM0VFXuoDqk7CNPNjP67vJmHC6SIsZzjmCUhi.jpeg?Expires=1660595057&Signature=Jf78wzp-qcZ8Soch2mhMjz3G0eKebKGu73to6ONkANuj6fuuLznh99LDPZh9H28yCGmJ66ZWdjvoCsDKlnuxWmam1ESssTjDb4qI2iqfQM~Rg8qMGIOlkpZ~bpT8UYUstWLvbPoElAARNtwlhxB2PRmcMtxFpCBqi9f4jcLoNkBuc8KzMM-4XofhV7GXX5NceE6IvwqMcvruN0NoyXQ5NdWF-6mckiP7JPHMWrBsuvhkQxa0C1gCFXC~~WAK6c88qutLYHemQ7jQ5DcsA4cW1N0IziUxUaZYp9tl~5zMMJN0wmeVznslCyA3~Xn8vpZ5U18omqfVDx2TwN-5fBq8vQ__&Key-Pair-Id=K269JMAT9ZF4GZ)

### Prioritised items
* Automated deployment of a single source base to multiple environments. The environment variables are the only difference (such as blockchain network name, RPC endpoint etc, database host and secrets)
  * Security is a concern, secrets must be treated carefully
  * The final application deployed should just echo the env variables/exposing
them via an http endpoint
* Infrastructure as Code
  * Deploy a cloud Kubernetes cluster or Docker enabled VM or similar
  * A cloud Database of your choice
* Docker build and push images to a registry of your choice

### Bonus items
* Quality gate pipeline (Unit testing, lint checkers, Docker image scan, license checker, etc..)
* IaC lifecycle & enhanced security
* Logs and metrics
* Docker Image Promotion strategy
* Governance (e.g. Prod deployment approvals)
* Multi-cloud support
* Cost friendly solution

### Out of scope
* Creation of real blockchain enabled applications
* Push service

### The candidate can
* Use any open source “hello world” application to simulate a working listener
* Use a cloud provider of his/her choice (GCP, AWS, Azure, DigitalOcean..)
* Use a cloud codebase and DevOps tool like GitHub and GitHub Actions, GitLab, Azure DevOps or similar
* Use a mono-repository or multi-repository approach

### Useful resources
* CI/CD tools: https://github.com/features/actions, https://docs.gitlab.com/ee/ci/pipelines/
* Docker promotion strategy: https://jfrog.com/blog/docker-registry-to-production/
* Pipeline governance: https://docs.harness.io/article/zhqccv0pff-pipeline-governance
* IaC: https://www.redhat.com/en/topics/automation/what-is-infrastructure-as-code-iac