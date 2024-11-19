import { useMUD } from "../MUDContext";
import React, { useRef, useState } from "react";
import { EveButton, EveInput } from "@eveworld/ui-components";
import { formatEther, parseEther } from "viem";

const BuyItem = React.memo(function BuyItem({
	smartAssemblyId,
	itemInId,
}: {
	smartAssemblyId: bigint;
	itemInId: string;
}) {
	const [itemPriceWei, setItemPriceWei] = useState<number | undefined>();
	const [itemQuantity, setItemQuantity] = useState<number | undefined>();
	const [erc20Balance, setErc20Balance] = useState<bigint | undefined>();

	const {
		network: { walletClient },
		systemCalls: {
			setItemPrice,
			getItemPriceData,
			purchaseItem,
			getErc20Balance,
			makeTrade
		},
	} = useMUD();

	const fetchItemPriceData = async () => {
		const itemPriceData = await getItemPriceData();
		setItemPriceWei(Number(itemPriceData?.price ?? 0));
	};

	const itemPriceWeiValueRef = useRef(0);

	const handleEdit = (
		refString: React.MutableRefObject<number>,
		eventString: number
	): void => {
		refString.current = eventString;
	};

	return (
		<>
			<div className="Quantum-Container my-4">
				<div>Trade Item</div>
				<div className="flex items-start flex-col gap-3">
					<EveInput
						inputType="numerical"
						defaultValue={itemQuantity}
						fieldName={"item quantity"}
						onChange={(str) => setItemQuantity(Number(str))}
					></EveInput>
					<div>
						<EveButton
							typeClass="primary"
							onClick={async (event) => {
								event.preventDefault();
								await makeTrade(
									smartAssemblyId,
									itemInId,
									itemQuantity
								);
								console.log(itemInId)
								console.log(`QUANTITY: ${itemQuantity}`)
							}}
						>
							Purchase items
						</EveButton>
					</div>
				</div>
			</div>
		</>
	);
});

export default BuyItem;
