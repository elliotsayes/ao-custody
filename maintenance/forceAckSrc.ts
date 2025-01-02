import * as path from 'node:path';
import * as fs from 'node:fs';
import * as process from 'node:process';
import { createDataItemSigner, message } from "@permaweb/aoconnect"

const CUSTODY_CREATOR = "zYBcGWB4KJeB4pc04XiNOKrD0DQBPelvNBbfDnqiunQ"

async function main() {
  const targetAddress = process.argv[2];

  if (!targetAddress) {
    console.error('Usage: node forceAckSrc.js <targetAddress>');
    process.exit(1);
  }

  if (!targetAddress.match(/^[a-zA-Z0-9_-]{43}$/)) {
    console.error('Invalid target address: ' + targetAddress);
    process.exit(1);
  }
  
  const walletPath = path.join('.', '.secret', 'wallet.json');
  const wallet = JSON.parse(fs.readFileSync(walletPath, 'utf-8'));
  const signer = createDataItemSigner(wallet);

  const sendAckSrc = `
Send({
  Target = Owner,
  Action = "AckSrc"
})
`

  const sendAckSrcEvalCommand = `
Send({
  Target = "${targetAddress}",
  Action = "Eval",
  Data = [[${sendAckSrc}]]
})
`;

  const ackSrcMsgEvalCommandMsgId = await message({
    process: CUSTODY_CREATOR,
    tags: [{
      name: 'Action',
      value: 'Eval',
    }],
    data: sendAckSrcEvalCommand,
    signer,
  })

  console.log(`ackSrcMsgEvalCommandMsgId: ${ackSrcMsgEvalCommandMsgId}`);
}

main().catch(console.error);
