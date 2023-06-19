import assert from 'assert'

import { DeployFunction } from 'hardhat-deploy/dist/types'

import {
  assertContractVariable,
  deploy,
} from '../src/deploy-utils'


const deployFn: DeployFunction = async (hre) => {
  const { deployer } = await hre.getNamedAccounts()

  await deploy({
    hre,
    name: 'L1CrossDomainMessengerProxy',
    contract: 'Proxy',
    args: [deployer],
    postDeployAction: async (contract) => {
      await assertContractVariable(contract, 'admin', deployer)
    },
  })
}
deployFn.tags = ['L1CrossDomainMessengerProxy', 'setup', 'l1']

export default deployFn
