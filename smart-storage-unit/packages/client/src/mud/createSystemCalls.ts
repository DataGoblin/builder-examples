import { useConfig } from "wagmi";
import { stash } from "./stash";
import { useRecords } from "./useRecords";
import { waitForTransactionReceipt } from "wagmi/actions";
import { useWorldContract } from "./useWorldContract";
import mudConfig from "contracts/mud.config";

export type SystemCalls = ReturnType<typeof createSystemCalls>;

export function createSystemCalls() {
	const wagmiConfig = useConfig();
	const { worldContract } = useWorldContract();

	/*
	 * This function is retrieved from the codegen function in contracts/src/codegen/world/IItemTradeSystem.sol
	 * And must be used with the test__ prefix due to namespacing
	 */

	const smartObjectId = BigInt(import.meta.env.VITE_SMARTASSEMBLY_ID);
	const itemInId = import.meta.env.VITE_ITEM_IN_ID;
	const itemOutId = import.meta.env.VITE_ITEM_OUT_ID;

	const getItemSellData = async () => {
		if (!worldContract) return;

		const result = useRecords({
			stash,
			table: mudConfig.namespaces.test.tables.RatioConfig,
			keys: [smartObjectId, itemInId],
		})
		return result;
	};

	const setRatio = async (qtyIn, qtyOut) => {
		if (!worldContract) return;

		const hash =  await worldContract.write.test__setRatio([
			smartObjectId,
			itemInId,
			itemOutId,
			qtyIn,
			qtyOut
		])
		const receipt = await waitForTransactionReceipt(
			wagmiConfig,
			{hash}
				);
		console.log("reset task receipt", receipt);

		const result = useRecords({
			stash,
			table: mudConfig.namespaces.test.tables.RatioConfig,
			keys: [smartObjectId, itemInId],
		})
		return result;
	};

	const execute = async (quantity) => {
		await worldContract.write.test__execute([
			smartObjectId,
			quantity,
			itemInId,
		]);
		// return useStore.getState().getValue(tables.ItemTradeERC20, {smartObjectId});
	};

	const calculateOutput = async (smartObjectId, receiver) => {
		await worldContract.write.test__updateERC20Receiver([
			smartObjectId,
			receiver,
		]);
		return useStore.getState().getValue(tables.ItemTradeERC20, {smartObjectId});
	};

	return {
		getItemSellData,
		setRatio,
	};
}
