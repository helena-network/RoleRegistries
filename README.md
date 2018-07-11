# Role Registries

[![Build Status](https://travis-ci.com/Frontier-project/RoleRegistries.svg?token=DJeMzxJJncp3nRaEUuxH&branch=master)](https://travis-ci.com/Frontier-project/RoleRegistries)
[![codecov](https://codecov.io/gh/Frontier-project/RoleRegistries/branch/master/graph/badge.svg?token=PesH6oJLTj)](https://codecov.io/gh/Frontier-project/RoleRegistries)

## About

A Solidity package to Manage role permissions.

## Install
In order to install the library, just run the following commands on your root solidity directory

```bash
npm init -y
npm i -E @frontier-token-research/role-registries
```

## Usage

In order to use it from a Smart Contract, just import it from npm package:

### Import
```javascript
import "@frontier-token-research/role-registries/contracts/OwnedRegistry.sol"; 
```

### Usage
Now you can just use it by creating a new instance of your preferred registry

```javascript
OwnedRegistry reg = new OwnedRegistry();

```

## Test
The repo has a comprehensive test suite. You can run it with:

```bash
npm run test
```

## Compile
In order to get the ABI and bytecode, it is opened a npm command

```bash
npm run compile
```

## Deploy

Registries and TRL are deployed by calling the migrate command

```bash
npm run migrate
```
