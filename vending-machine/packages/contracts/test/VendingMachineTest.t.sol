// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import "forge-std/Test.sol";
import { MudTest } from "@latticexyz/world/test/MudTest.t.sol";
import { getKeysWithValue } from "@latticexyz/world-modules/src/modules/keyswithvalue/getKeysWithValue.sol";
import { ResourceId, WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";

import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { ResourceId, WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { IBaseWorld } from "@eveworld/world/src/codegen/world/IWorld.sol";
import { RESOURCE_SYSTEM } from "@latticexyz/world/src/worldResourceTypes.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { IBaseWorld } from "@eveworld/world/src/codegen/world/IWorld.sol";
import { DeployableState, DeployableStateData } from "@eveworld/world/src/codegen/tables/DeployableState.sol";

import { InventoryItem } from "@eveworld/world/src/modules/inventory/types.sol";
import { Utils as SmartDeployableUtils } from "@eveworld/world/src/modules/smart-deployable/Utils.sol";
import { SmartDeployableLib } from "@eveworld/world/src/modules/smart-deployable/SmartDeployableLib.sol";
import { EntityRecordData, WorldPosition, SmartObjectData, Coord } from "@eveworld/world/src/modules/smart-storage-unit/types.sol";
import { FRONTIER_WORLD_DEPLOYMENT_NAMESPACE } from "@eveworld/common-constants/src/constants.sol";
import { GlobalDeployableState } from "@eveworld/world/src/codegen/tables/GlobalDeployableState.sol";
import { SmartStorageUnitLib } from "@eveworld/world/src/modules/smart-storage-unit/SmartStorageUnitLib.sol";
import { SmartCharacterLib } from "@eveworld/world/src/modules/smart-character/SmartCharacterLib.sol";
import { EntityRecordData as CharacterEntityRecord } from "@eveworld/world/src/modules/smart-character/types.sol";
import { EntityRecordOffchainTableData } from "@eveworld/world/src/codegen/tables/EntityRecordOffchainTable.sol";
import { CharactersByAddressTable } from "@eveworld/world/src/codegen/tables/CharactersByAddressTable.sol";
import { EntityRecordLib } from "@eveworld/world/src/modules/entity-record/EntityRecordLib.sol";
import { State } from "@eveworld/world/src/modules/smart-deployable/types.sol";
import { VendingMachineSystem } from "../src/systems/vending_machine/VendingMachineSystem.sol";
import { Utils as SmartDeployableUtils } from "@eveworld/world/src/modules/smart-deployable/Utils.sol";
import { Utils as InventoryUtils } from "@eveworld/world/src/modules/inventory/Utils.sol";
import { EphemeralInvItemTableData, EphemeralInvItemTable } from "@eveworld/world/src/codegen/tables/EphemeralInvItemTable.sol";
import { IInventoryErrors } from "@eveworld/world/src/modules/inventory/IInventoryErrors.sol";

import { Utils } from "../src/systems/vending_machine/Utils.sol";
import { IWorld } from "../src/codegen/world/IWorld.sol";

contract VendingMachineTest is MudTest {
  using SmartDeployableLib for SmartDeployableLib.World;
  using SmartStorageUnitLib for SmartStorageUnitLib.World;
  using EntityRecordLib for EntityRecordLib.World;
  using SmartCharacterLib for SmartCharacterLib.World;
  using SmartDeployableUtils for bytes14;
  using InventoryUtils for bytes14;

  SmartDeployableLib.World smartDeployable;
  SmartStorageUnitLib.World smartStorageUnit;
  EntityRecordLib.World entityRecord;
  SmartCharacterLib.World smartCharacter;
  ResourceId systemId = Utils.vendingMachineSystemId();

  IWorld world;

  function setUp() public override {
    super.setUp();
    world = IWorld(worldAddress);

    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    address owner = vm.addr(deployerPrivateKey);

    uint256 playerPrivateKey = vm.envUint("PLAYER_PRIVATE_KEY");
    address player = vm.addr(playerPrivateKey);

    smartDeployable = SmartDeployableLib.World({
      iface: IBaseWorld(worldAddress),
      namespace: FRONTIER_WORLD_DEPLOYMENT_NAMESPACE
    });
    smartStorageUnit = SmartStorageUnitLib.World({
      iface: IBaseWorld(worldAddress),
      namespace: FRONTIER_WORLD_DEPLOYMENT_NAMESPACE
    });

    entityRecord = EntityRecordLib.World({
      iface: IBaseWorld(worldAddress),
      namespace: FRONTIER_WORLD_DEPLOYMENT_NAMESPACE
    });

    smartCharacter = SmartCharacterLib.World({
      iface: IBaseWorld(worldAddress),
      namespace: FRONTIER_WORLD_DEPLOYMENT_NAMESPACE
    });

    if (CharactersByAddressTable.get(player) == 0) {      
      smartCharacter.createCharacter(
        777000011,
        player,
        7777,
        CharacterEntityRecord({ typeId: 123, itemId: 234, volume: 100 }),
        EntityRecordOffchainTableData({ name: "ron", dappURL: "noURL", description: "." }),
        ""
      );
    }

    if (CharactersByAddressTable.get(owner) == 0) {
      smartCharacter.createCharacter(
        777000022,
        owner,
        8888,
        CharacterEntityRecord({ typeId: 123, itemId: 234, volume: 100 }),
        EntityRecordOffchainTableData({ name: "harryporter", dappURL: "noURL", description: "." }),
        ""
      );
    }

    uint256 smartStorageUnitId = vm.envUint("SSU_ID");
    createAnchorAndOnline(smartStorageUnitId, owner);

    uint256 inventoryItemIn = vm.envUint("ITEM_IN_ID");
    uint256 inventoryItemOut = vm.envUint("ITEM_OUT_ID");

    //Deposit some mock items to inventory and ephemeral
    InventoryItem[] memory items = new InventoryItem[](1);
    items[0] = InventoryItem({
      inventoryItemId: inventoryItemOut,
      owner: owner,
      itemId: 0,
      typeId: 23,
      volume: 10,
      quantity: 15
    });
    smartStorageUnit.createAndDepositItemsToInventory(smartStorageUnitId, items);

    InventoryItem[] memory ephemeralItems = new InventoryItem[](1);
    ephemeralItems[0] = InventoryItem({
      inventoryItemId: inventoryItemIn,
      owner: player,
      itemId: 0,
      typeId: 23,
      volume: 10,
      quantity: 15
    });
    smartStorageUnit.createAndDepositItemsToEphemeralInventory(smartStorageUnitId, player, ephemeralItems);

  }  

  function createAnchorAndOnline(uint256 smartStorageUnitId, address owner) private {
    //Create, anchor the ssu and bring online
    smartStorageUnit.createAndAnchorSmartStorageUnit(
      smartStorageUnitId,
      EntityRecordData({ typeId: 7888, itemId: 111, volume: 10 }),
      SmartObjectData({ owner: owner, tokenURI: "test" }),
      WorldPosition({ solarSystemId: 1, position: Coord({ x: 1, y: 1, z: 1 }) }),
      1e18, // fuelUnitVolume,
      1, // fuelConsumptionPerMinute,
      1000000 * 1e18, //fuelMaxCapacity,
      100000000, // storageCapacity,
      100000000000 // ephemeralStorageCapacity
    );

    // check global state and resume if needed
    if (GlobalDeployableState.getIsPaused() == false) {
      smartDeployable.globalResume();
    }

    smartDeployable.depositFuel(smartStorageUnitId, 200010);
    smartDeployable.bringOnline(smartStorageUnitId);
  }
  
  function testOnline() public {
    uint256 smartStorageUnitId = vm.envUint("SSU_ID");

    //Make sure the SSU is online
    assertEq(uint8(DeployableState.getCurrentState(smartStorageUnitId)), uint8(State.ONLINE), "SSU should be online");
  }

  function testConfigureVendingMachine() public {
    //Read from .env
    uint256 smartStorageUnitId = vm.envUint("SSU_ID");
    uint256 itemIn = vm.envUint("ITEM_IN_ID");
    uint256 itemOut = vm.envUint("ITEM_OUT_ID");
    uint256 inRatio = vm.envUint("IN_RATIO");
    uint256 outRatio = vm.envUint("OUT_RATIO");
    //Make sure the SSU is online
    assertEq(uint8(DeployableState.getCurrentState(smartStorageUnitId)), uint8(State.ONLINE), "SSU should be online");

    //Make sure the SSU owner is the one configuring the gatekeeper
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    address admin = vm.addr(deployerPrivateKey);
    vm.startPrank(admin);

    //The method below will change based on the namespace you have configurd. If the namespace is changed, make sure to update the method name
    world.call(
      systemId,
      abi.encodeCall(
        VendingMachineSystem.setVendingMachineRatio,
        (smartStorageUnitId, itemIn, itemOut, inRatio, outRatio)
      )
    );    
 
    vm.expectRevert();  
    world.call(systemId, abi.encodeCall(VendingMachineSystem.setVendingMachineRatio, (1, 1, 1000000000000000, 2, 2)));    
  }

  function testExecuteVendingMachine() public {
    uint256 playerPrivateKey = vm.envUint("PLAYER_PRIVATE_KEY");
    address player = vm.addr(playerPrivateKey);

    vm.startBroadcast(playerPrivateKey);
    StoreSwitch.setStoreAddress(worldAddress);

    //Read from .env
    uint256 smartStorageUnitId = vm.envUint("SSU_ID");
    uint256 itemIn = vm.envUint("ITEM_IN_ID");
    uint256 itemOut = vm.envUint("ITEM_OUT_ID");

    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    address admin = vm.addr(deployerPrivateKey);

    //Check Players ephemeral inventory before
    EphemeralInvItemTableData memory invItem = EphemeralInvItemTable.get(smartStorageUnitId, itemOut, player);
    
    assertEq(invItem.quantity, 0, "Ephemeral Inventory should have no items");
    
    EphemeralInvItemTableData memory invItemTest = EphemeralInvItemTable.get(smartStorageUnitId, itemIn, player);
    console.log("Player 1: ", invItemTest.quantity); //2

    //The method below will change based on the namespace you have configurd. If the namespace is changed, make sure to update the method name
    world.call(systemId, abi.encodeCall(VendingMachineSystem.executeVendingMachine, (smartStorageUnitId, 1, itemIn)));

    //Check Players ephemeral inventory after
    invItem = EphemeralInvItemTable.get(smartStorageUnitId, itemOut, admin);
    
    assertEq(invItem.quantity, 2, "Ephemeral Inventory should have 2 items");
    
    invItemTest = EphemeralInvItemTable.get(smartStorageUnitId, itemIn, player);
    console.log("Player 2: ", invItemTest.quantity); //2
    
    //The method below will change based on the namespace you have configurd. If the namespace is changed, make sure to update the method name
    world.call(systemId, abi.encodeCall(VendingMachineSystem.executeVendingMachine, (smartStorageUnitId, 1, itemIn)));

    //Check Players ephemeral inventory after
    invItem = EphemeralInvItemTable.get(smartStorageUnitId, itemOut, player);
   
    assertEq(invItem.quantity, 4, "Ephemeral Inventory should have 2 items");

    invItemTest = EphemeralInvItemTable.get(smartStorageUnitId, itemIn, player);
    console.log("Player 3: ", invItemTest.quantity); //2
  }

  function testCalculateRatio() public {
    StoreSwitch.setStoreAddress(worldAddress);

    (uint256 quantityOutputItem, uint256 quantityInputItemLeftOver) = abi.decode(
      world.call(systemId, abi.encodeCall(VendingMachineSystem.calculateOutput, (1, 2, 2))),
      (uint256, uint256)
    );   
  
    assertEq(quantityOutputItem, 4, "Output should be 4 items");
    assertEq(quantityInputItemLeftOver, 0, "There should be no items left");
    
    (quantityOutputItem, quantityInputItemLeftOver) = abi.decode(
      world.call(systemId, abi.encodeCall(VendingMachineSystem.calculateOutput, (2, 1, 3))),
      (uint256, uint256)
    );   
  
    assertEq(quantityOutputItem, 1, "Output should be 1 item");
    assertEq(quantityInputItemLeftOver, 1, "There should be no items left");

    vm.expectRevert("Input ratio cannot be zero");    
    world.call(systemId, abi.encodeCall(VendingMachineSystem.calculateOutput, (0, 2, 2)));  

    vm.expectRevert("Output ratio cannot be zero");    
    world.call(systemId, abi.encodeCall(VendingMachineSystem.calculateOutput, (2, 0, 2)));  
  }
}
