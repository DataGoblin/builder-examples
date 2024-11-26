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

	const smartObjectId = import.meta.env.VITE_SMARTASSEMBLY_ID;
	const itemInId = import.meta.env.VITE_ITEM_IN_ID;
	const itemOutId = import.meta.env.VITE_ITEM_OUT_ID;

	const setRatio = async ({qtyIn, qtyOut} : {qtyIn: number, qtyOut: number}) => {
		if (!worldContract) throw new Error("No world contract found");

		const hash =  await worldContract.write.test__setRatio([
			BigInt(smartObjectId),
			BigInt(itemInId),
			BigInt(itemOutId),
			BigInt(qtyIn),
			BigInt(qtyOut)
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

	const execute = async (qtyIn: number) => {
		if (!worldContract) throw new Error("No world contract found");

		const hash =  await worldContract.write.test__execute([
			BigInt(smartObjectId),
			BigInt(qtyIn),
			BigInt(itemInId)
		])
		const receipt = await waitForTransactionReceipt(
			wagmiConfig,
			{hash}
				);
		console.log("execute tx receipt", receipt);

		const result = useRecords({
			stash,
			table: mudConfig.namespaces.test.tables.RatioConfig,
			keys: [smartObjectId, itemInId],
		})
		return result;
	};

	const calculateOutput = async (qtyIn: number) => {
		if (!worldContract) throw new Error("No world contract found");

		const output =  await worldContract.read.test__calculateOutput([
			BigInt(smartObjectId), // InputRatio
			BigInt(qtyIn), // OutputRatio
			BigInt(qtyIn) // InputAmount
		])

		return output // (uint256 outputAmount, uint256 remainingInput)
	};

	return {
		setRatio,
		execute,
		calculateOutput
	};
}
