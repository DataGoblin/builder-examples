import { useMUD } from "./MUDContext";
import ManageErc20Token from "./components/manageErc20Token"
import React, { useEffect, useState } from "react";
import { EveButton, Header } from "@eveworld/ui-components";
import { abbreviateAddress } from "@eveworld/utils";
import { SmartCharacter } from "@eveworld/types";
import "./styles.css";
import BuyItem from "./components/buyItem"
import SetRatio from "./components/setRatio";

export const App = () => {
	const [smartCharacter, setSmartCharacter] = useState<SmartCharacter>({
		address: `0x`,
		id: "",
		name: "",
		isSmartCharacter: false,
		eveBalanceWei: 0,
		gasBalanceWei: 0,
		image: "",
		smartAssemblies: []
	});

	const {
		network: { walletClient },
		systemCalls: {
			collectTokens,
		},
	} = useMUD();

	/**
	 * Initializes a SmartCharacter object with default values and sets it using the useState hook.
	 * @returns void
	 */
	useEffect(() => {
		const smartCharacter: SmartCharacter = {
			address: walletClient.account?.address as `0x${string}`,
			id: "",
			name: "",
			isSmartCharacter: false,
			eveBalanceWei: 0,
			gasBalanceWei: 0,
			image: "",
			smartAssemblies: [],
		};
		setSmartCharacter(smartCharacter);
	}, [walletClient.account?.address]);

	const smartAssemblyId = BigInt(import.meta.env.VITE_SMARTASSEMBLY_ID);
	const itemOutId = import.meta.env.VITE_ITEM_OUT_ID;
	const itemInId = import.meta.env.VITE_ITEM_IN_ID;

	return (
		<div className="bg-crude-5 w-screen min-h-screen">
			<div className="flex flex-col align-center max-w-[560px] mx-auto pb-6 min-h-screen h-full">
				<Header
					connected={walletClient ? true : false}
					// eslint-disable-next-line @typescript-eslint/no-empty-function
					handleDisconnect={() => {}}
					walletClient={walletClient}
					smartCharacter={smartCharacter}
				/>

				<div className="grid">
					<div className="text-xl font-bold">
						Item Trade: Configuring information for{" "}
						{abbreviateAddress(smartAssemblyId.toString())}
					</div>

					<BuyItem smartAssemblyId={smartAssemblyId} itemOutId={itemOutId} />

					<SetRatio smartAssemblyId={smartAssemblyId} itemInId={itemInId} itemOutId={itemOutId} />
				</div>
			</div>
		</div>
	);
};
