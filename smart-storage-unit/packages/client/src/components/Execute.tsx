import React, { useRef } from "react";
import { EveButton, EveInput } from "@eveworld/ui-components";
import { createSystemCalls } from "../mud/createSystemCalls";

const Execute = React.memo(function Execute() {
	const { execute, calculateOutput } = createSystemCalls();

	const handleEdit = (
		refString: React.MutableRefObject<number>,
		eventString: number
	): void => {
		refString.current = eventString;
	};

	const qtyInValueRef = useRef(0);

	return (
		<>
			<div className="Quantum-Container my-4">
				<div>Step 2: Execute transaction</div>

				<EveInput
					inputType="numerical"
					defaultValue={qtyInValueRef.current.toString()}
					fieldName={`Quantity In`}
					onChange={(str) => handleEdit(qtyInValueRef, str as number)}
				></EveInput>

				<EveButton
					className="mr-2"
					typeClass="tertiary"
					onClick={async (event) => {
						event.preventDefault();
						calculateOutput(qtyInValueRef.current);
					}}
				>
					Calculate Output
				</EveButton>

				<EveButton
					className="mr-2 mt-4"
					typeClass="primary"
					onClick={async (event) => {
						event.preventDefault();
						execute(qtyInValueRef.current);
					}}
				>
					Execute
				</EveButton>
			</div>
		</>
	);
});

export default Execute;
