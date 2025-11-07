import { expect } from "chai";
import { network } from "hardhat";

const { ethers } = await network.connect();

describe("Trigger → Condition Flow", function () {
  let trigger: any;
  let triggerId: bigint;

  const log = (msg: string) => console.log(`\x1b[36m${msg}\x1b[0m`);

  it("Should deploy Trigger contract", async function () {
    trigger = await ethers.deployContract("TriggerContract", []);
    await trigger.waitForDeployment();
    log("✅ Deploying Trigger contract: Success");
  });

  it("Should add new trigger with condition", async function () {
    const conditionStruct = {
      value: 5, // threshold
      operator: ">=",
      source: "water_level_m",
      expression: "water_level_m >= 5",
      sourceSubType: "warning_level",
    };

    const tx = await trigger.addTrigger(conditionStruct);
    const receipt = await tx.wait();

    const event = receipt!.logs
      .map((log: any) => {
        try {
          return trigger.interface.parseLog(log);
        } catch {
          return null;
        }
      })
      .find((e: any) => e?.name === "TriggerAdded");

    triggerId = event?.args?.triggerId;
    expect(triggerId).to.not.be.undefined;

    log(`✅ Adding trigger: Success (triggerId: ${triggerId})`);
  });

  it("Should fail to set trigger if observed value does not meet condition", async function () {
    const observedValue = 2; // below threshold
    await expect(
      trigger.setTrigger(triggerId, observedValue)
    ).to.be.revertedWith("Condition not met");

    log("✅ Condition failed as expected");
  });

  it("Should set trigger to triggered if observed value meets condition", async function () {
    const observedValue = 6; // meets threshold
    await expect(trigger.setTrigger(triggerId, observedValue))
      .to.emit(trigger, "TriggerActivated")
      .withArgs(triggerId, observedValue);

    const t = await trigger.getTrigger(triggerId);
    expect(t.isTriggered).to.be.true;

    log("✅ Trigger successfully activated after condition match");
  });
});
