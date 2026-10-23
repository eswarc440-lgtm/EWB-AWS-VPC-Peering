# Manual AWS Management Console implementation

**Region:** `us-east-1`. **Scope:** one account, one Region, lab deployment. Resource name tags may differ in places from Terraform identifiers; verify actual resource IDs in the AWS Console before referencing them.

## Steps

1. Created **Project-VPC-A** (`10.10.0.0/16`) and **Project-VPC-B** (`10.20.0.0/16`).
2. Created VPC A public subnet `10.10.1.0/24` and private subnet `10.10.2.0/24`; VPC B private subnet `10.20.1.0/24`.
3. Attached an **Internet Gateway** to VPC A only; VPC B has no IGW/NAT.
4. Created three custom route tables and associated them with the intended subnets.
5. Created the requester peering connection **VPC A → VPC B**, accepted it and confirmed **Active**.
6. Added VPC A routes to `10.20.0.0/16` via peering (both A public and A private route tables).
7. Added VPC B private route to `10.10.0.0/16` via the same peering connection.
8. Configured the bastion SG, private App-A SG and private App-B SG with restricted SSH and ICMP rules.
9. Launched Amazon Linux 2023 EC2 instances: bastion `10.10.1.10`, App-A `10.10.2.10`, App-B `10.20.1.10`. The bastion received the only public IPv4; the two application instances did not.
10. Verified SSH using Windows OpenSSH/ProxyJump and tested bidirectional ICMP. Intentionally removed App-B's ICMP echo-request rule, observed a blocked ping, and restored the rule.

## Exact security-group inbound rules captured in the report

| SG | Type | Source |
|---|---|---|
| `ewb-sg-bastion` | SSH TCP/22 | operator current public IP `/32` |
| `ewb-sg-app-a` | SSH TCP/22 | `10.10.1.10/32` |
| `ewb-sg-app-a` | ICMPv4 Echo Request type 8/code 0 | `10.20.1.10/32` |
| `ewb-sg-app-b` | SSH TCP/22 | `10.10.1.10/32` |
| `ewb-sg-app-b` | ICMPv4 Echo Request type 8/code 0 | `10.10.2.10/32` |

The SGs in this manual project used outbound allow-all. This is appropriate to describe the demo but should not be treated as a hardened production configuration. SSH keys are not included in this repository.
