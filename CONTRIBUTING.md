# Contributing Guidelines

There are many ways to contribute to CMTAT Contracts.

## Development branch

If you want to propose some improvement to CMTAT codebase, use the current development branch `dev` to perform the modification.

For big change or experimental features, we recommend to create a dedicated repository and use CMTAT as a [github submodule](https://www.atlassian.com/git/tutorials/git-submodule).

```bash
git submodule add https://github.com/CMTA/CMTAT
```

You can find example of using CMTAT as a github submodule in following repositories: [SnapshotEngine](https://github.com/CMTA/SnapshotEngine) or [CMTAT Factory](https://github.com/CMTA/CMTATFactory)

## Opening an issue

You can [open an issue] to suggest a feature, a difficulty you have or report a minor bug. For serious bugs in an audited version please do not open an issue, instead refer to our [security policy] for appropriate steps. See [SECURITY.md](./SECURITY.MD).

Before opening an issue, be sure to search through the existing open and closed issues, and consider posting a comment in one of those instead.

When requesting a new feature, include as many details as you can, especially around the use cases that motivate it. 

## Submitting a pull request

If you would like to contribute code or documentation you may do so by forking the repository and submitting a pull request.

Run linter and tests to make sure your pull request is good before submitting it.

## Reference

Based on the version made by [OpenZeppelin](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/CONTRIBUTING.md)
