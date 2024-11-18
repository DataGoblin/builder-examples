import { useMUD } from "../MUDContext";
import React, { useRef, useState } from "react";
import { EveButton, EveInput } from "@eveworld/ui-components";
import { formatEther, parseEther } from "viem";

const SetRatio = React.memo(function SetRatio({
	smartAssemblyId,
	itemInId,
	itemOutId
}: {
	smartAssemblyId: bigint;
	itemInId: string;
	itemOutId: string;
}) {
	const [itemStackMultiple, setItemStackMultiple] = useState<
		number | undefined
	>();
	const [itemPriceWei, setItemPriceWei] = useState<number | undefined>();
	const [sellQuantity, setSellQuantity] = useState<number | undefined>();

	const {
		systemCalls: { setSellConfig, SetRatio, getItemSellData },
	} = useMUD();

	const fetchItemSellData = async () => {
		const sellPriceData = await getItemSellData();
		setItemStackMultiple(Number(sellPriceData?.enforcedItemMultiple ?? 0));
		setItemPriceWei(Number(sellPriceData?.tokenAmount ?? 0));
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
				<div>ADMIN - Set Ratios inventory item ID: {itemInId}</div>
				<div className="text-xs">
					You can change this inventory item ID in the .env file
				</div>
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
							{itemPriceWei && itemStackMultiple
								? `Every ${itemStackMultiple} units of item ${itemInId} can be sold for ${formatEther(BigInt(itemPriceWei))} EVE`
								: "No sell config set"}
						</span>
					</div>
				</div>

				<div className="mt-4">Set item ratios</div>
				<div className="text-xs">
				For this step, you must be connected as the <b>smart assembly owner</b>.
				</div>
				<div className="flex flex-col items-start gap-3">
					<EveInput
						inputType="numerical"
						defaultValue={1}
						fieldName={`Item in: ${itemInId}`}
						onChange={(str) => handleEdit(itemInValueRef, str as number)}
					></EveInput>

					<EveInput
						inputType="numerical"
						defaultValue={undefined}
						fieldName={`Item out: ${itemOutId}`}
						onChange={(str) => handleEdit(itemOutValueRef, str as number)}
					></EveInput>
					<div>
						<EveButton
							typeClass="primary"
							onClick={async (event) => {
								event.preventDefault();
								await SetRatio(
									smartAssemblyId,
									itemInValueRef.current,
									itemOutValueRef.current,
								);
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
