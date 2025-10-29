import { expect } from "chai";
import { network } from "hardhat";

const { ethers } = await network.connect();

describe("Trigger → Action Flow", function () {
  let trigger: any;
  let action: any;
  let triggerId: bigint;
  let encodedParams: string;

  const log = (msg: string) => console.log(`\x1b[36m${msg}\x1b[0m`);

  it("Should deploy Trigger contract", async function () {
    trigger = await ethers.deployContract("Trigger");
    await trigger.waitForDeployment();
    log("✅ Deploying Trigger contract: Success");
  });

  it("Should deploy Action contract", async function () {
    action = await ethers.deployContract("Action");
    await action.waitForDeployment();
    log("✅ Deploying Action contract: Success");
  });

  it("Should register new Trigger", async function () {
    const triggerStruct = {
      triggerType: "flood",
      phase: "READINESS",
      title: "Flood Warning",
      source: "DHM",
      riverBasin: "Bagmati",
      paramsHash: "0x1234",
      isMandatory: true,
      isTriggered: false,
      actionContract: await action.getAddress(),
    };

    const tx = await trigger.registerTrigger(triggerStruct);
    const receipt = await tx.wait();

    const event = receipt!.logs
      .map((log: any) => {
        try {
          return trigger.interface.parseLog(log);
        } catch {
          return null;
        }
      })
      .find((e: any) => e?.name === "TriggerRegistered");

    triggerId = event?.args?.triggerId;
    expect(triggerId).to.not.be.undefined;

    log(`✅ Adding trigger: Success (triggerId: ${triggerId})`);
  });

  it("Should update trigger phase", async function () {
    await expect(trigger.updateTrigger(triggerId, "ACTIVENESS", false))
      .to.emit(trigger, "TriggerUpdated")
      .withArgs(triggerId, "ACTIVENESS", false);

    log("✅ Updating trigger: Success");
  });

  it("Should set trigger to TRIGGERED and execute Action", async function () {
    const [owner, addr1] = await ethers.getSigners();
    const beneficiaries = [owner.address, addr1.address];
    const amounts = [100, 200];

    encodedParams = ethers.AbiCoder.defaultAbiCoder().encode(
      ["address[]", "uint256[]"],
      [beneficiaries, amounts]
    );

    await expect(trigger.setTriggered(triggerId, encodedParams))
      .to.emit(trigger, "TriggerExecuted")
      .withArgs(triggerId, await action.getAddress(), encodedParams);

    log("✅ Setting trigger to triggered: Success");
  });

  it("Should check if Action contract received execution call", async function () {
    await expect(trigger.setTriggered(triggerId, encodedParams))
      .to.emit(action, "ActionExecuted")
      .withArgs(triggerId, encodedParams, await trigger.getAddress());

    log(`✅ Emitted event in Action contract: Success`);
  });
});
