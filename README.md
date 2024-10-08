# FMTM Governance

Information and scripts related to the FMTM governance model.

This is work in progress and subject to change.

## Do-ocracy

- The `stats.sh` script is used to calculate contribution activity on the
  Github repo.
- It uses the `gh` Github command line tool (repo: cli/cli).
- The following multipliers are used:
  - Pull Requests: x5
  - Issues: x1
  - Issue comments: x0.5
  - Commits: x0.5
  - Discussion comments: 0.5
- The final weightings can be used as a rough approximation for the 
  influence the individual user should have over decision making.

## Current Stats (2024-08-24)

```bash
spwoodcock 37.21
NSUWAL123 23.85
Sujanadh 17.36
nrjadkry 7.14
manjitapandey 5.16
varun2948 4.63
susmina94 2.03
azharcodeit 1.44
robsavoye 1.18
```

The weightings above break down by organisation to:
- 37% HOT
- 61% NAXA (contracted by HOT)
- 2% independent

## Installing the Github CLI

- The `stats.sh` script requires the `gh` command line tool:

```bash
curl -LO https://github.com/cli/cli/releases/download/v2.55.0/gh_2.55.0_linux_amd64.tar.gz
tar -xvzf gh_2.55.0_linux_amd64.tar.gz
rm -rf gh_2.55.0_linux_amd64.tar.gz
mv gh_2.55.0_linux_amd64/bin/gh .
rm -rf gh_2.55.0_linux_amd64

# Login to the CLI
./gh auth login
```

> Note this script can likely be ran via gh actions with GITHUB_TOKEN as auth.