# Architecture

This documents presents an overview of the CMTAT architecture.

[TOC]

## Introduction

There is two mains contracts for deployment: CMTAT_PROXY or CMTAT_STANDALONE in order to deploy the CMTAT with or without a proxy depending of your preference.

These two mains contract inherits from the same base contract CMTAT_BASE which inherits of the different modules.

The main schema describing the architecture can be found here: [architecture.pdf](schema/drawio/architecture.pdf) 

## Schema

This section presents the different schema

### Inheritance

#### Base

![surya_inheritance_CMTAT_BASE.sol](./schema/surya_inheritance/surya_inheritance_CMTAT_BASE.sol.png)



#### Proxy

![surya_inheritance_CMTAT_PROXY.sol](./schema/surya_inheritance/surya_inheritance_CMTAT_PROXY.sol.png)

#### Standalone

![surya_inheritance_CMTAT_STANDALONE.sol](./schema/surya_inheritance/surya_inheritance_CMTAT_STANDALONE.sol.png)

### UML

See 

[CMTAT_BASE.svg](./schema/sol2uml/CMTAT_BASE.svg)



#### CMTAT_PROXY

![CMTAT_PROXY_d1](./schema/sol2uml/CMTAT_PROXY_d1.svg)

#### CMTAT_STANDALONE

![CMTAT_STANDALONE_d1](./schema/sol2uml/CMTAT_STANDALONE_d1.svg)



### Graph

#### Base

![surya_graph_CMTAT_BASE.sol](./schema/surya_graph/surya_graph_CMTAT_BASE.sol.png)

#### Proxy

![surya_graph_CMTAT_PROXY.sol](./schema/surya_graph/surya_graph_CMTAT_PROXY.sol.png)

#### Standalone

![surya_graph_CMTAT_STANDALONE.sol](./schema/surya_graph/surya_graph_CMTAT_STANDALONE.sol.png)