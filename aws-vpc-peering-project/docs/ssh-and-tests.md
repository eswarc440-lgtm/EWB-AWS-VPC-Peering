# SSH and connectivity tests

## Example SSH access through bastion

Use the actual **current** bastion public IP and keep `vpc-peering-lab.pem` on your computer only. Never upload it to GitHub.

On Windows, create/edit `$HOME/.ssh/config` (the `HostName` below is a **placeholder**):

```sshconfig
Host vpc-bastion
  HostName REPLACE_WITH_CURRENT_BASTION_PUBLIC_IP
  User ec2-user
  IdentityFile ~/.ssh/vpc-peering-lab.pem
  IdentitiesOnly yes

Host vpc-app-a
  HostName 10.10.2.10
  User ec2-user
  IdentityFile ~/.ssh/vpc-peering-lab.pem
  IdentitiesOnly yes
  ProxyJump vpc-bastion

Host vpc-app-b
  HostName 10.20.1.10
  User ec2-user
  IdentityFile ~/.ssh/vpc-peering-lab.pem
  IdentitiesOnly yes
  ProxyJump vpc-bastion
```

From your Windows terminal:

```powershell
ssh vpc-bastion
ssh vpc-app-a
ssh vpc-app-b
```

## ICMP test from App-A to App-B

Once connected to App-A:

```bash
ping -c 4 10.20.1.10
```

**Previously observed in the manual lab:** 4 of 4 packets received (0% loss).

From App-B in the opposite direction:

```bash
ping -c 4 10.10.2.10
```

## Security group demonstration

Remove App-B inbound ICMP Echo Request rule from `10.10.2.10/32`; run ping from App-A again. The documented test observed 100% packet loss. Restore the rule and verify that connectivity returns. Perform this only on your own lab in a safe testing window.

Do not publish an SSH private key, full unredacted AWS identifiers or credentials in command screenshots.
