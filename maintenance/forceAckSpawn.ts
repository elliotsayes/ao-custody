import * as path from 'node:path';
import * as fs from 'node:fs';
import * as process from 'node:process';
import { createDataItemSigner, message } from "@permaweb/aoconnect"

const CUSTODY_CREATOR = "zYBcGWB4KJeB4pc04XiNOKrD0DQBPelvNBbfDnqiunQ"

async function main() {
  const spawnReference = process.argv[2];
  const processId = process.argv[3];

  if (!spawnReference) {
    console.error('Usage: node forceAckSpawn.js <spawnReference> <processId>');
    process.exit(1);
  }

  if (!spawnReference.match(/^[0-9]*$/)) {
    console.error('Invalid spawnReference: ' + spawnReference);
    process.exit(1);
  }

  if (!processId) {
    console.error('Usage: node forceAckSpawn.js <spawnReference> <processId>');
    process.exit(1);
  }

  if (!processId.match(/^[a-zA-Z0-9_-]{43}$/)) {
    console.error('Invalid processId: ' + processId);
    process.exit(1);
  }
  
  const walletPath = path.join('.', '.secret', 'wallet.json');
  const wallet = JSON.parse(fs.readFileSync(walletPath, 'utf-8'));
  const signer = createDataItemSigner(wallet);

  const sendAckEvalSpawn = `
table.insert(ao.outbox.Messages, {
  Target = ao.id,
  Anchor = "00000000000000000000000000002641",
  Tags = {
    {name = "Data-Protocol", value = "ao"},
    {name = "Variant", value = "ao.TN.1"},
    {name = "Type", value = "Message"},
    {name = "Action", value = "Spawned"},
    {name = "Reference", value = "${spawnReference}"},
    {name = "Process", value = "${processId}"},
  },
})
`;

  const ackSpawnEvalMsgId = await message({
    process: CUSTODY_CREATOR,
    tags: [{
      name: 'Action',
      value: 'Eval',
    }],
    data: sendAckEvalSpawn,
    signer,
  })

  console.log(`ackSpawnEvalMsgId: ${ackSpawnEvalMsgId}`);
}

main().catch(console.error);
