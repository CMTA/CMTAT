# Authorization Module

This document defines Authorization Module for the CMTA Token specification.

[TOC]

## Rationale

>  There are many operations that only authorized users are allowed to perform, such as issuing new tokens. Thus we need to manage authorization in a centralized way.
> Authorization Module covers authorization use cases for the CMTA Token specification.

## Schema

![AuthorizationUML](../../schema/uml/AuthorizationUML.png)

### RBAC

This diagram shows the different roles.

- The rectangle represent the functions
- The circle represents the roles

The actor admin, defined inside the constructor or with the function `initialize` has the role `DEFAULT_ADMIN_ROLE`.

The DEFAULT_ADMIN_ROLE has automatically all the roles.

This behavior is implemented by overriding the function `hasRole` from OpenZeppelin

![RBAC-diagram-RBAC.drawio](../../schema/accessControl/RBAC-diagram-RBAC.drawio.png)

### Graph

![surya_graph_AuthorizationModule.sol](../../schema/surya_graph/surya_graph_AuthorizationModule.sol.png)

## API for Ethereum

See [docs.openzeppelin.com - AccessControl](https://docs.openzeppelin.com/contracts/5.x/api/access#AccessControl)
