import React, { useRef, useState } from "react";
import { EveButton, EveInput } from "@eveworld/ui-components";
import { createSystemCalls } from "../mud/createSystemCalls";
import { useRecords } from "../mud/useRecords";
import { stash } from "../mud/stash";
import mudConfig from "contracts/mud.config";

const SetRatio = React.memo(function SetRatio() {
	const [ratioIn, setRatioIn] = useState<
		number | undefined
	>();
	const [ratioOut, setRatioOut] = useState<number | undefined>();

	const smartObjectId = import.meta.env.VITE_SMARTASSEMBLY_ID;
	const itemInId = import.meta.env.VITE_ITEM_IN_ID;
	const itemOutId = import.meta.env.VITE_ITEM_OUT_ID;

	const ratioConfig = useRecords({
		stash,
		table: mudConfig.namespaces.test.tables.RatioConfig,
		// keys: [smartObjectId, itemInId]
	});

	const { setRatio } = createSystemCalls();

	const fetchItemSellData = async () => {
		console.log(ratioConfig)
		// setRatioIn(Number(ratioConfig[0].ratioIn ?? 0));
		// setRatioOut(Number(ratioConfig[0].ratioOut ?? 0));
	};

	const itemInValueRef = useRef(0);
	const itemOutValueRef = useRef(0);

	const handleEdit = (
		refString: React.MutableRefObject<number>,
		eventString: number
	): void => {
		refString.current = eventString;
	};

	return (
		<>
			<div className="Quantum-Container my-4">
				<div>Step 1: Set Ratios</div>
				<div className="flex items-center">
					<EveButton
						className="mr-2"
						typeClass="tertiary"
						onClick={async (event) => {
							event.preventDefault();
							fetchItemSellData();
						}}
					>
						Fetch
					</EveButton>
					<div className="flex flex-col">
						<span className="text-xs">
							{ratioIn && ratioOut
								? `Every ${ratioIn} units of item ${itemInId} can be sold for ${ratioOut} units of ${itemOutId}`
								: "No ratio config set"}
						</span>
					</div>
				</div>

				<div className="mt-4 flex flex-col items-start gap-3">
					<EveInput
						inputType="numerical"
						defaultValue={ratioIn?.toString() ?? "0"}
						fieldName={`Item in: ${itemInId}`}
						onChange={(str) => handleEdit(itemInValueRef, str as number)}
					></EveInput>

					<EveInput
						inputType="numerical"
						defaultValue={ratioOut?.toString() ?? "0"}
						fieldName={`Item out: ${itemOutId}`}
						onChange={(str) => handleEdit(itemOutValueRef, str as number)}
					></EveInput>
					<div>
						<EveButton
							typeClass="primary"
							onClick={async (event) => {
								event.preventDefault();
								await setRatio({
									qtyIn: itemInValueRef.current,
									qtyOut: itemOutValueRef.current
								});
								fetchItemSellData();
							}}
						>
							Set Ratio
						</EveButton>
					</div>
				</div>
			</div>
		</>
	);
});

export default SetRatio;
