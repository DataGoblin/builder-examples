import { AccountButton, ConnectedClient } from "@latticexyz/entrykit/internal";
import { useSyncProgress } from "./mud/useSyncProgress";
import { Explorer } from "./Explorer";
import { ReactNode } from "react";
import { Header, EveButton } from "@eveworld/ui-components";
import { abbreviateAddress } from "@eveworld/utils";
import SetRatio from "./components/SetRatio";
import Execute from "./components/Execute";

export type Props = {
  children?: ReactNode;
};

export function UI({ children }: Props) {
  const { isLive, message, percentage } = useSyncProgress();  

  // return (
  //   <div className="absolute inset-0 grid sm:grid-cols-[auto_16rem]">
  //     <div className="p-4 grid place-items-center">
  //       {isLive ? (
  //         children
  //       ) : (
  //         <div className="tabular-nums">
  //           {message} ({percentage.toFixed(1)}%)…
  //         </div>
  //       )}
  //     </div>

  //     <div className="p-4 space-y-4">
  //       <AccountButton />
  //       {isLive ? <Tasks /> : null}
  //     </div>

  //     <Explorer />
  //   </div>
  // );



  return (
  <div className="bg-crude-5 w-screen min-h-screen">
    <div className="flex flex-col align-center max-w-[560px] mx-auto pb-6 min-h-screen h-full">
    <AccountButton />
    {/* {isLive} */}
      
    {/* <Header
        connected={ ? true : false}
        // eslint-disable-next-line @typescript-eslint/no-empty-function
        handleDisconnect={() => {}}
        walletClient={publicClient}
        smartCharacter={smartCharacter}
      /> */}

      <div className="grid">
        <div className="text-xl font-bold">
          Smart Storage Unit: Configuring information for{" "}
          {abbreviateAddress(import.meta.env.VITE_SMARTASSEMBLY_ID)}
        </div>

        <SetRatio />
        <Execute />

      </div>
    </div>


      <Explorer />
  </div>)

}
