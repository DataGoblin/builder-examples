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

	const setRatio = async (qtyIn, qtyOut) => {
		if (!worldContract) throw new Error("No world contract found");

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
		console.log("set ratio tx receipt", receipt);

		const result = useRecords({
			stash,
			table: mudConfig.namespaces.test.tables.RatioConfig,
			keys: [smartObjectId, itemInId],
		})
		return result;
	};

	return {
		setRatio,
	};
}
