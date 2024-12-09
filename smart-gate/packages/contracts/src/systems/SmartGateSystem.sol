// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { console } from "forge-std/console.sol";
import { ResourceId } from "@latticexyz/world/src/WorldResourceId.sol";
import { WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { IBaseWorld } from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { RESOURCE_SYSTEM } from "@latticexyz/world/src/worldResourceTypes.sol";

import { CharactersTable } from "@eveworld/world/src/codegen/tables/CharactersTable.sol";
import { GateAccess } from "../codegen/tables/GateAccess.sol";

/**
 * @dev This contract is an example for implementing logic to a smart gate
 */
contract SmartGateSystem is System {  
  /**
   * @dev Used to define which players are allowed to use the smart gate
   * @param characterId The smart character ID of the player
   * @param sourceGateId The id for the smart gate the player is using
   * @param destinationGateId The id for the smart gate the player is requesting to travel to
   * @return Whether the player is granted access
   */
  function canJump(uint256 characterId, uint256 sourceGateId, uint256 destinationGateId) public view returns (bool) {
    //Get the allowed corp
    uint256 allowedCorp = GateAccess.get(sourceGateId);

    //Get the character corp
    uint256 characterCorp = CharactersTable.getCorpId(characterId);

    //If the corp is the same, allow jumps
    if(allowedCorp == characterCorp){
      return true;
    } else{
      return false;
    }    
  }
  
  /**
   * @dev Set the corp that is allowed to use the smart gate
   * @param sourceGateId The id for the smart gate to be configured
   * @param corpID The corporation that will have access to the smart gate
   */
  function setAllowedCorp(uint256 sourceGateId, uint256 corpID) public {
    GateAccess.set(sourceGateId, corpID);
  }
}